USE OlistDB;
GO

-- ============================================================
-- REVIEW & CUSTOMER SATISFACTION ANALYSIS
-- ============================================================


-- ============================================================
-- Q1: What is the overall distribution of review scores?
-- ============================================================

SELECT
    review_score,
    COUNT(*) AS number_of_reviews,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage

FROM reviews

GROUP BY review_score

ORDER BY review_score;


-- ============================================================
-- Q2: What is the average review score?
-- ============================================================

SELECT
    ROUND(AVG(CAST(review_score AS FLOAT)), 2) AS average_review_score
FROM reviews;


-- ============================================================
-- Q3: What percentage of reviews are positive, neutral, and negative?
-- ============================================================

SELECT
    CASE
        WHEN review_score IN (1, 2)
            THEN 'Negative'

        WHEN review_score = 3
            THEN 'Neutral'

        WHEN review_score IN (4, 5)
            THEN 'Positive'
    END AS review_category,

    COUNT(*) AS number_of_reviews,

    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER(),
        2
    ) AS percentage

FROM reviews

GROUP BY
    CASE
        WHEN review_score IN (1, 2)
            THEN 'Negative'

        WHEN review_score = 3
            THEN 'Neutral'

        WHEN review_score IN (4, 5)
            THEN 'Positive'
    END

ORDER BY number_of_reviews DESC;


-- ============================================================
-- Q4: How does customer satisfaction change over time?
-- ============================================================

SELECT
    YEAR(review_creation_date) AS review_year,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(CAST(review_score AS FLOAT)),
        2
    ) AS average_review_score

FROM reviews

GROUP BY YEAR(review_creation_date)

ORDER BY review_year;


-- ============================================================
-- Q5: What is the average review score by month?
-- ============================================================

SELECT
    MONTH(review_creation_date) AS review_month,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(CAST(review_score AS FLOAT)),
        2
    ) AS average_review_score

FROM reviews

GROUP BY MONTH(review_creation_date)

ORDER BY review_month;


-- ============================================================
-- Q6: Which review scores are associated with late deliveries?
-- ============================================================

SELECT
    o.late_delivery,

    r.review_score,

    COUNT(*) AS number_of_reviews,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER(PARTITION BY o.late_delivery),
        2
    ) AS percentage

FROM reviews r

JOIN orders o
    ON r.order_id = o.order_id

GROUP BY
    o.late_delivery,
    r.review_score

ORDER BY
    o.late_delivery,
    r.review_score;


-- ============================================================
-- Q7: What is the average review score for late vs on-time orders?
-- ============================================================

SELECT
    CASE
        WHEN o.late_delivery = 1
            THEN 'Late Delivery'
        ELSE 'On-Time Delivery'
    END AS delivery_status,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(CAST(r.review_score AS FLOAT)),
        2
    ) AS average_review_score

FROM reviews r

JOIN orders o
    ON r.order_id = o.order_id

GROUP BY o.late_delivery

ORDER BY o.late_delivery;


-- ============================================================
-- Q8: Does delivery delay affect customer satisfaction?
-- ============================================================

SELECT
    CASE
        WHEN o.delivery_time_days <= 5
            THEN '0-5 Days'

        WHEN o.delivery_time_days <= 10
            THEN '6-10 Days'

        WHEN o.delivery_time_days <= 20
            THEN '11-20 Days'

        ELSE '20+ Days'
    END AS delivery_time_group,

    COUNT(*) AS number_of_orders,

    ROUND(
        AVG(CAST(r.review_score AS FLOAT)),
        2
    ) AS average_review_score

FROM reviews r

JOIN orders o
    ON r.order_id = o.order_id

WHERE o.delivery_time_days IS NOT NULL

GROUP BY
    CASE
        WHEN o.delivery_time_days <= 5
            THEN '0-5 Days'

        WHEN o.delivery_time_days <= 10
            THEN '6-10 Days'

        WHEN o.delivery_time_days <= 20
            THEN '11-20 Days'

        ELSE '20+ Days'
    END

ORDER BY
    MIN(o.delivery_time_days);


-- ============================================================
-- Q9: Which product categories receive the highest average ratings?
-- ============================================================

SELECT TOP 20
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS product_category,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(CAST(r.review_score AS FLOAT)),
        2
    ) AS average_review_score

FROM reviews r

JOIN order_items oi
    ON r.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

GROUP BY
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    )

HAVING COUNT(*) >= 50

ORDER BY average_review_score DESC;


-- ============================================================
-- Q10: Which product categories receive the lowest average ratings?
-- ============================================================

SELECT TOP 20
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS product_category,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(CAST(r.review_score AS FLOAT)),
        2
    ) AS average_review_score

FROM reviews r

JOIN order_items oi
    ON r.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

GROUP BY
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    )

HAVING COUNT(*) >= 50

ORDER BY average_review_score ASC;


-- ============================================================
-- Q11: Which sellers receive the highest average ratings?
-- ============================================================

SELECT TOP 20
    s.seller_id,

    s.seller_state,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(CAST(r.review_score AS FLOAT)),
        2
    ) AS average_review_score

FROM reviews r

JOIN order_items oi
    ON r.order_id = oi.order_id

JOIN sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    s.seller_id,
    s.seller_state

HAVING COUNT(*) >= 20

ORDER BY average_review_score DESC;


-- ============================================================
-- Q12: Which sellers receive the lowest average ratings?
-- ============================================================

SELECT TOP 20
    s.seller_id,

    s.seller_state,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(CAST(r.review_score AS FLOAT)),
        2
    ) AS average_review_score

FROM reviews r

JOIN order_items oi
    ON r.order_id = oi.order_id

JOIN sellers s
    ON oi.seller_id = s.seller_id

GROUP BY
    s.seller_id,
    s.seller_state

HAVING COUNT(*) >= 20

ORDER BY average_review_score ASC;


-- ============================================================
-- Q13: Which states have the highest customer satisfaction?
-- ============================================================

SELECT
    c.customer_state,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(CAST(r.review_score AS FLOAT)),
        2
    ) AS average_review_score,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN r.review_score IN (4, 5)
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS positive_review_percentage

FROM reviews r

JOIN orders o
    ON r.order_id = o.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

GROUP BY c.customer_state

HAVING COUNT(*) >= 100

ORDER BY average_review_score DESC;


-- ============================================================
-- Q14: Which states have the highest percentage of negative reviews?
-- ============================================================

SELECT
    c.customer_state,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(CAST(r.review_score AS FLOAT)),
        2
    ) AS average_review_score,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN r.review_score IN (1, 2)
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS negative_review_percentage

FROM reviews r

JOIN orders o
    ON r.order_id = o.order_id

JOIN customers c
    ON o.customer_id = c.customer_id

GROUP BY c.customer_state

HAVING COUNT(*) >= 100

ORDER BY negative_review_percentage DESC;


-- ============================================================
-- Q15: How many reviews contain customer comments?
-- ============================================================

SELECT
    COUNT(*) AS total_reviews,

    SUM(
        CASE
            WHEN review_comment_message IS NOT NULL
                 AND LTRIM(RTRIM(review_comment_message)) <> ''
            THEN 1
            ELSE 0
        END
    ) AS reviews_with_comments,

    SUM(
        CASE
            WHEN review_comment_message IS NULL
                 OR LTRIM(RTRIM(review_comment_message)) = ''
            THEN 1
            ELSE 0
        END
    ) AS reviews_without_comments,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN review_comment_message IS NOT NULL
                     AND LTRIM(RTRIM(review_comment_message)) <> ''
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS comment_percentage

FROM reviews;


-- ============================================================
-- Q16: Is there a relationship between review score and written comments?
-- ============================================================

SELECT
    r.review_score,

    COUNT(*) AS total_reviews,

    SUM(
        CASE
            WHEN r.review_comment_message IS NOT NULL
                 AND LTRIM(RTRIM(r.review_comment_message)) <> ''
            THEN 1
            ELSE 0
        END
    ) AS reviews_with_comments,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN r.review_comment_message IS NOT NULL
                     AND LTRIM(RTRIM(r.review_comment_message)) <> ''
                THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS comment_percentage

FROM reviews r

GROUP BY r.review_score

ORDER BY r.review_score;


-- ============================================================
-- Q17: Which review scores generate the most customer comments?
-- ============================================================

SELECT
    review_score,

    COUNT(*) AS commented_reviews

FROM reviews

WHERE review_comment_message IS NOT NULL
  AND LTRIM(RTRIM(review_comment_message)) <> ''

GROUP BY review_score

ORDER BY commented_reviews DESC;


-- ============================================================
-- Q18: What is the average response time to customer reviews?
-- ============================================================

SELECT
    ROUND(
        AVG(
            DATEDIFF(
                SECOND,
                review_creation_date,
                review_answer_timestamp
            ) / 3600.0
        ),
        2
    ) AS average_response_time_hours

FROM reviews;


-- ============================================================
-- Q19: How does response time differ by review score?
-- ============================================================

SELECT
    review_score,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(
            DATEDIFF(
                SECOND,
                review_creation_date,
                review_answer_timestamp
            ) / 3600.0
        ),
        2
    ) AS average_response_time_hours

FROM reviews

GROUP BY review_score

ORDER BY review_score;


-- ============================================================
-- Q20: Do negative reviews receive faster or slower responses?
-- ============================================================

SELECT
    CASE
        WHEN review_score IN (1, 2)
            THEN 'Negative'

        WHEN review_score = 3
            THEN 'Neutral'

        ELSE 'Positive'
    END AS review_category,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(
            DATEDIFF(
                SECOND,
                review_creation_date,
                review_answer_timestamp
            ) / 3600.0
        ),
        2
    ) AS average_response_time_hours

FROM reviews

GROUP BY
    CASE
        WHEN review_score IN (1, 2)
            THEN 'Negative'

        WHEN review_score = 3
            THEN 'Neutral'

        ELSE 'Positive'
    END

ORDER BY average_response_time_hours;


-- ============================================================
-- Q21: Which product categories have the highest number of negative reviews?
-- ============================================================

SELECT TOP 20
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS product_category,

    COUNT(*) AS total_reviews,

    SUM(
        CASE
            WHEN r.review_score IN (1, 2)
                THEN 1
            ELSE 0
        END
    ) AS negative_reviews,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN r.review_score IN (1, 2)
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS negative_review_percentage

FROM reviews r

JOIN order_items oi
    ON r.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

GROUP BY
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    )

HAVING COUNT(*) >= 50

ORDER BY negative_review_percentage DESC;


-- ============================================================
-- Q22: Does late delivery increase the probability of a negative review?
-- ============================================================

SELECT
    CASE
        WHEN o.late_delivery = 1
            THEN 'Late Delivery'
        ELSE 'On-Time Delivery'
    END AS delivery_status,

    COUNT(*) AS total_reviews,

    SUM(
        CASE
            WHEN r.review_score IN (1, 2)
                THEN 1
            ELSE 0
        END
    ) AS negative_reviews,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN r.review_score IN (1, 2)
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS negative_review_percentage

FROM reviews r

JOIN orders o
    ON r.order_id = o.order_id

GROUP BY o.late_delivery

ORDER BY o.late_delivery;


-- ============================================================
-- Q23: What is the relationship between delivery performance
-- and the extreme review scores?
-- ============================================================

SELECT
    CASE
        WHEN o.late_delivery = 1
            THEN 'Late'
        ELSE 'On-Time'
    END AS delivery_status,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN r.review_score = 1
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS one_star_percentage,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN r.review_score = 5
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS five_star_percentage

FROM reviews r

JOIN orders o
    ON r.order_id = o.order_id

GROUP BY o.late_delivery;


-- ============================================================
-- Q24: Which categories have both high review volume and strong ratings?
-- ============================================================

SELECT TOP 20
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    ) AS product_category,

    COUNT(*) AS number_of_reviews,

    ROUND(
        AVG(CAST(r.review_score AS FLOAT)),
        2
    ) AS average_review_score,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN r.review_score IN (4, 5)
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS positive_review_percentage

FROM reviews r

JOIN order_items oi
    ON r.order_id = oi.order_id

JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

GROUP BY
    COALESCE(
        ct.product_category_name_english,
        p.product_category_name
    )

HAVING COUNT(*) >= 100

ORDER BY
    number_of_reviews DESC;


-- ============================================================
-- Q25: What are the key customer satisfaction KPIs?
-- ============================================================

SELECT

    COUNT(*) AS total_reviews,

    ROUND(
        AVG(CAST(review_score AS FLOAT)),
        2
    ) AS average_review_score,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN review_score IN (4, 5)
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS positive_review_percentage,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN review_score IN (1, 2)
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS negative_review_percentage,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN review_comment_message IS NOT NULL
                     AND LTRIM(RTRIM(review_comment_message)) <> ''
                    THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS comment_percentage,

    ROUND(
        AVG(
            DATEDIFF(
                SECOND,
                review_creation_date,
                review_answer_timestamp
            ) / 3600.0
        ),
        2
    ) AS average_response_time_hours

FROM reviews;