CREATE TABLE Departments_(
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

CREATE TABLE Employees_5(
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    salary NUMERIC,
    status VARCHAR(10),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

INSERT INTO Departments_ VALUES
(1, 'HR')
INSERT INTO Departments_ VALUES
(2, 'IT')
INSERT INTO Departments_ VALUES
(3, 'Finance')

INSERT INTO  Employees_5 VALUES
(1, 'Roshan', 30000, 'Active', 2)
INSERT INTO  Employees_5 VALUES
(2, 'Anindita', 40000, 'Active', 2)
INSERT INTO  Employees_5 VALUES
(3, 'Shriya', 25000, 'Inactive', 1)
INSERT INTO  Employees_5 VALUES
(4, 'Anju', 35000, 'Active', 3)
INSERT INTO  Employees_5 VALUES
(5, 'Sanjana', 28000, 'Active', 1);



--1
CREATE VIEW active_employees AS
SELECT emp_id, emp_name, dept_id
FROM Employees_5
WHERE status = 'Active';

SELECT * FROM active_employees;

--2

CREATE VIEW employee_department_view AS
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employees_5 as e
JOIN department d ON e.dept_id = d.dept_id;

SELECT * FROM employee_department_view;

--3

CREATE VIEW department_summary AS
SELECT d.dept_name,
       COUNT(e.emp_id) AS total_employees,
       AVG(e.salary) AS average_salary
FROM Departments_ as d
JOIN Employees_5 e ON d.dept_id = e.dept_id
GROUP BY d.dept_name;

SELECT * FROM department_summary;

DROP VIEW department_summary;

