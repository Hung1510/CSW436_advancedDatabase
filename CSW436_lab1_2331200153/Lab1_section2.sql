-- sample data in main file
-- Question 2

-- READ UNCOMMITTED
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = '003';

-- READ COMMITTED
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    INSERT INTO User_account (ID, Name, Balance) VALUES ('004', 'abcd', '10000');
COMMIT;

-- REPEATABLE READ
START TRANSACTION;

UPDATE User_account
SET Balance = Balance + 1000
WHERE ID = 005;
COMMIT;


-- SERIALIZABLE
START TRANSACTION;

INSERT INTO User_account (ID, Name, Balance)
VALUES (006, 'F', 9999);


-- Question 5

-- i DEMONSTRATE CONCURRENCY PROBLEMS

-- a Lost Update
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 1;
UPDATE User_account SET Balance = Balance + 5000 WHERE ID = 1;
COMMIT;


-- b Dirty Read
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 1;
COMMIT;


-- c Non-Repeatable Read
START TRANSACTION;
UPDATE User_account SET Balance = 80000 WHERE ID = 1;
COMMIT;


-- d Phantom Read
START TRANSACTION;
INSERT INTO User_account VALUES (4, 'D', 20000);
COMMIT;


-- ii PREVENT CONCURRENCY PROBLEMS

-- a Prevent Lost Update
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 1 FOR UPDATE;
UPDATE User_account SET Balance = Balance + 5000 WHERE ID = 1;
COMMIT;


-- b Prevent Dirty Read
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 1;
COMMIT;


-- c Prevent Non-Repeatable Read 
START TRANSACTION;
UPDATE User_account SET Balance = 80000 WHERE ID = 1;
COMMIT;


-- d Prevent Phantom Read
START TRANSACTION;
INSERT INTO User_account VALUES (4, 'D', 20000);
COMMIT;


-- Question 6

-- iv Prevent Lost Update
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 FOR UPDATE;
UPDATE User_account SET Balance = Balance + 3000 WHERE ID = 101;
COMMIT;


-- Question 7

-- a Deadlock Situation
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 1000 WHERE ID = 102;
UPDATE User_account SET Balance = Balance + 1000 WHERE ID = 101;
COMMIT;


-- c Prevent Deadlock
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 1000 WHERE ID = 101;
UPDATE User_account SET Balance = Balance + 1000 WHERE ID = 102;
COMMIT;


-- d Lock Wait Timeout
SET innodb_lock_wait_timeout = 5;
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 1000 WHERE ID = 102;
COMMIT;