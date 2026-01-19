create database lab3;
use lab3;

-- drop table user
create table user(
Id int not null,
name varchar(50),
balance double(15,2)
);

insert into user(Id, name,balance) values
( 1,'magal',500),
( 2, 'typhon',600),
( 3,'Perlica',700),
( 4, 'Fangyi',800);
select * from user;

-- Local Stored Procedure is a temporary stored procedure.
-- It is created inside a session and exists only for that session.
-- It is automatically deleted when the session ends.
-- Name starts with # (example: #MyProcedure).
-- Used for temporary tasks, testing, or intermediate calculations
-- Ex:
-- fixed number addnumber
DELIMITER $$
CREATE PROCEDURE addNumber()
BEGIN
 DECLARE a INT DEFAULT 10;
 DECLARE b INT DEFAULT 20;
 DECLARE sum INT;
 SET sum = a + b;
 SELECT sum AS Result;
END $$
DELIMITER ;
call addNumber();

-- Advanced SQL Programming : Stored procedures
-- A Stored Procedure is a precompiled collection of SQL statements stored in the database.
-- It is executed as a single unit to perform specific tasks (CRUD operations, business logic).
-- Stored procedures accept input parameters and can return output values.
-- Commonly used in databases like MySQL, SQL Server, Oracle, PostgreSQL.
-- Contain control flow statements (IF, WHILE, etc.)
-- Modify database state
-- It accept Reusability (Write once, use multiple times.)
-- It is used for such as Transaction control, Executing sequence of statements, Data modification
-- Each parameter is an IN parameter by default. To specify otherwise for a parameter, use
-- the keyword OUT or INOUT before the parameter name.


-- Advanced SQL Programming : When to Use Stored Procedures
-- Complex Operations: When you need to perform a series of SQL operations as a single unit.
-- Data Integrity: For operations that require multiple steps to maintain data consistency.
-- Security: To restrict direct access to tables and provide a controlled interface to the data.
-- Performance: To reduce network traffic by sending only the call to the procedure instead of
-- multiple SQL statements.
-- Maintenance: When you want to centralize business logic for easier updates and
-- maintenance.
-- Example -

DELIMITER $$
CREATE PROCEDURE get_students()
BEGIN
 SELECT * FROM student;
END $$
DELIMITER ;
call get_students();



-- input output addnumber
drop procedure AddNumbers;
DELIMITER $$
CREATE PROCEDURE AddNumbers(in a int, in b int, out sum int)
BEGIN
--  DECLARE a INT DEFAULT 10;
--  DECLARE b INT DEFAULT 20;
--  DECLARE sum INT;
 SET sum = a + b;
--  SELECT sum AS Result;
END $$
DELIMITER ;

set @sum=0;
call AddNumbers(10,35,@sum);
select @sum as result;


-- Selecting highest balance output from user table 

-- compare the highest balance compare to input
DELIMITER $$
CREATE PROCEDURE get_high_balance(IN min DOUBLE(15,2), OUT max DOUBLE(15,2))
BEGIN
    SELECT MAX(balance) INTO max
    FROM user
    WHERE balance > min;
END $$
DELIMITER ;

SET @max = 0;
CALL get_high_balance(600, @max);
SELECT @max AS Highest_Balance;


-- Assignment
-- Create a stored procedure named checkEvenOdd that:
-- Takes one IN parameter (an integer number)
-- Uses one OUT parameter to return: "Even" if the number is even and "Odd" if the number is odd

-- drop procedure checkEvenOdd;
Delimiter $$
Create procedure checkEvenOdd( in input int, out res varchar(50))
BEGIN
    IF input % 2 = 0 THEN
	SET res = 'Even';
    ELSE
	SET res = 'Odd';
    END IF;
END$$
DELIMITER ;

CALL checkEvenOdd(7, @res);
SELECT @res;


-- function
-- A Function returns a single value
-- Must return a value using RETURN
-- Commonly used in: SELECT statements , Calculations and data formatting
-- Cannot modify database data (in most DBs)
-- Example. - Calculating tax, age, or total price

DELIMITER $$
CREATE FUNCTION emp_name_max_salary() RETURNS VARCHAR(50)
DETERMINISTIC NO SQL READS SQL DATA
BEGIN
DECLARE V_max INT;
DECLARE V_emp_name VARCHAR (50) ;
SELECT MAX(salary) into v_max FROM employees;
SELECT fame into v_emp_name FROM employees WHERE salary=v_max;
return v_emp_name;
END$$
DELIMITER;

SELECT emp_name_max_salary();
Name of the employee who has
highest salary
