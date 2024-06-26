-- Inventory Management
WITH product_sales AS (
    SELECT
        oi.product_id,
        SUM(oi.price) AS total_sales,
        COUNT(oi.order_item_id) AS total_orders
    FROM
        order_items oi
    GROUP BY oi.product_id
),

product_inventory AS (
    SELECT
        p.product_id,
        p.product_category_name,
        p.product_weight_g,
        p.product_length_cm,
        p.product_height_cm,
        p.product_width_cm,
        p.product_photos_qty,
        ps.total_sales,
        ps.total_orders
    FROM
        products p
    LEFT JOIN product_sales ps ON p.product_id = ps.product_id
)

SELECT
    *,
    CASE 
        WHEN total_orders IS NULL OR total_orders = 0 THEN 'No sales data'
        WHEN total_orders / (DATEDIFF(CURDATE(), '2017-01-01') / 30) > 100 THEN 'High demand'
        WHEN total_orders / (DATEDIFF(CURDATE(), '2017-01-01') / 30) BETWEEN 50 AND 100 THEN 'Medium demand'
        ELSE 'Low demand'
    END AS demand_level
FROM
    product_inventory;

-- Shipment Performance
WITH delivery_times AS (
    SELECT
        o.order_id,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS actual_delivery_time,
        DATEDIFF(o.order_estimated_delivery_date, o.order_purchase_timestamp) AS estimated_delivery_time,
        CASE 
            WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Delayed'
            ELSE 'On time'
        END AS delivery_status
    FROM
        orders o
)

SELECT
    *,
    AVG(actual_delivery_time) OVER() AS avg_actual_delivery_time,
    AVG(estimated_delivery_time) OVER() AS avg_estimated_delivery_time
FROM
    delivery_times
ORDER BY delivery_status DESC;

-- Cost Analysis
WITH logistics_costs AS (
    SELECT
        oi.product_id,
        oi.seller_id,
        oi.freight_value,
        o.order_id,
        o.order_purchase_timestamp,
        DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS delivery_time,
        CASE 
            WHEN o.order_status = 'delivered' THEN oi.freight_value / DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)
            ELSE NULL
        END AS daily_logistics_cost
    FROM
        order_items oi
    JOIN orders o ON oi.order_id = o.order_id
)

SELECT
    product_id,
    seller_id,
    AVG(daily_logistics_cost) AS avg_daily_logistics_cost,
    SUM(freight_value) AS total_logistics_cost
FROM
    logistics_costs
GROUP BY product_id, seller_id
ORDER BY total_logistics_cost DESC;
