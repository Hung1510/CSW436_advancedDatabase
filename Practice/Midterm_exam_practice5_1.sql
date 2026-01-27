CREATE DATABASE sql_practice;
USE sql_practice;

-- drop table Student
CREATE TABLE Student (
    snum INT PRIMARY KEY,
    sname VARCHAR(50),
    major VARCHAR(50),
    level VARCHAR(50),
    age INT
);

-- drop table Faculty
CREATE TABLE Faculty (
    fid INT PRIMARY KEY,
    fname VARCHAR(50),
    deptid INT
);

-- drop table Class
CREATE TABLE Class (
    cname VARCHAR(50) PRIMARY KEY,
    meets_at TIME,
    room VARCHAR(50),
    fid INT,
    FOREIGN KEY (fid) REFERENCES Faculty(fid)
);

-- drop table Enrolled
CREATE TABLE Enrolled (
    snum INT,
    cname VARCHAR(50),
    PRIMARY KEY (snum, cname),
    FOREIGN KEY (snum) REFERENCES Student(snum),
    FOREIGN KEY (cname) REFERENCES Class(cname)
);

INSERT INTO Faculty VALUES
(1, 'I. Teach', 10),
(2, 'A. Smith', 20),
(3, 'B. Johnson', 30);

INSERT INTO Student VALUES
(101, 'Alice', 'History', 'JR', 20),
(102, 'Bob', 'CS', 'SR', 22),
(103, 'Carol', 'Math', 'FR', 18),
(104, 'David', 'History', 'JR', 21),
(105, 'Eve', 'CS', 'SO', 19),
(106, 'Frank', 'Math', 'FR', 18);

INSERT INTO Class VALUES
('DB', '09:00:00', 'R128', 1),
('OS', '10:00:00', 'R128', 1),
('Math1', '09:00:00', 'R200', 2),
('History1', '11:00:00', 'R300', 3);

INSERT INTO Enrolled VALUES
(101, 'DB'),
(101, 'OS'),
(102, 'DB'),
(103, 'Math1'),
(104, 'History1'),
(105, 'DB'),
(106, 'Math1');

-- question 1
-- find name of all junior enroll in I.Teach class
SELECT DISTINCT s.sname
FROM Student s
JOIN Enrolled e ON s.snum = e.snum
JOIN Class c ON e.cname = c.cname
JOIN Faculty f ON c.fid = f.fid
WHERE s.level = 'JR'
AND f.fname = 'I. Teach';


-- question 2
-- FInd oldest age in either History class or in I.Teach class
SELECT MAX(s.age) AS oldest_age
FROM Student s
WHERE s.major = 'History'
   OR s.snum IN (
       SELECT e.snum
       FROM Enrolled e
       JOIN Class c ON e.cname = c.cname
       JOIN Faculty f ON c.fid = f.fid
       WHERE f.fname = 'I. Teach'
   );


-- question 3
-- find name of all classes in room R128 or have 5 or above student
SELECT DISTINCT c.cname
FROM Class c
LEFT JOIN Enrolled e ON c.cname = e.cname
GROUP BY c.cname, c.room
HAVING c.room = 'R128'
OR COUNT(e.snum) >= 5;


-- question 4
-- find name of all student enroll in 2 class that met at the same time
-- test for question 4
INSERT INTO Class VALUES
('AI', '09:00:00', 'R400', 2),
('Networks', '10:00:00', 'R500', 3);
INSERT INTO Enrolled VALUES
(101, 'AI'),
(102, 'OS'),
(102, 'Networks');

SELECT DISTINCT s.sname
FROM Student s
JOIN Enrolled e1 ON s.snum = e1.snum
JOIN Enrolled e2 ON s.snum = e2.snum
JOIN Class c1 ON e1.cname = c1.cname
JOIN Class c2 ON e2.cname = c2.cname
WHERE e1.cname <> e2.cname
AND c1.meets_at = c2.meets_at;


-- question 5
-- find name of faculty memeber who teach in every room in which some class is taught
SELECT f.fname
FROM Faculty f
WHERE NOT EXISTS (
    SELECT DISTINCT c1.room
    FROM Class c1
    WHERE NOT EXISTS (
	SELECT *
	FROM Class c2
	WHERE c2.fid = f.fid
	AND c2.room = c1.room
    )
);


-- question 6
-- find name of facultgy member whom combine enrollment of the course is <5
SELECT f.fname
FROM Faculty f
LEFT JOIN Class c ON f.fid = c.fid
LEFT JOIN Enrolled e ON c.cname = e.cname
GROUP BY f.fid, f.fname
HAVING COUNT(e.snum) < 5;


-- question 7
-- print level and average age for that level, for each level
SELECT level, AVG(age) AS avg_age
FROM Student
GROUP BY level;


-- question 8
-- print level and average age for that level, for each level except for junior (JR)
SELECT level, AVG(age) AS avg_age
FROM Student
WHERE level <> 'JR'
GROUP BY level;


-- question 9
-- for faculty member teach in only room r128, print name  and total number of classes taught
SELECT f.fname, COUNT(c.cname) AS total_classes
FROM Faculty f
JOIN Class c ON f.fid = c.fid
GROUP BY f.fid, f.fname
HAVING SUM(c.room <> 'R128') = 0;


-- question 10
-- find name ofc studwent enroll in maximum of class
SELECT s.sname
FROM Student s
JOIN Enrolled e ON s.snum = e.snum
GROUP BY s.snum, s.sname
HAVING COUNT(e.cname) = (
    SELECT MAX(cnt)
    FROM (
	SELECT COUNT(*) AS cnt
	FROM Enrolled
	GROUP BY snum
    ) t
);



-- question 11
-- find studnet name not enroll inc any class
SELECT s.sname
FROM Student s
LEFT JOIN Enrolled e ON s.snum = e.snum
WHERE e.snum IS NULL;




-- question 12
-- for each age value that appear in student, find level value taht appear most often
SELECT age, level
FROM Student s1
WHERE (
    SELECT COUNT(*)
    FROM Student s2
    WHERE s2.age = s1.age
	AND s2.level = s1.level
) = (
    SELECT MAX(cnt)
    FROM (
	SELECT COUNT(*) AS cnt
	FROM Student s3
	WHERE s3.age = s1.age
	GROUP BY s3.level
    ) t
)
GROUP BY age, level;