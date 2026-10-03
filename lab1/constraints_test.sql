-- Тест 1: UNIQUE(customers.email)
-- Ожидается: ERROR: duplicate key value violates unique constraint (23505)
INSERT INTO customers (first_name, email, password_hash)
VALUES ('Дубликат', 'ivan.ivanov@example.com', 'hash');

-- Тест 2: CHECK(products.price > 0)
-- Ожидается: ERROR: new row violates check constraint (23514)
UPDATE products
SET price = -100
WHERE id = 1;

-- Тест 3: CHECK(orders.status IN (...))
-- Ожидается: ERROR: new row violates check constraint (23514)
INSERT INTO orders (status, delivery_address, customer_id)
VALUES ('refunded', 'Москва, ул. Тестовая, д. 1', 1);

-- Тест 4: FOREIGN KEY(order_items.product_id)
-- Ожидается: ERROR: violates foreign key constraint (23503)
UPDATE order_items
SET product_id = 9999
WHERE order_id = 1 AND product_id = 1;

-- Тест 5: PRIMARY KEY(order_items.order_id, order_items.product_id)
-- Ожидается: ERROR: duplicate key value violates unique constraint (23505)
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1, 1, 1, 89990.00);