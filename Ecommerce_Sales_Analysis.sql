CREATE DATABASE IF NOT EXISTS ecommerce_analytics;

USE ecommerce_analytics;

-- =========================================
-- 1. Total Revenue Analysis
-- Business Question: What is the total revenue generated?
SELECT SUM(price) AS total_revenue
FROM olist_order_items_dataset;

-- 2. Total Orders Analysis
-- Business Question: How many unique orders were placed?
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset;

-- 3. Total Customers Analysis
-- Business Question: How many unique customers placed orders?
SELECT COUNT(DISTINCT customer_unique_id) AS total_customers
FROM olist_customers_dataset;

-- 4. Average Order Value Analysis
-- Business Question: What is the average value of each order?
SELECT
    SUM(price) / COUNT(DISTINCT order_id) AS average_order_value
FROM olist_order_items_dataset;

-- 5. Average Delivery Time Analysis
-- Business Question: How many days does an order take to reach the customer?
SELECT
    ROUND(AVG(DATEDIFF(
        order_delivered_customer_date,
        order_purchase_timestamp
    )), 2) AS avg_delivery_days
FROM olist_orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NOT NULL;

-- 6. Monthly Revenue Analysis
-- Business Question: How does revenue change month over month?
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY month
ORDER BY month;

SELECT
    MONTHNAME(o.order_purchase_timestamp) AS month,
    MONTH(o.order_purchase_timestamp) AS month_number,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM olist_orders_dataset o
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
WHERE o.order_purchase_timestamp IS NOT NULL
GROUP BY
    MONTH(o.order_purchase_timestamp),
    MONTHNAME(o.order_purchase_timestamp)
ORDER BY month_number;

-- 7. Order Status Analysis
-- Business Question: How are orders distributed across different order statuses?

SELECT
    order_status,
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;

-- 8. Top 10 Product Categories by Revenue
-- Business Question: Which product categories generate the highest revenue?

SELECT
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 9. Top 10 States by Revenue
-- Business Question: Which customer states generate the highest revenue?

SELECT
    c.customer_state,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;

-- 10. Payment Method Analysis
-- Business Question: Which payment methods generate the highest revenue?

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_revenue DESC;

-- 11. Customer Review Score Analysis
-- Business Question: How are customers rating their shopping experience?

SELECT
    review_score,
    COUNT(*) AS total_reviews,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM olist_order_reviews_dataset),
        2
    ) AS percentage
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score DESC;

-- 12. Delivery Performance Analysis
-- Business Question: How many orders were delivered on time versus late?

SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 'On-Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- 13. Delivery Performance vs Customer Satisfaction
-- Business Question: How does delivery performance affect customer satisfaction?

SELECT
    CASE
        WHEN order_delivered_customer_date <= order_estimated_delivery_date
        THEN 'On-Time'
        ELSE 'Late'
    END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r
    ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY delivery_status;

-- 14. Yearly Order Growth Analysis
-- Business Question: How has the number of orders changed year over year?

SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    COUNT(DISTINCT order_id) AS total_orders
FROM olist_orders_dataset
WHERE order_purchase_timestamp IS NOT NULL
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY order_year;
