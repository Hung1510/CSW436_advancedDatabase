use sql_practice;
-- drop table Suppliers
CREATE TABLE Suppliers (
    sid INT PRIMARY KEY,
    sname VARCHAR(100),
    address VARCHAR(200)
);
-- drop table Parts
CREATE TABLE Parts (
    pid INT PRIMARY KEY,
    pname VARCHAR(100),
    color VARCHAR(20)
);
-- drop table Catalog
CREATE TABLE Catalog (
    sid INT,
    pid INT,
    cost DECIMAL(10,2),
    PRIMARY KEY (sid, pid),
    FOREIGN KEY (sid) REFERENCES Suppliers(sid),
    FOREIGN KEY (pid) REFERENCES Parts(pid)
);

INSERT INTO Suppliers VALUES
(1, 'Acme Widget Suppliers', 'Hanoi'),
(2, 'Best Parts Co', 'Ho Chi Minh City'),
(3, 'Green Supply', 'Da Nang'),
(4, 'Red Only Ltd', 'Hue');

INSERT INTO Parts VALUES
(101, 'Bolt', 'red'),
(102, 'Nut', 'green'),
(103, 'Screw', 'red'),
(104, 'Washer', 'blue');

INSERT INTO Catalog VALUES
-- Acme supplies all parts
(1, 101, 10.00),
(1, 102, 12.00),
(1, 103, 11.00),
(1, 104, 9.00),
-- Best Parts Co supplies red & green
(2, 101, 11.00),
(2, 102, 10.50),
-- Green Supply supplies only green
(3, 102, 9.50),
-- Red Only Ltd supplies only red
(4, 101, 10.80),
(4, 103, 12.50);


-- Q1
SELECT DISTINCT p.pname
FROM Parts p
JOIN Catalog c ON p.pid = c.pid;


-- Q2
SELECT s.sname
FROM Suppliers s
WHERE NOT EXISTS (
    SELECT p.pid
    FROM Parts p
    WHERE NOT EXISTS (
	SELECT *
	FROM Catalog c
	WHERE c.sid = s.sid AND c.pid = p.pid
    )
);


-- Q3
SELECT s.sname
FROM Suppliers s
WHERE NOT EXISTS (
    SELECT p.pid
    FROM Parts p
    WHERE p.color = 'red'
    AND NOT EXISTS (
	SELECT *
	FROM Catalog c
	WHERE c.sid = s.sid AND c.pid = p.pid
    )
);


-- Q4
SELECT p.pname
FROM Parts p
JOIN Catalog c ON p.pid = c.pid
JOIN Suppliers s ON c.sid = s.sid
WHERE s.sname = 'Acme Widget Suppliers'
AND p.pid NOT IN (
    SELECT pid
    FROM Catalog c2
    JOIN Suppliers s2 ON c2.sid = s2.sid
    WHERE s2.sname <> 'Acme Widget Suppliers'
);


-- Q5
SELECT DISTINCT c.sid
FROM Catalog c
WHERE c.cost > (
    SELECT AVG(c2.cost)
    FROM Catalog c2
    WHERE c2.pid = c.pid
);


-- Q6
SELECT p.pname, s.sname
FROM Parts p
JOIN Catalog c ON p.pid = c.pid
JOIN Suppliers s ON c.sid = s.sid
WHERE c.cost = (
    SELECT MAX(c2.cost)
    FROM Catalog c2
    WHERE c2.pid = p.pid
);


-- Q7
SELECT s.sid
FROM Suppliers s
WHERE NOT EXISTS (
    SELECT *
    FROM Catalog c
    JOIN Parts p ON c.pid = p.pid
    WHERE c.sid = s.sid AND p.color <> 'red'
);


-- Q8
SELECT DISTINCT c1.sid
FROM Catalog c1
JOIN Parts p1 ON c1.pid = p1.pid
JOIN Catalog c2 ON c1.sid = c2.sid
JOIN Parts p2 ON c2.pid = p2.pid
WHERE p1.color = 'red'
AND p2.color = 'green';


-- Q9
SELECT DISTINCT c.sid
FROM Catalog c
JOIN Parts p ON c.pid = p.pid
WHERE p.color IN ('red', 'green');


-- Q10
SELECT s.sname, COUNT(c.pid) AS total_parts
FROM Suppliers s
JOIN Catalog c ON s.sid = c.sid
JOIN Parts p ON c.pid = p.pid
GROUP BY s.sid, s.sname
HAVING SUM(p.color <> 'green') = 0;


-- Q11
SELECT s.sname, MAX(c.cost) AS max_price
FROM Suppliers s
JOIN Catalog c ON s.sid = c.sid
JOIN Parts p ON c.pid = p.pid
GROUP BY s.sid, s.sname
HAVING SUM(p.color = 'red') > 0
AND SUM(p.color = 'green') > 0;

