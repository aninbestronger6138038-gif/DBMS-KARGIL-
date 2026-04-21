-- Smart City Application Database Schema
-- Create all 4 databases

CREATE DATABASE IF NOT EXISTS TrafficDB;
CREATE DATABASE IF NOT EXISTS HealthcareDB;
CREATE DATABASE IF NOT EXISTS SecurityDB;
CREATE DATABASE IF NOT EXISTS EnergyDB;

-- ========================================
-- TRAFFIC DATABASE SETUP
-- ========================================
USE TrafficDB;

-- Traffic Incidents Table
CREATE TABLE IF NOT EXISTS TrafficIncident (
    incident_id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(255) NOT NULL,
    severity ENUM('Low', 'Medium', 'High') NOT NULL,
    reported_by VARCHAR(100) NOT NULL,
    incident_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50) DEFAULT 'Reported'
);

-- Hospital Table (for reference and dispatch)
CREATE TABLE IF NOT EXISTS Hospital (
    hospital_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location VARCHAR(255) NOT NULL,
    available_beds INT DEFAULT 0,
    last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Dispatch Log Table
CREATE TABLE IF NOT EXISTS DispatchLog (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    incident_id INT,
    hospital_id INT,
    dispatch_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (incident_id) REFERENCES TrafficIncident(incident_id) ON DELETE CASCADE,
    FOREIGN KEY (hospital_id) REFERENCES Hospital(hospital_id)
);

-- ========================================
-- HEALTHCARE DATABASE SETUP
-- ========================================
USE HealthcareDB;

CREATE TABLE IF NOT EXISTS HealthAlerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    incident_id INT NOT NULL,
    incident_location VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    alert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- SECURITY DATABASE SETUP
-- ========================================
USE SecurityDB;

CREATE TABLE IF NOT EXISTS SecurityAlerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    incident_id INT NOT NULL,
    incident_location VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    alert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========================================
-- ENERGY DATABASE SETUP
-- ========================================
USE EnergyDB;

-- Main energy monitoring table
CREATE TABLE IF NOT EXISTS EnergyMonitoring (
    monitor_id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(255) NOT NULL,
    device_type ENUM('Street_Light', 'Traffic_Signal', 'Emergency_System', 'Hospital_Equipment', 'Security_Camera') NOT NULL,
    energy_usage DECIMAL(10,2) NOT NULL, -- in kWh
    power_status ENUM('Online', 'Offline', 'Maintenance') DEFAULT 'Online',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Energy alerts table for power outages and high consumption
CREATE TABLE IF NOT EXISTS EnergyAlerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    incident_id INT, -- Link to traffic incident if energy issue is related
    location VARCHAR(255) NOT NULL,
    alert_type ENUM('Power_Outage', 'High_Consumption', 'Equipment_Failure', 'Emergency_Backup_Active') NOT NULL,
    message TEXT NOT NULL,
    severity ENUM('Low', 'Medium', 'High', 'Critical') NOT NULL,
    resolved BOOLEAN DEFAULT FALSE,
    alert_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_time TIMESTAMP NULL
);

-- Energy consumption summary table
CREATE TABLE IF NOT EXISTS EnergyConsumptionSummary (
    summary_id INT AUTO_INCREMENT PRIMARY KEY,
    location VARCHAR(255) NOT NULL,
    date DATE NOT NULL,
    total_consumption DECIMAL(12,2) NOT NULL,
    peak_hour_consumption DECIMAL(10,2),
    peak_hour TIME,
    average_consumption DECIMAL(10,2),
    cost_estimate DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY unique_location_date (location, date)
);

-- ========================================
-- TRIGGERS AND PROCEDURES
-- ========================================
USE TrafficDB;

-- Drop existing triggers and procedures if they exist
DROP TRIGGER IF EXISTS before_incident_insert;
DROP TRIGGER IF EXISTS after_incident_insert;
DROP TRIGGER IF EXISTS before_incident_delete;
DROP PROCEDURE IF EXISTS find_nearest_hospital_in_location;
DROP PROCEDURE IF EXISTS dispatch_ambulance_to_hospital;

DELIMITER //

-- BEFORE INSERT TRIGGER: Set status based on severity
CREATE TRIGGER before_incident_insert
    BEFORE INSERT ON TrafficIncident
    FOR EACH ROW
BEGIN
    IF NEW.severity = 'High' THEN
        SET NEW.status = 'Notified';
    ELSE
        SET NEW.status = 'Reported';
    END IF;
END//

-- AFTER INSERT TRIGGER: Create alerts in Healthcare and Security DBs + Auto-dispatch for HIGH severity
CREATE TRIGGER after_incident_insert
    AFTER INSERT ON TrafficIncident
    FOR EACH ROW
BEGIN
    DECLARE health_message TEXT;
    DECLARE security_message TEXT;
    DECLARE nearest_hospital_id INT;
    DECLARE hospital_beds INT;
    
    -- Create health alert message
    SET health_message = CONCAT('Traffic incident reported at ', NEW.location, 
                               ' with ', NEW.severity, ' severity. Medical assistance may be required.');
    
    -- Create security alert message
    SET security_message = CONCAT('Traffic incident at ', NEW.location, 
                                 ' requires security attention. Severity: ', NEW.severity);
    
    -- Insert into HealthcareDB
    INSERT INTO HealthcareDB.HealthAlerts (incident_id, incident_location, message)
    VALUES (NEW.incident_id, NEW.location, health_message);
    
    -- Insert into SecurityDB
    INSERT INTO SecurityDB.SecurityAlerts (incident_id, incident_location, message)
    VALUES (NEW.incident_id, NEW.location, security_message);
    
    -- AUTO-DISPATCH AMBULANCE FOR HIGH SEVERITY INCIDENTS
    IF NEW.severity = 'High' THEN
        -- Find nearest hospital with available beds
        SELECT hospital_id, available_beds INTO nearest_hospital_id, hospital_beds
        FROM Hospital
        WHERE location LIKE CONCAT('%', SUBSTRING_INDEX(NEW.location, ' ', 1), '%')
          AND available_beds > 0
        ORDER BY available_beds DESC
        LIMIT 1;
        
        -- If no hospital found in same area, find any hospital with beds
        IF nearest_hospital_id IS NULL THEN
            SELECT hospital_id, available_beds INTO nearest_hospital_id, hospital_beds
            FROM Hospital
            WHERE available_beds > 0
            ORDER BY available_beds DESC
            LIMIT 1;
        END IF;
        
        -- Dispatch ambulance if hospital found
        IF nearest_hospital_id IS NOT NULL AND hospital_beds > 0 THEN
            -- Insert dispatch record
            INSERT INTO DispatchLog (incident_id, hospital_id)
            VALUES (NEW.incident_id, nearest_hospital_id);
            
            -- Decrease available beds
            UPDATE Hospital
            SET available_beds = available_beds - 1
            WHERE hospital_id = nearest_hospital_id;
            
            -- Create special alert for auto-dispatch
            INSERT INTO HealthcareDB.HealthAlerts (incident_id, incident_location, message)
            VALUES (NEW.incident_id, NEW.location, 
                   CONCAT('🚨 EMERGENCY AUTO-DISPATCH: Ambulance automatically dispatched to ', NEW.location, 
                         ' for HIGH severity incident. Hospital: ', 
                         (SELECT name FROM Hospital WHERE hospital_id = nearest_hospital_id)));
        ELSE
            -- Create alert if no hospital available
            INSERT INTO HealthcareDB.HealthAlerts (incident_id, incident_location, message)
            VALUES (NEW.incident_id, NEW.location, 
                   CONCAT('⚠️ CRITICAL ALERT: HIGH severity incident at ', NEW.location, 
                         ' but NO AMBULANCE available - all hospitals at capacity!'));
        END IF;
    END IF;
END//

-- BEFORE DELETE TRIGGER: Restore hospital beds when incident is deleted
CREATE TRIGGER before_incident_delete
    BEFORE DELETE ON TrafficIncident
    FOR EACH ROW
BEGIN
    -- Restore beds for any dispatched ambulances for this incident
    UPDATE Hospital h
    INNER JOIN DispatchLog dl ON h.hospital_id = dl.hospital_id
    SET h.available_beds = h.available_beds + 1
    WHERE dl.incident_id = OLD.incident_id;
    
    -- Also delete corresponding alerts from other databases
    DELETE FROM HealthcareDB.HealthAlerts WHERE incident_id = OLD.incident_id;
    DELETE FROM SecurityDB.SecurityAlerts WHERE incident_id = OLD.incident_id;
END//

-- STORED PROCEDURE: Find nearest hospital with available beds
CREATE PROCEDURE find_nearest_hospital_in_location(IN search_location VARCHAR(255))
BEGIN
    SELECT hospital_id, name, location, available_beds
    FROM Hospital
    WHERE location LIKE CONCAT('%', search_location, '%')
      AND available_beds > 0
    ORDER BY available_beds DESC
    LIMIT 1;
END//

-- STORED PROCEDURE: Dispatch ambulance to hospital
CREATE PROCEDURE dispatch_ambulance_to_hospital(IN hospital_id_param INT, IN incident_id_param INT)
BEGIN
    DECLARE beds_available INT;
    
    -- Check if hospital has available beds
    SELECT available_beds INTO beds_available
    FROM Hospital
    WHERE hospital_id = hospital_id_param;
    
    IF beds_available > 0 THEN
        -- Insert dispatch record
        INSERT INTO DispatchLog (incident_id, hospital_id)
        VALUES (incident_id_param, hospital_id_param);
        
        -- Decrease available beds
        UPDATE Hospital
        SET available_beds = available_beds - 1
        WHERE hospital_id = hospital_id_param;
    END IF;
END//

DELIMITER ;

-- ========================================
-- SAMPLE DATA INSERTION
-- ========================================

-- Insert sample hospitals
INSERT INTO Hospital (name, location, available_beds) VALUES
('City General Hospital', 'Downtown', 25),
('Metro Medical Center', 'Uptown', 15),
('Riverside Hospital', 'Riverside', 30),
('Central Emergency Hospital', 'City Center', 20),
('Northside Medical', 'North District', 18);

-- Insert sample energy monitoring data
USE EnergyDB;

INSERT INTO EnergyMonitoring (location, device_type, energy_usage, power_status) VALUES
('Downtown Main St', 'Street_Light', 2.5, 'Online'),
('Downtown Main St', 'Traffic_Signal', 1.8, 'Online'),
('Uptown Bridge', 'Street_Light', 3.2, 'Online'),
('Uptown Bridge', 'Emergency_System', 5.4, 'Online'),
('Riverside Ave', 'Security_Camera', 0.8, 'Online'),
('City Center', 'Traffic_Signal', 2.1, 'Online'),
('City Center', 'Hospital_Equipment', 15.7, 'Online'),
('North District', 'Street_Light', 2.8, 'Offline'),
('North District', 'Emergency_System', 4.2, 'Maintenance');

INSERT INTO EnergyAlerts (location, alert_type, message, severity) VALUES
('North District', 'Power_Outage', 'Street lighting system offline in North District. Immediate attention required.', 'High'),
('City Center', 'High_Consumption', 'Hospital equipment showing 25% higher than normal energy consumption.', 'Medium'),
('Uptown Bridge', 'Equipment_Failure', 'Emergency backup system activated due to main power fluctuation.', 'Critical');

INSERT INTO EnergyConsumptionSummary (location, date, total_consumption, peak_hour_consumption, peak_hour, average_consumption, cost_estimate) VALUES
('Downtown Main St', CURDATE(), 45.6, 8.2, '19:00:00', 3.8, 182.40),
('Uptown Bridge', CURDATE(), 52.3, 9.1, '18:30:00', 4.4, 209.20),
('City Center', CURDATE(), 78.9, 12.5, '20:00:00', 6.6, 315.60),
('Riverside Ave', CURDATE(), 32.1, 5.8, '19:30:00', 2.7, 128.40),
('North District', CURDATE(), 28.4, 4.9, '18:00:00', 2.4, 113.60);

-- Verify the setup
SELECT 'Traffic Incidents' as Table_Name;
SELECT * FROM TrafficIncident;

SELECT 'Hospitals' as Table_Name;
SELECT * FROM Hospital;

SELECT 'Healthcare Alerts' as Table_Name;
SELECT * FROM HealthcareDB.HealthAlerts;

SELECT 'Security Alerts' as Table_Name;
SELECT * FROM SecurityDB.SecurityAlerts;



-- Auto-Dispatch Feature Update Script
-- Run this if you already have the system set up

USE TrafficDB;

-- Drop the existing trigger
DROP TRIGGER IF EXISTS after_incident_insert;

-- Create the enhanced trigger with auto-dispatch
DELIMITER //

CREATE TRIGGER after_incident_insert
    AFTER INSERT ON TrafficIncident
    FOR EACH ROW
BEGIN
    DECLARE health_message TEXT;
    DECLARE security_message TEXT;
    DECLARE nearest_hospital_id INT;
    DECLARE hospital_beds INT;
    
    -- Create health alert message
    SET health_message = CONCAT('Traffic incident reported at ', NEW.location, 
                               ' with ', NEW.severity, ' severity. Medical assistance may be required.');
    
    -- Create security alert message
    SET security_message = CONCAT('Traffic incident at ', NEW.location, 
                                 ' requires security attention. Severity: ', NEW.severity);
    
    -- Insert into HealthcareDB
    INSERT INTO HealthcareDB.HealthAlerts (incident_id, incident_location, message)
    VALUES (NEW.incident_id, NEW.location, health_message);
    
    -- Insert into SecurityDB
    INSERT INTO SecurityDB.SecurityAlerts (incident_id, incident_location, message)
    VALUES (NEW.incident_id, NEW.location, security_message);
    
    -- AUTO-DISPATCH AMBULANCE FOR HIGH SEVERITY INCIDENTS
    IF NEW.severity = 'High' THEN
        -- Find nearest hospital with available beds
        SELECT hospital_id, available_beds INTO nearest_hospital_id, hospital_beds
        FROM Hospital
        WHERE location LIKE CONCAT('%', SUBSTRING_INDEX(NEW.location, ' ', 1), '%')
          AND available_beds > 0
        ORDER BY available_beds DESC
        LIMIT 1;
        
        -- If no hospital found in same area, find any hospital with beds
        IF nearest_hospital_id IS NULL THEN
            SELECT hospital_id, available_beds INTO nearest_hospital_id, hospital_beds
            FROM Hospital
            WHERE available_beds > 0
            ORDER BY available_beds DESC
            LIMIT 1;
        END IF;
        
        -- Dispatch ambulance if hospital found
        IF nearest_hospital_id IS NOT NULL AND hospital_beds > 0 THEN
            -- Insert dispatch record
            INSERT INTO DispatchLog (incident_id, hospital_id)
            VALUES (NEW.incident_id, nearest_hospital_id);
            
            -- Decrease available beds
            UPDATE Hospital
            SET available_beds = available_beds - 1
            WHERE hospital_id = nearest_hospital_id;
            
            -- Create special alert for auto-dispatch
            INSERT INTO HealthcareDB.HealthAlerts (incident_id, incident_location, message)
            VALUES (NEW.incident_id, NEW.location, 
                   CONCAT('🚨 EMERGENCY AUTO-DISPATCH: Ambulance automatically dispatched to ', NEW.location, 
                         ' for HIGH severity incident. Hospital: ', 
                         (SELECT name FROM Hospital WHERE hospital_id = nearest_hospital_id)));
        ELSE
            -- Create alert if no hospital available
            INSERT INTO HealthcareDB.HealthAlerts (incident_id, incident_location, message)
            VALUES (NEW.incident_id, NEW.location, 
                   CONCAT('⚠️ CRITICAL ALERT: HIGH severity incident at ', NEW.location, 
                         ' but NO AMBULANCE available - all hospitals at capacity!'));
        END IF;
    END IF;
END//

DELIMITER ;

-- Test the auto-dispatch feature
SELECT 'Auto-dispatch feature installed successfully!' as Status;
SELECT 'Testing Instructions:' as Instructions;
SELECT '1. Report a HIGH severity incident' as Step1;
SELECT '2. Check DispatchLog table for automatic dispatch' as Step2;
SELECT '3. Check HealthAlerts for auto-dispatch confirmation' as Step3;
SELECT '4. Verify hospital available_beds decreased' as Step4;

-- Show current hospital status
SELECT 'Current Hospital Status:' as Info;
SELECT hospital_id, name, location, available_beds FROM Hospital;