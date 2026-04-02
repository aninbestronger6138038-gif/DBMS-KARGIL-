CREATE TABLE Employee (
    empId INT PRIMARY KEY,
    name VARCHAR(50),
    salary INT
);

--- INSERT PROCEDURE
CREATE OR REPLACE PROCEDURE insert_employee(
    eid INT,
    ename VARCHAR,
    esalary INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Employee VALUES (eid, ename, esalary);
END;
$$;

--- UPDATE PROCEDURE
CREATE OR REPLACE PROCEDURE update_salary(
    eid INT,
    new_salary INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Employee
    SET salary = new_salary
    WHERE empId = eid;
END;
$$;

--- DELETE PROCEDURE
CREATE OR REPLACE PROCEDURE delete_employee(
    eid INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Employee
    WHERE empId = eid;
END;
$$;

--- RETRIVE DATA USING FUNCTION
CREATE OR REPLACE FUNCTION get_employees()
RETURNS TABLE(empId INT, name VARCHAR, salary INT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM Employee;
END;
$$;

--- EXECUTION PART
CALL insert_employee(1, 'John', 5000);
CALL update_salary(1, 6000);
CALL insert_employee(2, 'Rahul', 5000);

SELECT * FROM get_employees();

CALL delete_employee(1);
