-- Q1: What are the top product categories by number of items sold?

SELECT
    ct.product_category_name_english AS category,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    ct.product_category_name_english
ORDER BY
    items_sold DESC;

-- Q2: Which product categories generate the highest revenue?

SELECT
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    ct.product_category_name_english
ORDER BY
    total_revenue DESC;

-- Q3: Which product categories have the highest average selling price?

SELECT
    ct.product_category_name_english AS category,
    ROUND(AVG(oi.price), 2) AS avg_item_price,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    ct.product_category_name_english
HAVING COUNT(*) >= 50
ORDER BY
    avg_item_price DESC;

-- Q4: Which product categories have the highest average freight cost?

SELECT
    ct.product_category_name_english AS category,
    ROUND(AVG(oi.freight_value), 2) AS avg_freight,
    ROUND(AVG(oi.price), 2) AS avg_product_price
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    ct.product_category_name_english
HAVING COUNT(*) >= 50
ORDER BY
    avg_freight DESC;

-- Q5: Which product categories have the lowest average review scores?

SELECT
    ct.product_category_name_english AS category,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score,
    COUNT(r.review_id) AS review_count
FROM reviews r
JOIN order_items oi
    ON r.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    ct.product_category_name_english
HAVING COUNT(r.review_id) >= 50
ORDER BY
    avg_review_score ASC;

-- Q6: Which categories combine high revenue with low customer satisfaction?

SELECT
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    COUNT(r.review_id) AS review_count
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
LEFT JOIN reviews r
    ON oi.order_id = r.order_id
GROUP BY
    ct.product_category_name_english
HAVING COUNT(DISTINCT oi.order_id) >= 50
ORDER BY
    total_revenue DESC;

-- Q7: Is there a relationship between product price and customer review score?

SELECT
    CASE
        WHEN oi.price < 50 THEN 'Under 50'
        WHEN oi.price < 100 THEN '50 - 99'
        WHEN oi.price < 200 THEN '100 - 199'
        WHEN oi.price < 500 THEN '200 - 499'
        ELSE '500+'
    END AS price_range,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score
FROM order_items oi
JOIN reviews r
    ON oi.order_id = r.order_id
GROUP BY
    CASE
        WHEN oi.price < 50 THEN 'Under 50'
        WHEN oi.price < 100 THEN '50 - 99'
        WHEN oi.price < 200 THEN '100 - 199'
        WHEN oi.price < 500 THEN '200 - 499'
        ELSE '500+'
    END
ORDER BY
    avg_review_score DESC;

-- Q8: Which categories have the largest product catalog?

SELECT
    ct.product_category_name_english AS category,
    COUNT(DISTINCT p.product_id) AS product_count
FROM products p
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    ct.product_category_name_english
ORDER BY
    product_count DESC;

-- Q9: Which categories have a large product catalog but relatively low sales?

SELECT
    ct.product_category_name_english AS category,
    COUNT(DISTINCT p.product_id) AS products_in_catalog,
    COUNT(oi.order_item_id) AS items_sold,
    ROUND(SUM(oi.price), 2) AS revenue
FROM products p
LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
LEFT JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    ct.product_category_name_english
ORDER BY
    products_in_catalog DESC;


-- Q10: What is the overall performance of each product category?

SELECT
    ct.product_category_name_english AS category,

    COUNT(DISTINCT p.product_id) AS product_count,

    COUNT(DISTINCT oi.order_id) AS orders_count,

    COUNT(oi.order_item_id) AS items_sold,

    ROUND(SUM(oi.price), 2) AS revenue,

    ROUND(AVG(oi.price), 2) AS avg_item_price,

    ROUND(AVG(oi.freight_value), 2) AS avg_freight,

    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score

FROM products p

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

LEFT JOIN order_items oi
    ON p.product_id = oi.product_id

LEFT JOIN reviews r
    ON oi.order_id = r.order_id

GROUP BY
    ct.product_category_name_english

HAVING COUNT(oi.order_item_id) > 0

ORDER BY
    revenue DESC;