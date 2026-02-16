CREATE TABLE  Employees_(
emp_id SERIAL PRIMARY KEY,
emp_name VARCHAR(100),
salary NUMERIC(10,2)
);


INSERT INTO Employees_ VALUES(6,'Rahul', 40000),
INSERT INTO Employees_ VALUES(7,'Ankit', 52000),
INSERT INTO Employees_ VALUES(8,'Priya', 60000),
INSERT INTO Employees_ VALUES(9,'Neha', 35000),
INSERT INTO Employees_ VALUES(10,'Aman', 70000);

SELECT * FROM Employees_;

DO $$
BEGIN
    FOR i IN 1..5 LOOP
        RAISE NOTICE 'Iteration number: %', i;
    END LOOP;
END $$;


DO $$
DECLARE
    emp RECORD;
BEGIN
    FOR emp IN SELECT emp_id, emp_name FROM Employees_
	LOOP
        RAISE NOTICE 'Employee ID: %, Name: %', emp.emp_id, emp.emp_name;
    END LOOP;
END $$;


DO $$
DECLARE
    counter INT := 1;
BEGIN
    WHILE counter <= 5 LOOP
        RAISE NOTICE 'Counter: %', counter;
        counter := counter + 1;
    END LOOP;
END $$; 


DO $$
DECLARE   
  x INT := 1;
BEGIN
      LOOP
             RAISE NOTICE 'Value: %', x;
             x := x + 1;
             
             EXIT WHEN x > 5;
      END LOOP;
END $$;


DO $$
DECLARE
    emp RECORD;
BEGIN
    FOR emp IN SELECT emp_id, salary FROM Employees_ 
	LOOP
        UPDATE Employees_
        SET salary = salary * 1.10
        WHERE emp_id = emp.emp_id;
    END LOOP;
END $$;


select*from Employees_;


DO $$
DECLARE
    emp RECORD;
BEGIN
    FOR emp IN SELECT emp_name, salary FROM Employees_
	LOOP
        IF emp. salary > 50000 THEN
            RAISE NOTICE '% is a High Earner', emp.emp_name;
        ELSE
            RAISE NOTICE '% is a Regular Employee', emp.emp_name;
        END IF;
    END LOOP;
END $$;

