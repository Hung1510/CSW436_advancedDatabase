create database cursor_practice;
use cursor_practice;
DROP TABLE IF EXISTS employee;

CREATE TABLE employee_firstEx (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    department VARCHAR(50),
    salary INT
);
INSERT INTO employee_firstEx (id, name, department, salary) VALUES
(1, 'Alice', 'Sales', 5000),
(2, 'Bob', 'Sales', 6000),
(3, 'Charlie', 'HR', 5500),
(4, 'David', 'IT', 7000),
(5, 'Eva', 'Sales', 4500);

-- Transaction control with Cursor example -
-- • Transfer a bonus of 500.000 to all employees in the Sales department
-- • If any error occurs, rollback the entire transaction
-- drop procedure give_bonus;
DELIMITER $$
CREATE PROCEDURE give_bonus()
BEGIN
 DECLARE done INT DEFAULT 0;
 DECLARE emp_id INT;
 -- Cursor declaration
 DECLARE emp_cursor CURSOR FOR
 SELECT id FROM employee_firstEx WHERE department = 'Sales';
 -- Handler for cursor end
 DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
 -- rollback if error
--  DECLARE EXIT HANDLER FOR SQLEXCEPTION
--     BEGIN
--         ROLLBACK;
--     END;
-- Start transaction
 START TRANSACTION;
 OPEN emp_cursor;
bonus_loop: LOOP
 FETCH emp_cursor INTO emp_id;
 IF done = 1 THEN
 LEAVE bonus_loop;
 END IF;
 -- Update salary
 UPDATE employee
 SET salary = salary +500
 WHERE id = emp_id;
 END LOOP;
 CLOSE emp_cursor;
 -- Commit transaction
 COMMIT;
END$$
DELIMITER ;

CALL give_bonus();
select * from employee_firstEx;


-- Check a table employee with attribute, employee Id, name, salary
-- Task: Create a cursor under a stored procedure, in that you have to fetch all employee record
-- + Display employee name and salary
-- + Close cursor after all rows has been fetched
CREATE TABLE employee_secondEx (
    employee_id INT PRIMARY KEY,
    name VARCHAR(100),
    salary DECIMAL(10,2)
);
INSERT INTO employee_secondEx VALUES
(1, 'Alice', 5000),
(2, 'Bob', 6000),
(3, 'Charlie', 5500);

-- drop procedure display_employee_salary;
DELIMITER $$
CREATE PROCEDURE display_employee_salary()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE emp_name VARCHAR(100);
    DECLARE emp_salary DECIMAL(10,2);
    -- declare cursor
    DECLARE emp_cursor CURSOR FOR
        SELECT name, salary FROM employee_secondEx;
    -- detect end ofc cursor handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN emp_cursor;

    read_loop: LOOP
        FETCH emp_cursor INTO emp_name, emp_salary;

        IF done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Display name and salary
        SELECT emp_name AS Employee_Name,
               emp_salary AS Salary;
    END LOOP;

    CLOSE emp_cursor;
END$$

DELIMITER ;

CALL display_employee_salary();
