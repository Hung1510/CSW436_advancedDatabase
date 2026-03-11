create database shopdb;
use shopdb;

CREATE TABLE customers (
id INT PRIMARY KEY,
name VARCHAR(100),
email VARCHAR(100)
);
CREATE TABLE orders (
id INT PRIMARY KEY,
customer_id INT,
order_date DATE,
total DECIMAL(10,2),
FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- Insert sample customers
INSERT INTO customers (id, name, email) VALUES
(1, 'John Doe', 'john.doe@email.com'),
(2, 'Jane Smith', 'jane.smith@email.com'),
(3, 'Bob Johnson', 'bob.johnson@email.com'),
(4, 'Alice Williams', 'alice.williams@email.com'),
(5, 'Charlie Brown', 'charlie.brown@email.com');

-- Insert sample orders
INSERT INTO orders (id, customer_id, order_date, total) VALUES
(101, 1, '2024-01-15', 1250.50),
(102, 1, '2024-02-20', 340.00),
(103, 2, '2024-01-18', 890.75),
(104, 3, '2024-01-22', 560.00),
(105, 2, '2024-02-10', 1100.25),
(106, 4, '2024-02-15', 780.00),
(107, 1, '2024-03-01', 450.50),
(108, 5, '2024-02-28', 920.00),
(109, 3, '2024-03-05', 1500.75),
(110, 4, '2024-03-10', 650.00);