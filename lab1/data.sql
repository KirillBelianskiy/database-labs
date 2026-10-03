INSERT INTO manufacturers (name, description, registration_date)
VALUES ('Apple', 'Американский производитель электроники и ПО', '2015-03-12'),
       ('Samsung', 'Южнокорейский конгломерат, смартфоны и бытовая техника', '2014-07-01'),
       ('Xiaomi', 'Китайский производитель смартфонов и умных устройств', '2016-09-20'),
       ('Logitech', 'Швейцарский производитель периферии для компьютеров', '2013-01-15'),
       ('Sony', 'Японская корпорация: консоли, аудио, камеры', '2012-11-05');

INSERT INTO products (name, description, category, price, stock_quantity, sku, manufacturer_id)
VALUES ('iPhone 15 128GB', 'Смартфон с чипом A16 Bionic', 'smartphones', 89990.00, 25, 'APL-IP15-128', 1),
       ('MacBook Air 13 M2', 'Ультрабук на чипе Apple M2, 8/256 ГБ', 'laptops', 119990.00, 10, 'APL-MBA13-M2', 1),
       ('AirPods Pro 2', 'TWS-наушники с шумоподавлением', 'headphones', 24990.00, 40, 'APL-APP2', 1),
       ('Galaxy S24 256GB', 'Флагманский смартфон на Android', 'smartphones', 79990.00, 30, 'SMS-GS24-256', 2),
       ('Galaxy Tab S9', 'Планшет с AMOLED-экраном 11"', 'tablets', 69990.00, 12, 'SMS-GTS9', 2),
       ('Galaxy Buds2 Pro', 'Беспроводные наушники с ANC', 'headphones', 14990.00, 50, 'SMS-GB2P', 2),
       ('Redmi Note 13 128GB', 'Бюджетный смартфон с AMOLED-экраном', 'smartphones', 19990.00, 80, 'XMI-RN13-128', 3),
       ('Xiaomi Pad 6', 'Планшет 11" с экраном 144 Гц', 'tablets', 29990.00, 20, 'XMI-PAD6', 3),
       ('Mi Band 8', 'Фитнес-браслет', 'wearables', 3490.00, 150, 'XMI-MB8', 3),
       ('MX Master 3S', 'Беспроводная мышь для работы', 'peripherals', 9990.00, 60, 'LGT-MXM3S', 4),
       ('MX Keys', 'Беспроводная клавиатура с подсветкой', 'peripherals', 11990.00, 35, 'LGT-MXKEYS', 4),
       ('C920 HD Pro', 'Веб-камера Full HD', 'peripherals', 6490.00, 45, 'LGT-C920', 4),
       ('WH-1000XM5', 'Накладные наушники с лучшим ANC', 'headphones', 29990.00, 18, 'SNY-WH1000XM5', 5),
       ('PlayStation 5 Slim', 'Игровая консоль с дисководом', 'consoles', 54990.00, 8, 'SNY-PS5-SLIM', 5),
       ('Alpha ZV-E10', 'Беззеркальная камера для блогеров', 'cameras', 64990.00, 5, 'SNY-ZVE10', 5);

INSERT INTO customers (first_name, last_name, email, phone_number, password_hash)
VALUES ('Иван', 'Петров', 'ivan.petrov@example.com', '+79991234567', '$2b$12$abcdefghijklmnopqrstuuK1nFq8vJ3m9Xw2LzY0pQ4rT6sU8vW1y'),
       ('Мария', 'Сидорова', 'maria.sidorova@example.com', '+79997654321', '$2b$12$bcdefghijklmnopqrstuvK2oGr9wK4n0Yx3MaZ1qR5sU7tV9wX2z'),
       ('Алексей', 'Смирнов', 'alexey.smirnov@example.com', '+79161112233', '$2b$12$cdefghijklmnopqrstuvwK3pHs0xL5o1Zy4NbA2rS6tV8uW0xY3a'),
       ('Екатерина', 'Кузнецова', 'ekaterina.kuznetsova@example.com', NULL, '$2b$12$defghijklmnopqrstuvwxK4qIt1yM6p2Az5OcB3sT7uW9vX1yZ4b'),
       ('Дмитрий', NULL, 'dmitry@example.com', '+79263334455', '$2b$12$efghijklmnopqrstuvwxyK5rJu2zN7q3Ba6PdC4tU8vX0wY2zA5c'),
       ('Ольга', 'Новикова', 'olga.novikova@example.com', '+79035556677', '$2b$12$fghijklmnopqrstuvwxyzK6sKv3aO8r4Cb7QeD5uV9wY1xZ3aB6d'),
       ('Сергей', 'Морозов', 'sergey.morozov@example.com', NULL, '$2b$12$ghijklmnopqrstuvwxyzaK7tLw4bP9s5Dc8RfE6vW0xZ2yA4bC7e'),
       ('Анна', 'Волкова', 'anna.volkova@example.com', '+79457778899', '$2b$12$hijklmnopqrstuvwxyzabK8uMx5cQ0t6Ed9SgF7wX1yA3zB5cD8f'),
       ('Павел', 'Соколов', 'pavel.sokolov@example.com', '+79169990011', '$2b$12$ijklmnopqrstuvwxyzabcK9vNy6dR1u7Fe0ThG8xY2zB4aC6dE9g'),
       ('Наталья', 'Лебедева', 'natalia.lebedeva@example.com', '+79051231231', '$2b$12$jklmnopqrstuvwxyzabcdK0wOz7eS2v8Gf1UiH9yZ3aC5bD7eF0h');

INSERT INTO orders (status, created_at, delivery_address, customer_id)
VALUES ('delivered', '2026-08-01 10:15:00', 'Москва, ул. Тверская, д. 10, кв. 5', 1),
       ('delivered', '2026-08-03 14:40:00', 'Москва, пр-т Мира, д. 25, кв. 112', 2),
       ('shipped', '2026-09-10 09:05:00', 'Санкт-Петербург, Невский пр-т, д. 50, кв. 7', 3),
       ('paid', '2026-09-15 18:22:00', 'Казань, ул. Баумана, д. 3, кв. 41', 4),
       ('created', '2026-09-28 12:00:00', 'Москва, ул. Арбат, д. 8, кв. 19', 5),
       ('delivered', '2026-08-20 16:30:00', 'Москва, ул. Тверская, д. 10, кв. 5', 1),
       ('shipped', '2026-09-25 11:11:00', 'Новосибирск, Красный пр-т, д. 77, кв. 63', 6),
       ('paid', '2026-09-30 20:45:00', 'Екатеринбург, ул. Ленина, д. 24, кв. 9', 7),
       ('delivered', '2026-07-18 13:20:00', 'Нижний Новгород, ул. Большая Покровская, д. 15, кв. 30', 8),
       ('cancelled', '2026-09-05 08:50:00', 'Самара, ул. Куйбышева, д. 100, кв. 2', 9),
       ('cancelled', '2026-09-12 19:10:00', 'Москва, Ленинский пр-т, д. 60, кв. 88', 10),
       ('created', '2026-10-02 15:35:00', 'Санкт-Петербург, Невский пр-т, д. 50, кв. 7', 3);

INSERT INTO order_items (order_id, product_id, quantity, unit_price)
VALUES (1, 1, 1, 89990.00),
       (1, 3, 1, 24990.00),
       (2, 7, 2, 19990.00),
       (2, 9, 1, 3490.00),
       (3, 2, 1, 119990.00),
       (4, 10, 1, 9990.00),
       (4, 11, 1, 11990.00),
       (4, 12, 1, 6490.00),
       (5, 14, 1, 54990.00),
       (6, 13, 1, 29990.00),
       (7, 4, 1, 79990.00),
       (7, 6, 1, 14990.00),
       (8, 8, 1, 29990.00),
       (8, 9, 2, 3490.00),
       (9, 15, 1, 64990.00),
       (10, 5, 1, 69990.00),
       (11, 7, 1, 19990.00),
       (11, 3, 1, 24990.00),
       (12, 10, 1, 9990.00),
       (12, 12, 2, 6490.00);

UPDATE order_items
SET unit_price = 79990.00
WHERE order_id = 1 AND product_id = 1;



UPDATE customers
SET last_name = 'Иванов'
WHERE email = 'ivan.petrov@example.com';


UPDATE customers
SET email = 'ivan.ivanov@example.com'
WHERE first_name = 'Иван' AND last_name = 'Иванов';

SELECT *
FROM customers
WHERE last_name = 'Иванов';
