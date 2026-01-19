CREATE DATABASE Lab2;
USE Lab2;

CREATE TABLE Student (
student_id INT NOT NULL,
name VARCHAR(50) NOT NULL,
department VARCHAR(50),
year INT,
PRIMARY KEY (student_id)
);

CREATE TABLE Course(
course_id INT NOT NULL,
course_name VARCHAR(50) NOT NULL,
department VARCHAR(50),
credits INT,
PRIMARY KEY(course_id)
);

CREATE TABLE Enrollment(
student_id INT,
course_id INT,
semester INT,
FOREIGN KEY(student_id) REFERENCES Student(student_id),
FOREIGN KEY(course_id) REFERENCES Course(course_id)
);

INSERT INTO Student (student_id, name, department, year) VALUES
(1, 'Typhon', 'CSE', 2),
(2, 'Eblana', 'CSE', 3),
(3, 'Elbanana', 'CSE', 1),
(4, 'Fangyi', 'CSE', 4),
(5, 'Perlica', 'ECE', 2),
(6, 'Chen', 'ECE', 3),
(7, 'Lavaetain', 'ECE', 1),
(8, 'Fluorite', 'ECE', 4),
(9, 'Nearl', 'BBS', 2),
(10, 'Lapipi', 'BBS', 3),
(11, 'Kalstit', 'BBS', 1),
(12, 'Amiya', 'BBS', 2),
(13, 'Hoolheyak', 'CSE', 2),
(14, 'Muelseye', 'CSE', 3),
(15, 'Dorothy', 'CSE', 1),
(16, 'Saria', 'CSE', 4);
-- 16 tset

INSERT INTO Course (course_id, course_name, department, credits) VALUES
(101, 'Programming', 'CSE', 4),
(102, 'Database', 'CSE', 3),
(103, 'Backend', 'CSE', 3),
(104, 'Frontend', 'CSE', 4),
(105, 'Signals', 'ECE', 3),
(106, 'Mechanics', 'ECE', 3),
(107, 'Thermodynamics', 'ECE', 4),
(108, 'Electronics', 'ECE', 3),
(109, 'BBS course 1', 'BBS', 3),
(110, 'BBS course 2', 'BBS', 3),
(111, 'BBS course 3', 'BBS', 3),
(112, 'BBS course 4', 'BBS', 4);
-- 12 test

INSERT INTO Enrollment (student_id, course_id, semester) VALUES
(1, 101, 1),  -- Typhon - Programming
(1, 102, 1),  -- Typhon - Database
(2, 102, 1),  -- Eblana - Database
(2, 103, 2),  -- Eblana - Backend
(3, 103, 2),  -- Elbanana - Backend
(3, 104, 3),  -- Elbanana - Frontend
(4, 104, 4),  -- Fangyi - Frontend
(5, 105, 3),  -- Perlica - Signals
(5, 106, 2),  -- Perlica - Mechanics
(5, 107, 3),  -- Perlica - Thermodynamics
(6, 105, 1),  -- Chen - Signals
(6, 106, 1),  -- Chen - Mechanics
(7, 107, 2),  -- Lavaetain - Thermodynamics
(8, 107, 3),  -- Fluorite - Thermodynamics
(8, 108, 1),  -- Fluorite - Electronics
(9, 109, 3),  -- Nearl - BBS course 1
(10, 109, 2), -- Lapipi - BBS course 1
(10, 111, 2), -- Lapipi - BBS course 3 
(11, 110, 1), -- Kalstit - BBS course 2
(11, 110, 1), -- Kalstit - BBS course 2
(12, 112, 3), -- Amiya - BBS course 4
(12, 111, 3), -- Amiya - BBS course 3
(13, 101, 1),  -- Hoolheyak - Programming
(13, 103, 2),  -- Hoolheyak - Backend
(14, 104, 3),  -- Muelseye - Frontend
(14, 102, 1),  -- Muelseye - Database
(15, 102, 1),  -- Dorothy - Database
(15, 103, 2),  -- Dorothy - Backend
(16, 104, 4);  -- Saria - Frontend
-- 29 test

-- Question 2

Select * from Student;
Select * from Course;
Select * from Enrollment;

-- students enrolled in any course
SELECT DISTINCT s.name AS student_name
FROM Student s
WHERE s.student_id IN (SELECT student_id FROM Enrollment);


-- Question 3:

--  INNER JOIN to display: Student name, Course name
SELECT s.name AS student_name, c.course_name
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
INNER JOIN Course c ON e.course_id = c.course_id
ORDER BY s.name, c.course_name;


-- Question 4
EXPLAIN SELECT s.name AS student_name, c.course_name
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
INNER JOIN Course c ON e.course_id = c.course_id
ORDER BY s.name, c.course_name;

EXPLAIN ANALYZE SELECT s.name AS student_name, c.course_name
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
INNER JOIN Course c ON e.course_id = c.course_id
ORDER BY s.name, c.course_name;


-- Question 5 display the names of students enrolled in courses offered by the CSE

SELECT DISTINCT s.name AS student_name
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
INNER JOIN Course c ON e.course_id = c.course_id
WHERE c.department = 'CSE'
ORDER BY s.name;

--  EXPLAIN to observe pipelining of operations
EXPLAIN SELECT DISTINCT s.name AS student_name
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
INNER JOIN Course c ON e.course_id = c.course_id
WHERE c.department = 'CSE'
ORDER BY s.name;


-- Question 6 find students who are enrolled in more than one course

SELECT s.name AS student_name, COUNT(e.course_id) AS courses_enrolled
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
GROUP BY s.student_id, s.name
HAVING COUNT(e.course_id) > 1
ORDER BY courses_enrolled DESC;

-- Use EXPLAIN to analyze the execution plan  ( switch to form editor tfo see)
EXPLAIN 
SELECT s.name AS student_name, COUNT(e.course_id) AS courses_enrolled
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
GROUP BY s.student_id, s.name
HAVING COUNT(e.course_id) > 1
ORDER BY courses_enrolled DESC;

EXPLAIN 
ANALYZE 
SELECT s.name AS student_name, COUNT(e.course_id) AS courses_enrolled
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
GROUP BY s.student_id, s.name
HAVING COUNT(e.course_id) > 1;
-- ORDER BY courses_enrolled DESC;


-- Question 7 Write two equivalent SQL queries to display student names

-- JOIN
SELECT DISTINCT s.name AS student_name
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
ORDER BY s.name;

-- EXPLAIN for JOIN
EXPLAIN SELECT DISTINCT s.name AS student_name
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
ORDER BY s.name;

-- Subquery
SELECT s.name AS student_name
FROM Student s
WHERE s.student_id IN (SELECT student_id FROM Enrollment)
ORDER BY s.name;

-- EXPLAIN for subquery 
EXPLAIN SELECT s.name AS student_name
FROM Student s
WHERE s.student_id IN (SELECT student_id FROM Enrollment)
ORDER BY s.name;


-- Question 8: Create an index on student_id in the ENROLLMENT table
-- Compare the execution cost before and after the index is created

-- join
SELECT s.name AS student_name, c.course_name
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
INNER JOIN Course c ON e.course_id = c.course_id
ORDER BY s.name;

EXPLAIN analyze SELECT s.name AS student_name, c.course_name
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
INNER JOIN Course c ON e.course_id = c.course_id
ORDER BY s.name;

-- Create index
CREATE INDEX index_enrollment_studentId ON Enrollment(student_id);

-- EXPLAIN
EXPLAIN analyze SELECT s.name AS student_name, c.course_name
FROM Student s
INNER JOIN Enrollment e ON s.student_id = e.student_id
INNER JOIN Course c ON e.course_id = c.course_id
Where  s.student_id =1;
-- View index
SHOW INDEX FROM Enrollment;



-- Question 9: Transaction Control Commands

START TRANSACTION;

-- Insert new enrollment
INSERT INTO Enrollment (student_id, course_id, semester) 
VALUES (1, 103, 3);

-- Display the ENROLLMENT table
SELECT * FROM Enrollment WHERE student_id = 1;

-- SELECT * FROM Enrollment;

-- Rollback transaction
ROLLBACK;

-- Display the table again
SELECT * FROM Enrollment WHERE student_id = 1;
-- SELECT * FROM Enrollment;
START TRANSACTION;

-- Insert value 
INSERT INTO Enrollment (student_id, course_id, semester) 
VALUES (1, 103, 3);

COMMIT;

-- Verify final state
SELECT * FROM Enrollment WHERE student_id = 1;
-- SELECT * FROM Enrollment;

-- EXPLAIN observe query processing of SELECT 
EXPLAIN SELECT * FROM Enrollment WHERE student_id = 1;

EXPLAIN SELECT * FROM Enrollment;