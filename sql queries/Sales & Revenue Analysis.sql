USE OlistDB;
GO

-- ============================================================
-- SALES & REVENUE ANALYSIS
-- ============================================================


-- Q1: What is the total revenue generated from all orders?
SELECT
    SUM(payment_value) AS total_revenue
FROM payments;


-- Q2: What is the average order value?
SELECT
    AVG(order_total) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(payment_value) AS order_total
    FROM payments
    GROUP BY order_id
) AS order_values;


-- Q3: What is the total revenue by year?
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    SUM(p.payment_value) AS total_revenue
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY order_year;


-- Q4: What is the total revenue by month?
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    MONTH(o.order_purchase_timestamp) AS order_month,
    SUM(p.payment_value) AS total_revenue
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY
    order_year,
    order_month;


-- Q5: How many orders were placed each year?
SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    COUNT(*) AS total_orders
FROM orders
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY order_year;


-- Q6: What is the average order value by year?
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    AVG(order_total) AS average_order_value
FROM orders o
JOIN (
    SELECT
        order_id,
        SUM(payment_value) AS order_total
    FROM payments
    GROUP BY order_id
) p
    ON o.order_id = p.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY order_year;


-- Q7: Which payment type generates the highest revenue?
SELECT
    payment_type,
    SUM(payment_value) AS total_revenue
FROM payments
GROUP BY payment_type
ORDER BY total_revenue DESC;


-- Q8: What is the average freight value per order?
SELECT
    AVG(total_freight_value) AS average_freight_value
FROM (
    SELECT
        order_id,
        SUM(freight_value) AS total_freight_value
    FROM order_items
    GROUP BY order_id
) AS freight_orders;


-- Q9: What is the total freight revenue by year?
SELECT
    YEAR(o.order_purchase_timestamp) AS order_year,
    SUM(oi.freight_value) AS total_freight
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY YEAR(o.order_purchase_timestamp)
ORDER BY order_year;


-- Q10: Which months generate the highest revenue?
SELECT
    MONTH(o.order_purchase_timestamp) AS order_month,
    SUM(p.payment_value) AS total_revenue
FROM orders o
JOIN payments p
    ON o.order_id = p.order_id
GROUP BY MONTH(o.order_purchase_timestamp)
ORDER BY total_revenue DESC;