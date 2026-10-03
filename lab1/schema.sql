CREATE TABLE manufacturers
(
    id                INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name              VARCHAR(64) NOT NULL UNIQUE,
    description       TEXT,
    registration_date DATE        NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE products
(
    id              INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name            VARCHAR(64)    NOT NULL,
    description     VARCHAR(1000),
    category        VARCHAR(64)    NOT NULL,
    price           NUMERIC(10, 2) NOT NULL CHECK ( price > 0 ),
    stock_quantity  INT            NOT NULL CHECK ( stock_quantity >= 0 ),
    sku             VARCHAR(64)    NOT NULL UNIQUE,
    manufacturer_id INT            NOT NULL REFERENCES manufacturers (id)
);

CREATE TABLE customers
(
    id            INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name    VARCHAR(64)  NOT NULL,
    last_name     VARCHAR(64),
    email         VARCHAR(128) NOT NULL UNIQUE,
    phone_number  VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL
);

CREATE TABLE orders
(
    id               INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    status           VARCHAR(20)  NOT NULL
        CHECK (status IN ('created', 'paid', 'shipped', 'delivered', 'cancelled')),
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    delivery_address VARCHAR(128) NOT NULL,
    customer_id      INT          NOT NULL REFERENCES customers (id)
);

CREATE TABLE order_items
(
    order_id   INT            NOT NULL REFERENCES orders (id),
    product_id INT            NOT NULL REFERENCES products (id),
    quantity   INT            NOT NULL CHECK ( quantity > 0 ),
    unit_price NUMERIC(10, 2) NOT NULL CHECK ( unit_price > 0 ),

    PRIMARY KEY (order_id, product_id)
);
