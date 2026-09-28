USE OlistDB;
GO

-- ============================================================
-- CUSTOMER & SELLER BUSINESS ANALYSIS
-- ============================================================


-- Q1: How many unique customers placed orders, and how many
-- customers placed more than one order?
SELECT
    COUNT(*) AS total_customers,

    SUM(CASE
            WHEN order_count > 1 THEN 1
            ELSE 0
        END) AS repeat_customers,

    SUM(CASE
            WHEN order_count = 1 THEN 1
            ELSE 0
        END) AS one_time_customers,

    CAST(
        100.0 * SUM(CASE
                        WHEN order_count > 1 THEN 1
                        ELSE 0
                    END) / COUNT(*)
        AS DECIMAL(5,2)
    ) AS repeat_customer_percentage

FROM (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
) AS customer_orders;


-- Q2: Which customer states generate the highest revenue?
SELECT
    c.customer_state,

    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(p.payment_value) AS total_revenue,

    AVG(p.payment_value) AS average_payment_value

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN payments p
    ON o.order_id = p.order_id

WHERE o.order_status <> 'canceled'

GROUP BY c.customer_state

ORDER BY total_revenue DESC;


-- Q3: Which states have high customer volume but relatively low
-- average order value?
SELECT
    c.customer_state,

    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(p.payment_value) AS total_revenue,

    AVG(p.payment_value) AS average_order_value

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN payments p
    ON o.order_id = p.order_id

WHERE o.order_status <> 'canceled'

GROUP BY c.customer_state

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY average_order_value ASC;


-- Q4: Do repeat customers generate more revenue per customer
-- than one-time customers?
SELECT
    CASE
        WHEN customer_order_count > 1
        THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type,

    COUNT(*) AS number_of_customers,

    SUM(total_customer_revenue) AS total_revenue,

    AVG(total_customer_revenue) AS average_revenue_per_customer

FROM (
    SELECT
        c.customer_unique_id,

        COUNT(DISTINCT o.order_id) AS customer_order_count,

        SUM(p.payment_value) AS total_customer_revenue

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN payments p
        ON o.order_id = p.order_id

    WHERE o.order_status <> 'canceled'

    GROUP BY c.customer_unique_id
) AS customer_summary

GROUP BY
    CASE
        WHEN customer_order_count > 1
        THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END;


-- Q5: Which sellers generate the highest revenue?
SELECT TOP 20
    oi.seller_id,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    COUNT(*) AS total_items,

    SUM(oi.price) AS product_revenue,

    SUM(oi.freight_value) AS total_freight,

    AVG(oi.price) AS average_item_price

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status <> 'canceled'

GROUP BY oi.seller_id

ORDER BY product_revenue DESC;


-- Q6: Which sellers have high revenue but also high delivery
-- delay rates?
SELECT TOP 20
    oi.seller_id,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(oi.price) AS product_revenue,

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

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY oi.seller_id

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY late_delivery_percentage DESC;


-- Q7: Which seller states generate the highest revenue?
SELECT
    s.seller_state,

    COUNT(DISTINCT s.seller_id) AS number_of_sellers,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    SUM(oi.price) AS product_revenue,

    AVG(oi.price) AS average_item_price

FROM sellers s

JOIN order_items oi
    ON s.seller_id = oi.seller_id

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status <> 'canceled'

GROUP BY s.seller_state

ORDER BY product_revenue DESC;


-- Q8: How does seller location relate to delivery performance?
SELECT
    s.seller_state,

    COUNT(DISTINCT oi.order_id) AS delivered_orders,

    AVG(
        DATEDIFF(
            DAY,
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        )
    ) AS average_delivery_days,

    CAST(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN o.order_delivered_customer_date >
                 o.order_estimated_delivery_date
            THEN o.order_id
        END)
        / COUNT(DISTINCT oi.order_id)
        AS DECIMAL(5,2)
    ) AS late_delivery_percentage

FROM sellers s

JOIN order_items oi
    ON s.seller_id = oi.seller_id

JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY s.seller_state

HAVING COUNT(DISTINCT oi.order_id) >= 100

ORDER BY late_delivery_percentage DESC;


-- Q9: Which sellers have strong sales volume and customer
-- satisfaction?
SELECT TOP 20
    oi.seller_id,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    SUM(oi.price) AS product_revenue,

    AVG(CAST(r.review_score AS DECIMAL(10,2)))
        AS average_review_score

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN reviews r
    ON o.order_id = r.order_id

WHERE o.order_status = 'delivered'

GROUP BY oi.seller_id

HAVING COUNT(DISTINCT oi.order_id) >= 100

ORDER BY
    product_revenue DESC,
    average_review_score DESC;


-- Q10: Which customer states have both high revenue and high
-- late-delivery rates?
-- This identifies potentially important markets with delivery issues.

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

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN payments p
    ON o.order_id = p.order_id

WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL

GROUP BY c.customer_state

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY
    total_revenue DESC,
    late_delivery_percentage DESC;


-- Q11: What is the average order value for repeat vs one-time
-- customers?
SELECT
    CASE
        WHEN customer_order_count > 1
        THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type,

    COUNT(DISTINCT order_id) AS total_orders,

    AVG(order_value) AS average_order_value

FROM (
    SELECT
        c.customer_unique_id,
        o.order_id,

        COUNT(o.order_id) OVER (
            PARTITION BY c.customer_unique_id
        ) AS customer_order_count,

        SUM(p.payment_value) AS order_value

    FROM customers c

    JOIN orders o
        ON c.customer_id = o.customer_id

    JOIN payments p
        ON o.order_id = p.order_id

    WHERE o.order_status <> 'canceled'

    GROUP BY
        c.customer_unique_id,
        o.order_id
) AS customer_order_data

GROUP BY
    CASE
        WHEN customer_order_count > 1
        THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END;


-- Q12: Which sellers have a large customer base but relatively
-- low average order value?
SELECT TOP 20
    oi.seller_id,

    COUNT(DISTINCT o.order_id) AS total_orders,

    COUNT(DISTINCT c.customer_unique_id) AS unique_customers,

    SUM(oi.price) AS revenue,

    SUM(oi.price) /
        NULLIF(COUNT(DISTINCT o.order_id), 0)
        AS revenue_per_order

FROM order_items oi

JOIN orders o
    ON oi.order_id = o.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

WHERE o.order_status <> 'canceled'

GROUP BY oi.seller_id

HAVING COUNT(DISTINCT o.order_id) >= 100

ORDER BY revenue_per_order ASC;