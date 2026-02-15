CREATE TABLE Schema_Analysis_(
schema_id SERIAL PRIMARY KEY,
schema_name VARCHAR(100),
violation_count INT );


INSERT INTO Schema_Analysis_ VALUES(1,'Employee_Schema',0);
INSERT INTO Schema_Analysis_ VALUES(2,'Payroll_Schema',2);
INSERT INTO Schema_Analysis_ VALUES(3,'Inventory_Schema',5);
INSERT INTO Schema_Analysis_ VALUES(4,'Finance_Schema',1);

SELECT * FROM Schema_Analysis_;

SELECT
      schema_id,
      schema_name,
      violation_count,
CASE
    WHEN violation_count = 0 THEN 'No Violation'
    WHEN violation_count BETWEEN 1 AND 2 THEN 'Minor Violation'
    ELSE 'Critical Violation'
END AS Violation_category
FROM Schema_Analysis_;


ALTER TABLE Schema_Analysis_
ADD Status VARCHAR(100);
UPDATE Schema_Analysis_
SET Status = CASE

           WHEN violation_count = 0 THEN 'APPROVED'
           
           WHEN violation_count BETWEEN 1 AND 2 THEN 'REVIEW'
           
           ELSE 'REJECTED'
           
           END;
SELECT * FROM Schema_Analysis_;

DO $$
DECLARE
VAL INT := 2;
BEGIN
IF VAL > 10 THEN

    RAISE NOTICE 'Value greater than 10';

ELSIF VAL BETWEEN 10 AND 50 THEN

    RAISE NOTICE 'Value is between 10 and 50';
    
ELSE
    
    RAISE NOTICE 'Value less than 10'; 
END IF;
END $$;


CREATE TABLE Students_1_(
student_names VARCHAR (100),
student_marks INT
);

CREATE TABLE IF NOT EXISTS students_12(
id SERIAL PRIMARY KEY,
name VARCHAR(100),
marks INTEGER CHECK (marks >= 0 AND marks <= 100),
grade VARCHAR(2)
);


INSERT INTO students_12(name, marks) VALUES ('Anindita', 85);
INSERT INTO students_12(name, marks) VALUES('John', 92);
INSERT INTO students_12(name, marks) VALUES ('Alice', 65);
INSERT INTO students_12(name, marks)VALUES('Bob', 45);
INSERT INTO students_12(name, marks) VALUES('Eve', 78);


DO $$
DECLARE
student_rec RECORD;
student_grade VARCHAR(2);
BEGIN

-- Loop through students and assign grades

FOR student_rec IN SELECT id, name, marks FROM students_12 
LOOP

    
    -- Conditional logic for grades
    
    CASE
    
        WHEN student_rec.marks >= 90 THEN student_grade := 'A+';
        WHEN student_rec.marks >= 80 THEN student_grade := 'A';
        WHEN student_rec.marks >= 70 THEN student_grade := 'B';
        WHEN student_rec.marks >= 60 THEN student_grade := 'C';
        WHEN student_rec.marks >= 50 THEN student_grade := 'D';
        ELSE student_grade := 'F';
        
    END CASE;
	
-- Update grade
UPDATE students_12
SET grade = student_grade
WHERE id = student_rec.id;
RAISE NOTICE 'Student: %, Marks: %, Grade: %', 
student_rec.name, student_rec.marks, student_grade;

END LOOP;
END $$;





