create database usecase_application;
use usecase_application;

-- drop table customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    email VARCHAR(50)
);
-- drop table products
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    price DECIMAL(15,2),
    stock_quantity INT
);
-- drop table orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(15,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
-- drop table order_items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    item_price DECIMAL(15,2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);
-- drop table order_audit
CREATE TABLE order_audit (
    audit_id INT PRIMARY KEY,
    order_id INT,
    action VARCHAR(50),
    action_date DATETIME
);
-- drop table error_log
CREATE TABLE error_log (
    error_id INT PRIMARY KEY,
    error_message VARCHAR(255),
    error_time DATETIME
);

INSERT INTO customers VALUES
(1, 'Fangyi', 'a@gmail.com'),
(2, 'Laevetain', 'b@gmail.com'),
(3, 'Lifang', 'c@gmail.com');

INSERT INTO products VALUES
(1, 'Laptop', 1500, 10),
(2, 'Mouse', 20, 50),
(3, 'Keyboard', 45, 30);

INSERT INTO orders VALUES
(1, 1, '2026-01-20', 1540),
(2, 2, '2026-01-21', 45);

INSERT INTO order_items VALUES
(1, 1, 1, 1, 1500),
(2, 1, 2, 2, 40),
(3, 2, 3, 1, 45);

INSERT INTO order_audit VALUES
(1, 1, 'ORDER CREATED', NOW()),
(2, 2, 'ORDER CREATED', NOW());

INSERT INTO error_log VALUES
(1, 'Insufficient stock for product_id = 1', NOW());

-- Orders with customer info
SELECT *
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id;
-- Order details (order + items + products)
SELECT *
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- Task 1: Query Processing & Optimization
-- 1. Write a query to retrieve:
-- o All orders placed by a specific customer
-- o Include customer name and total order amount
-- 2. Analyze the query using EXPLAIN.
-- 3. Create suitable indexes to optimize the query and compare execution plans before and
-- after indexing.

-- q1
SELECT c.customer_name, o.order_id, o.order_date, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id = 1;

-- q2
EXPLAIN analyze
SELECT c.customer_name, o.order_id, o.order_date, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE c.customer_id = 1;

-- q3
CREATE INDEX idx_orders_customer ON orders(customer_id);


-- Task 2: User-Defined Function
-- Create a function named calculate_order_total that:
-- • Accepts an order_id
-- • Returns the total amount of the order based on order items
DELIMITER $$
CREATE FUNCTION calculate_order_total(p_order_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT SUM(quantity * item_price)
    INTO total
    FROM order_items
    WHERE order_id = p_order_id;
    RETURN IFNULL(total, 0);
END$$
DELIMITER ;

SELECT calculate_order_total(1);


-- Task 3: Trigger Implementation
-- 1. Create a BEFORE INSERT trigger on order_items that:
-- o Prevents inserting an order item if sufficient stock is not available
-- 2. Create an AFTER INSERT trigger on orders that:
-- o Logs the order creation into the order_audit table

-- q1
DELIMITER $$
CREATE TRIGGER before_order_item_insert
BEFORE INSERT ON order_items
FOR EACH ROW
BEGIN
    DECLARE available_stock INT;
    SELECT stock_quantity
    INTO available_stock
    FROM products
    WHERE product_id = NEW.product_id;
    IF available_stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;
END$$
DELIMITER ;
-- test
SELECT * FROM products;
-- vadlid insert
INSERT INTO order_items
VALUES (10, 1, 1, 2, 1500);
SELECT * FROM order_items WHERE order_item_id = 10;

-- invalid insert
INSERT INTO order_items
VALUES (11, 1, 1, 100, 1500);


-- q2
DELIMITER $$
CREATE TRIGGER after_order_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    INSERT INTO order_audit VALUES (
	(SELECT IFNULL(MAX(audit_id),0)+1 FROM order_audit),
	NEW.order_id,
	'ORDER CREATED',NOW()
    );
END$$
DELIMITER ;
-- test 
INSERT INTO orders
VALUES (5, 2, CURDATE(), 0);
SELECT * FROM order_audit WHERE order_id = 5;


-- Task 4: Stored Procedure with Transaction & Cursor
-- Create a stored procedure named process_order that performs the following:
-- Inputs:
-- • customer_id
-- • list of product IDs and quantities (The temporary table is already populated before
-- calling the procedure)
-- Procedure Requirements:
-- 1. Start a transaction
-- 2. Insert a new record into the orders table
-- 3. Use a cursor to:
-- o Iterate through each product in the order
-- o Insert records into order_items
-- o Update stock in the products table
-- 4. Calculate the total order amount using the function created earlier
-- 5. Update the total amount in the orders table
-- 6. Commit the transaction if all operations succeed

-- temprary table and data
CREATE TEMPORARY TABLE temp_order_items (
    order_item_id INT,
    product_id INT,
    quantity INT
);

INSERT INTO temp_order_items VALUES
(1, 1, 1),   -- 1 Laptop
(2, 2, 2),   -- 2 Mouse
(3, 3, 1),   -- 1 Keyboard
(4, 2, 5),   -- 5 Mouse
(5, 1, 2),   -- 2 Laptop
(6, 3, 3);   -- 3 Keyboard
SELECT * FROM temp_order_items;

DELIMITER $$
CREATE PROCEDURE process_order(IN p_order_id INT, IN p_customer_id INT)
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_product_id INT;
    DECLARE v_quantity INT;

    DECLARE cur CURSOR FOR
        SELECT product_id, quantity FROM temp_order_items;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        INSERT INTO error_log VALUES (
		(SELECT IFNULL(MAX(error_id),0)+1 FROM error_log),
		'Error while processing order', NOW()
        );
    END;
    -- q1
    START TRANSACTION;
    -- q2
    INSERT INTO orders VALUES (p_order_id, p_customer_id, CURDATE(), 0);
    -- q3
    OPEN cur;
    read_loop: LOOP
        FETCH cur INTO v_product_id, v_quantity;
        IF done = 1 THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO order_items VALUES (
        -- q4
            (SELECT IFNULL(MAX(order_item_id),0)+1 FROM order_items),
            p_order_id,
            v_product_id,
            v_quantity,
            (SELECT price FROM products WHERE product_id = v_product_id)
        );
        UPDATE products
        SET stock_quantity = stock_quantity - v_quantity
        WHERE product_id = v_product_id;
    END LOOP;
    CLOSE cur;

    -- q5 update total amount
    UPDATE orders
    SET total_amount = calculate_order_total(p_order_id)
    WHERE order_id = p_order_id;
    -- q6
    COMMIT;
END$$
DELIMITER ;

-- Task 5: Error Handling
-- 1. Implement exception handling using:
-- o DECLARE HANDLER
-- o SIGNAL or RESIGNAL
-- 2. If any error occurs:
-- o Roll back the transaction
-- o Insert error details into the error_log table
-- o Display a meaningful error message
SELECT * FROM error_log;



-- Task 6: Transaction Control
-- 1. Demonstrate the use of:
-- o START TRANSACTION
-- o COMMIT
-- o ROLLBACK
-- 2. Explain how ACID properties are maintained in your solution.

-- q1
-- Commit
START TRANSACTION;
INSERT INTO orders VALUES (20, 1, CURDATE(), 0);
INSERT INTO order_items VALUES (20, 20, 1, 1, 1500);
COMMIT;

-- Rollback
START TRANSACTION;
INSERT INTO orders VALUES (21, 1, CURDATE(), 0);
-- This will fail if stock is insufficient
INSERT INTO order_items VALUES (21, 21, 1, 100, 1500);
ROLLBACK;


-- q2
START TRANSACTION;
COMMIT;
ROLLBACK;


-- Task 7: Testing & Validation
-- 1. Insert sample data into all tables
-- 2. Execute the stored procedure for:
-- o A valid order
-- o An order with insufficient stock
-- 3. Observe:
-- o Trigger execution
-- o Transaction rollback
-- o Error logging

-- q1
-- q2
-- q3
CALL process_order(3, 1);
-- invalid order
-- temp_order_items has quantity > stock
CALL process_order(4, 2);
