-- Лаба 1. Сценарий проверки ограничений интернет-магазина.

-- 1. Повторный email покупателя: ошибка UNIQUE
-- expect: error unique
INSERT INTO customers (name, email)
VALUES ('Test Customer', 'anna@example.com');

-- 2. Отрицательный остаток товара: ошибка CHECK
-- expect: error check
INSERT INTO products (category_id, name, price, stock_quantity)
VALUES (1, 'Invalid Stock Product', 100, -1);

-- 3. Ссылка на несуществующую категорию: ошибка внешнего ключа
-- expect: error fk
INSERT INTO products (category_id, name, price, stock_quantity)
VALUES (999999, 'Invalid Category Product', 100, 5);