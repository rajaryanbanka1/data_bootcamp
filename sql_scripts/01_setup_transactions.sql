create table transactions(
	transaction_id int primary key,
	user_id varchar(50) not null,
	purchase_time timestamp not null,
	amount decimal(10,2) not null
);

--truncate table transactions;

INSERT INTO transactions (transaction_id, user_id, purchase_time, amount) VALUES
(1, 'USR_001', '2026-05-01 10:00:00', 50.00),
(2, 'USR_002', '2026-05-01 11:30:00', 20.00),
(3, 'USR_001', '2026-05-01 15:45:00', 10.00), -- Repeat user on same day
(4, 'USR_003', '2026-05-02 09:15:00', 100.00),
(5, 'USR_001', '2026-05-02 14:00:00', 30.00);  -- Same user, different day

SELECT 
    purchase_time::DATE AS activity_date,
    COUNT(DISTINCT user_id) AS dau
FROM transactions
GROUP BY activity_date;

