-- Лаба 1. Схема базы: таблицы, ключи, ограничения.


-- Лаба 1. Схема базы данных интернет-магазина.

CREATE TABLE categories (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE
);

CREATE TABLE products (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id integer NOT NULL REFERENCES categories(id),
    name text NOT NULL UNIQUE,
    price numeric(10, 2) NOT NULL CHECK (price > 0),
    stock_quantity integer NOT NULL DEFAULT 0
        CHECK (stock_quantity >= 0)
);

CREATE TABLE customers (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    email text NOT NULL UNIQUE
);

CREATE TABLE orders (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id integer NOT NULL REFERENCES customers(id),
    created_at timestamptz NOT NULL DEFAULT now(),
    status text NOT NULL DEFAULT 'new'
        CHECK (status IN ('new', 'paid', 'shipped', 'cancelled'))
);

CREATE TABLE order_items (
    id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id integer NOT NULL REFERENCES orders(id),
    product_id integer NOT NULL REFERENCES products(id),
    quantity integer NOT NULL CHECK (quantity > 0),
    unit_price numeric(10, 2) NOT NULL CHECK (unit_price > 0),
    UNIQUE (order_id, product_id)
);
