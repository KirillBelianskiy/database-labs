-- Задание 1.2. Проверяю жизненный цикл тестового заказа в одной транзакции.

-- Сохраняю исходные количества строк в выводе, чтобы сравнить их с результатом после ROLLBACK.
SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders
UNION ALL
SELECT 'order_items', COUNT(*)
FROM order_items;

-- Показываю исходные цены товаров Dell с нулевым остатком для проверки отката переоценки.
SELECT p.sku, p.price, p.stock_quantity
FROM products p
         JOIN manufacturers m ON m.id = p.manufacturer_id
WHERE m.name = 'Dell'
  AND p.stock_quantity = 0
ORDER BY p.sku;

BEGIN;

-- 1.2.1. Создаю клиента, чтобы связать с ним новый тестовый заказ.
INSERT INTO customers (first_name, last_name, email, password_hash)
VALUES ('Alexandr', 'Kalinin', 'lab2-dml@example.test', '34djdfh@df');

-- 1.2.1. Создаю заказ в статусе created и нахожу его владельца по уникальному email.
INSERT INTO orders (status, created_at, delivery_address, customer_id)
SELECT o.status, o.created_at::timestamp, o.delivery_address, c.id
FROM (VALUES ('created', '2026-10-30 12:00:00', 'Москва, ул. Лесная, д. 52, кв. 67', 'lab2-dml@example.test'))
         AS o(status, created_at, delivery_address, customer_email)
         JOIN customers c ON c.email = o.customer_email;

-- 1.2.1. Добавляю две позиции и фиксирую цены из каталога на момент покупки.
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT o.id, p.id, oi.quantity, p.price
FROM (VALUES ('lab2-dml@example.test', '2026-10-30 12:00:00', 'JBL-TUNE-520BT', 2),
             ('lab2-dml@example.test', '2026-10-30 12:00:00', 'HUAWEI-BAND-9', 1))
         AS oi(customer_email, created_at, sku, quantity)
         JOIN customers c ON c.email = oi.customer_email
         JOIN orders o ON o.customer_id = c.id AND o.created_at = oi.created_at::timestamp
         JOIN products p ON p.sku = oi.sku;

-- Проверяю состав заказа: две позиции должны дать общую сумму 11970 рублей.
SELECT p.sku,
       oi.quantity,
       oi.unit_price,
       oi.quantity * oi.unit_price AS line_total
FROM order_items oi
         JOIN orders o ON o.id = oi.order_id
         JOIN customers c ON c.id = o.customer_id
         JOIN products p ON p.id = oi.product_id
WHERE c.email = 'lab2-dml@example.test'
  AND o.created_at = TIMESTAMP '2026-10-30 12:00:00';

-- 1.2.2. Перевожу только тестовый заказ из created в paid, имитируя оплату.
UPDATE orders
SET status = 'paid'
WHERE customer_id = (SELECT id
                     FROM customers
                     WHERE email = 'lab2-dml@example.test')
  AND created_at = TIMESTAMP '2026-10-30 12:00:00'
  AND status = 'created';

-- Проверяю, что заказ тестового клиента получил статус paid.
SELECT o.id, o.status
FROM orders o
         JOIN customers c ON c.id = o.customer_id
WHERE c.email = 'lab2-dml@example.test';

-- 1.2.3. Снижаю на 10% цены отсутствующих товаров Dell для демонстрации массового UPDATE.
UPDATE products
SET price = price * 0.9
WHERE manufacturer_id = (SELECT id FROM manufacturers WHERE name = 'Dell')
  AND stock_quantity = 0;

-- Проверяю новые цены: Latitude — 98991, мышь MS3320W — 2241 рубль. Цены покупок не меняются.
SELECT m.name, p.sku, p.stock_quantity, p.price
FROM products p
         JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE p.stock_quantity = 0
  AND m.name = 'Dell';

-- 1.2.4. Удаляю только созданный тестовый заказ
DELETE
FROM orders
WHERE customer_id = (SELECT id
                     FROM customers
                     WHERE email = 'lab2-dml@example.test')
  AND created_at = TIMESTAMP '2026-10-30 12:00:00'
RETURNING id;

-- Проверяю каскадное удаление: у удалённого заказа должно остаться 0 позиций.
-- currval возвращает ID последнего заказа, созданного именно в этой сессии, без угадывания номера.
SELECT COUNT(*) AS remaining_item_count
FROM order_items
WHERE order_id = CURRVAL(PG_GET_SERIAL_SEQUENCE('orders', 'id'));

-- Проверяю, что удаление заказа не удалило клиента или товары: ожидаются 1 клиент и 2 товара.
SELECT (SELECT COUNT(*) FROM customers WHERE email = 'lab2-dml@example.test')           AS customer_count,
       (SELECT COUNT(*) FROM products WHERE sku IN ('JBL-TUNE-520BT', 'HUAWEI-BAND-9')) AS product_count;

-- 1.2.5. Отменяю всю транзакцию, чтобы тест не изменил постоянные данные магазина.
ROLLBACK;


-- После отката проверяю отсутствие созданного клиента: ожидается 0.
SELECT COUNT(*) AS customer_count
FROM customers
WHERE email = 'lab2-dml@example.test';

-- Проверяю восстановление исходных цен: Latitude — 109990, мышь MS3320W — 2490 рублей.
SELECT p.sku, p.price, p.stock_quantity
FROM products p
         JOIN manufacturers m ON m.id = p.manufacturer_id
WHERE m.name = 'Dell'
  AND p.stock_quantity = 0
ORDER BY p.sku;

-- Проверяю отсутствие тестового заказа и его позиций после отката: оба счётчика должны быть 0.
-- currval сохраняется в сессии после ROLLBACK, поскольку последовательности не откатываются.
SELECT (SELECT COUNT(*)
        FROM orders
        WHERE id = CURRVAL(PG_GET_SERIAL_SEQUENCE('orders', 'id')))       AS test_order_count,
       (SELECT COUNT(*)
        FROM order_items
        WHERE order_id = CURRVAL(PG_GET_SERIAL_SEQUENCE('orders', 'id'))) AS test_item_count;

-- Сравниваю количества строк с первой выборкой: откат должен вернуть исходные значения.
SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers
UNION ALL
SELECT 'orders', COUNT(*)
FROM orders
UNION ALL
SELECT 'order_items', COUNT(*)
FROM order_items;
