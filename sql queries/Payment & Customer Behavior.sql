USE OlistDB;
GO

-- ============================================================
-- PAYMENT & CUSTOMER BEHAVIOR ANALYSIS
-- ============================================================


-- ============================================================
-- Q1: What are the most commonly used payment methods?
-- ============================================================

SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER(),
        2
    ) AS payment_percentage
FROM payments
GROUP BY payment_type
ORDER BY payment_count DESC;


-- ============================================================
-- Q2: What is the total payment value by payment method?
-- ============================================================

SELECT
    payment_type,
    COUNT(*) AS number_of_payments,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(AVG(payment_value), 2) AS average_payment_value
FROM payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- ============================================================
-- Q3: Which payment methods have the highest average transaction value?
-- ============================================================

SELECT
    payment_type,
    ROUND(AVG(payment_value), 2) AS average_payment_value,
    COUNT(*) AS number_of_transactions
FROM payments
GROUP BY payment_type
ORDER BY average_payment_value DESC;


-- ============================================================
-- Q4: How common are installment payments?
-- ============================================================

SELECT
    payment_installments,
    COUNT(*) AS payment_count,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- ============================================================
-- Q5: What is the distribution of installment payments?
-- ============================================================

SELECT
    CASE
        WHEN payment_installments = 1 THEN '1 Installment'
        WHEN payment_installments BETWEEN 2 AND 3 THEN '2-3 Installments'
        WHEN payment_installments BETWEEN 4 AND 6 THEN '4-6 Installments'
        WHEN payment_installments BETWEEN 7 AND 12 THEN '7-12 Installments'
        ELSE '13+ Installments'
    END AS installment_group,

    COUNT(*) AS payment_count,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage

FROM payments
GROUP BY
    CASE
        WHEN payment_installments = 1 THEN '1 Installment'
        WHEN payment_installments BETWEEN 2 AND 3 THEN '2-3 Installments'
        WHEN payment_installments BETWEEN 4 AND 6 THEN '4-6 Installments'
        WHEN payment_installments BETWEEN 7 AND 12 THEN '7-12 Installments'
        ELSE '13+ Installments'
    END
ORDER BY payment_count DESC;


-- ============================================================
-- Q6: Do customers who use more installments have higher order values?
-- ============================================================

SELECT
    payment_installments,
    COUNT(DISTINCT order_id) AS number_of_orders,
    ROUND(AVG(payment_value), 2) AS average_payment_value,
    ROUND(SUM(payment_value), 2) AS total_payment_value
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;


-- ============================================================
-- Q7: Which orders were paid using multiple payment transactions?
-- ============================================================

SELECT
    order_id,
    COUNT(*) AS payment_count,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    MAX(payment_installments) AS max_installments
FROM payments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_count DESC;


-- ============================================================
-- Q8: What percentage of orders use multiple payment transactions?
-- ============================================================

WITH order_payments AS
(
    SELECT
        order_id,
        COUNT(*) AS payment_count
    FROM payments
    GROUP BY order_id
)

SELECT
    COUNT(*) AS total_orders_with_payments,

    SUM(
        CASE
            WHEN payment_count > 1 THEN 1
            ELSE 0
        END
    ) AS multiple_payment_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN payment_count > 1 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS multiple_payment_percentage

FROM order_payments;


-- ============================================================
-- Q9: What is the average order value by payment type?
-- ============================================================

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS number_of_orders,
    ROUND(SUM(payment_value), 2) AS total_revenue,
    ROUND(
        SUM(payment_value) / COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM payments
GROUP BY payment_type
ORDER BY average_order_value DESC;


-- ============================================================
-- Q10: How does payment behavior differ between late and on-time orders?
-- ============================================================

SELECT
    o.late_delivery,

    COUNT(DISTINCT o.order_id) AS number_of_orders,

    ROUND(AVG(p.payment_value), 2) AS average_payment_value,

    ROUND(AVG(p.payment_installments), 2) AS average_installments,

    ROUND(AVG(
        CASE
            WHEN p.payment_type = 'credit_card'
            THEN 1.0
            ELSE 0.0
        END
    ) * 100, 2) AS credit_card_percentage

FROM orders o
JOIN payments p
    ON o.order_id = p.order_id

GROUP BY o.late_delivery
ORDER BY o.late_delivery;


-- ============================================================
-- Q11: Which payment types are associated with late deliveries?
-- ============================================================

SELECT
    p.payment_type,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(
        CASE
            WHEN o.late_delivery = 1 THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN o.late_delivery = 1 THEN 1
                ELSE 0
            END
        ) / COUNT(DISTINCT o.order_id),
        2
    ) AS late_delivery_percentage

FROM payments p
JOIN orders o
    ON p.order_id = o.order_id

GROUP BY p.payment_type

ORDER BY late_delivery_percentage DESC;


-- ============================================================
-- Q12: Do customers with multiple orders spend more overall?
-- ============================================================

WITH customer_orders AS
(
    SELECT
        o.customer_id,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(p.payment_value) AS total_spending
    FROM orders o
    JOIN payments p
        ON o.order_id = p.order_id
    GROUP BY o.customer_id
)

SELECT
    CASE
        WHEN order_count = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,

    COUNT(*) AS number_of_customers,

    ROUND(AVG(total_spending), 2) AS average_total_spending,

    ROUND(AVG(order_count), 2) AS average_orders

FROM customer_orders

GROUP BY
    CASE
        WHEN order_count = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END

ORDER BY average_total_spending DESC;


-- ============================================================
-- Q13: Who are the highest-value customers?
-- ============================================================

SELECT TOP 20
    o.customer_id,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(SUM(p.payment_value), 2) AS total_spending,

    ROUND(
        SUM(p.payment_value) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM orders o
JOIN payments p
    ON o.order_id = p.order_id

GROUP BY o.customer_id

ORDER BY total_spending DESC;


-- ============================================================
-- Q14: What is the average spending per customer by state?
-- ============================================================

SELECT
    c.customer_state,

    COUNT(DISTINCT c.customer_unique_id) AS customers,

    ROUND(
        SUM(p.payment_value) /
        COUNT(DISTINCT c.customer_unique_id),
        2
    ) AS average_customer_spending,

    ROUND(SUM(p.payment_value), 2) AS total_revenue

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN payments p
    ON o.order_id = p.order_id

GROUP BY c.customer_state

ORDER BY average_customer_spending DESC;


-- ============================================================
-- Q15: Which states generate the highest payment revenue?
-- ============================================================

SELECT
    c.customer_state,

    COUNT(DISTINCT o.order_id) AS total_orders,

    ROUND(SUM(p.payment_value), 2) AS total_revenue,

    ROUND(
        SUM(p.payment_value) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value

FROM customers c

JOIN orders o
    ON c.customer_id = o.customer_id

JOIN payments p
    ON o.order_id = p.order_id

GROUP BY c.customer_state

ORDER BY total_revenue DESC;


-- ============================================================
-- Q16: Is higher-value spending associated with installment payments?
-- ============================================================

SELECT
    CASE
        WHEN p.payment_value < 50 THEN 'Under 50'
        WHEN p.payment_value < 100 THEN '50-99'
        WHEN p.payment_value < 200 THEN '100-199'
        WHEN p.payment_value < 500 THEN '200-499'
        ELSE '500+'
    END AS order_value_group,

    ROUND(AVG(p.payment_installments), 2) AS average_installments,

    COUNT(*) AS number_of_payments

FROM payments p

GROUP BY
    CASE
        WHEN p.payment_value < 50 THEN 'Under 50'
        WHEN p.payment_value < 100 THEN '50-99'
        WHEN p.payment_value < 200 THEN '100-199'
        WHEN p.payment_value < 500 THEN '200-499'
        ELSE '500+'
    END

ORDER BY
    MIN(p.payment_value);


-- ============================================================
-- Q17: What are the main payment behaviors of customers?
-- ============================================================

WITH customer_payment_behavior AS
(
    SELECT
        o.customer_id,

        COUNT(DISTINCT o.order_id) AS total_orders,

        SUM(p.payment_value) AS total_spending,

        AVG(p.payment_value) AS average_payment,

        AVG(p.payment_installments) AS average_installments

    FROM orders o

    JOIN payments p
        ON o.order_id = p.order_id

    GROUP BY o.customer_id
)

SELECT
    CASE
        WHEN total_orders = 1
            THEN 'One-time'

        WHEN total_orders BETWEEN 2 AND 3
            THEN 'Occasional Repeat'

        ELSE 'Frequent Repeat'
    END AS customer_segment,

    COUNT(*) AS customers,

    ROUND(AVG(total_spending), 2) AS avg_total_spending,

    ROUND(AVG(average_payment), 2) AS avg_payment_value,

    ROUND(AVG(average_installments), 2) AS avg_installments

FROM customer_payment_behavior

GROUP BY
    CASE
        WHEN total_orders = 1
            THEN 'One-time'

        WHEN total_orders BETWEEN 2 AND 3
            THEN 'Occasional Repeat'

        ELSE 'Frequent Repeat'
    END

ORDER BY avg_total_spending DESC;


-- ============================================================
-- Q18: What percentage of revenue comes from credit cards?
-- ============================================================

SELECT
    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN payment_type = 'credit_card'
                THEN payment_value
                ELSE 0
            END
        ) / SUM(payment_value),
        2
    ) AS credit_card_revenue_percentage

FROM payments;





-- ============================================================
-- Q19: What are the key payment KPIs?
-- ============================================================

SELECT

    COUNT(DISTINCT order_id) AS total_orders,

    COUNT(*) AS total_payment_transactions,

    ROUND(SUM(payment_value), 2) AS total_payment_value,

    ROUND(AVG(payment_value), 2) AS average_payment_value,

    ROUND(AVG(payment_installments), 2) AS average_installments,

    COUNT(DISTINCT
        CASE
            WHEN payment_type = 'credit_card'
            THEN order_id
        END
    ) AS credit_card_orders,

    COUNT(DISTINCT
        CASE
            WHEN payment_type = 'boleto'
            THEN order_id
        END
    ) AS boleto_orders

FROM payments;