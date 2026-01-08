CREATE DATABASE Lab1;
USE Lab1;

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

DROP TABLE User_account;



-- Question 2
CREATE TABLE User_account (
    ID INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Balance DECIMAL(15,2) NOT NULL,
    PRIMARY KEY (ID)
);

INSERT INTO User_account (ID, Name, Balance) VALUES 
(003, 'C', 1234),
(004, 'D', 12345),
(005, 'E', 123456);

SELECT * FROM User_account;



-- Question 3
INSERT INTO User_account (ID, Name, Balance) VALUES 
(10, 'Nguyen', 500000),
(11, 'Pham', 100000);

DELIMITER $$
CREATE PROCEDURE TransferMoney()
BEGIN
    DECLARE acc_count INT DEFAULT 0;
    DECLARE balance_010 DECIMAL(15,2);

    START TRANSACTION;

    SELECT COUNT(*) INTO acc_count
    FROM User_account
    WHERE ID IN (10, 11);

    SELECT Balance INTO balance_010
    FROM User_account
    WHERE ID = 10
    FOR UPDATE;

    IF acc_count = 2 AND balance_010 >= 500000 THEN

        UPDATE User_account
        SET Balance = Balance - 50000
        WHERE ID = 10;

        UPDATE User_account
        SET Balance = Balance + 50000
        WHERE ID = 11;

        COMMIT;
    ELSE
        ROLLBACK;
    END IF;

END$$
DELIMITER ;

CALL TransferMoney();
SELECT * FROM User_account WHERE ID IN (10, 11);


-- Question 4
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    Name VARCHAR(100),
    Amount DECIMAL(15,2),
    Status VARCHAR(20)
);

DELIMITER $$
CREATE PROCEDURE ProcessOrders()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Transaction rollback because there an error' AS Result;
    END;
    
    START TRANSACTION;
    
    INSERT INTO Orders VALUES (1, 'Order1', 1000.00, 'Pending');
    INSERT INTO Orders VALUES (2, 'Order2', 2000.00, 'Pending');
    INSERT INTO Orders VALUES (3, 'Order3', 3000.00, 'Pending');
    
    UPDATE Orders SET Status = 'Completed' WHERE OrderID = 1;
    UPDATE Orders SET Status = 'Completed' WHERE OrderID = 2;
    UPDATE Orders SET Status = 'Completed' WHERE OrderID = 3;
    
    COMMIT;
    SELECT 'All orders process successfully' AS Result;
END$$
DELIMITER ;

CALL ProcessOrders();
SELECT * FROM Orders;


-- Question 5, 6, 7, 8 sample data
INSERT INTO User_account VALUES 
(101, 'Account1', 100000),
(102, 'Account2', 50000),
(103, 'Account3', 30000);


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
