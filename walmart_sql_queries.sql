--WALMART DATA ANALYSIS
--EDA:

SELECT * FROM walmart;

SELECT COUNT(*) FROM walmart;

SELECT 
	payment_method,
	COUNT(*)
FROM walmart
GROUP BY payment_method;

DROP TABLE walmart; --Dropped bcoz the some columns(Branch,City) had capital letter so we couldnt get results(changed all colums to lower case in vs code)

SELECT 
	COUNT(DISTINCT branch)
FROM walmart;

SELECT MAX(quantity) FROM walmart;

SELECT MIN(quantity) FROM walmart;

--BUSINESS PROBLEMS:

--1. What are the different payment methods, and how many transactions and items were sold with each method?

SELECT 
	payment_method,
	COUNT(*) as no_payments,
	SUM(quantity) as no_item_sold
FROM walmart
GROUP BY payment_method;

--2. Which category received the highest average rating in each branch?

SELECT * FROM 
(SELECT
    branch,
	category,
	AVG(rating) as avg_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) as rank
FROM walmart
GROUP BY 1,2)
WHERE rank = 1;

--3. What is the busiest day of the week for each branch based on transaction volume?

SELECT * FROM 
(
SELECT 
	branch,
	TO_CHAR(TO_DATE(date,'DD/MM/YY'),'Day') as formatted_date, -- extract function will give output as numbers but to_char give as names(ex:days)
	COUNT(*) AS transactions,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1,2)
WHERE rank = 1;

--4. How many items were sold through each payment method?

SELECT 
	payment_method,
	SUM(quantity) as no_items_sold
FROM walmart
GROUP BY payment_method;

--5.  What are the average, minimum, and maximum ratings for each category in each city?

SELECT 
	category,
	city,
	MIN(rating),
	AVG(rating),
	MAX(rating)
FROM walmart
GROUP BY 1,2
ORDER BY 1,2;

--6. What is the total profit for each category, ranked from highest to lowest?

SELECT 
	category,
	SUM(total) AS total_Revenue,
	SUM(total*profit_margin) AS total_profit
FROM walmart
GROUP BY category;

--7.  What is the most frequently used payment method in each branch?

WITH CTE AS 
(SELECT 
	branch,
	payment_method,
	COUNT(payment_method) AS total_transaction,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(payment_method) DESC) as rank
FROM walmart
GROUP BY 1,2)
SELECT * FROM CTE
WHERE rank = 1;

--8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

SELECT 
	branch,
	CASE 
		WHEN EXTRACT(HOUR FROM (time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*) AS total_transaction
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;

--9. Identify 5 branch with highest decrease ratio in revenue compare to last year(current year 2023 and last year 2022)

SELECT * FROM walmart;


SELECT 
	 DISTINCT EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) AS formatted_date
FROM walmart;


WITH revenue_2022 AS(
SELECT
	branch,
	SUM(total) AS total_revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2022
GROUP BY 1
),
revenue_2023 AS (
SELECT
	branch,
	SUM(total) AS total_revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date,'DD/MM/YY')) = 2023
GROUP BY 1
)
SELECT 
	ls.branch,
	ls.total_revenue AS last_year_revenue,
	cs.total_revenue AS cur_year_revenue,
	ROUND((
		   ls.total_revenue - cs.total_revenue)::numeric/
		   ls.total_revenue::numeric * 100,2) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs
ON ls.branch = cs.branch
WHERE ls.total_revenue > cs.total_revenue
ORDER BY 4 DESC
LIMIT 5;








































