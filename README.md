# Online Retail Dataset Analysis

This repository contains SQL queries to analyze customer behavior and trends using the Online Retail Dataset from the UCI Machine Learning Repository. The analysis covers various aspects, including customer segmentation, dormant vs. consistent customers, customer lifetime value, and churn rate.

![sql_pj1](https://github.com/aishwaryaSudhakar01/Ecommerce-Insights/assets/126569607/8437f521-4dd0-427f-acf1-9115e1d47493)

## Dataset

The dataset consists of transactions from a UK-based online retailer from 2010 to 2011. Each row represents a transaction, including details such as `CustomerID`, `InvoiceDate`, `Quantity`, and `UnitPrice`.

[Online Retail Dataset](https://archive.ics.uci.edu/dataset/352/online+retail)

## Queries and Analyses

### 1. Customer Segmentation

**Problem Statement:** Segment customers based on their total spending and average days between purchases.

**SQL Functions and Steps:**
- **Aggregating Data:** Calculate the total amount spent and average days between purchases for each customer.
- **Segmentation:** Use NTILE to divide customers into segments (Low, Medium, High) based on total spending and purchase frequency (Frequent, Regular, Infrequent).

![sql_1](https://github.com/aishwaryaSudhakar01/Ecommerce-Insights/assets/126569607/3f48b8bc-136f-4eb6-94ba-0bcb7ff34b82)

![sql_2](https://github.com/aishwaryaSudhakar01/Ecommerce-Insights/assets/126569607/1e39e485-0e0c-4712-951d-f72476fc94c5)

### 2. Count of Occurrence of Customer Segments

**Problem Statement:** Determine the frequency of each customer segment combination.

**SQL Functions and Steps:**
- **Concatenation and Counting:** Combine the value and frequency segments into a single column and count occurrences of each segment combination.
- **Grouping and Ordering:** Group by the concatenated segment combination and order by the frequency count.

![sql_3](https://github.com/aishwaryaSudhakar01/Ecommerce-Insights/assets/126569607/506971f3-34d0-4471-a9e5-a1c8422b8d52)

### 3. Dormant vs. Consistent Customers

**Problem Statement:** Identify customers who have become dormant versus those who are consistent.

**SQL Functions and Steps:**
- **Purchase Dates:** Calculate the first and last purchase dates for each customer.
- **Classification:** Classify customers as 'Consistent' or 'Dormant' based on their purchase activity within specified date ranges.

![sql_4](https://github.com/aishwaryaSudhakar01/Ecommerce-Insights/assets/126569607/b79ac75e-c56d-46d3-ad75-9242e9febe66)

### 4. Customer Lifetime Value (CLV)

**Problem Statement:** Calculate the customer lifetime value.

**SQL Functions and Steps:**
- **Revenue Calculation:** Calculate total revenue per customer.
- **Purchase Frequency:** Determine the total number of transactions per customer.
- **Average Values:** Calculate the average order value, purchase frequency, and customer lifespan.
- **CLV Calculation:** Use the above values to compute the customer lifetime value.

![sql_5](https://github.com/aishwaryaSudhakar01/Ecommerce-Insights/assets/126569607/b8c2601e-9230-4796-a177-2fec2bc608ee)

![sql_6](https://github.com/aishwaryaSudhakar01/Ecommerce-Insights/assets/126569607/45ff0713-03e2-489a-ad54-ebbb70caf27a)

### 5. Churn Rate

**Problem Statement:** Calculate the churn rate for the customers.

**SQL Functions and Steps:**
- **Last Purchase Date:** Identify the last purchase date for each customer.
- **Churn Calculation:** Determine the number of churned customers (those whose last purchase was before a specific date) and calculate the churn rate.

![sql_7](https://github.com/aishwaryaSudhakar01/Ecommerce-Insights/assets/126569607/fa321d1d-a423-4a2b-bf51-14a573d3f4e6)
