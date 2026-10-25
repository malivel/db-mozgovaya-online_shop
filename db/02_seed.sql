INSERT INTO categories (name) VALUES
    ('Ноутбуки'),
    ('Смартфоны'),
    ('Планшеты'),
    ('Мониторы'),
    ('Клавиатуры'),
    ('Мыши'),
    ('Наушники'),
    ('Принтеры'),
    ('Камеры'),
    ('Аксессуары');

    INSERT INTO products (category_id, name, price, stock_quantity) VALUES
    (1, 'Laptop Pro 15', 1299.99, 10),
    (1, 'Laptop Air 13', 999.99, 15),
    (2, 'Smartphone X', 799.99, 20),
    (2, 'Smartphone Mini', 499.99, 25),
    (3, 'Tablet Plus', 599.99, 12),
    (4, 'Monitor 27', 349.99, 8),
    (5, 'Keyboard Mechanical', 89.99, 30),
    (6, 'Wireless Mouse', 39.99, 40),
    (7, 'Headphones Pro', 149.99, 18),
    (10, 'USB-C Hub', 49.99, 22);

    INSERT INTO customers (name, email) VALUES
    ('Anna Ivanova', 'anna@example.com'),
    ('Pavel Smirnov', 'pavel@example.com'),
    ('Maria Petrova', 'maria@example.com'),
    ('Ivan Sokolov', 'ivan@example.com'),
    ('Elena Volkova', 'elena@example.com'),
    ('Dmitry Kozlov', 'dmitry@example.com'),
    ('Olga Morozova', 'olga@example.com'),
    ('Alexey Novikov', 'alexey@example.com'),
    ('Natalia Fedorova', 'natalia@example.com'),
    ('Sergey Pavlov', 'sergey@example.com');

    INSERT INTO orders (customer_id, created_at, status) VALUES
    (1, '2026-10-01 10:00:00+00', 'new'),
    (2, '2026-10-02 11:30:00+00', 'paid'),
    (3, '2026-10-03 12:15:00+00', 'shipped'),
    (4, '2026-10-04 14:00:00+00', 'new'),
    (5, '2026-10-05 09:45:00+00', 'paid'),
    (6, '2026-10-06 16:20:00+00', 'cancelled'),
    (7, '2026-10-07 13:10:00+00', 'shipped'),
    (8, '2026-10-08 15:00:00+00', 'new'),
    (9, '2026-10-09 17:25:00+00', 'paid'),
    (10, '2026-10-10 18:40:00+00', 'new');

    INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 1299.99),
    (1, 7, 1, 89.99),
    (2, 3, 1, 799.99),
    (2, 8, 2, 39.99),
    (3, 5, 1, 599.99),
    (4, 6, 2, 349.99),
    (5, 2, 1, 999.99),
    (6, 9, 1, 149.99),
    (7, 10, 2, 49.99),
    (8, 4, 1, 499.99),
    (9, 1, 1, 1299.99),
    (10, 3, 2, 799.99);