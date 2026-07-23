-- =============================================
-- 04_analytics_queries.sql
-- SupportDesk Analytics Queries
-- =============================================

USE supportdesk_db;

-- ===============================
-- BASIC METRICS
-- ===============================

-- 1. Total Tickets
SELECT COUNT(*) AS total_tickets FROM tickets;

-- 2. Total Customers
SELECT COUNT(*) AS total_customers FROM customers;

-- 3. Total Engineers
SELECT COUNT(*) AS total_engineers FROM engineers;

-- 4. Tickets by Status
SELECT status, COUNT(*) AS ticket_count
FROM tickets
GROUP BY status
ORDER BY ticket_count DESC;

-- 5. Tickets by Priority
SELECT priority, COUNT(*) AS ticket_count
FROM tickets
GROUP BY priority
ORDER BY FIELD(priority,'Critical','High','Medium','Low');

-- 6. Tickets by Severity
SELECT severity, COUNT(*) AS ticket_count
FROM tickets
GROUP BY severity;

-- 7. Tickets by Source
SELECT ticket_source, COUNT(*) AS ticket_count
FROM tickets
GROUP BY ticket_source
ORDER BY ticket_count DESC;

-- ===============================
-- PRODUCT ANALYTICS
-- ===============================

-- 8. Tickets by Product
SELECT p.product_name, COUNT(*) AS total_tickets
FROM tickets t
JOIN products p ON t.product_id=p.product_id
GROUP BY p.product_name
ORDER BY total_tickets DESC;

-- 9. Tickets by Module
SELECT m.module_name, COUNT(*) AS total_tickets
FROM tickets t
JOIN modules m ON t.module_id=m.module_id
GROUP BY m.module_name
ORDER BY total_tickets DESC;

-- ===============================
-- CUSTOMER ANALYTICS
-- ===============================

-- 10. Top 10 Customers
SELECT c.company_name, COUNT(*) AS total_tickets
FROM tickets t
JOIN customers c ON t.customer_id=c.customer_id
GROUP BY c.company_name
ORDER BY total_tickets DESC
LIMIT 10;

-- 11. Customers with Critical Tickets
SELECT c.company_name, COUNT(*) AS critical_tickets
FROM tickets t
JOIN customers c ON t.customer_id=c.customer_id
WHERE t.priority='Critical'
GROUP BY c.company_name
ORDER BY critical_tickets DESC;

-- ===============================
-- ENGINEER ANALYTICS
-- ===============================

-- 12. Tickets Handled Per Engineer
SELECT e.engineer_name, COUNT(*) AS tickets_handled
FROM tickets t
JOIN engineers e ON t.engineer_id=e.engineer_id
GROUP BY e.engineer_name
ORDER BY tickets_handled DESC;

-- 13. Average Resolution Hours
SELECT
ROUND(AVG(TIMESTAMPDIFF(HOUR,created_at,resolved_at)),2) AS avg_resolution_hours
FROM tickets
WHERE resolved_at IS NOT NULL;

-- 14. Top 5 Fastest Engineers
SELECT
e.engineer_name,
ROUND(AVG(TIMESTAMPDIFF(HOUR,created_at,resolved_at)),2) avg_hours
FROM tickets t
JOIN engineers e ON t.engineer_id=e.engineer_id
WHERE resolved_at IS NOT NULL
GROUP BY e.engineer_name
ORDER BY avg_hours
LIMIT 5;

-- ===============================
-- FEEDBACK ANALYTICS
-- ===============================

-- 15. Average Customer Rating
SELECT ROUND(AVG(rating),2) AS average_rating
FROM feedback;

-- 16. Rating Distribution
SELECT rating, COUNT(*) AS total
FROM feedback
GROUP BY rating
ORDER BY rating;

-- ===============================
-- TIME ANALYTICS
-- ===============================

-- 17. Monthly Ticket Trend
SELECT
DATE_FORMAT(created_at,'%Y-%m') AS month,
COUNT(*) AS tickets
FROM tickets
GROUP BY month
ORDER BY month;

-- 18. Yearly Ticket Trend
SELECT
YEAR(created_at) AS year,
COUNT(*) AS tickets
FROM tickets
GROUP BY year;

-- ===============================
-- ADVANCED SQL
-- ===============================

-- 19. Rank Products by Ticket Volume
SELECT
p.product_name,
COUNT(*) AS total_tickets,
RANK() OVER(ORDER BY COUNT(*) DESC) AS product_rank
FROM tickets t
JOIN products p ON t.product_id=p.product_id
GROUP BY p.product_name;

-- 20. Top 10 Longest Resolution Times
SELECT
ticket_id,
TIMESTAMPDIFF(HOUR,created_at,resolved_at) AS resolution_hours
FROM tickets
WHERE resolved_at IS NOT NULL
ORDER BY resolution_hours DESC
LIMIT 10;
