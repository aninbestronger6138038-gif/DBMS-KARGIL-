CREATE TABLE Students(
Student_id int,
Student_name VARCHAR(100)
);

INSERT INTO  Students VALUES (1,'Anish');
INSERT INTO  Students VALUES (2,'Anil');
INSERT INTO  Students VALUES (3,'Snehasish');
INSERT INTO  Students VALUES (4,'Anindita');
INSERT INTO  Students VALUES (5,'Rani');
INSERT INTO  Students VALUES (6,'Rajni');
INSERT INTO  Students VALUES (7,'Ranibala');

SELECT * FROM Students;

CREATE TABLE Courses(
course_id int,
Course_name VARCHAR(100)
);

INSERT INTO  Courses VALUES (101,'DBMS');
INSERT INTO  Courses VALUES (102,'FRONTEND');
INSERT INTO  Courses VALUES (103,'BACKEND');
INSERT INTO  Courses VALUES (104,'COMPUTER NETWORKS');
INSERT INTO  Courses VALUES (105,'CYBERSECURITY');
INSERT INTO  Courses VALUES (106,'ADVANCED INTERNET PROGRAMMING');

SELECT * FROM Courses;

CREATE TABLE Enrollments(
Student_id int,
course_id int,
Course_name VARCHAR(100)
);

INSERT INTO  Enrollments VALUES (1,101,'DBMS');
INSERT INTO  Enrollments VALUES (1,102,'FRONTEND');
INSERT INTO  Enrollments VALUES (2,103,'BACKEND');
INSERT INTO  Enrollments VALUES (3,104,'COMPUTER NETWORKS');
INSERT INTO  Enrollments VALUES (4,105,'CYBERSECURITY');
INSERT INTO  Enrollments VALUES (5,103,'BACKEND');
INSERT INTO  Enrollments VALUES (5,104,'COMPUTER NETWORKS');

SELECT * FROM Enrollments;

CREATE TABLE Departments(
Department_id INT,
Department_name VARCHAR(100),
Student_id INT
);
SELECT * FROM Departments;
INSERT INTO  Departments VALUES (1,'MCA',1);
INSERT INTO  Departments VALUES (11,'MCA',2);
INSERT INTO  Departments VALUES (12,'ENGINEERING',3);
INSERT INTO  Departments VALUES (13,'ENGINEERING',4);
INSERT INTO  Departments VALUES (12,'BCA',5);
INSERT INTO  Departments VALUES (12,'BCA',6);
INSERT INTO  Departments VALUES (12,'BCA',7);

SELECT * FROM Departments;

--1. Write queries to list students with their enrolled courses (INNER JOIN).
SELECT s.Student_id, s.Student_name, e.course_id, e.Course_name
FROM Students AS s
JOIN Enrollments AS e
ON s.Student_id = e.Student_id
ORDER BY Student_id ASC;

--2. Find students not enrolled in any course (LEFT JOIN).
SELECT s.Student_id, s.Student_name
FROM Students AS s
LEFT JOIN Enrollments as e
ON s.Student_id = e.Student_id
WHERE e.Student_id IS NULL
ORDER BY s.Student_id ASC;

--3. Display all courses with or without enrolled students (RIGHT JOIN).

SELECT DISTINCT(c.course_id),e.Course_name
FROM Enrollments AS e
RIGHT JOIN Courses AS c 
ON e.course_id=c.course_id 
ORDER BY course_id ASC; 

--4. Show students with department info using SELF JOIN or multiple joins.
SELECT s.Student_id, s.Student_name, d.Department_id,d.Department_name,e.course_id,e.Course_name
FROM Students AS s
LEFT JOIN Departments AS d ON s.Student_id = d.Student_id
LEFT JOIN Enrollments AS e ON  s.Student_id = e.Student_id
ORDER BY s.Student_id ASC;

--5. Display all possible student-course combinations (CROSS JOIN). (Oracle, SAP, IBM, Microsoft)
SELECT s.Student_id,s.Student_name,c.course_id,c.Course_name
FROM Students AS s
CROSS JOIN Courses AS c
ORDER BY s.Student_id ASC;

