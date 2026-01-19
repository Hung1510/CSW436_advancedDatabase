CREATE DATABASE IF NOT EXISTS lab3;
USE lab3;

-- 1.	Create a stored procedure named getTodayDate that:
-- •	Uses no IN parameters
-- •	Uses one OUT parameter to return the current system date
DELIMITER $$
CREATE PROCEDURE GetTodayDate(OUT Current_date_param DATE)
BEGIN
    SET Current_date_param = CURDATE();
END $$
DELIMITER ;

CALL GetTodayDate(@today);
SELECT @today AS Today_Date;
drop table Student;

-- 2.	Create a stored procedure named checkEvenOdd that:
-- •	Takes one IN parameter (an integer number)
-- •	Uses one OUT parameter to return:
-- o	"Even" if the number is even
-- o	"Odd" if the number is odd
DELIMITER $$
CREATE PROCEDURE CheckEvenOdd(IN num INT, OUT Result VARCHAR(10))
BEGIN
    IF num % 2 = 0 THEN
        SET Result = 'Even';
    ELSE
        SET Result = 'Odd';
    END IF;
END $$
DELIMITER ;

CALL checkEvenOdd(10, @res);
SELECT @res;
CALL checkEvenOdd(7, @res);
SELECT @res;

-- 3.	Write an SQL statement to create a table named students with the following columns: 
-- •	student_id (INT, Primary Key, Auto Increment)
-- •	name (VARCHAR(50))
-- •	marks (INT). 
CREATE TABLE IF NOT EXISTS Student (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    marks INT NOT NULL
);
INSERT INTO Student (name, marks) VALUES
('wulfgard', 90),
('Pogranichnik', 50),
('Mifu', 80),
('Tangtang', 60);
select * from Student;

-- 4.	Write a stored procedure named addStudent that: 
-- •	Accepts IN parameters for name and marks.
-- •	Inserts a new student record into the students table.
-- drop PROCEDURE addStudent;
DELIMITER $$
CREATE PROCEDURE addStudent(IN studentName VARCHAR(50), IN studentMarks INT)
BEGIN
    INSERT INTO Student VALUES (null,studentName, studentMarks);
END $$
DELIMITER ;

CALL addStudent('huichieh', 100);
select * from Student;


-- 5.	Write a stored procedure named getStudentById that: 
-- •	Accepts one IN parameter (student_id). 
-- •	Displays the name and marks of the student with the given ID
-- drop PROCEDURE getStudentById;
DELIMITER $$
CREATE PROCEDURE getStudentById(IN id INT)
BEGIN
    SELECT name, marks
    FROM Student
    WHERE student_id = id;
END $$
DELIMITER ;

CALL getStudentById(2);


-- 6.	Write a stored procedure named getTotalStudents that: 
-- •	Uses one OUT parameter. 
-- •	Returns the total number of students present in the students table.

DELIMITER $$
CREATE PROCEDURE getTotalStudents(OUT totalStudents INT)
BEGIN
    SELECT COUNT(*) INTO totalStudents
    FROM Student;
END $$
DELIMITER ;

CALL getTotalStudents(@total);
SELECT @total AS Total_Students;


-- 7.	Write a stored procedure named getResultStatus that: 
-- •	Accepts one IN parameter (student_id). 
-- •	Uses one OUT parameter to return: "Pass" if marks ≥ 40 and "Fail" if marks < 40.

DELIMITER $$
CREATE PROCEDURE getResultStatus(IN id INT, OUT resultStatus VARCHAR(10))
BEGIN
    DECLARE studentMarks INT;

    SELECT marks INTO studentMarks
    FROM Student
    WHERE student_id = id;

    IF studentMarks >= 40 THEN
        SET resultStatus = 'Pass';
    ELSE
        SET resultStatus = 'Fail';
    END IF;
END $$
DELIMITER ;

CALL getResultStatus(1, @status);
SELECT @status AS Result;
-- create 1 more student with fail condition
CALL addStudent('pramanix', 39);
select * from Student;
CALL getResultStatus(6, @status);
SELECT @status AS Result;

-- 8.	Write a stored procedure named updateMarks that: 
-- •	Accepts IN parameters (student_id, new_marks). 
-- •	Updates the marks of the specified student.
DELIMITER $$
CREATE PROCEDURE updateMarks(IN id INT, IN newMark INT)
BEGIN
    UPDATE Student
    SET marks = newMark
    WHERE student_id = id;
END $$
DELIMITER ;

CALL updateMarks(1, 75);
SELECT * FROM Student WHERE student_id = 1;


-- 9.	Write a stored procedure named deleteStudent that: 
-- •	Accepts one IN parameter (student_id). 
-- •	Deletes the student record with the given ID from the table.
DELIMITER $$
CREATE PROCEDURE deleteStudent(IN id INT)
BEGIN
    DELETE FROM Student
    WHERE student_id = id;
END $$
DELIMITER ;

CALL deleteStudent(5);
SELECT * FROM Student;


-- 10.	Write a function to calculate grade that:
-- •	Accepts marks as input
-- •	Returns:
-- o	'A' if marks ≥ 80
-- o	'B' if marks ≥ 60
-- o	'C' if marks ≥ 40
-- o	‘F' if marks < 40
DELIMITER $$
CREATE FUNCTION calculateGrade(marks INT)
RETURNS CHAR(1) DETERMINISTIC
BEGIN
    DECLARE grade CHAR(1);
    IF marks >= 80 THEN
        SET grade = 'A';
    ELSEIF marks >= 60 THEN
        SET grade = 'B';
    ELSEIF marks >= 40 THEN
        SET grade = 'C';
    ELSE
        SET grade = 'F';
    END IF;
    RETURN grade;
END $$
DELIMITER ;

SELECT calculateGrade(85) AS Grade;  -- A
SELECT calculateGrade(65) AS Grade;  -- B
SELECT calculateGrade(45) AS Grade;  -- C
SELECT calculateGrade(30) AS Grade;  -- F


-- 11.	Write a function named checkPassFail that used to return Pass or Fail
-- o	Accepts student marks as input
-- o	Returns 'Pass' if marks ≥ 40
-- o	Returns 'Fail' if marks < 40

-- hardset 
-- DELIMITER $$
-- CREATE FUNCTION checkPassFail(marks INT)
-- RETURNS VARCHAR(10) DETERMINISTIC
-- BEGIN
--     IF marks >= 40 THEN
--         RETURN 'Pass';
--     ELSE
--         RETURN 'Fail';
--     END IF;
-- END $$
-- DELIMITER ;
-- select * from Student;
-- SELECT checkPassFail(55) AS Result;  -- Pass
-- SELECT checkPassFail(35) AS Result;  -- Fail

DELIMITER $$
CREATE FUNCTION checkPassFailById(id INT)
RETURNS VARCHAR(10) DETERMINISTIC
BEGIN
    DECLARE studentMarks INT;
    SELECT marks
    INTO studentMarks
    FROM Student
    WHERE student_id = id;
    IF studentMarks >= 40 THEN
        RETURN 'Pass';
    ELSE
        RETURN 'Fail';
    END IF;
END $$
DELIMITER ;

SELECT student_id, name, marks, checkPassFailById(student_id) AS Result
FROM Student;


-- 12.	Write a function named totalStudents that:
-- o	Returns the total number of records present in the students table
-- drop function totalStudents;
DELIMITER $$
CREATE FUNCTION totalStudents()
RETURNS INT DETERMINISTIC
BEGIN
    DECLARE total INT;
    SELECT COUNT(*) INTO total
    FROM Student;
    RETURN total;
END $$
DELIMITER ;

SELECT totalStudents() AS Total_Students;