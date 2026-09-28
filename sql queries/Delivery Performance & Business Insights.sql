USE OlistDB;
GO

-- ============================================================
-- DELIVERY PERFORMANCE & BUSINESS INSIGHTS
-- ============================================================


-- Q1: What percentage of delivered orders arrived late?
SELECT
    COUNT(*) AS delivered_orders,
    SUM(CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 1 ELSE 0
        END) AS late_orders,
    CAST(
        100.0 * SUM(CASE
                        WHEN order_delivered_customer_date > order_estimated_delivery_date
                        THEN 1 ELSE 0
                    END) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS late_delivery_percentage
FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;


-- Q2: How does delivery performance change by year?
SELECT
    YEAR(order_purchase_timestamp) AS order_year,
    COUNT(*) AS delivered_orders,

    SUM(CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 1 ELSE 0
        END) AS late_orders,

    CAST(
        100.0 * SUM(CASE
                        WHEN order_delivered_customer_date > order_estimated_delivery_date
                        THEN 1 ELSE 0
                    END) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS late_delivery_percentage

FROM orders
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL

GROUP BY YEAR(order_purchase_timestamp)
ORDER BY order_year;


-- Q3: Which months have the highest late-delivery rate?
SELECT
    MONTH(order_purchase_timestamp) AS order_month,

    COUNT(*) AS delivered_orders,

    SUM(CASE
            WHEN order_delivered_customer_date > order_estimated_delivery_date
            THEN 1 ELSE 0
        END) AS late_orders,

    CAST(
        100.0 * SUM(CASE
                        WHEN order_delivered_customer_date > order_estimated_delivery_date
                        THEN 1 ELSE 0
                    END) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS late_delivery_percentage

FROM orders

WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL

GROUP BY MONTH(order_purchase_timestamp)
ORDER BY late_delivery_percentage DESC;


-- Q4: Which states have the highest late-delivery rate?
-- JOIN orders with customers to identify the customer's state.

SELECT
    c.customer_state,

    COUNT(*) AS delivered_orders,

    SUM(CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END) AS late_orders,

    CAST(
        100.0 * SUM(CASE
                        WHEN o.order_delivered_customer_date >
                             o.order_estimated_delivery_date
                        THEN 1 ELSE 0
                    END) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS late_delivery_percentage

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY c.customer_state

HAVING COUNT(*) >= 100

ORDER BY late_delivery_percentage DESC;


-- Q5: Does late delivery affect customer review scores?
-- JOIN orders with reviews.

SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,

    COUNT(*) AS number_of_reviews,

    AVG(CAST(r.review_score AS DECIMAL(10,2))) AS average_review_score

FROM orders o

JOIN reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END

ORDER BY average_review_score DESC;


-- Q6: What is the relationship between delivery delay and review score?
-- Calculate the average review score for each score level.

SELECT
    r.review_score,

    COUNT(*) AS number_of_orders,

    AVG(
        DATEDIFF(
            DAY,
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date
        )
    ) AS average_days_vs_estimate

FROM orders o

JOIN reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY r.review_score

ORDER BY r.review_score;


-- Q7: Which product categories experience the highest late-delivery rate?
-- JOIN orders -> order_items -> products -> category translation.

SELECT
    ct.product_category_name_english AS category,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN o.order_id
    END) AS late_orders,

    CAST(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN o.order_id
        END)
        / COUNT(DISTINCT o.order_id)
        AS DECIMAL(5,2)
    ) AS late_delivery_percentage

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY ct.product_category_name_english

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY late_delivery_percentage DESC;


-- Q8: Which categories generate the most revenue and how does
-- their delivery performance compare?
-- BUSINESS INSIGHT:
-- Revenue + delivery performance in the same analysis.

SELECT
    ct.product_category_name_english AS category,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(oi.price) AS product_revenue,

    AVG(oi.price) AS average_item_price,

    CAST(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN o.order_id
        END)
        / COUNT(DISTINCT o.order_id)
        AS DECIMAL(5,2)
    ) AS late_delivery_percentage

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY ct.product_category_name_english

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY product_revenue DESC;


-- Q9: Does higher freight cost relate to late delivery?
-- JOIN orders with order_items and compare freight with delivery status.

SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,

    COUNT(DISTINCT o.order_id) AS total_orders,

    AVG(oi.freight_value) AS average_freight,

    AVG(oi.price) AS average_product_price

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END;


-- Q10: Which states combine high sales with high late-delivery rates?
-- BUSINESS INSIGHT:
-- Identify markets with both significant revenue and delivery issues.

SELECT
    c.customer_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(p.payment_value) AS total_revenue,

    CAST(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN o.order_id
        END)
        / COUNT(DISTINCT o.order_id)
        AS DECIMAL(5,2)
    ) AS late_delivery_percentage

FROM orders o

JOIN customers c
    ON o.customer_id = c.customer_id

JOIN payments p
    ON o.order_id = p.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY c.customer_state

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY total_revenue DESC;


-- Q11: Do late deliveries have lower customer satisfaction?
-- Compare the percentage of low ratings between late and on-time orders.

SELECT
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,

    COUNT(*) AS total_reviews,

    SUM(CASE
            WHEN r.review_score <= 2
            THEN 1 ELSE 0
        END) AS low_reviews,

    CAST(
        100.0 * SUM(CASE
                        WHEN r.review_score <= 2
                        THEN 1 ELSE 0
                    END) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS low_review_percentage

FROM orders o

JOIN reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY
    CASE
        WHEN o.order_delivered_customer_date >
             o.order_estimated_delivery_date
        THEN 'Late'
        ELSE 'On Time'
    END;


-- Q12: Which categories have BOTH high revenue and high late-delivery rates?
-- This creates a business-risk view combining two dimensions.

SELECT
    ct.product_category_name_english AS category,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(oi.price) AS revenue,

    CAST(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN o.order_id
        END)
        / COUNT(DISTINCT o.order_id)
        AS DECIMAL(5,2)
    ) AS late_delivery_percentage

FROM orders o

JOIN order_items oi
    ON o.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY ct.product_category_name_english

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY
    revenue DESC,
    late_delivery_percentage DESC;