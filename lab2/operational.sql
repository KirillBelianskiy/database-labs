-- Часть 2. Операционная информация и агрегатные показатели.
-- Период всех запросов, кроме 2.1.2: [2026-08-01, 2026-11-01).
-- Для продаж учитывается только delivered, сумма покупки берётся из order_items.

-- 2.1.1. Собираю состав заказов из пяти таблиц.
SELECT o.id                                      AS order_id,
       o.created_at,
       o.status,
       c.email                                   AS customer_email,
       CONCAT_WS(' ', c.first_name, c.last_name) AS customer_name,
       p.sku,
       p.name                                    AS product_name,
       m.name                                    AS manufacturer_name,
       oi.quantity,
       oi.unit_price,
       ROUND(oi.quantity * oi.unit_price, 2)     AS line_total
FROM orders o
         JOIN customers c ON o.customer_id = c.id
         JOIN order_items oi ON o.id = oi.order_id
         JOIN products p ON oi.product_id = p.id
         JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE o.created_at >= TIMESTAMP '2026-08-01 00:00:00'
  AND o.created_at < TIMESTAMP '2026-11-01 00:00:00'
ORDER BY o.created_at, o.id, p.sku;

-- 2.1.2. Через LEFT JOIN ищу товары, которые не попадали ни в один заказ.
SELECT p.id               AS product_id,
       p.sku,
       p.name             AS product_name,
       m.name             AS manufacturer_name,
       p.category,
       p.stock_quantity,
       COUNT(oi.order_id) AS order_count
FROM products p
         JOIN manufacturers m ON p.manufacturer_id = m.id
         LEFT JOIN order_items oi ON oi.product_id = p.id
WHERE oi.order_id IS NULL
GROUP BY p.id, m.name
ORDER BY p.sku;

-- 2.1.3. Нахожу клиентов с минимум двумя доставленными комплектами «ноутбук Dell + периферия».
SELECT c.id                 AS customer_id,
       c.email,
       COUNT(DISTINCT o.id) AS qualifying_order_count
FROM customers c
         JOIN orders o ON o.customer_id = c.id
         JOIN order_items oi ON oi.order_id = o.id
         JOIN products p ON p.id = oi.product_id
         JOIN manufacturers m ON m.id = p.manufacturer_id
WHERE o.status = 'delivered'
  AND o.created_at >= TIMESTAMP '2026-08-01 00:00:00'
  AND o.created_at < TIMESTAMP '2026-11-01 00:00:00'
  AND p.category = 'laptops'
  AND m.name = 'Dell'
  AND EXISTS (SELECT 1
              FROM order_items peripheral_item
                       JOIN products peripheral ON peripheral.id = peripheral_item.product_id
              WHERE peripheral_item.order_id = o.id
                AND peripheral.category = 'peripherals')
GROUP BY c.id
HAVING COUNT(DISTINCT o.id) >= 2
ORDER BY qualifying_order_count DESC, c.id;

-- 2.2.1. Считаю заказы, единицы и выручку по категориям, чтобы закупки могли оценить спрос.
SELECT p.category,
       COUNT(DISTINCT o.id)                       AS order_count,
       SUM(oi.quantity)                           AS units_sold,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
         JOIN order_items oi ON oi.order_id = o.id
         JOIN products p ON p.id = oi.product_id
WHERE o.status = 'delivered'
  AND o.created_at >= TIMESTAMP '2026-08-01 00:00:00'
  AND o.created_at < TIMESTAMP '2026-11-01 00:00:00'
GROUP BY p.category
ORDER BY units_sold DESC, p.category;

-- 2.2.2. Через HAVING оставляю категории с выручкой не менее 100000 рублей.
SELECT p.category,
       SUM(oi.quantity)                                              AS units_sold,
       ROUND(SUM(oi.quantity * oi.unit_price), 2)                    AS revenue,
       ROUND(SUM(oi.quantity * oi.unit_price) / SUM(oi.quantity), 2) AS avg_unit_price
FROM orders o
         JOIN order_items oi ON oi.order_id = o.id
         JOIN products p ON p.id = oi.product_id
WHERE o.status = 'delivered'
  AND o.created_at >= TIMESTAMP '2026-08-01 00:00:00'
  AND o.created_at < TIMESTAMP '2026-11-01 00:00:00'
GROUP BY p.category
HAVING SUM(oi.quantity * oi.unit_price) >= 100000
ORDER BY revenue DESC, p.category;

-- 2.2.3. Сначала собираю сумму каждого доставленного заказа, затем показатели по месяцам.
-- Это позволяет сравнить средний, минимальный и максимальный чек без усреднения отдельных позиций.
WITH order_totals AS (SELECT o.id                                    AS order_id,
                             DATE_TRUNC('month', o.created_at)::date AS month_start,
                             SUM(oi.quantity * oi.unit_price)        AS order_total
                      FROM orders o
                               JOIN order_items oi ON oi.order_id = o.id
                      WHERE o.status = 'delivered'
                        AND o.created_at >= TIMESTAMP '2026-08-01 00:00:00'
                        AND o.created_at < TIMESTAMP '2026-11-01 00:00:00'
                      GROUP BY o.id)
SELECT month_start,
       COUNT(*)                   AS order_count,
       ROUND(SUM(order_total), 2) AS revenue,
       ROUND(AVG(order_total), 2) AS avg_order_total,
       ROUND(MIN(order_total), 2) AS min_order_total,
       ROUND(MAX(order_total), 2) AS max_order_total
FROM order_totals
GROUP BY month_start
ORDER BY month_start;
