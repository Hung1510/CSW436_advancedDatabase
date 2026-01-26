CREATE DATABASE lab4;
USE lab4;

-- 1.	Create a trigger that prevents inserting an employee record if the salary is less than 20,000.
-- o	Create an employee table if it does not exist.
-- o	Insert at least two valid records.
-- o	Create a BEFORE INSERT trigger to check salary.
-- o	Display a meaningful error message when the salary is invalid.
-- o	Test the trigger with an invalid salary value.
-- drop table employee
CREATE TABLE IF NOT EXISTS employee (
    emp_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_name VARCHAR(50),
    salary INT
);
INSERT INTO employee (emp_name, salary) VALUES
('Fangyi', 30000),
('Wulfgard', 25000);
SELECT * FROM employee;

-- drop trigger before_insert;
DELIMITER $$
CREATE TRIGGER before_insert
BEFORE INSERT ON employee 
FOR EACH ROW
BEGIN
    IF NEW.salary < 20000 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must > 20000';
    END IF;
END$$
DELIMITER ;

-- test invalid
INSERT INTO employee (emp_name, salary)VALUES 
('RandomGuy1', 15000);


-- 2.	Create a trigger that prevents updating product quantity to zero or negative value. (Trigger to Maintain Stock Quantity)
-- o	Create a product table if it does not exist.
-- o	Insert sample records.
-- o	Create a BEFORE UPDATE trigger to validate quantity.
-- o	Display an error message if quantity is less than 1.
-- o	Test the trigger using an UPDATE statement.
-- drop table product
CREATE TABLE IF NOT EXISTS product (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(50),
    quantity INT NOT NULL
);
INSERT INTO product (product_name, quantity) VALUES 
('Laptop', 10), 
('Keyboard', 20);
SELECT * FROM product;

-- drop trigger product_before_update;
DELIMITER $$
CREATE TRIGGER product_before_update
BEFORE UPDATE ON product
FOR EACH ROW
BEGIN
    IF NEW.quantity < 1 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity cannot be less than 1';
    END IF;
END$$
DELIMITER ;

-- test
UPDATE product
SET quantity = 0
WHERE product_name = 'Laptop';


-- 3.	Create a trigger that automatically records update operations on a student table into a student_log table.
-- o	Create both tables if they do not exist.
-- o	Insert sample data into the student table.
-- o	Create an AFTER UPDATE trigger to store old and new values.
-- o	Update a record and display the log table.
-- drop table student
CREATE TABLE IF NOT EXISTS student (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    marks INT
);
-- drop table student_log
CREATE TABLE IF NOT EXISTS student_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    old_marks INT,
    new_marks INT,
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO student (name, marks) VALUES 
('Pogranichnik', 70),
('Alesh', 80);
SELECT * FROM student;

-- drop trigger check_price;
DELIMITER $$
CREATE TRIGGER check_price
AFTER UPDATE ON student
FOR EACH ROW
BEGIN
    INSERT INTO student_log (student_id, old_marks, new_marks)
    VALUES (OLD.student_id, OLD.marks, NEW.marks);
END$$
DELIMITER ;

-- test ( wont work cauase no laevetain
UPDATE student
SET marks = 90
WHERE name = 'laevetain';

-- test (work cause there is alesh)
UPDATE student
SET marks = 90
WHERE name = 'Alesh';
SELECT * FROM student_log;

-- 4.	Create a trigger that prevents inserting duplicate email addresses into a user’s table.
-- o	Create the users table if it does not exist.
-- o	Insert initial user data.
-- o	Create a BEFORE INSERT trigger to check for duplicate emails.
-- o	Display a meaningful error message when a duplicate email is inserted.
-- o	Test the trigger with duplicate data.
-- drop table users
CREATE TABLE IF NOT EXISTS users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50),
    email VARCHAR(100)
);
INSERT INTO users (username, Email) VALUES 
('Admin', 'admin@gmail.com');
SELECT * FROM users;

-- drop trigger beforer_insert;
DELIMITER $$
CREATE TRIGGER beforer_insert
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM users WHERE email = NEW.email) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email already exists';
    END IF;
END$$
DELIMITER ;

-- test
INSERT INTO users (username, Email) VALUES 
('User1', 'admin@gmail.com');


-- 5.	Create a trigger that prevents inserting a student record if age is less than 18.
-- o	Create a student table if it does not exist.
-- o	Insert valid student records.
-- o	Create a BEFORE INSERT trigger using SIGNAL for error handling.
-- o	Display a custom error message if age is invalid.
-- o	Test the trigger with age less than 18.
-- drop table student_age
CREATE TABLE IF NOT EXISTS student_age (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    age INT
);
INSERT INTO student_age (name, age) VALUES 
('Perlica', 20), 
('Endmin', 22);
SELECT * FROM student_age;

-- drop trigger before_age_insert;
DELIMITER $$
CREATE TRIGGER before_age_insert
BEFORE INSERT ON student_age
FOR EACH ROW
BEGIN
    IF NEW.aGe < 18 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Student age must be > 18';
    END IF;
END$$
DELIMITER ;

-- test 
INSERT INTO student_age (name, age) VALUES 
('RandomGuy2', 16);
