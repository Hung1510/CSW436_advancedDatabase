use lab1;
-- Question 2

-- a. READ UNCOMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 10000 WHERE ID = 13;
-- run sec 2
ROLLBACK;
-- b. READ COMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
UPDATE User_account SET Balance = 99999 WHERE ID = 14;
-- run sec 2
COMMIT;

-- c. REPEATABLE READ
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 15;
-- run sec 2
SELECT * FROM User_account WHERE ID = 15;
COMMIT;

-- d. SERIALIZABLE
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 12;
-- run sec 2
COMMIT;



-- Question 5
-- i. demonstrate concurrency problems
-- a. Lost Update
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 11;
-- run sec 2
UPDATE User_account SET Balance = Balance + 10000 WHERE ID = 11;
COMMIT;

-- b. Dirty Read
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
UPDATE User_account SET Balance = 50000 WHERE ID = 11;
-- run sec 2
ROLLBACK;

-- c. Non-Repeatable Read
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 11;
-- run sec 2
SELECT * FROM User_account WHERE ID = 11;
COMMIT;

-- d. Phantom Read
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT COUNT(*) FROM User_account;
-- run sec 2
SELECT COUNT(*) FROM User_account;
COMMIT;


-- ii. prevent concurrency problems
-- a. Prevent Lost Update
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 11 FOR UPDATE;
-- run sec 2
UPDATE User_account SET Balance = Balance + 10000 WHERE ID = 11;
COMMIT;

-- b. Prevent Dirty Read
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
UPDATE User_account SET Balance = 60000 WHERE ID = 11;
-- run sec 2
ROLLBACK;

-- c. Prevent Non-Repeatable Read
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 11;
-- run sec 2
SELECT * FROM User_account WHERE ID = 11;
COMMIT;

-- d. Prevent Phantom Read
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
START TRANSACTION;
SELECT COUNT(*) FROM User_account;
-- run sec 2
SELECT COUNT(*) FROM User_account;
COMMIT;



-- Question 6
-- i. Shared Lock (Read Lock)
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 LOCK IN SHARE MODE;

COMMIT;

-- ii. Exclusive Lock (Write Lock)
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 FOR UPDATE;
UPDATE User_account SET Balance = 110000 WHERE ID = 101;
COMMIT;

-- iii. Two-Phase Locking
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 FOR UPDATE;
SELECT Balance FROM User_account WHERE ID = 102 FOR UPDATE;
UPDATE User_account SET Balance = Balance - 100000 WHERE ID = 101;
UPDATE User_account SET Balance = Balance + 100000 WHERE ID = 102;
COMMIT;

-- iv. Prevent Lost Update
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 FOR UPDATE;
-- run sec 2
UPDATE User_account SET Balance = Balance + 5000 WHERE ID = 101;
COMMIT;



-- Question 7
-- a. Create Deadlock
set autocommit=0;
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 100 WHERE ID = 14;
do sleep(5);
UPDATE User_account SET Balance = Balance + 100 WHERE ID = 15;
COMMIT;

-- b. Identify Deadlock
SHOW ENGINE INNODB STATUS;

-- c. Prevent Deadlock
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 100 WHERE ID = 001;
DO SLEEP(10);
UPDATE User_account SET Balance = Balance + 100 WHERE ID = 002;
COMMIT;

-- d. Lock Wait Timeout
SET innodb_lock_wait_timeout = 2;
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 100 WHERE ID = 002;
DO SLEEP(10);
-- run sec 2
COMMIT;

-- ex7:


-- c) PREVENT deadlock
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 50 WHERE ID = 001;
DO SLEEP(5);
UPDATE User_account SET Balance = Balance + 50 WHERE ID = 002;
COMMIT;

-- d) avoid deadlock by using a lock wait timeout:
SET innodb_lock_wait_timeout = 3;
START TRANSACTION;
UPDATE User_account SET Balance = Balance + 100 WHERE ID = 002;