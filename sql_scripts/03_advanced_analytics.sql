-- 1. Create Products Table
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2)
);

-- 2. Insert Robust Product Data
INSERT INTO products VALUES
(101, 'Mechanical Keyboard', 'Tech', 150.00),
(102, 'Ergonomic Mouse', 'Tech', 80.00),
(103, 'Office Chair', 'Furniture', 300.00),
(104, 'Noise Cancelling Headphones', 'Tech', 250.00),
(105, 'Standing Desk', 'Furniture', 500.00);

-- 3. Expand Users (10 Diverse Users)
TRUNCATE TABLE users CASCADE; 
INSERT INTO users (user_id, signup_date, region, membership_type) VALUES
('USR_001', '2026-01-10', 'North', 'Premium'),
('USR_002', '2026-01-15', 'South', 'Basic'),
('USR_003', '2026-02-01', 'West', 'Basic'),
('USR_004', '2026-02-10', 'East', 'Premium'),
('USR_005', '2026-02-20', 'North', 'Basic'),
('USR_006', '2026-03-05', 'West', 'Premium'),
('USR_007', '2026-03-12', 'South', 'Basic'),
('USR_008', '2026-04-01', 'North', 'Premium'),
('USR_009', '2026-04-15', 'East', 'Basic'),
('USR_010', '2026-05-01', 'South', 'Premium');

-- 4. Expand Transactions (High Frequency for Metric Calculation)
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    user_id VARCHAR(50),
    product_id INT,
    purchase_time TIMESTAMP,
    amount DECIMAL(10, 2)
);

INSERT INTO transactions (user_id, product_id, purchase_time, amount) VALUES
('USR_001', 101, '2026-01-12 10:00:00', 150.00),
('USR_001', 102, '2026-02-15 11:00:00', 80.00),
('USR_001', 104, '2026-03-20 14:00:00', 250.00), -- High Value User
('USR_002', 102, '2026-01-16 09:00:00', 80.00),
('USR_002', 102, '2026-04-10 12:00:00', 80.00),
('USR_003', 103, '2026-02-05 16:00:00', 300.00),
('USR_005', 101, '2026-02-22 10:30:00', 150.00),
('USR_006', 105, '2026-03-10 11:15:00', 500.00),
('USR_006', 104, '2026-04-15 15:00:00', 250.00),
('USR_008', 101, '2026-04-05 13:00:00', 150.00),
('USR_008', 102, '2026-05-02 10:00:00', 80.00),
('USR_010', 105, '2026-05-05 09:00:00', 500.00);


-- Advanced CLV & AOV Dashboard
WITH user_metrics AS (
    SELECT 
        user_id,
        COUNT(transaction_id) AS total_orders,
        SUM(amount) AS total_spent,
        DATE(MAX(purchase_time)) - DATE(MIN(purchase_time)) AS customer_lifespan_days
    FROM transactions
    GROUP BY user_id
)
select
	u.region AS Region,
    ROUND(AVG(um.total_spent / NULLIF(um.total_orders, 0)),2) AS average_order_value,
    ROUND(AVG(um.total_spent),2) AS current_clv
FROM users u
join user_metrics um
on u.user_id = um.user_id 
GROUP BY region
order BY current_clv DESC;

-- Ranking Regional Customers
SELECT 
    user_id,
    region,
    SUM(amount) as total_spent,
    RANK() OVER(PARTITION BY region ORDER BY SUM(amount) DESC) as regional_rank
FROM users
JOIN transactions USING (user_id)
GROUP BY user_id, region;


--Month-over-Month (MoM) Growth
WITH monthly_sales AS (
    SELECT 
        DATE_TRUNC('month', purchase_time) AS sales_month,
        SUM(amount) AS total_revenue
    FROM transactions
    GROUP BY 1
)
SELECT 
    sales_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY sales_month) AS prev_month_revenue,
    ROUND(
        (total_revenue - LAG(total_revenue) OVER (ORDER BY sales_month)) / 
        NULLIF(LAG(total_revenue) OVER (ORDER BY sales_month), 0) * 100, 2
    ) AS mom_growth_pct
FROM monthly_sales;


