-- Sales Overview

-- Data Cleaning

SELECT order_id, COUNT(*) as dupicate_count
FROM order_details
GROUP BY order_id
HAVING COUNT(*) >1;

-- Removing Duplicates
WITH CTE AS (
    SELECT 
        ctid,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY ctid) AS row_num
    FROM order_details
)
DELETE FROM order_details
WHERE ctid IN (
    SELECT ctid
    FROM CTE
    WHERE row_num > 1
);


-- KPI's

--1.Revenue

SELECT 
	SUM(amount) AS Total_Revenue,
	(SUM(amount) - (SELECT SUM(amount) FROM order_details
	WHERE order_date < CURRENT_DATE - INTERVAL '1month'))/
	NULLIF((SELECT SUM(amount)FROM order_details 
	WHERE order_date < CURRENT_DATE - INTERVAL '1month'),0)*100 AS Revnue_Growth
	FROM order_details;

SELECT * FROM order_details;
-- Monthly Revenue Growth 
SELECT
	 DATE_TRUNC('month',o.order_date) AS Month,--Group by Month
	 SUM(od.amount) AS Total_Revenue, -- Sum up sales
	 (SUM(od.amount) - LAG(SUM(od.amount)) OVER (ORDER BY DATE_TRUNC('month',o.order_date)))/
	 NULLIF(LAG(SUM(od.amount)) OVER (ORDER BY DATE_TRUNC('month',o.order_date)),0) * 100 AS Sales_Growth -- Calculate growth 
	FROM Orders o
	JOIN Order_details od ON o.order_id = od.order_id
	GROUP BY month
	ORDER BY month;


--2. Profit

SELECT SUM(profit) AS Total_Profit
FROM order_details;

--3.Profit Margin

SELECT 
     SUM(amount) /
     SUM(Profit)
  *100 AS Profit_Margin
FROM order_details;

-- 4.Orders

SELECT COUNT(order_id) AS Total_Orders
FROM order_details;

--5.AOV

SELECT SUM(amount)/ COUNT(order_id) AS AOV
FROM Order_details;

-- Visuals
--1. Category
-- Revenue by Category
SELECT category, SUM(Amount) AS Revenue
FROM order_details
GROUP BY category
ORDER BY Revenue DESC;

-- Profit by Category
SELECT category, SUM(Profit) AS Profit
FROM order_details
GROUP BY category
ORDER BY Profit DESC;

--2. Sub-Catrgory
-- Revenue by Sub-Category
SELECT sub_category, SUM(Amount) AS Revenue
FROM order_details
GROUP BY sub_category
ORDER BY Revenue DESC
LIMIT 5;

--Profit by Sub-Category
SELECT sub_category,SUM(Profit) AS Profit
FROM order_details
GROUP BY sub_category
ORDER BY Profit DESC
LIMIT 5;

--3. Revnue & Profit OverTime
SELECT 
      DATE_TRUNC('month',order_date) AS Month,
      SUM(Amount) AS Total_Revenue,
      SUM(Profit) AS Total_Profit
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY month
ORDER BY month;

--4. Payment Method
SELECT 
      Payment_mode,
      SUM(Amount) AS Total_Revenue,
      ROUND((SUM(Amount)*100) / (SELECT COUNT(*) FROM order_details),2) AS Percentage
FROM order_details
GROUP BY Payment_Mode
ORDER BY Total_Revenue DESC;

--5. State
SELECT 
	state, 
    SUM(Amount) AS Total_Revenue,
    SUM(Profit) AS Total_Profit
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY State
ORDER BY total_Revenue DESC;

--6. Top 5 Customers
-- Revenue
SELECT 
     customer_name,
     SUM(Amount) AS Total_Revenue
FROM Orders o
JOIN order_details od ON O.order_id = od.order_id
GROUP BY Customer_Name
ORDER BY Total_Revenue DESC
LIMIT 5;

-- Profit
SELECT 
     customer_name,
     SUM(Profit) AS Total_Profit
FROM orders o
JOIN order_details  od ON o.order_id = od.order_id
GROUP BY customer_name
ORDER BY total_profit DESC
LIMIT 5;