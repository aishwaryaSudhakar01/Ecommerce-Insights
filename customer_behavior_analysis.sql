-- create segmented_customers table with segments based on total amount spent and average days between purchases
CREATE TABLE retail.segmented_customers AS 
WITH customer_summary AS (
  SELECT
    CustomerID,
    ROUND(SUM(Quantity * UnitPrice)) AS total_amount_spent,
    ROUND((DATE_DIFF(MAX(InvoiceDate), MIN(InvoiceDate), DAY) / COUNT(*))) AS avg_days_between_purchases
  FROM `retail.retail_data` 
  WHERE CustomerID IS NOT NULL
  GROUP BY CustomerID
)

SELECT
  CustomerID,
  total_amount_spent,
  avg_days_between_purchases,
  CASE
    WHEN value_segment = 1 THEN 'Low'
    WHEN value_segment = 2 THEN 'Medium'
    WHEN value_segment = 3 THEN 'High'
    ELSE NULL
  END AS value_segment,
  CASE
    WHEN frequency_segment = 1 THEN 'Frequent'
    WHEN frequency_segment = 2 THEN 'Regular'
    WHEN frequency_segment = 3 THEN 'Infrequent'
    ELSE NULL
  END AS frequency_segment
FROM (
  SELECT
    CustomerID,
    total_amount_spent,
    avg_days_between_purchases,
    NTILE(3) OVER (ORDER BY total_amount_spent) AS value_segment, 
    NTILE(3) OVER (ORDER BY avg_days_between_purchases) AS frequency_segment
  FROM customer_summary
  WHERE avg_days_between_purchases <> 0
);

-- display segmented customers
SELECT *
FROM `retail.segmented_customers`
ORDER BY CustomerID;

-- count of occurrence of customer segments
SELECT
  CONCAT(value_segment, ' - ', frequency_segment) AS segment_combination,
  COUNT(*) AS frequency_count
FROM `retail.segmented_customers`
GROUP BY CONCAT(value_segment, ' - ', frequency_segment)
ORDER BY segment_combination DESC;

-- dormant vs consistent customers
WITH customer_purchases AS (
  SELECT
    CustomerID,
    MIN(InvoiceDate) AS first_purchase_date,
    MAX(InvoiceDate) AS last_purchase_date
  FROM`retail.retail_data`
  WHERE InvoiceDate BETWEEN TIMESTAMP('2010-12-01') AND TIMESTAMP('2011-12-09')
  GROUP BY CustomerID
),

customer_classification AS (
  SELECT
    CustomerID,
    CASE
      WHEN first_purchase_date BETWEEN TIMESTAMP('2010-12-01') AND TIMESTAMP('2011-06-30')
        AND last_purchase_date BETWEEN TIMESTAMP('2011-07-01') AND TIMESTAMP('2011-12-09')
          THEN 'Consistent'
      WHEN first_purchase_date BETWEEN TIMESTAMP('2010-12-01') AND TIMESTAMP('2011-06-30')
        AND last_purchase_date <= TIMESTAMP('2011-06-30')
        THEN 'Dormant'
      ELSE 'Other'
    END AS customer_status
  FROM customer_purchases
  WHERE  CustomerID IN (
    SELECT DISTINCT CustomerID
    FROM `retail.segmented_customers`
  )
)

SELECT
  COUNTIF(customer_status = 'Dormant') AS dormant_count,
  COUNTIF(customer_status = 'Consistent') AS consistent_count,
  ROUND(COUNTIF(customer_status = 'Consistent') / COUNT(*) * 100) AS consistent_percentage
FROM customer_classification
WHERE customer_status IN ('Dormant', 'Consistent');

-- customer lifetime value
WITH customer_revenue AS (
  SELECT
    CustomerID,
    ROUND(SUM(Quantity * UnitPrice)) AS total_revenue
  FROM `retail.retail_data`
  WHERE CustomerID IS NOT NULL
  GROUP BY CustomerID
),

purchase_frequency AS (
  SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_transactions
  FROM `retail.retail_data`
  WHERE CustomerID IS NOT NULL
  GROUP BY CustomerID
),

average_purchase_frequency AS (
  SELECT AVG(total_transactions) AS avg_purchase_frequency
  FROM purchase_frequency
),

customer_lifespan AS (
  SELECT
    CustomerID,
    DATE_DIFF(MAX(InvoiceDate), MIN(InvoiceDate), DAY) AS lifespan_days
  FROM`retail.retail_data`
  WHERE CustomerID IS NOT NULL
  GROUP BY CustomerID
),

average_customer_lifespan AS (
  SELECT ROUND(AVG(lifespan_days) / 30) AS avg_lifespan_months 
  FROM customer_lifespan
)

SELECT
  cr.CustomerID,
  cr.total_revenue,
  pf.total_transactions,
  ROUND((cr.total_revenue / pf.total_transactions)) AS avg_order_value,
  acf.avg_purchase_frequency,
  acl.avg_lifespan_months,
  ROUND((cr.total_revenue / pf.total_transactions) * acf.avg_purchase_frequency * acl.avg_lifespan_months) AS clv
FROM customer_revenue cr
JOIN purchase_frequency pf
  ON
    cr.CustomerID = pf.CustomerID,
    average_purchase_frequency acf,
    average_customer_lifespan acl
ORDER BY clv DESC;

-- Calculate Churn Rate
WITH customer_summary AS (
  SELECT
    CustomerID,
    MAX(InvoiceDate) AS last_purchase_date
  FROM `retail.retail_data`
  WHERE CustomerID IS NOT NULL
  GROUP BY CustomerID
)

SELECT
  COUNTIF(last_purchase_date < TIMESTAMP('2011-06-01')) AS churned_customers,
  COUNT(DISTINCT CustomerID) AS total_customers,
  ROUND(COUNTIF(last_purchase_date < TIMESTAMP('2011-06-01')) * 100.0 / COUNT(DISTINCT CustomerID)) AS churn_rate
FROM customer_summary;
