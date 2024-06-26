-- Customer Segmentation
WITH customer_agg AS (
    SELECT
        c.customer_id,
        COUNT(o.order_id) AS total_orders,
        SUM(p.payment_value) AS total_spent,
        DATEDIFF(MAX(o.order_purchase_timestamp), MIN(o.order_purchase_timestamp)) / COUNT(o.order_id) AS avg_time_between_orders,
        MAX(o.order_purchase_timestamp) AS last_order_date
    FROM
        customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id
)

SELECT
  customer_id,
  total_orders,
  total_spent,
  avg_time_between_orders,
  CASE  
    WHEN total_spent > 10000 THEN 'High Value'
	WHEN total_spent BETWEEN 5000 AND 10000 THEN 'Medium Value'
	ELSE 'Low Value'
  END AS value_segment,
  CASE 
	WHEN avg_time_between_orders < 30 THEN 'Frequent'
	WHEN avg_time_between_orders BETWEEN 30 AND 90 THEN 'Regular'
	ELSE 'Infrequent'
  END AS frequency_segment
FROM
  customer_agg;

-- Customer Lifetime Value Prediction
WITH customer_lifetime AS (
    SELECT
        c.customer_id,
        AVG(p.payment_value) AS avg_order_value,
        COUNT(o.order_id) / DATEDIFF(MAX(o.order_purchase_timestamp), MIN(o.order_purchase_timestamp)) * 365 AS purchase_frequency_per_year,
        DATEDIFF(MAX(o.order_purchase_timestamp), MIN(o.order_purchase_timestamp)) / 365 AS customer_lifespan_years
    FROM
        customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_payments p ON o.order_id = p.order_id
    GROUP BY c.customer_id
)

SELECT 
    customer_id,
    avg_order_value * purchase_frequency_per_year * customer_lifespan_years AS predicted_clv
FROM
    customer_lifetime;

-- Customer Churn Prediction
WITH recent_orders AS (
    SELECT
        customer_id,
        MAX(order_purchase_timestamp) AS last_order_date
    FROM
        orders
    GROUP BY customer_id
)

SELECT
    ro.customer_id,
    CASE 
        WHEN DATEDIFF(CURDATE(), ro.last_order_date) > 365 THEN 'Churned'
        ELSE 'Active'
    END AS churn_status,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    c.customer_zip_code_prefix
FROM
    recent_orders ro
JOIN customers c ON ro.customer_id = c.customer_id
ORDER BY churn_status DESC;

