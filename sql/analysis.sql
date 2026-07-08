--Общая выручка по дням--
SELECT
    SUM(price * quantity) revenue,
    date
FROM sales
GROUP BY date
ORDER BY date;

--Топ-10 товаров по выручке--
SELECT
    productname,
    SUM(price * quantity) revenue
FROM sales
GROUP BY productname
ORDER BY revenue DESC
LIMIT 10;

---Средний чек--
SELECT
    AVG(order_total) avg_check
FROM (
    SELECT
        transactionno,
        SUM(price * quantity) order_total
    FROM sales
    GROUP BY transactionno
) order_totals;

--Количество заказов--
SELECT
    COUNT(DISTINCT transactionno) total_orders
FROM sales;

--Количество уникальных клиентов--
SELECT
    COUNT(DISTINCT customerno) unique_customers
FROM sales;

--Повторные покупки (клиенты с >1 заказом)--
SELECT
    customerno,
    COUNT(DISTINCT transactionno) orders_count
FROM sales
GROUP BY customerno
HAVING COUNT(DISTINCT transactionno) > 1
ORDER BY orders_count DESC;

-- процент повторных покупок:
SELECT
    ROUND(
        COUNT(DISTINCT CASE WHEN order_count > 1 THEN customerno END) * 100.0 / COUNT(DISTINCT customerno),
        2
    ) repeat_purchase_rate_percent
FROM (
    SELECT
        customerno,
        COUNT(DISTINCT transactionno) order_count
    FROM sales
    GROUP BY customerno
) customer_orders;

--Топ клиентов по выручке--
SELECT
    customerno,
    SUM(price * quantity) total_revenue
FROM sales
GROUP BY customerno
ORDER BY total_revenue DESC
LIMIT 10;

--Новые vs возвращающиеся клиенты--
WITH customer_first_order AS (
    SELECT
        customerno,
        MIN(date) first_order_date
    FROM sales
    GROUP BY customerno
),
customer_orders_with_type AS (
    SELECT
        s.customerno,
        s.transactionno,
        s.date,
        s.price,
        s.quantity,
        CASE
            WHEN s.date = c.first_order_date THEN 'New'
            ELSE 'Returning'
        END customer_type
    FROM sales s
    JOIN customer_first_order c ON s.customerno = c.customerno
)
SELECT
    customer_type,
    COUNT(DISTINCT customerno) customer_count,
    COUNT(DISTINCT transactionno) orders_count,
    SUM(price * quantity) revenue
FROM customer_orders_with_type
GROUP BY customer_type;

--Выручка по странам--
SELECT
    country,
    SUM(price * quantity) revenue,
    COUNT(DISTINCT transactionno) orders_count,
    COUNT(DISTINCT customerno) customers_count
FROM sales
GROUP BY country
ORDER BY revenue DESC;

--Доля UK в общей выручке--
SELECT
    ROUND(
        SUM(CASE WHEN country = 'United Kingdom' THEN price * quantity ELSE 0 END) * 100.0 / SUM(price * quantity),
        2
    ) uk_revenue_share_percent
FROM sales;

-- выручка по месяцам --
SELECT
    TO_CHAR(date, 'YYYY-MM') month,
    SUM(price * quantity) revenue,
    COUNT(DISTINCT transactionno) orders_count
FROM sales
GROUP BY TO_CHAR(date, 'YYYY-MM')
ORDER BY month;

-- средняя стоимость заказа по дням --
SELECT
    date,
    SUM(price * quantity) daily_revenue,
    COUNT(DISTINCT transactionno) orders_count,
    ROUND(SUM(price * quantity) / COUNT(DISTINCT transactionno), 2) avg_order_value
FROM sales
GROUP BY date
ORDER BY date;