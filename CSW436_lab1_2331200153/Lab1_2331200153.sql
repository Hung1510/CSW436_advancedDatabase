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

-- commit if transaction successful
COMMIT;	
-- show result
SELECT * FROM User_account;

-- drop to take result screenshot
DROP TABLE User_account;



-- Question 2
-- Sample data for question 2
INSERT INTO User_account (ID, Name, Balance) VALUES 
(003, 'C', 1234),(004, 'D', 12345),(005, 'E', 123456);
SELECT * FROM User_account ;
-- READ UNCOMMITTED
-- READ COMMITTED
-- REPEATABLE READ
-- SERIALIZABLE



-- Question 3
INSERT INTO User_account (ID, Name, Balance) VALUES 
(10, 'Nguyen', 500000),(11, 'Pham', 100000);

DELIMITER $$
CREATE PROCEDURE TransferMoney()
BEGIN
    DECLARE acc_count INT DEFAULT 0;
    DECLARE balance_010 DECIMAL(15,2);

    START TRANSACTION;

    SELECT COUNT(*) INTO acc_count
    FROM User_account
    WHERE ID IN (10, 11);

    -- get balance account 10
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


-- Question4
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    Name VARCHAR(100),
    Amount DECIMAL(15,2),
    Status VARCHAR(20)
);


