-- section 1
-- READ UNCOMMITTED
Select * from User_account where ID = '003'; -- check info before question
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;

UPDATE User_account
SET Balance = Balance - 100000
WHERE ID = '003';

rollback;

-- READ COMMITTED
START TRANSACTION;
    UPDATE User_account SET Balance= 1000 WHERE ID = 004;
COMMIT;
    SELECT * FROM User_account WHERE ID = 004;


-- REPEATABLE READ
-- run this first then go to section2
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;

SELECT * FROM User_account WHERE ID = 005;

-- run this after running sectiob 2
SELECT * FROM User_account WHERE ID = 005;
COMMIT;


-- SERIALIZABLE 
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;

SELECT * FROM User_account WHERE ID = 3;
COMMIT;


-- Question 5




-- Question 6
INSERT INTO User_account VALUES 
(101, 'Account1', 100000),
(102, 'Account2', 50000),
(103, 'Account3', 30000);


-- i. Shared Lock (Read Lock) - Transaction T1
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 LOCK IN SHARE MODE;
COMMIT;


-- ii. Exclusive Lock (Write Lock) - Transaction T2
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 FOR UPDATE;
UPDATE User_account SET Balance = 110000 WHERE ID = 101;
COMMIT;


-- iii. Two-Phase Locking - Transaction T1
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 FOR UPDATE;
SELECT Balance FROM User_account WHERE ID = 102 FOR UPDATE;
UPDATE User_account SET Balance = Balance - 100000 WHERE ID = 101;
UPDATE User_account SET Balance = Balance + 100000 WHERE ID = 102;
COMMIT;


-- iv. Prevent Lost Update - Transaction T1
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 FOR UPDATE;
UPDATE User_account SET Balance = Balance + 5000 WHERE ID = 101;
COMMIT;




