from flask import Flask, request, jsonify, render_template
from flask_cors import CORS
import mysql.connector
from mysql.connector import Error
from datetime import datetime
import json

app = Flask(__name__)
CORS(app)

# Database configuration
DB_CONFIG = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Ravi1234',  # Change this to your MySQL password
    'charset': 'utf8mb4',
    'autocommit': True
}

def get_db_connection(database_name):
    """Create database connection for specific database"""
    try:
        config = DB_CONFIG.copy()
        config['database'] = database_name
        connection = mysql.connector.connect(**config)
        return connection
    except Error as e:
        print(f"Error connecting to database {database_name}: {e}")
        return None

def execute_query(database_name, query, params=None, fetch_all=False, fetch_one=False):
    """Execute query on specified database"""
    connection = get_db_connection(database_name)
    if not connection:
        return None
    
    try:
        cursor = connection.cursor(dictionary=True)
        cursor.execute(query, params or ())
        
        if fetch_all:
            result = cursor.fetchall()
        elif fetch_one:
            result = cursor.fetchone()
        else:
            result = cursor.rowcount
            
        connection.commit()
        return result
        
    except Error as e:
        print(f"Database error: {e}")
        return None
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

@app.route('/')
def index():
    """Serve the main HTML page"""
    return render_template('index.html')

@app.route('/api/incident', methods=['POST'])
def report_incident():
    """Report a new traffic incident with auto-dispatch for HIGH severity"""
    try:
        data = request.get_json()
        
        if not all(key in data for key in ['location', 'severity', 'reported_by']):
            return jsonify({'error': 'Missing required fields'}), 400
        
        # Get database connection
        connection = get_db_connection('TrafficDB')
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
            
        try:
            cursor = connection.cursor(dictionary=True)
            
            # Insert the incident (triggers will handle status, alerts, and auto-dispatch)
            query = """
            INSERT INTO TrafficIncident (location, severity, reported_by)
            VALUES (%s, %s, %s)
            """
            
            cursor.execute(query, (data['location'], data['severity'], data['reported_by']))
            incident_id = cursor.lastrowid
            connection.commit()
            
            # Check if ambulance was auto-dispatched for HIGH severity
            auto_dispatch_info = None
            if data['severity'] == 'High':
                # Check if dispatch occurred
                dispatch_query = """
                SELECT dl.log_id, dl.hospital_id, h.name as hospital_name, h.location as hospital_location
                FROM DispatchLog dl
                JOIN Hospital h ON dl.hospital_id = h.hospital_id
                WHERE dl.incident_id = %s
                ORDER BY dl.dispatch_time DESC
                LIMIT 1
                """
                
                cursor.execute(dispatch_query, (incident_id,))
                dispatch_result = cursor.fetchone()
                
                if dispatch_result:
                    auto_dispatch_info = {
                        'dispatched': True,
                        'hospital_name': dispatch_result['hospital_name'],
                        'hospital_location': dispatch_result['hospital_location'],
                        'dispatch_id': dispatch_result['log_id']
                    }
                else:
                    auto_dispatch_info = {
                        'dispatched': False,
                        'reason': 'No hospitals with available beds found'
                    }
            
            # Prepare response message
            if data['severity'] == 'High' and auto_dispatch_info and auto_dispatch_info['dispatched']:
                message = f"🚨 HIGH SEVERITY incident reported! Ambulance automatically dispatched to {auto_dispatch_info['hospital_name']} ({auto_dispatch_info['hospital_location']})"
            elif data['severity'] == 'High' and auto_dispatch_info and not auto_dispatch_info['dispatched']:
                message = f"⚠️ HIGH SEVERITY incident reported! WARNING: {auto_dispatch_info['reason']}"
            else:
                message = f"Incident reported successfully with {data['severity']} severity"
            
            return jsonify({
                'message': message,
                'status': 'success',
                'incident_id': incident_id,
                'severity': data['severity'],
                'auto_dispatch': auto_dispatch_info
            }), 201
            
        except mysql.connector.Error as db_error:
            return jsonify({'error': f'Database error: {str(db_error)}'}), 500
        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
                
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/incidents', methods=['GET'])
def get_incidents():
    """Get all traffic incidents"""
    try:
        query = """
        SELECT incident_id, location, severity, reported_by, 
               incident_time, status
        FROM TrafficIncident 
        ORDER BY incident_time DESC
        """
        
        incidents = execute_query('TrafficDB', query, fetch_all=True)
        
        if incidents is not None:
            # Convert datetime objects to strings
            for incident in incidents:
                if incident['incident_time']:
                    incident['incident_time'] = incident['incident_time'].isoformat()
            
            return jsonify({
                'incidents': incidents,
                'count': len(incidents)
            }), 200
        else:
            return jsonify({'error': 'Failed to retrieve incidents'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/healthalerts', methods=['GET'])
def get_health_alerts():
    """Get all healthcare alerts"""
    try:
        query = """
        SELECT alert_id, incident_id, incident_location, 
               message, alert_time
        FROM HealthAlerts 
        ORDER BY alert_time DESC
        """
        
        alerts = execute_query('HealthcareDB', query, fetch_all=True)
        
        if alerts is not None:
            # Convert datetime objects to strings
            for alert in alerts:
                if alert['alert_time']:
                    alert['alert_time'] = alert['alert_time'].isoformat()
            
            return jsonify({
                'alerts': alerts,
                'count': len(alerts)
            }), 200
        else:
            return jsonify({'error': 'Failed to retrieve health alerts'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/securityalerts', methods=['GET'])
def get_security_alerts():
    """Get all security alerts"""
    try:
        query = """
        SELECT alert_id, incident_id, incident_location, 
               message, alert_time
        FROM SecurityAlerts 
        ORDER BY alert_time DESC
        """
        
        alerts = execute_query('SecurityDB', query, fetch_all=True)
        
        if alerts is not None:
            # Convert datetime objects to strings
            for alert in alerts:
                if alert['alert_time']:
                    alert['alert_time'] = alert['alert_time'].isoformat()
            
            return jsonify({
                'alerts': alerts,
                'count': len(alerts)
            }), 200
        else:
            return jsonify({'error': 'Failed to retrieve security alerts'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/hospitals', methods=['GET'])
def get_hospitals():
    """Get all hospitals with available beds"""
    try:
        query = """
        SELECT hospital_id, name, location, available_beds, last_update
        FROM Hospital 
        ORDER BY available_beds DESC
        """
        
        hospitals = execute_query('TrafficDB', query, fetch_all=True)
        
        if hospitals is not None:
            # Convert datetime objects to strings
            for hospital in hospitals:
                if hospital['last_update']:
                    hospital['last_update'] = hospital['last_update'].isoformat()
            
            return jsonify({
                'hospitals': hospitals,
                'count': len(hospitals)
            }), 200
        else:
            return jsonify({'error': 'Failed to retrieve hospitals'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/dispatch/<int:incident_id>', methods=['POST'])
def dispatch_ambulance(incident_id):
    """Dispatch ambulance for a specific incident"""
    try:
        data = request.get_json()
        
        # Get incident location to find nearest hospital
        incident_query = """
        SELECT location FROM TrafficIncident WHERE incident_id = %s
        """
        
        incident = execute_query('TrafficDB', incident_query, (incident_id,), fetch_one=True)
        
        if not incident:
            return jsonify({'error': 'Incident not found'}), 404
        
        location = incident['location']
        
        # Find nearest hospital with available beds
        connection = get_db_connection('TrafficDB')
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
        
        try:
            cursor = connection.cursor(dictionary=True)
            
            # Call the stored procedure to find nearest hospital
            cursor.callproc('find_nearest_hospital_in_location', [location])
            
            # Get the result
            hospital = None
            for result in cursor.stored_results():
                hospital = result.fetchone()
                break
            
            if not hospital:
                return jsonify({'error': 'No available hospitals found in the area'}), 404
            
            # Dispatch ambulance using stored procedure
            cursor.callproc('dispatch_ambulance_to_hospital', [hospital['hospital_id'], incident_id])
            connection.commit()
            
            return jsonify({
                'message': f'Ambulance dispatched to {hospital["name"]}',
                'hospital': hospital,
                'incident_id': incident_id,
                'status': 'success'
            }), 200
            
        except Error as e:
            return jsonify({'error': f'Dispatch failed: {str(e)}'}), 500
        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
                
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/dispatch_log', methods=['GET'])
def get_dispatch_log():
    """Get dispatch log entries"""
    try:
        query = """
        SELECT dl.log_id, dl.incident_id, dl.hospital_id, dl.dispatch_time,
               h.name as hospital_name, h.location as hospital_location,
               ti.location as incident_location, ti.severity
        FROM DispatchLog dl
        JOIN Hospital h ON dl.hospital_id = h.hospital_id
        JOIN TrafficIncident ti ON dl.incident_id = ti.incident_id
        ORDER BY dl.dispatch_time DESC
        """
        
        dispatch_logs = execute_query('TrafficDB', query, fetch_all=True)
        
        if dispatch_logs is not None:
            # Convert datetime objects to strings
            for log in dispatch_logs:
                if log['dispatch_time']:
                    log['dispatch_time'] = log['dispatch_time'].isoformat()
            
            return jsonify({
                'dispatch_logs': dispatch_logs,
                'count': len(dispatch_logs)
            }), 200
        else:
            return jsonify({'error': 'Failed to retrieve dispatch logs'}), 500
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/dispatch_log/<int:incident_id>', methods=['GET'])
def get_dispatch_by_incident(incident_id):
    """Get dispatch information for a specific incident"""
    try:
        query = """
        SELECT dl.log_id, dl.incident_id, dl.hospital_id, dl.dispatch_time,
               h.name as hospital_name, h.location as hospital_location,
               ti.location as incident_location, ti.severity, ti.status
        FROM DispatchLog dl
        JOIN Hospital h ON dl.hospital_id = h.hospital_id
        JOIN TrafficIncident ti ON dl.incident_id = ti.incident_id
        WHERE dl.incident_id = %s
        ORDER BY dl.dispatch_time DESC
        """
        
        dispatch_info = execute_query('TrafficDB', query, (incident_id,), fetch_all=True)
        
        if dispatch_info is not None:
            # Convert datetime objects to strings
            for info in dispatch_info:
                if info['dispatch_time']:
                    info['dispatch_time'] = info['dispatch_time'].isoformat()
            
            return jsonify({
                'dispatch_info': dispatch_info,
                'count': len(dispatch_info),
                'incident_id': incident_id,
                'status': 'success'
            }), 200
        else:
            return jsonify({
                'error': 'Failed to retrieve dispatch information',
                'incident_id': incident_id,
                'dispatch_info': [],
                'count': 0
            }), 500
            
    except Exception as e:
        return jsonify({
            'error': str(e),
            'incident_id': incident_id,
            'dispatch_info': [],
            'count': 0
        }), 500

@app.route('/api/incident/<int:incident_id>', methods=['DELETE'])
def delete_incident(incident_id):
    """Delete a traffic incident (triggers hospital bed restoration)"""
    try:
        # First, check if the incident exists and get dispatch info
        check_query = """
        SELECT dl.hospital_id, COUNT(*) as dispatch_count
        FROM DispatchLog dl
        WHERE dl.incident_id = %s
        GROUP BY dl.hospital_id
        """
        
        dispatches = execute_query('TrafficDB', check_query, (incident_id,), fetch_all=True)
        
        # Delete the incident (trigger will handle bed restoration and alert cleanup)
        delete_query = "DELETE FROM TrafficIncident WHERE incident_id = %s"
        result = execute_query('TrafficDB', delete_query, (incident_id,))
        
        if result is not None and result > 0:
            # Verify beds were restored by checking the dispatches
            beds_restored = len(dispatches) if dispatches else 0
            
            return jsonify({
                'message': f'Incident deleted successfully. {beds_restored} hospital bed(s) restored.',
                'status': 'success',
                'beds_restored': beds_restored
            }), 200
        else:
            return jsonify({'error': 'Incident not found or already deleted'}), 404
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/energy_monitoring', methods=['GET'])
def get_energy_monitoring():
    """Get all energy monitoring data"""
    try:
        query = """
        SELECT monitor_id, location, device_type, energy_usage, 
               power_status, timestamp
        FROM EnergyMonitoring 
        ORDER BY timestamp DESC
        """
        
        monitoring_data = execute_query('EnergyDB', query, fetch_all=True)
        
        if monitoring_data is not None:
            # Convert datetime objects to strings
            for data in monitoring_data:
                if data['timestamp']:
                    data['timestamp'] = data['timestamp'].isoformat()
            
            return jsonify({
                'energy_data': monitoring_data,
                'count': len(monitoring_data),
                'status': 'success'
            }), 200
        else:
            return jsonify({'error': 'Failed to retrieve energy monitoring data'}), 500
            
    except Exception as e:
        print(f"Energy monitoring error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/energy_alerts', methods=['GET'])
def get_energy_alerts():
    """Get all energy alerts"""
    try:
        query = """
        SELECT alert_id, incident_id, location, alert_type, message, 
               severity, resolved, alert_time, resolved_time
        FROM EnergyAlerts 
        ORDER BY alert_time DESC
        """
        
        alerts = execute_query('EnergyDB', query, fetch_all=True)
        
        if alerts is not None:
            # Convert datetime objects to strings
            for alert in alerts:
                if alert['alert_time']:
                    alert['alert_time'] = alert['alert_time'].isoformat()
                if alert['resolved_time']:
                    alert['resolved_time'] = alert['resolved_time'].isoformat()
            
            return jsonify({
                'energy_alerts': alerts,
                'count': len(alerts),
                'status': 'success'
            }), 200
        else:
            return jsonify({'error': 'Failed to retrieve energy alerts'}), 500
            
    except Exception as e:
        print(f"Energy alerts error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/energy_consumption', methods=['GET'])
def get_energy_consumption():
    """Get energy consumption summary"""
    try:
        query = """
        SELECT summary_id, location, date, total_consumption, 
               peak_hour_consumption, peak_hour, average_consumption, 
               cost_estimate, created_at
        FROM EnergyConsumptionSummary 
        ORDER BY date DESC, total_consumption DESC
        """
        
        consumption_data = execute_query('EnergyDB', query, fetch_all=True)
        
        if consumption_data is not None:
            # Convert datetime and date objects to strings
            for data in consumption_data:
                if data['date']:
                    data['date'] = data['date'].isoformat()
                if data['peak_hour']:
                    data['peak_hour'] = str(data['peak_hour'])
                if data['created_at']:
                    data['created_at'] = data['created_at'].isoformat()
            
            return jsonify({
                'consumption_data': consumption_data,
                'count': len(consumption_data),
                'status': 'success'
            }), 200
        else:
            return jsonify({'error': 'Failed to retrieve energy consumption data'}), 500
            
    except Exception as e:
        print(f"Energy consumption error: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/energy_alert', methods=['POST'])
def create_energy_alert():
    """Create a new energy alert"""
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        required_fields = ['location', 'alert_type', 'message', 'severity']
        missing_fields = [field for field in required_fields if field not in data]
        
        if missing_fields:
            return jsonify({'error': f'Missing required fields: {", ".join(missing_fields)}'}), 400
        
        # Get database connection
        connection = get_db_connection('EnergyDB')
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
            
        try:
            cursor = connection.cursor(dictionary=True)
            
            query = """
            INSERT INTO EnergyAlerts (incident_id, location, alert_type, message, severity)
            VALUES (%s, %s, %s, %s, %s)
            """
            
            cursor.execute(query, (
                data.get('incident_id'),  # Can be None
                data['location'], 
                data['alert_type'], 
                data['message'], 
                data['severity']
            ))
            
            alert_id = cursor.lastrowid
            connection.commit()
            
            return jsonify({
                'message': 'Energy alert created successfully',
                'status': 'success',
                'alert_id': alert_id
            }), 201
            
        except mysql.connector.Error as db_error:
            print(f"Database error creating energy alert: {str(db_error)}")
            return jsonify({'error': f'Database error: {str(db_error)}'}), 500
        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
                
    except Exception as e:
        print(f"Error creating energy alert: {str(e)}")
        return jsonify({'error': str(e)}), 500

@app.route('/api/energy_alert/<int:alert_id>/resolve', methods=['POST'])
def resolve_energy_alert(alert_id):
    """Resolve an energy alert"""
    try:
        # Get database connection
        connection = get_db_connection('EnergyDB')
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
            
        try:
            cursor = connection.cursor(dictionary=True)
            
            query = """
            UPDATE EnergyAlerts 
            SET resolved = TRUE, resolved_time = CURRENT_TIMESTAMP
            WHERE alert_id = %s
            """
            
            cursor.execute(query, (alert_id,))
            rows_affected = cursor.rowcount
            connection.commit()
            
            if rows_affected > 0:
                return jsonify({
                    'message': 'Energy alert resolved successfully',
                    'status': 'success'
                }), 200
            else:
                return jsonify({'error': 'Alert not found or already resolved'}), 404
                
        except mysql.connector.Error as db_error:
            print(f"Database error resolving energy alert: {str(db_error)}")
            return jsonify({'error': f'Database error: {str(db_error)}'}), 500
        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
                
    except Exception as e:
        print(f"Error resolving energy alert: {str(e)}")
        return jsonify({'error': str(e)}), 500
# Add these routes to your app.py file, after the existing energy routes

@app.route('/api/energy_simulate/outage', methods=['POST'])
def simulate_power_outage():
    """Simulate a power outage in a specific area"""
    try:
        data = request.get_json()
        
        if not data or 'location' not in data:
            return jsonify({'error': 'Missing location'}), 400
        
        location = data['location']
        
        # Get database connection
        connection = get_db_connection('EnergyDB')
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
            
        try:
            cursor = connection.cursor(dictionary=True)
            
            # Update all devices in the location to Offline
            cursor.execute("""
                UPDATE EnergyMonitoring 
                SET power_status = 'Offline', timestamp = CURRENT_TIMESTAMP
                WHERE location = %s AND power_status = 'Online'
            """, (location,))
            
            affected_devices = cursor.rowcount
            
            if affected_devices > 0:
                # Create critical alert
                cursor.execute("""
                    INSERT INTO EnergyAlerts (location, alert_type, message, severity)
                    VALUES (%s, %s, %s, %s)
                """, (
                    location,
                    'Power_Outage',
                    f"🚨 AREA POWER OUTAGE: All devices in {location} have lost power. {affected_devices} devices affected. Emergency response required!",
                    'Critical'
                ))
                
                connection.commit()
                
                return jsonify({
                    'message': f'Power outage simulated in {location}',
                    'affected_devices': affected_devices,
                    'status': 'success',
                    'alert_created': True
                }), 200
            else:
                return jsonify({
                    'message': f'No online devices found in {location}',
                    'affected_devices': 0,
                    'status': 'info'
                }), 200
                
        except Exception as db_error:
            return jsonify({'error': f'Database error: {str(db_error)}'}), 500
        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
                
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/energy_simulate/restore', methods=['POST'])
def simulate_power_restore():
    """Simulate power restoration in a specific area"""
    try:
        data = request.get_json()
        
        if not data or 'location' not in data:
            return jsonify({'error': 'Missing location'}), 400
        
        location = data['location']
        
        # Get database connection
        connection = get_db_connection('EnergyDB')
        if not connection:
            return jsonify({'error': 'Database connection failed'}), 500
            
        try:
            cursor = connection.cursor(dictionary=True)
            
            # Restore all offline devices in the location
            cursor.execute("""
                UPDATE EnergyMonitoring 
                SET power_status = 'Online', timestamp = CURRENT_TIMESTAMP
                WHERE location = %s AND power_status = 'Offline'
            """, (location,))
            
            restored_devices = cursor.rowcount
            
            if restored_devices > 0:
                # Create restoration alert
                cursor.execute("""
                    INSERT INTO EnergyAlerts (location, alert_type, message, severity)
                    VALUES (%s, %s, %s, %s)
                """, (
                    location,
                    'Emergency_Backup_Active',
                    f"✅ POWER RESTORED: All devices in {location} are back online. {restored_devices} devices restored successfully.",
                    'Low'
                ))
                
                # Mark related power outage alerts as resolved
                cursor.execute("""
                    UPDATE EnergyAlerts 
                    SET resolved = TRUE, resolved_time = CURRENT_TIMESTAMP
                    WHERE location = %s AND alert_type = 'Power_Outage' AND resolved = FALSE
                """, (location,))
                
                connection.commit()
                
                return jsonify({
                    'message': f'Power restored in {location}',
                    'restored_devices': restored_devices,
                    'status': 'success',
                    'alert_created': True
                }), 200
            else:
                return jsonify({
                    'message': f'No offline devices found in {location}',
                    'restored_devices': 0,
                    'status': 'info'
                }), 200
                
        except Exception as db_error:
            return jsonify({'error': f'Database error: {str(db_error)}'}), 500
        finally:
            if connection.is_connected():
                cursor.close()
                connection.close()
                
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    print("Starting Smart City Application Server...")
    print("Make sure MySQL is running and databases are set up!")
    print("Access the application at: http://localhost:5000")
    app.run(debug=True, host='0.0.0.0', port=5000)