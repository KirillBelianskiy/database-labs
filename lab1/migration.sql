-- добавить историю изменения цен
CREATE TABLE product_price_history
(
    id         INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id INT            NOT NULL REFERENCES products (id),
    old_price  NUMERIC(10, 2) NOT NULL CHECK (old_price > 0),
    changed_at TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);


BEGIN;

INSERT INTO product_price_history (product_id, old_price)
SELECT id, price
FROM products
WHERE id = 1;

UPDATE products
SET price = 99990.00
WHERE id = 1;

COMMIT;

SELECT *
FROM products
WHERE id = 1;

SELECT *
    FROM product_price_history

