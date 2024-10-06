/* SQL PROJECT – HIRING ABC COMPANY (Real Question) */

CREATE DATABASE assignments;
USE assignments;

-- TASK_1:
/* Create a table 'shopping_history' which represents a list of shopping transactions, where each transaction consists of 
the product name, the number of items bought & the price of a single item. Notice that some products may appear multiple times, 
sometimes with different prices. You are asked to calculate the total cost of each product.*/

CREATE TABLE sj_shopping_history
    (
    product VARCHAR(30) NOT NULL,
    quantity INT NOT NULL,
    unit_price INT NOT NULL
    );
DESCRIBE TABLE sj_shopping_history;

INSERT INTO sj_shopping_history(product,quantity,unit_price)
VALUES 
    ('pen', 2, 10),
    ('ice_cream', 2, 25),
    ('egg', 4, 7),
    ('soap', 4, 30),
    ('pen', 5, 5),
    ('chocolate', 3, 10),
    ('milk', 2, 25),
    ('cake', 2, 15),
    ('chocolate', 2, 30),
    ('egg', 6, 7),
    ('notebook', 2, 30),
    ('watch', 1, 650),
    ('shirt', 2, 149),
    ('shirt', 2, 299),
    ('bread', 6, 5);

SELECT * FROM sj_shopping_history;

/* Write an SQL query that, for each 'product', returns the total amount of money spent on it. 
Rows should be ordered in descending alphabetical order by 'product'. */

SELECT product, SUM(quantity * unit_price) AS total_price
FROM sj_shopping_history
GROUP BY 1
ORDER BY product DESC;

-------------------------------------------------------------------------------

-- TASK_2:
/*  A telecommunications company decided to find which of their clients talked for at least 10 minutes on the phone in total 
and offer them a new contract. Create two tables, 'phones' and 'calls'. 
Each row of the table 'phones' contains information about a client: name and phone number. Each client has only one phone number. 
Each row of the table 'calls' contains information about a single call: Id, phone number of the caller, 
phone number of the callee and duration of the call in minutes. */

CREATE TABLE sj_phones
    (
    name VARCHAR(20) NOT NULL UNIQUE,
    phone_number INT NOT NULL UNIQUE
    );
INSERT INTO sj_phones 
VALUES
    ('Jack', 1234), -- 8+1+1= 10
    ('Lena', 3333), -- 4+3+1+1= 9
    ('Mark', 9999), -- 1+4= 5
    ('Anna', 7582), -- 8+1+3= 12
    ('John', 6356), -- 0
    ('Addison', 4315), -- 18
    ('Kate', 8003), -- 7+3= 10
    ('Ginny', 9831); -- 7+3+18= 28
    
SELECT * FROM sj_phones;

CREATE TABLE sj_calls
    (
    id INT NOT NULL UNIQUE,
    caller INT NOT NULL,
    callee INT NOT NULL,
    duration INT NOT NULL
    );
INSERT INTO sj_calls
VALUES
    (25, 1234, 7582, 8),
    (7, 9999, 7582, 1),
    (18, 9999, 3333, 4),
    (2, 7582, 3333, 3),
    (3, 3333, 1234, 1),
    (21, 3333, 1234, 1),
    (65, 8003, 9831, 7),
    (100, 9831, 8003, 3),
    (145, 4315, 9831, 18);

SELECT * FROM sj_calls ORDER BY caller, callee;

/* Write an SQL query that finds all clients who talked for at least 10 minutes in total. 
The table of results should contain one column: the name of the client(name). Rows should be sorted alphabetically. */

WITH call_info AS
(SELECT caller AS phone_number, SUM(duration) AS duration
FROM sj_calls 
GROUP BY 1
UNION ALL
SELECT callee AS phone_number, SUM(duration) AS duration
FROM sj_calls 
GROUP BY 1)

SELECT name
FROM sj_phones AS P
INNER JOIN call_info AS C ON P.phone_number = C.phone_number
GROUP BY name
HAVING SUM(duration) >= 10
ORDER BY name;

-------------------------------------------------------------------------

-- TASK_3:
/* You are given a history of your bank account transactions for the year 2020. Each transaction was either 
a credit card payment or an incomming transfer. There is a fee of 5 for holding a credit card which you have to pay every month. 
However, you are not charged for a given month if you made at least three credit card payments for a total cost of 
at least 100 within that month. Note that this fee is not included in the supplied history of transactions. 
At the beginning of the year, the balance of your account was 0. Your task is to compute the balance at the end of the year.
You are given a table transactions with following structure:
Each row of the table contains information about a single transaction, the amount of money and the date when the transaction happened. 
If the amount value is negative, then it is a credit card payment. Otherwise, it is an incoming transfer. 
There are no transactions with an amount of 0. */

CREATE TABLE sj_transactions
    (
    amount INT NOT NULL,
    date DATE NOT NULL
    );

INSERT INTO sj_transactions(amount,date)
VALUES (1000, '2020-01-06'),
       (-10, '2020-01-14'),
       (-75, '2020-01-20'),
       (-5, '2020-01-25'),
       (-4, '2020-01-29'),
       (2000, '2020-03-10'),
       (-75, '2020-03-12'),
       (-20, '2020-03-15'),
       (40, '2020-03-15'),
       (-50, '2020-03-17'),
       (200, '2020-10-10'),
       (-200, '2020-10-10');

SELECT * FROM sj_transactions;

/* Write an SQL query that returns a table containing one column, 'balance'. The table should contain one row 
with the total balance of your account at the end of the year, including the fee for holding a credit card. */

WITH all_months AS (
    SELECT '2020-01-01' AS month UNION ALL
    SELECT '2020-02-01' UNION ALL
    SELECT '2020-03-01' UNION ALL
    SELECT '2020-04-01' UNION ALL
    SELECT '2020-05-01' UNION ALL
    SELECT '2020-06-01' UNION ALL
    SELECT '2020-07-01' UNION ALL
    SELECT '2020-08-01' UNION ALL
    SELECT '2020-09-01' UNION ALL
    SELECT '2020-10-01' UNION ALL
    SELECT '2020-11-01' UNION ALL
    SELECT '2020-12-01'
    ),
monthly_summary AS (
    SELECT MONTH(date) AS month,
           SUM(CASE WHEN amount < 0 THEN amount ELSE 0 END) AS total_credit_payments,
           SUM(CASE WHEN amount < 0 THEN 1 ELSE 0 END) AS credit_payment_count
    FROM sj_transactions
    GROUP BY month
    ),
all_months_summary AS (
    SELECT 
        MONTH(AM.month) AS month, 
        COALESCE(MS.total_credit_payments, 0) AS total_credit_payments, 
        COALESCE(MS.credit_payment_count, 0) AS credit_payment_count,
        CASE 
            WHEN COALESCE(MS.credit_payment_count, 0) >= 3 AND COALESCE(MS.total_credit_payments, 0) <= -100 THEN 0
            ELSE 5
        END AS fee
    FROM all_months AS AM
    LEFT OUTER JOIN monthly_summary AS MS ON MS.month = MONTH(AM.month)
    ),
total_fees AS (
    SELECT SUM(fee) AS total_fee
    FROM all_months_summary
    ),
total_balance AS (
    SELECT SUM(amount) AS total_amount
    FROM sj_transactions
    )

SELECT total_amount - total_fee AS balance
FROM total_balance, total_fees;

------------------------------------------------------------------------------

