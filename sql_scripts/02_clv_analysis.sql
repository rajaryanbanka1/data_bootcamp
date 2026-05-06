--Calculating the Customer Lifetime Value for a Region
SELECT 
    u.region,
    COALESCE(SUM(t.amount), 0) AS total_revenue,
    COUNT(DISTINCT t.transaction_id) AS total_orders
FROM users u
LEFT JOIN transactions t ON u.user_id = t.user_id
GROUP BY u.region
ORDER BY total_revenue DESC;


