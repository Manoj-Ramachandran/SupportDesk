-- =============================================
-- 04C_Advanced_SQL.sql
-- SupportDesk Advanced SQL Analytics
-- MySQL 8+
-- =============================================

USE supportdesk_db;

-- 1. Rank Engineers by Tickets Resolved
SELECT
    e.engineer_name,
    COUNT(*) AS resolved_tickets,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS engineer_rank
FROM tickets t
JOIN engineers e ON t.engineer_id = e.engineer_id
WHERE t.status IN ('Resolved','Closed')
GROUP BY e.engineer_name;

-- 2. Dense Rank Products by Ticket Volume
SELECT
    p.product_name,
    COUNT(*) AS total_tickets,
    DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS product_rank
FROM tickets t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.product_name;

-- 3. Running Monthly Ticket Total
WITH monthly AS (
SELECT DATE_FORMAT(created_at,'%Y-%m') AS month,
COUNT(*) AS tickets
FROM tickets
GROUP BY month
)
SELECT month,
tickets,
SUM(tickets) OVER(ORDER BY month) AS running_total
FROM monthly;

-- 4. Previous Month Comparison
WITH monthly AS (
SELECT DATE_FORMAT(created_at,'%Y-%m') AS month,
COUNT(*) AS tickets
FROM tickets
GROUP BY month
)
SELECT month,
tickets,
LAG(tickets) OVER(ORDER BY month) AS previous_month,
tickets-LAG(tickets) OVER(ORDER BY month) AS difference
FROM monthly;

-- 5. Engineer Workload Percentage
SELECT
e.engineer_name,
COUNT(*) AS tickets,
ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(),2) AS workload_percent
FROM tickets t
JOIN engineers e ON t.engineer_id=e.engineer_id
GROUP BY e.engineer_name
ORDER BY workload_percent DESC;

-- 6. SLA Compliance
SELECT
priority,
COUNT(*) total_tickets,
SUM(
CASE
WHEN resolved_at IS NOT NULL
AND TIMESTAMPDIFF(HOUR,created_at,resolved_at) <=
CASE priority
WHEN 'Low' THEN 72
WHEN 'Medium' THEN 48
WHEN 'High' THEN 24
WHEN 'Critical' THEN 8
END
THEN 1 ELSE 0 END
) AS sla_met
FROM tickets
GROUP BY priority;

-- 7. Top 5 Customers per Product
WITH ranked AS (
SELECT
p.product_name,
c.company_name,
COUNT(*) AS tickets,
ROW_NUMBER() OVER(
PARTITION BY p.product_name
ORDER BY COUNT(*) DESC
) rn
FROM tickets t
JOIN customers c ON t.customer_id=c.customer_id
JOIN products p ON t.product_id=p.product_id
GROUP BY p.product_name,c.company_name
)
SELECT * FROM ranked
WHERE rn<=5;

-- 8. Product Stability Score
SELECT
p.product_name,
ROUND(100-(COUNT(*)*100.0/(SELECT COUNT(*) FROM tickets)),2) AS stability_score
FROM products p
JOIN tickets t ON p.product_id=t.product_id
GROUP BY p.product_name
ORDER BY stability_score DESC;

-- 9. Customer Satisfaction by Product
SELECT
p.product_name,
ROUND(AVG(f.rating),2) avg_rating
FROM feedback f
JOIN tickets t ON f.ticket_id=t.ticket_id
JOIN products p ON t.product_id=p.product_id
GROUP BY p.product_name;

-- 10. Top Longest Open Tickets
SELECT
ticket_id,
status,
TIMESTAMPDIFF(DAY,created_at,NOW()) AS age_days
FROM tickets
WHERE status IN ('Open','Pending','In Progress')
ORDER BY age_days DESC
LIMIT 20;
