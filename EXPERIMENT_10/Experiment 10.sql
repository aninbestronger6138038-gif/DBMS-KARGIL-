CREATE TABLE Payroll (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary DECIMAL(10,2) CHECK(SALARY>0)
);


 
--DROP TABLE PAYROLL

INSERT INTO Payroll VALUES
(1, 'Amit', 30000);

INSERT INTO Payroll VALUES
(2, 'Neha', 40000);

INSERT INTO Payroll VALUES
(3, 'Ravi', 50000);

SELECT * FROM Payroll;

BEGIN;

UPDATE Payroll
SET salary = 1000
WHERE emp_id=3;


UPDATE Payroll
SET salary = 1000
WHERE emp_id=3;

SELECT * FROM Payroll;

ROLLBACK;

-- truncate table pAYROLL

BEGIN;

UPDATE Payroll
SET salary = -1000
WHERE emp_id = 3;

UPDATE Payroll
SET salary = 1000
WHERE emp_id = 3;


SELECT * FROM Payroll

ROLLBACK;


SELECT * FROM Payroll


SELECT * FROM PAYROLL


BEGIN;
-- Update 1
UPDATE Payroll
SET salary = salary + 5000
WHERE emp_id = 1;

-- Savepoint
SAVEPOINT sp1;

-- Update 2
UPDATE Payroll
SET salary = salary + 7000
WHERE emp_id = 2;


-- Error simulation
UPDATE Payroll
SET salary = -1000
WHERE emp_id = 3;


-- Rollback to savepoint
ROLLBACK TO sp1;

-- Commit valid changes
COMMIT;

 