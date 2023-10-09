CREATE DATABASE sj_database;
USE DATABASE sj_database;

--1) Load the given dataset into snowflake with a primary key to Order Date column.

CREATE OR REPLACE TABLE sj_sales_data
    (
    order_id VARCHAR(16),
    order_date DATE PRIMARY KEY,
    ship_date DATE,
    ship_mode CHAR(15),
    customer_name CHAR(25),
    segment CHAR(12),
    state VARCHAR(50),
    country CHAR(35),
    market CHAR(7),
    region CHAR(15),
    product_id VARCHAR(18),
    category CHAR(15),
    sub_category CHAR(12),
    product_name VARCHAR2(150),
    sales NUMBER(6,0),
    quantity INT,
    discount NUMBER(4,4),
    profit FLOAT,
    shipping_cost FLOAT,
    order_priority CHAR(10),
    year NUMBER(4,0)
    );
DESCRIBE TABLE sj_sales_data;
SELECT * FROM sj_sales_data;

CREATE OR REPLACE TABLE copy_sj_sales_data AS
SELECT * FROM sj_sales_data;
DESCRIBE TABLE copy_sj_sales_data;
SELECT * FROM copy_sj_sales_data;

--------------------------------------------------------------------

--2) Change the Primary key to Order Id Column.

ALTER TABLE copy_sj_sales_data
ADD PRIMARY KEY (order_id);

---------------------------------------------------------------------

--3) Check the data type for Order date and Ship date and mention in what data type it should be?

SELECT GET_DDL ('TABLE','copy_sj_sales_data');  --'order_date' & 'ship_date' columns are already in the DATE data type.

---------------------------------------------------------------------

--4) Create a new column called order_extract and extract the number after the last ‘–‘from Order ID column.

ALTER TABLE copy_sj_sales_data
ADD COLUMN order_extract VARCHAR(10);

UPDATE copy_sj_sales_data
SET order_extract = (SPLIT_PART (order_id,'-',3));

----------------------------------------------------------------------

--5) Create a new column called Discount Flag and categorize it based on discount. Use ‘Yes’ if the discount is greater than zero else ‘No’.

ALTER TABLE copy_sj_sales_data
ADD COLUMN discount_flag VARCHAR(4);

UPDATE copy_sj_sales_data
SET discount_flag =(CASE WHEN DISCOUNT > 0 THEN 'YES' 
                         ELSE 'NO' END);
                         
-----------------------------------------------------------------------------

--6) Create a new column called process days and calculate how many days it takes for each order id to process from the order to its shipment.

ALTER TABLE copy_sj_sales_data
ADD COLUMN process_days NUMBER(2,0);

UPDATE copy_sj_sales_data
SET process_days = (DATEDIFF('DAY',ORDER_DATE,SHIP_DATE));

-----------------------------------------------------------------------------

/* 7) Create a new column called Rating and then based on the Process dates give rating like given below.
    a. If process days less than or equal to 3days then rating should be 5
    b. If process days are greater than 3 and less than or equal to 6 then rating should be 4
    c. If process days are greater than 6 and less than or equal to 10 then rating  should be 3
    d. If process days are greater than 10 then the rating should be 2. */

ALTER TABLE copy_sj_sales_data
ADD COLUMN Rating VARCHAR(2);

UPDATE copy_sj_sales_data
SET Rating = (CASE WHEN process_days <= 3 THEN '5'
                   WHEN process_days > 3 AND process_days <= 6 THEN '4'
                   WHEN process_days > 6 AND process_days <= 10 THEN '3'
                   ELSE '2' 
              END);

SELECT ORDER_ID,ORDER_EXTRACT,ORDER_DATE,SHIP_DATE,PROCESS_DAYS,RATING,DISCOUNT,DISCOUNT_FLAG FROM copy_sj_sales_data;

SELECT * FROM copy_sj_sales_data;















