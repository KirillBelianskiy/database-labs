-- Часть 3. Подзапросы для поиска нетривиальных ситуаций.
-- Период задач 3.2–3.4: [2026-08-01, 2026-11-01); продажи — только delivered.

-- 3.1. Сравниваю текущую цену товара со средним по его категории, чтобы выделить дорогой сегмент.
-- Подзапрос получает средние по всему каталогу, включая товары без продаж и сам рассматриваемый товар.
-- Фильтрую до округления: цена, равная среднему, не подходит.
SELECT p.id                                          AS product_id,
       p.sku,
       p.category,
       p.price,
       ROUND(category_prices.avg_price, 2)           AS category_avg_price,
       ROUND(p.price - category_prices.avg_price, 2) AS price_above_avg
FROM products p
         JOIN (SELECT category, AVG(price) AS avg_price
               FROM products
               GROUP BY category) category_prices ON category_prices.category = p.category
WHERE p.price > category_prices.avg_price
ORDER BY p.category, p.price DESC, p.id;

-- 3.2. Через EXISTS нахожу покупателей товаров с нулевым текущим остатком для уведомления о поступлении.
-- Остаток проверяется сейчас, а не на дату покупки; повторные заказы не дублируют клиента.
SELECT c.id AS customer_id,
       c.email,
       c.first_name
FROM customers c
WHERE EXISTS (SELECT 1
              FROM orders o
                       JOIN order_items oi ON oi.order_id = o.id
                       JOIN products p ON p.id = oi.product_id
              WHERE o.customer_id = c.id
                AND o.status = 'delivered'
                AND o.created_at >= TIMESTAMP '2026-08-01 00:00:00'
                AND o.created_at < TIMESTAMP '2026-11-01 00:00:00'
                AND p.stock_quantity = 0)
ORDER BY c.email, c.id;

-- 3.3. Нахожу клиентов с заказами, но без доставок в выбранном периоде.
SELECT c.id AS customer_id,
       c.email
FROM customers c
WHERE EXISTS (SELECT 1
              FROM orders o
              WHERE o.customer_id = c.id
                AND o.created_at >= TIMESTAMP '2026-08-01 00:00:00'
                AND o.created_at < TIMESTAMP '2026-11-01 00:00:00')
  AND NOT EXISTS (SELECT 1
                  FROM orders o
                  WHERE o.customer_id = c.id
                    AND o.status = 'delivered'
                    AND o.created_at >= TIMESTAMP '2026-08-01 00:00:00'
                    AND o.created_at < TIMESTAMP '2026-11-01 00:00:00')
ORDER BY c.email, c.id;

-- 3.4. Выделяю заказы дороже личного среднего чека.
-- Коррелированный подзапрос зависит от customer_id внешней строки и включает текущий заказ в среднее.
-- Вход: доставленные заказы периода и их позиции; выход: суммы отдельных заказов.
WITH order_totals AS (SELECT o.id                             AS order_id,
                             o.customer_id,
                             SUM(oi.quantity * oi.unit_price) AS order_total
                      FROM orders o
                               JOIN order_items oi ON oi.order_id = o.id
                      WHERE o.status = 'delivered'
                        AND o.created_at >= TIMESTAMP '2026-08-01 00:00:00'
                        AND o.created_at < TIMESTAMP '2026-11-01 00:00:00'
                      GROUP BY o.id)
SELECT compared.order_id,
       c.email                                                      AS customer_email,
       ROUND(compared.order_total, 2)                               AS order_total,
       ROUND(compared.customer_avg_total, 2)                        AS customer_avg_total,
       ROUND(compared.order_total - compared.customer_avg_total, 2) AS amount_above_avg
FROM (SELECT current_order.*,
             (SELECT AVG(other_order.order_total)
              FROM order_totals other_order
              WHERE other_order.customer_id = current_order.customer_id) AS customer_avg_total
      FROM order_totals current_order) compared
         JOIN customers c ON c.id = compared.customer_id
WHERE compared.order_total > compared.customer_avg_total
ORDER BY c.email, compared.order_total, compared.order_id;
