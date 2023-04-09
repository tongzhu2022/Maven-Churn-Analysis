-- Change the frequently used column names
-- ALTER TABLE `telecom`.`telecom_customer_churn` 
-- CHANGE COLUMN `Customer ID` `Customer_ID` TEXT NULL DEFAULT NULL,
-- CHANGE COLUMN `Customer Status` `Customer_Status` TEXT NULL DEFAULT NULL,
-- CHANGE COLUMN `Total Revenue` `Total_Revenue` TEXT NULL DEFAULT NULL,
-- CHANGE COLUMN `Tenure in Months` `Tenure_in_Months` TEXT NULL DEFAULT NULL,
-- CHANGE COLUMN `Churn Category` `Churn_Category` TEXT NULL DEFAULT NULL,
-- CHANGE COLUMN `Churn Reason` `Churn_Reason` TEXT NULL DEFAULT NULL,
-- CHANGE COLUMN `Internet Type` `Internet_Type` TEXT NULL DEFAULT NULL,
-- CHANGE COLUMN `Premium Tech Support` `Premium_Tech_Support` TEXT NULL DEFAULT NULL;


-- Check for `customer_id` duplicates
SELECT customer_id, COUNT(*) as count
FROM telecom.telecom_customer_churn
GROUP BY customer_id
HAVING COUNT(customer_id) > 1;
-- No duplicates in `customer_id`


-- Check total number of rows for the dataset
SELECT COUNT(customer_id) as customer_count
FROM telecom.telecom_customer_churn;


-- 1. How much revenue did Maven lost due to churned customers?
SELECT customer_status,
	   COUNT(customer_id) AS customer_count,
       ROUND((SUM(total_revenue)*100) / SUM(SUM(total_revenue)) OVER(), 1) AS revenue_percentage
FROM telecom.telecom_customer_churn
GROUP BY customer_status;
-- Customer churn accounted for 17.2% of Maven's total revenue


-- 2. What is the typical tenure for churned customers?
SELECT CASE WHEN tenure_in_months <= 6 THEN '6 months'
			WHEN tenure_in_months <= 12 THEN '1 year'
            WHEN tenure_in_months <= 24 THEN '2 years'
            ELSE '2 years +' END AS tenure_length,
	   ROUND(COUNT(customer_id)*100 / SUM(COUNT(customer_id)) OVER(), 1) AS churn_percentage
FROM telecom.telecom_customer_churn
WHERE customer_status = 'Churned'
GROUP BY tenure_length
ORDER BY churn_percentage DESC;
-- A large percentage(41.9%) of churned customers have a tenure length of 6 months


-- 3. Which cities had the highest churn rates?
SELECT city,
	   COUNT(customer_id) AS churned,
       ROUND(COUNT(CASE WHEN customer_status = 'Churned' THEN customer_id ELSE NULL END)*100 / COUNT(customer_id), 1) AS churn_rate
FROM telecom.telecom_customer_churn
GROUP BY city
HAVING churned > 30
ORDER BY churn_rate DESC
LIMIT 5; 
-- San Diego had the highest number of customer churn(285) and churn rate(64.9%)


-- 4. Breakdown of customers who have churned
SELECT churn_category,
	   ROUND(SUM(total_revenue),1) AS churn_revenue,
       ROUND(COUNT(customer_id)*100 / SUM(COUNT(customer_id)) OVER(), 1)AS churn_percentage
FROM telecom.telecom_customer_churn
WHERE customer_status = 'Churned'
GROUP BY churn_category
ORDER BY churn_revenue DESC;
-- 'Competitor' caused approximately 45% of the customer churned and a $1.7M lost in revenue for Maven


-- 5. Detailed reason for churn
SELECT churn_reason,
	   churn_category,
       ROUND(COUNT(customer_id)*100 / SUM(COUNT(customer_id)) OVER(), 1) AS churn_percentage
FROM telecom.telecom_customer_churn
WHERE customer_status = 'Churned'
GROUP BY churn_reason,
		 churn_category
ORDER BY churn_percentage DESC
LIMIT 5;


-- 6. What offers were made to customers who have churned
SELECT offer,
	   ROUND(COUNT(customer_id)*100 / SUM(COUNT(customer_id)) OVER(), 1) AS churn_percentage
FROM telecom.telecom_customer_churn
WHERE customer_status = 'Churned'
GROUP BY offer
ORDER BY churn_percentage DESC;


-- 7. What internet did the churned customers have?
SELECT internet_type,
	   COUNT(customer_id) AS churned,
       ROUND(COUNT(customer_id)*100 / SUM(COUNT(customer_id)) OVER(), 1) AS churn_percentage
FROM telecom.telecom_customer_churn
WHERE customer_status = 'Churned'
GROUP BY internet_type
ORDER BY churn_percentage DESC;
-- 66.1% of the churned customers were using Fiber Optic internet

-- 8. What internet type did 'Competitor' churners have?\
SELECT internet_type,
	   churn_category,
       COUNT(customer_id) AS churned,
       ROUND(COUNT(customer_id)*100 / SUM(COUNT(customer_id)) OVER(), 1) AS churn_percentage
FROM telecom.telecom_customer_churn
WHERE customer_status = 'Churned' AND churn_category = 'Competitor'
GROUP BY internet_type
ORDER BY churn_percentage DESC;
-- 69.8% of the customers left for competitor's Fiber Optic
-- Is there a quality issue with Maven's Fiber Optic internet?


-- 9. What type of contract were churned customers on?
SELECT contract,
	   COUNT(customer_id) AS churned,
       ROUND(COUNT(customer_id)*100 / SUM(COUNT(customer_id)) OVER(), 1) AS churn_percentage
FROM telecom.telecom_customer_churn
WHERE customer_status = 'Churned'
GROUP BY contract
ORDER BY churn_percentage DESC;
-- Customers on a short contract(Month-to-Month) are more likely to churn


-- 10. Did churned customers have premium tech support?
SELECT premium_tech_support,
	   COUNT(customer_id) AS churned,
       ROUND(COUNT(customer_id)*100 / SUM(COUNT(customer_id)) OVER(), 1) AS churn_percentage
FROM telecom.telecom_customer_churn
WHERE customer_status = 'Churned'
GROUP BY premium_tech_support
ORDER BY churn_percentage DESC;
-- 1446 churned customers(77.4%) DOES NOT have premium tech support
-- Improving this service could potentially make a big difference


