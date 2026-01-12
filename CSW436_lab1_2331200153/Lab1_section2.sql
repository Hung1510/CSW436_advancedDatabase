-- Question 2

-- a. READ UNCOMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 13;
COMMIT;

-- b. READ COMMITTED
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 14;
COMMIT;

-- c. REPEATABLE READ
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 1000 WHERE ID = 15;
COMMIT;

-- d. SERIALIZABLE
START TRANSACTION;
INSERT INTO User_account (ID, Name, Balance) VALUES (17, 'TestUser', 9999);
COMMIT;



-- Question 5
-- i. demonstrate concurrency problems
-- a. Lost Update
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 11;
UPDATE User_account SET Balance = Balance + 5000 WHERE ID = 11;
COMMIT;

-- b. Dirty Read
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 11;
COMMIT;

-- c. Non-Repeatable Read
START TRANSACTION;
UPDATE User_account SET Balance = 80000 WHERE ID = 11;
COMMIT;

-- d. Phantom Read
START TRANSACTION;
INSERT INTO User_account VALUES (18, 'NewUser', 25000);
COMMIT;


-- ii. prevent concurrency problems
-- a. Prevent Lost Update
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 11 FOR UPDATE;
UPDATE User_account SET Balance = Balance + 5000 WHERE ID = 11;
COMMIT;

-- b. Prevent Dirty Read
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM User_account WHERE ID = 11;
COMMIT;

-- c. Prevent Non-Repeatable Read
START TRANSACTION;
UPDATE User_account SET Balance = 85000 WHERE ID = 11;
COMMIT;

-- d. Prevent Phantom Read
START TRANSACTION;
INSERT INTO User_account VALUES (19, 'AnotherUser', 30000);
COMMIT;



-- Question 6

-- iv. Prevent Lost Update
START TRANSACTION;
SELECT Balance FROM User_account WHERE ID = 101 FOR UPDATE;
UPDATE User_account SET Balance = Balance + 3000 WHERE ID = 101;
COMMIT;



-- Question 7
-- a. Create Deadlock
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 100 WHERE ID = 15;
UPDATE User_account SET Balance = Balance + 100 WHERE ID = 14;
COMMIT;

-- c. Prevent Deadlock
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 50 WHERE ID = 001;
DO SLEEP(5);
UPDATE User_account SET Balance = Balance + 50 WHERE ID = 002;
COMMIT;

-- d. Lock Wait Timeout
SET innodb_lock_wait_timeout = 3;
START TRANSACTION;
UPDATE User_account SET Balance = Balance - 100 WHERE ID = 002;
COMMIT;