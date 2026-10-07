CREATE DATABASE banking;
USE banking;

-- Branch Table
CREATE TABLE branches (
branch_id INT PRIMARY KEY,
branch_name VARCHAR(50),
city VARCHAR(50),
state VARCHAR(50)
);


-- Employees Table
CREATE TABLE employees (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(100) NOT NULL,
gender VARCHAR(10) NOT NULL,
department VARCHAR(50) NOT NULL,
designation VARCHAR(50) NOT NULL,
salary DECIMAL(10,2) NOT NULL,
joining_date DATE NOT NULL,
branch_id INT NOT NULL,
FOREIGN KEY (branch_id)
REFERENCES Branches(branch_id)
);


-- Customers Table
CREATE TABLE customers (
customer_id INT PRIMARY KEY,
customer_name VARCHAR(100) NOT NULL,
gender VARCHAR(10) NOT NULL,
dob DATE NOT NULL,
phone VARCHAR(15) NOT NULL,
city VARCHAR(50) NOT NULL,
branch_id INT NOT NULL,
FOREIGN KEY (branch_id)
REFERENCES Branches(branch_id)
);


-- Accounts Table
CREATE TABLE accounts (
account_id INT PRIMARY KEY,
customer_id INT NOT NULL,
account_type VARCHAR(20) NOT NULL,
balance DECIMAL(12,2) NOT NULL,
open_date DATE NOT NULL,
status VARCHAR(20) NOT NULL,
FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id)
);


-- Transactions Table
CREATE TABLE transactions (
transaction_id INT PRIMARY KEY,
account_id INT NOT NULL,
transaction_type VARCHAR(20) NOT NULL,
amount DECIMAL(12,2) NOT NULL,
transaction_datetime DATETIME NOT NULL,
payment_mode VARCHAR(20) NOT NULL,
FOREIGN KEY (account_id)
REFERENCES Accounts(account_id)
);


-- Loans Table
CREATE TABLE loans (
loan_id INT PRIMARY KEY,
customer_id INT NOT NULL,
loan_type VARCHAR(30) NOT NULL,
loan_amount DECIMAL(12,2) NOT NULL,
interest_rate DECIMAL(5,2) NOT NULL,
issue_date DATE NOT NULL,
status VARCHAR(20) NOT NULL,
FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id)
);


SELECT COUNT(*) FROM branches;
SELECT COUNT(*) FROM employees;
SELECT COUNT(*) FROM customers;
SELECT COUNT(*) FROM accounts;
SELECT COUNT(*) FROM transactions;
SELECT COUNT(*) FROM loans;


SELECT * FROM branches;
SELECT * FROM accounts;
SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM loans;
SELECT * FROM transactions;

-- Total number of customer
SELECT COUNT(*) AS Total_Customer
From customers; 

-- Total accounts balance 
SELECT SUM(balance) AS Total_Accounts 
FROM accounts;

-- Average account balance
SELECT AVG(balance) AS Avg_Account
FROM accounts;

-- Customers in each branch
SELECT branch_id, count(*) AS Customers
FROM customers
GROUP BY branch_id; 

-- Employees in each branch
SELECT branch_id, count(*) AS Employees
FROM employees
GROUP BY branch_id;

-- Total balance by account type
SELECT account_type, SUM(balance) 
FROM accounts
GROUP BY account_type; 

-- Transaction count by payment mode
SELECT payment_mode,COUNT(*)
FROM  transactions
GROUP BY payment_mode;

-- Rank Customers by Total Deposit Within Each Branch
SELECT c.customer_id,c.customer_name,c.branch_id,
SUM(t.amount) AS Total_Deposit,
RANK() OVER(PARTITION BY c.branch_id ORDER BY SUM(t.amount) DESC) AS Deposit_Rank
FROM customers AS c
JOIN accounts AS a
ON c.customer_id = a.customer_id
JOIN transactions AS t
ON t.account_id = a.account_id
WHERE t.transaction_type = 'Deposit'
GROUP BY c.customer_id,c.customer_name,c.branch_id;

-- Display Customer Account Details
SELECT a.account_type, c.customer_name, a.balance
FROM customers AS c
JOIN accounts AS a
ON c.customer_id = a.customer_id;

-- Display Customer Loan Details
SELECT c.customer_name,l.loan_type,l.loan_amount,l.interest_rate
FROM customers AS c
JOIN loans AS l
ON c.customer_id = l.customer_id;

-- Display Customer Transaction Details
SELECT c.customer_name, t.transaction_type,t.amount,a.balance
FROM customers AS c
JOIN accounts as a
ON c.customer_id = a.customer_id
JOIN transactions AS t
ON t.account_id = a.account_id;

-- Customers without loans
SELECT c.customer_name
FROM customers AS c
LEFT JOIN loans AS l
ON c.customer_id = l.customer_id
WHERE l.loan_id IS NULL;


-- Customers Who Have Transactions in Every Month
SELECT a.customer_id
FROM accounts AS a
JOIN transactions AS t
ON t.account_id = a.account_id
GROUP BY a.customer_id
HAVING COUNT(DISTINCT CONCAT(YEAR(t.transaction_datetime),'-',MONTH(t.transaction_datetime))) =
(SELECT COUNT(DISTINCT CONCAT(YEAR(transaction_datetime),'-',MONTH(transaction_datetime)))
FROM transactions
);


-- Branch Having Highest Number of Customers
SELECT * FROM branches
WHERE branch_id=
(
SELECT branch_id 
FROM customers
GROUP BY branch_id
ORDER BY COUNT(*) DESC
LIMIT 1
);

-- Customers Without Any Transactions
SELECT c.customer_id,c.customer_name
FROM customers AS c
WHERE NOT EXISTS
(
SELECT 1
FROM accounts AS a
JOIN transactions AS t
ON a.account_id = t.account_id
WHERE a.customer_id = c.customer_id
);

-- Customer with highest balance
SELECT customer_name 
FROM customers
WHERE customer_id = 
(SELECT customer_id FROM accounts
ORDER BY balance DESC
LIMIT 1);

-- Employees Earning More Than the Average Salary of Their Branch 
SELECT * FROM employees AS e 
WHERE e.salary >
(
SELECT AVG(e1.salary) FROM employees AS e1
WHERE e1.branch_id = e.branch_id);

-- Write an SQL query to assign a unique row number to each customer based on their account balance in descending order using ROW_NUMBER().
SELECT customer_id,balance,
ROW_NUMBER() OVER(ORDER BY balance DESC) AS Row_Num
FROM accounts;

-- Write an SQL query to rank customers according to their account balance in descending order using RANK().
SELECT customer_id, balance,
RANK() OVER(ORDER BY balance DESC) AS Rk
FROM accounts;

-- Write an SQL query to rank customers according to their account balance using DENSE_RANK().
SELECT customer_id, balance,
DENSE_RANK() OVER(ORDER BY balance DESC) AS Dr
FROM accounts;

-- Write an SQL query to display each transaction along with the amount of the next transaction using LEAD().
SELECT transaction_id,amount,
LEAD(amount) OVER(ORDER BY transaction_datetime) AS Next_transaction
FROM transactions;

-- Write an SQL query to display each transaction along with the amount of the previous transaction using LAG().
SELECT transaction_id, amount,
LAG(amount) OVER(ORDER BY transaction_datetime) AS Previous_Transaction
FROM transactions;

-- Write an SQL query to calculate the running total of transaction amounts in chronological order using a window function.
SELECT transaction_datetime,amount,
SUM(amount) OVER(ORDER BY transaction_datetime) AS Running_Total
FROM transactions;

-- Write an SQL query to calculate the total transaction amount for each month.
SELECT MONTH(transaction_datetime) AS Month,
SUM(amount) AS Total_Transaction_Amount
FROM transactions
GROUP BY MONTH(transaction_datetime);

-- Write an SQL query to count the number of loans issued in each year.
SELECT YEAR(issue_date) AS Year_Loan,COUNT(*) AS Total_Loans
FROM loans
GROUP BY YEAR(issue_date)
ORDER BY Year_Loan;

-- Write an SQL query to categorize customers into High, Medium, and Low balance categories based on their account balance using the CASE statement.
SELECT customer_name,balance,
CASE 
WHEN balance> 300000 THEN "High"
WHEN balance> 100000 THEN "Medium"
ELSE "Low"
END AS category
FROM customers c
JOIN accounts a 
ON c.customer_id = a.customer_id;

-- CTE
-- Top 5 Customers by Net Transaction Amount
WITH Net_Transaction AS
(
SELECT c.customer_id,c.customer_name,SUM(
CASE 
WHEN transaction_type="Deposit" THEN amount
ELSE -amount
END
) Net_Balance
FROM customers AS c
JOIN accounts AS a
ON c.customer_id = a.customer_id
JOIN transactions AS t
ON t.account_id = a.account_id
GROUP BY c.customer_id,c.customer_name
)
SELECT * FROM Net_Transaction
ORDER BY Net_Balance DESC
LIMIT 5;

-- Find the Top 3 Customers with the Highest Account Balance
WITH Highest_Account_Balance AS
(
SELECT c.customer_id,c.customer_name,a.balance,
DENSE_RANK() OVER(ORDER BY a.balance DESC) AS Dr
FROM customers c
JOIN accounts a
ON c.customer_id = a.customer_id
)
SELECT * FROM Highest_Account_Balance
WHERE Dr<=3;

-- Display the top 2 customers by total transaction amount in each branch.
WITH CustomerTransactions AS
(
SELECT c.branch_id,c.customer_id,c.customer_name,
SUM(t.amount)AS Total_Amount
FROM customers AS c
JOIN accounts AS a
ON c.customer_id = a.customer_id 
JOIN transactions AS t
ON t.account_id = a.account_id
GROUP BY c.branch_id,c.customer_id,c.customer_name
),
RankCustomers AS 
(
SELECT * ,
DENSE_RANK() OVER(PARTITION BY branch_id ORDER BY Total_Amount DESC) AS Dr
FROM CustomerTransactions
)
SELECT * FROM RankCustomers
WHERE Dr <= 2; 

-- View

-- Create a view that shows the total number of transactions and total transaction amount for each month.
CREATE VIEW  Monthly_Transaction_Summary AS
SELECT YEAR(transaction_datetime) AS Year,
MONTH(transaction_datetime) AS Month,
Count(*) AS Total_Transaction,
SUM(amount) AS Total_Amount
FROM transactions
GROUP BY YEAR(transaction_datetime),MONTH(transaction_datetime);

-- Create a View for High Balance Customers (> ₹300000)
CREATE VIEW High_Balance_Customer AS
SELECT c.customer_id,c.customer_name,a.balance
FROM accounts AS a
JOIN customers AS c
ON c.customer_id = a.customer_id
WHERE a.balance > 300000;

-- Stored Procedure

-- Get Complete Customer Details by Customer ID

DELIMITER //
CREATE PROCEDURE Get_Customer_Details (IN p_customer_id INT)
BEGIN
SELECT c.customer_name,b.branch_name,a.account_type,a.balance,l.loan_type,l.loan_amount
FROM customers AS c
JOIN branches AS b
ON c.branch_id = b.branch_id
JOIN accounts AS a
ON a.customer_id = c.customer_id
LEFT JOIN loans AS l 
ON c.customer_id = l.customer_id
WHERE c.customer_id = p_customer_id;
END //
DELIMITER ;
-- Execute
CALL Get_Customer_Details(10);

-- Display Transactions Between Two Dates
DELIMITER //
CREATE PROCEDURE Transaction_History
(
IN start_date DATE, 
IN end_date DATE 
)
BEGIN
SELECT * FROM transactions
WHERE DATE(transaction_datetime)
BETWEEN start_date AND end_date;
END //
DELIMITER ;

CALL Transaction_History('2025-01-01', '2025-01-31');

-- Customer Balance Category
DELIMITER //
CREATE PROCEDURE Customer_Blance_Category
(IN cid INT 
)
BEGIN
SELECT customer_name,balance,
CASE
WHEN balance >300000 THEN  "High"
WHEN balance >100000 THEN "Median"
ELSE
"Low"
END AS category
FROM customers c
JOIN accounts a
ON c.customer_id=a.customer_id
WHERE c.customer_id=cid;
END//
DELIMITER ;

CALL Customer_Blance_Category(5);





