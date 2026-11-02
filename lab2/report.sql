-- Часть 4. Отчёт о продажах по месяцам и категориям.
-- Отвечаю на вопрос: какие категории приносят выручку, а какие не продаются?
-- Схема: месяцы и позиции доставленных заказов => суммы по категориям => итоги месяцев => отчёт.

WITH months AS (
    -- Явно задаю три месяца отчёта: первая дата включается, следующая не включается.
    SELECT v.month_start::date AS month_start,
           v.next_month::date  AS next_month
    FROM (VALUES ('2026-08-01', '2026-09-01'),
                 ('2026-09-01', '2026-10-01'),
                 ('2026-10-01', '2026-11-01')) AS v(month_start, next_month)),
     sales_lines AS (
         -- Вход: месяцы, заказы, позиции и товары. Выбираю delivered и определяю месяц по диапазону дат.
         -- Выход: позиции продаж с категорией, количеством и стоимостью по цене покупки.
         SELECT m.month_start,
                o.id                        AS order_id,
                p.category,
                oi.quantity,
                oi.quantity * oi.unit_price AS line_total
         FROM months m
                  JOIN orders o ON o.created_at >= m.month_start
             AND o.created_at < m.next_month
                  JOIN order_items oi ON oi.order_id = o.id
                  JOIN products p ON p.id = oi.product_id
         WHERE o.status = 'delivered'),
     category_totals AS (
         -- Вход: позиции продаж. Группирую по месяцу и категории, считаю заказы, единицы и выручку.
         -- Средний чек категории — стоимость её позиций / число заказов с этой категорией.
         -- Здесь каждая группа содержит хотя бы одну позицию, поэтому число заказов больше нуля.
         SELECT month_start,
                category,
                COUNT(DISTINCT order_id)                   AS order_count,
                SUM(quantity)                              AS units_sold,
                SUM(line_total)                            AS revenue,
                SUM(line_total) / COUNT(DISTINCT order_id) AS avg_category_order_total
         FROM sales_lines
         GROUP BY month_start, category),
     month_totals AS (
         -- Вход: выручка категорий. Складываю её, чтобы получить общую выручку каждого месяца.
         -- Выход: знаменатель для расчёта доли категории в месячных продажах.
         SELECT month_start,
                SUM(revenue) AS month_revenue
         FROM category_totals
         GROUP BY month_start)
-- Сочетаю каждый месяц с каждой категорией, затем присоединяю рассчитанные показатели.
-- В month_totals присоединяю только положительную выручку: при её отсутствии деление даёт NULL,
SELECT m.month_start,
       c.category,
       COALESCE(ct.order_count, 0)                                AS order_count,
       COALESCE(ct.units_sold, 0)                                 AS units_sold,
       ROUND(COALESCE(ct.revenue, 0), 2)                          AS revenue,
       ROUND(ct.avg_category_order_total, 2)                      AS avg_category_order_total,
       ROUND(COALESCE(mt.month_revenue, 0), 2)                    AS month_revenue,
       COALESCE(ROUND(100 * ct.revenue / mt.month_revenue, 2), 0) AS revenue_share_pct
FROM months m
         CROSS JOIN (SELECT DISTINCT category FROM products) c
         LEFT JOIN category_totals ct ON ct.month_start = m.month_start
    AND ct.category = c.category
         LEFT JOIN month_totals mt ON mt.month_start = m.month_start
    AND mt.month_revenue > 0
ORDER BY m.month_start, revenue DESC, c.category;
