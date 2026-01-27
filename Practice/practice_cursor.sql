create database cursor_practice;
use cursor_practice;
-- Create a table Order, Id, customer name, order amount
-- write stored procedure order cursor in which 
-- + Iterate through all order
-- + Increase order amount by 10% for order below 500000 vnd

CREATE TABLE Orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100),
    order_amount DECIMAL(15,2)
);

INSERT INTO Orders (customer_name, order_amount) VALUES
('Mlynar', 300000),
('Nearl', 700000),
('Kjera', 450000),
('RandomGuy1', 900000);

-- DROP TABLE Orders;
-- DROP PROCEDURE update_order_amount;
DELIMITER $$
CREATE PROCEDURE update_order_amount()
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_order_id INT;
    DECLARE v_order_amount DECIMAL(15,2);

    -- Cursor declare
    DECLARE order_cursor CURSOR FOR
        SELECT order_id, order_amount FROM Orders;

    -- Handler for cursor end
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Rollback if error
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;
    OPEN order_cursor;
    order_loop: LOOP
        FETCH order_cursor INTO v_order_id, v_order_amount;
        IF done = 1 THEN
            LEAVE order_loop;
        END IF;

        -- Increase order amount by 10% if below 500000
        IF v_order_amount < 500000 THEN
            UPDATE Orders
            SET order_amount = order_amount * 1.10
            WHERE order_id = v_order_id;
        END IF;
    END LOOP;
    CLOSE order_cursor;
    COMMIT;
END$$
DELIMITER ;

CALL update_order_amount();
SELECT * FROM Orders;
