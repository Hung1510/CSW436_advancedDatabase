-- sample data in main file
-- Question 2

-- READ UNCOMMITTED
Select * from User_account where ID = '003';
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
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;

SELECT * FROM User_account WHERE ID = 005;

SELECT * FROM User_account WHERE ID = 005;
COMMIT;


-- SERIALIZABLE 
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;

SELECT * FROM User_account WHERE ID = 3;
COMMIT;


-- Question 5

-- i DEMONSTRATE CONCURRENCY PROBLEMS

-- a Lost Update 
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 1;
UPDATE User_account SET Balance = Balance + 10000 WHERE ID = 1;
COMMIT;


-- b Dirty Read 
START TRANSACTION;
UPDATE User_account SET Balance = 50000 WHERE ID = 1;
ROLLBACK;


-- c Non-Repeatable Read
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 1;
SELECT * FROM User_account WHERE ID = 1;
COMMIT;


-- d Phantom Read 
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM User_account;
SELECT * FROM User_account;
COMMIT;


-- ii PREVENT CONCURRENCY PROBLEMS

-- a Prevent Lost Update 
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 1 FOR UPDATE;
UPDATE User_account SET Balance = Balance + 10000 WHERE ID = 1;
COMMIT;


-- b Prevent Dirty Read
START TRANSACTION;
UPDATE User_account SET Balance = 50000 WHERE ID = 1;
ROLLBACK;


-- c Prevent Non-Repeatable Read
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 1;
SELECT * FROM User_account WHERE ID = 1;
COMMIT;


-- d Prevent Phantom Read
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM User_account;
SELECT * FROM User_account;
COMMIT;


-- Question 6

-- i Shared Lock (Read Lock) Transaction T1
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 LOCK IN SHARE MODE;
COMMIT;


-- ii Exclusive Lock (Write Lock) Transaction T2
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 FOR UPDATE;
UPDATE User_account SET Balance = 110000 WHERE ID = 101;
COMMIT;


-- iii Two-Phase Locking Transaction T1
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 FOR UPDATE;
SELECT Balance FROM User_account WHERE ID = 102 FOR UPDATE;
UPDATE User_account SET Balance = Balance - 100000 WHERE ID = 101;
UPDATE User_account SET Balance = Balance + 100000 WHERE ID = 102;
COMMIT;


-- iv Prevent Lost Update Transaction T1
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 FOR UPDATE;
UPDATE User_account SET Balance = Balance + 5000 WHERE ID = 101;
COMMIT;


-- Question 7

-- Deadlock Situation
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 1000 WHERE ID = 101;
UPDATE User_account SET Balance = Balance + 1000 WHERE ID = 102;
COMMIT;


-- b Identify Deadlock
SHOW ENGINE INNODB STATUS;
SELECT * FROM information_schema.INNODB_TRX;


-- c Prevent Deadlock
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 1000 WHERE ID = 101;
UPDATE User_account SET Balance = Balance + 1000 WHERE ID = 102;
COMMIT;


-- d Lock Wait Timeout
SET innodb_lock_wait_timeout = 5;
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 1000 WHERE ID = 101;
COMMIT;