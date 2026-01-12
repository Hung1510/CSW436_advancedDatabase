CREATE DATABASE Lab1;
USE Lab1;

-- DROP DATABASE Lab1; -- delete database to reset test data

-- question 1
CREATE TABLE User_account (
    ID INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Balance DECIMAL(15,2) NOT NULL,
    PRIMARY KEY (ID)
);

INSERT INTO User_account (ID, Name, Balance) VALUES 
(001, 'A', 100000),
(002, 'B', 0);

SELECT * FROM User_account;

START TRANSACTION;

UPDATE User_account
SET Balance = Balance - 100000
WHERE ID = 001;

UPDATE User_account
SET Balance = Balance + 100000
WHERE ID = 002;

COMMIT;	

SELECT * FROM User_account;



-- Question 2
INSERT INTO user_account (ID, Name, Balance) VALUES 
(11, 'Test1', 100000),
(12, 'Test2', 50000),
(13, 'Test3', 30000),
(14, 'Account1', 100000),
(15, 'Account2', 50000),
(16, 'Account3', 30000);


-- Question 3
INSERT INTO User_account (ID, Name, Balance) VALUES 
(001, 'A', 500000),
(002, 'B', 0);
DELIMITER $$
CREATE PROCEDURE TransferMoneyCorrect()
BEGIN
    DECLARE acc_count INT DEFAULT 0;
    DECLARE balance_001 DECIMAL(15,2);
    
    START TRANSACTION;
    
    SELECT COUNT(*) INTO acc_count
    FROM User_account
    WHERE ID IN (001, 002);
    
    SELECT Balance INTO balance_001
    FROM User_account
    WHERE ID = 001
    FOR UPDATE;
    
    IF acc_count = 2 AND balance_001 >= 50000 THEN
        UPDATE User_account
        SET Balance = Balance - 50000
        WHERE ID = 001;
        
        UPDATE User_account
        SET Balance = Balance + 50000
        WHERE ID = 002;
        
        COMMIT;
        SELECT 'Transfer successful' AS Result;
    ELSE
        ROLLBACK;
        SELECT 'Transfer failed' AS Result;
    END IF;
END$$
DELIMITER ;

CALL TransferMoneyCorrect();
SELECT * FROM User_account WHERE ID IN (001, 002);



-- Question 4
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    Name VARCHAR(100),
    Amount DECIMAL(15,2),
    Status VARCHAR(20)
);

DELIMITER $$
CREATE PROCEDURE ProcessOrdersWithRollback()
BEGIN
    DECLARE error_occurred BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET error_occurred = TRUE;
    
    START TRANSACTION;
    INSERT INTO Orders VALUES (1, 'Order1', 1000.00, 'Pending');
    INSERT INTO Orders VALUES (2, 'Order2', 2000.00, 'Pending');
    INSERT INTO Orders VALUES (3, 'Order3', 3000.00, 'Pending');
    
    UPDATE Orders SET Status = 'Completed' WHERE OrderID = 1;
    UPDATE Orders SET Status = 'Completed' WHERE OrderID = 2;
    UPDATE Orders SET Status = 'Completed' WHERE OrderID = 3;
    
    IF error_occurred THEN
        ROLLBACK;
        SELECT 'Transaction rolled back because of error' AS Result;
    ELSE
        COMMIT;
        SELECT 'All orders processed successfully' AS Result;
    END IF;
END$$
DELIMITER ;

CALL ProcessOrdersWithRollback();
SELECT * FROM Orders;



-- Question 2, 5, 6, 7, 8 sample data
INSERT INTO User_account VALUES 
(101, 'User101', 100000),
(102, 'User102', 50000);


-- Question 8

-- Transaction with COMMIT
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 5000 WHERE ID = 101;
UPDATE User_account SET Balance = Balance + 5000 WHERE ID = 102;
COMMIT;

SELECT * FROM User_account WHERE ID IN (101, 102);


-- Transaction with ROLLBACK
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 5000 WHERE ID = 101;
ROLLBACK;

SELECT * FROM User_account WHERE ID IN (101, 102);


-- Recovery After System Failure
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 10000 WHERE ID = 101;
ROLLBACK;

SELECT * FROM User_account WHERE ID = 101;


-- SAVEPOINT
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 5000 WHERE ID = 101;
SAVEPOINT sp1;
UPDATE User_account SET Balance = Balance + 5000 WHERE ID = 102;
ROLLBACK TO sp1;
COMMIT;

SELECT * FROM User_account WHERE ID IN (101, 102);