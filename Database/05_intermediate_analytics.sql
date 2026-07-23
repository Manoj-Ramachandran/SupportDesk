-- =============================================
-- 04B_Intermediate_Analytics.sql
-- SupportDesk Intermediate SQL Analytics
-- =============================================

USE supportdesk_db;

-- 1. Tickets by Subscription Plan
SELECT c.subscription_plan, COUNT(*) AS total_tickets
FROM tickets t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.subscription_plan
ORDER BY total_tickets DESC;

-- 2. Product vs Priority Matrix
SELECT p.product_name, t.priority, COUNT(*) AS total
FROM tickets t
JOIN products p ON t.product_id = p.product_id
GROUP BY p.product_name, t.priority
ORDER BY p.product_name;

-- 3. Average Resolution Time by Product
SELECT p.product_name,
ROUND(AVG(TIMESTAMPDIFF(HOUR,t.created_at,t.resolved_at)),2) AS avg_hours
FROM tickets t
JOIN products p ON t.product_id=p.product_id
WHERE t.resolved_at IS NOT NULL
GROUP BY p.product_name
ORDER BY avg_hours;

-- 4. Engineers Handling Critical Tickets
SELECT e.engineer_name, COUNT(*) AS critical_tickets
FROM tickets t
JOIN engineers e ON t.engineer_id=e.engineer_id
WHERE t.priority='Critical'
GROUP BY e.engineer_name
ORDER BY critical_tickets DESC;

-- 5. Top 10 Modules with Most Tickets
SELECT m.module_name, COUNT(*) AS tickets
FROM tickets t
JOIN modules m ON t.module_id=m.module_id
GROUP BY m.module_name
ORDER BY tickets DESC
LIMIT 10;

-- 6. Average Rating per Engineer
SELECT e.engineer_name,
ROUND(AVG(f.rating),2) AS avg_rating
FROM feedback f
JOIN tickets t ON f.ticket_id=t.ticket_id
JOIN engineers e ON t.engineer_id=e.engineer_id
GROUP BY e.engineer_name
ORDER BY avg_rating DESC;

-- 7. Monthly Closed Tickets
SELECT DATE_FORMAT(created_at,'%Y-%m') AS month,
COUNT(*) AS closed_tickets
FROM tickets
WHERE status='Closed'
GROUP BY month
ORDER BY month;

-- 8. Open Tickets by Product
SELECT p.product_name, COUNT(*) AS open_tickets
FROM tickets t
JOIN products p ON t.product_id=p.product_id
WHERE t.status IN ('Open','In Progress','Pending')
GROUP BY p.product_name
ORDER BY open_tickets DESC;

-- 9. SLA Distribution
SELECT s.priority AS sla_priority, COUNT(*) AS tickets
FROM tickets t
JOIN sla_rules s ON t.sla_id=s.sla_id
GROUP BY s.priority;

-- 10. Top 20 Customers by Average Rating
SELECT c.company_name,
ROUND(AVG(f.rating),2) AS avg_rating,
COUNT(f.feedback_id) AS feedback_count
FROM customers c
JOIN tickets t ON c.customer_id=t.customer_id
JOIN feedback f ON t.ticket_id=f.ticket_id
GROUP BY c.company_name
HAVING feedback_count>0
ORDER BY avg_rating DESC, feedback_count DESC
LIMIT 20;
