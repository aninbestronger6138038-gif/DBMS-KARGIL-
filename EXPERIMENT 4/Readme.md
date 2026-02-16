DBMS Lab – Worksheet 1

To understand and implement iterative control structures in PostgreSQL 

👨‍🎓 Student Details

Name: Anindita Dhar

UID: 25MCA20259

Branch: MCA(GENERAL)

Semester: 2nd

Section/Group: 1/A

Subject: TECHNICAL TRAINING

Date of Performance: 01/02/2026

🎯 Aim
To understand and implement iterative control structures in PostgreSQL conceptually, including FOR loops, WHILE loops, and basic LOOP constructs, for repeated execution of database logic.

🎯Objectives:
•	To understand why iteration is required in database programming

•	To learn the purpose and behaviour of FOR, WHILE, and LOOP constructs

•	To understand how repeated data processing is handled in databases

•	To relate loop concepts to real-world batch processing scenarios

•	To strengthen conceptual knowledge of procedural SQL used in enterprise systems


💻 Input/Apparatus Used:

	PostgreSQL

	pgAdmin

Practical / Experiment Steps

Pre-requisite Understanding

• Students should first understand that iterative control structures are executed inside PL/pgSQL blocks, not in normal SQL queries

• Students should create a table that stores multiple records so that loop execution over rows can be demonstrated

• The table should contain:

•	A unique identifier

•	A descriptive attribute (such as name or category)

•	A numeric value to be processed repeatedly


Procedure/Algorithm/Code:

i.	Start the system and log in to the computer.

ii. Open PostgreSQL software.

iii. Create a table using the DDL command.

CREATE TABLE  Employees (
emp_id SERIAL PRIMARY KEY,
emp_name VARCHAR(100),
salary NUMERIC(10,2)
);
      
iv. 
Insert records into the table named customer_orders

INSERT INTO Employees VALUES('Rahul', 40000),

INSERT INTO Employees VALUES('Ankit', 52000),

INSERT INTO Employees VALUES('Priya', 60000),

INSERT INTO Employees VALUES('Neha', 35000),

INSERT INTO Employees VALUES('Aman', 70000);

vi. Display all records

SELECT * FROM Employees;

<img width="864" height="372" alt="image" src="https://github.com/user-attachments/assets/fd47a73b-14dd-409f-90ae-94a7c06160f5" />

vii. (Step 1) FOR Loop – Simple Iteration

DO $$

BEGIN

    FOR i IN 1..5 LOOP
    
        RAISE NOTICE 'Iteration number: %', i;
        
    END LOOP;
    
END $$.


<img width="753" height="426" alt="image" src="https://github.com/user-attachments/assets/a5fdf29a-cbc3-4faf-9151-360cb5bdb3b4" />


viii. (Step  2) FOR Loop with Query (Row-by-Row Processing)

DO $$

DECLARE

    emp RECORD;
    
BEGIN

    FOR emp IN SELECT emp_id, emp_name FROM Employees LOOP
    
        RAISE NOTICE 'Employee ID: %, Name: %', emp.emp_id, emp.emp_name;
        
    END LOOP;
    
END $$;

<img width="777" height="428" alt="image" src="https://github.com/user-attachments/assets/ef7cb2c2-8d19-4085-9b75-e0c605195761" />

ix.(Step  3) WHILE Loop – Conditional Iteration

DO $$

DECLARE

    counter INT := 1;
    
BEGIN

    WHILE counter <= 5 LOOP
    
        RAISE NOTICE 'Counter: %', counter;
        
        counter := counter + 1;
        
    END LOOP;
    
END $$; 

<img width="659" height="375" alt="image" src="https://github.com/user-attachments/assets/b7f7f9a1-5659-4ba0-a646-fe5e602ed7ed" />

x. (Step 4) LOOP with EXIT WHEN

DO $$

DECLARE   

  x INT := 1;
  
BEGIN

      LOOP
      
             RAISE NOTICE 'Value: %', x;
             
             x := x + 1;
             
             EXIT WHEN x > 5;
             
      END LOOP;
      
END $$.

<img width="686" height="430" alt="image" src="https://github.com/user-attachments/assets/f044afe1-e18a-49fb-978b-e5bee45460fd" />


xi.(Step 5) Salary Increment Using FOR Loop

DO $$

DECLARE

    emp RECORD;
    
BEGIN

    FOR emp IN SELECT emp_id, salary FROM Employees LOOP
    
        UPDATE employee
        
        SET salary = salary * 1.10
        
        WHERE emp_id = emp.emp_id;
        
    END LOOP;
    
END $$;


select*from Employees;

<img width="838" height="445" alt="image" src="https://github.com/user-attachments/assets/2ea6d3a6-9819-4bbe-aa6f-5d4f16f6114d" />

Step 6: Combining LOOP with IF Condition


DO $$

DECLARE

    emp RECORD;
    
BEGIN

    FOR emp IN SELECT emp_name, salary FROM Employees  LOOP
    
        IF emp. salary > 50000 THEN
        
            RAISE NOTICE '% is a High Earner', emp.emp_name;
            
        ELSE
        
            RAISE NOTICE '% is a Regular Employee', emp.emp_name;
            
        END IF;
        
    END LOOP;
    
END $$;

<img width="824" height="470" alt="image" src="https://github.com/user-attachments/assets/d9afad8a-7cae-47e4-a5c3-6015c2a001ed" />


6. I/O Analysis (Input / Output)
   
Input:

• Employee or sample records inserted into a database table for iterative processing

• PL/pgSQL DO block containing procedural logic

• FOR loop constructs for fixed-range and query-based iteration

• WHILE loop with condition-based execution

• LOOP construct with explicit EXIT WHEN condition

• IF–ELSE conditions used inside loops for decision making

• UPDATE statements executed repeatedly within loop structures


Output:

	Repeated execution of SQL statements based on loop conditions

	Row-by-row processing of table records using FOR loops

	Conditional messages are displayed during each iteration

	Successful salary updates or value modifications through iterative logic

	Proper termination of loops based on defined conditions

	Correct execution of procedural SQL demonstrating iteration control


7. Learning Outcomes

	Understood the need for iterative control structures in database programming

	Learned the usage of FOR, WHILE, and LOOP constructs in PostgreSQL

	 Gained knowledge of executing repeated logic using PL/pgSQL

	Understood row-by-row processing and conditional execution in the database

	 Developed foundational skills for writing procedural SQL in real-world applications






 














