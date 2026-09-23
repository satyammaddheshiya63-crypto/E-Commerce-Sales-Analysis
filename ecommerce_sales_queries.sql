SELECT * FROM commerce;

-- 1. Find the total number of unique orders
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM commerce;

-- Q2. Find the total sales/revenue generated from all orders.
SELECT SUM(sales) AS revenue
FROM commerce;

-- Q3. Find the total profit generated.
SELECT SUM(profit) AS total_profit
FROM commerce;

-- Q4. Find the total quantity of products sold.
SELECT SUM(quantity) AS total_qty
FROM commerce;

-- Q5.Calculate the average order value.
SELECT SUM(sales) / COUNT(DISTINCT order_id) AS avg_order_value
FROM commerce;

-- Q6. Calculate the overall profit margin using:
SELECT SUM(profit) * 100 / SUM(sales) AS profit_margin
FROM commerce;

-- 7. Find total sales for each product category.
SELECT category, SUM(sales) AS total_sales
FROM commerce
GROUP BY category;

-- Q8. Find total profit for each product category.
SELECT category, SUM(profit) AS total_profit
FROM commerce
GROUP BY category;

-- Q9. Find total sales for every state and sort the result from highest to lowest.
SELECT state, SUM(sales) AS total_sales
FROM commerce
GROUP BY state
ORDER BY total_sales DESC;

-- Q10. For each payment method find: Number of orders, Total sales, Total profit
SELECT payment_method, COUNT(DISTINCT Order_id) AS total_orders,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit
FROM commerce
GROUP BY payment_method;

-- 11. Find total sales for each month.
SELECT DATE_FORMAT(order_date, "%Y-%m") AS month, 
SUM(sales) AS total_sales
FROM commerce
GROUP BY DATE_FORMAT(order_date, "%Y-%m")
ORDER BY month;

-- Q12. For every month calculate: Total orders, Total sales, Total profit, Total quantity
SELECT DATE_FORMAT(order_date, "%Y-%m") AS month, 
COUNT(DISTINCT order_id) AS total_orders,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
SUM(quantity) AS total_qty
FROM commerce
GROUP BY DATE_FORMAT(order_date, "%Y-%m")
ORDER BY month;

-- Q13. Yearly Performance : For each year calculate:Orders, Sales, Profit, Quantity
SELECT YEAR(order_date) AS yearly, 
COUNT(DISTINCT order_id) AS total_orders,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
SUM(quantity) AS total_qty
FROM commerce
GROUP BY YEAR(order_date)
ORDER BY yearly;

-- Q14.Channel Analysis Compare using: Orders, Sales, Profit
SELECT sales_channel, 
COUNT(DISTINCT order_id) AS total_orders,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit
FROM commerce
GROUP BY sales_channel;

-- Q15. For each customer segment calculate:Orders, Sales, Profit, Quantity, Average Order Value.
SELECT customer_segment,
COUNT(DISTINCT order_id) AS total_orders,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
SUM(quantity) AS total_qty,
SUM(sales) / COUNT(DISTINCT order_id) AS avg_order_value
FROM commerce
GROUP BY customer_segment;

-- Q16. Return Analysis: Calculate:Total orders, Returned orders, Non-returned orders, Return rate
SELECT
COUNT(DISTINCT order_id) AS total_orders,
COUNT(DISTINCT CASE WHEN returned = "Yes" THEN order_id END) AS returned_orders,
COUNT(DISTINCT CASE WHEN returned = "No" THEN order_id END) AS non_returned_orders,
COUNT(DISTINCT CASE WHEN returned = "Yes" THEN order_id END) * 100 
/ COUNT(DISTINCT order_id) AS return_rate
FROM commerce;

-- Q17. Calculate the return rate for every category.
SELECT category, 
SUM(returned = "Yes") * 100 / COUNT(DISTINCT order_id) AS return_rate
FROM commerce
GROUP BY category;

-- Q18. Find the top 10 products based on total sales.
SELECT product, SUM(Sales) AS total_sales,
ROW_NUMBER() OVER (ORDER BY SUM(Sales) DESC) AS ranking
FROM commerce
GROUP BY product
ORDER BY total_sales DESC
LIMIT 10;

SELECT product
FROM (
SELECT product,
ROW_NUMBER() OVER (ORDER BY SUM(Sales) DESC) AS ranking
FROM commerce
GROUP BY product
ORDER BY SUM(sales) DESC
) t
WHERE ranking <= 10;

-- 19. Find the top 10 customers based on total sales. Customer_ID, Customer_Name, Total_Orders
-- Total_Sales, Total_Profit
SELECT customer_id, customer_name,
SUM(sales) AS total_sales,
COUNT(*) AS total_orders,
SUM(profit) AS total_profit
FROM commerce
GROUP BY customer_id, customer_name
ORDER BY SUM(sales) DESC
LIMIT 10;

-- 20. Find customers who have placed more than 5 orders.
SELECT customer_id, customer_name, COUNT(DISTINCT order_id) AS total_orders
FROM commerce
GROUP BY customer_id, customer_name
HAVING COUNT(DISTINCT order_id) > 5;

-- 21. Find the top 3 products by sales within every category.
-- Return: Category, Product, Total_Sales, Rank
SELECT *
FROM (
SELECT category, product, SUM(sales) AS total_sales,
ROW_NUMBER() OVER (PARTITION BY Category ORDER BY SUM(sales) DESC) AS ranking
FROM commerce
GROUP BY product, category
) t
WHERE ranking <= 3;

-- Q22.Find the customer with the highest total sales in every state.
SELECT customer_id, customer_name, state, total_sales
FROM (
SELECT customer_id, customer_name, state, SUM(sales) AS total_sales,
ROW_NUMBER() OVER (PARTITION BY state ORDER BY SUM(sales) DESC) AS ranking
FROM commerce
GROUP BY customer_id, customer_name, state
) t
WHERE ranking = 1
ORDER BY total_sales DESC;

-- Q23. Rank all categories according to total sales.
SELECT category, SUM(sales) AS total_sales,
RANK() OVER (ORDER BY SUM(sales) DESC) AS ranking
FROM commerce
GROUP BY category;

-- Q24. For every product calculate:Total sales, Total cost, Total profit, Profit margin.
SELECT product,
SUM(sales) AS total_sales,
SUM(cost) AS total_cost,
SUM(profit) AS total_profit,
SUM(profit) * 100 / SUM(sales) AS profit_margin
FROM commerce
GROUP BY product;

-- Q25. Loss-Making Products : Find products where total profit is negative.
SELECT product, 
SUM(sales) AS total_sales,
SUM(cost) AS total_cost,
SUM(profit) AS total_profit
FROM commerce
GROUP BY product
HAVING SUM(profit) < 0
ORDER BY total_sales DESC;

-- Q26. High-Value Customers:Find customers whose total sales are greater than the average sales 
-- per customer.
WITH Highest_Sales_Value AS (
SELECT customer_id, customer_name,
SUM(sales) AS total_sales
FROM commerce
GROUP BY customer_id, customer_name
)
SELECT customer_id, customer_name, total_sales
FROM Highest_Sales_Value
WHERE total_sales > (SELECT AVG(sales) FROM commerce)
ORDER BY total_sales DESC;

-- Q27. Calculate cumulative/running sales month by month.
-- Return: Month, Monthly_Sales, Running_Total_Sales
WITH monthlySales AS (
SELECT DATE_FORMAT(order_date, "%Y-%m") AS month,
SUM(sales) AS monthly_sales
FROM commerce
GROUP BY DATE_FORMAT(order_date, "%Y-%m")
)
SELECT month, monthly_sales,
SUM(monthly_sales) OVER (ORDER BY month) AS running_total_sales
FROM monthlySales;

-- Q28. Calculate yearly sales and compare each year with the previous year.
-- Return:Year, Sales, Previous_Year_Sales, Growth_Percentage
WITH YOY AS (
SELECT YEAR(order_date) AS Year,
SUM(sales) AS sales, 
LAG(SUM(sales)) OVER (ORDER BY YEAR(order_date)) AS previous_year_sale
FROM commerce
GROUP BY YEAR(order_date)
)
SELECT year, sales, previous_year_sale,
(sales - previous_year_sale) * 100 / previous_year_sale AS Growth_Percentage
FROM YOY;

-- Q29. Find the category with the highest sales in every region.
 -- Return: Region, Category, Total_Sales, Ranking
 SELECT category, region, total_sales, ranking
 FROM (
 SELECT category, region,
 SUM(sales) AS total_sales,
 ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sales) DESC) AS ranking
 FROM commerce
 GROUP BY category, region
 ) t
 WHERE ranking = 1;
 
-- Q30. Executive Dashboard KPIs
-- Create one query that returns: Total Orders, Total Sales, Total Profit, Total Quantity, 
-- Average Order Value, Profit Margin, Returned Orders, Return Rate
SELECT COUNT(DISTINCT order_id) AS total_orders,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit,
SUM(quantity) AS total_qty,
SUM(sales) / COUNT(DISTINCT order_id) AS avg_order_value,
SUM(profit) * 100 / SUM(sales) AS profit_margin,
SUM(returned = "Yes") AS returned_orders,
SUM(returned = "Yes") * 100 / COUNT(DISTINCT order_id) AS return_rate
FROM commerce;

-- 31. Find the average delivery days for every state.
SELECT state, AVG(delivery_days) AS avg_delivery_days
FROM commerce
GROUP BY state;

-- 32. For each customer rating calculate: Number of orders, Total sales, Average sales
SELECT customer_rating,
COUNT(DISTINCT order_id) AS total_orders,
SUM(sales) AS total_sales,
AVG(sales) AS average_sales
FROM commerce
GROUP BY customer_rating;

-- 33. For every discount percentage calculate: Orders, Sales, Profit
SELECT discount_percent,
COUNT(DISTINCT order_id) AS total_orders,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit
FROM commerce
GROUP BY discount_percent
ORDER BY discount_percent;

-- Q34. Brand Performance:For every brand calculate:Orders, Quantity, Sales, Profit
SELECT brand,
COUNT(DISTINCT order_id) AS total_orders,
SUM(quantity) AS total_quantity,
SUM(sales) AS total_sales,
SUM(profit) AS total_profit
FROM commerce
GROUP BY brand;