
-- [setup]
DELETE FROM order_items
WHERE order_id = 1 AND product_id = 10;

UPDATE products
SET stock_quantity = 22
WHERE id = 10;

-- 1. Остаток до транзакции
SELECT stock_quantity
FROM products
WHERE id = 10;

-- expect: rows 1

-- 2. Ошибка внутри транзакции и откат
BEGIN;

UPDATE products
SET stock_quantity = stock_quantity - 5
WHERE id = 10;

-- expect: error raise
INSERT INTO order_items(order_id, product_id, quantity, unit_price)
VALUES (1, 10, 999, 100);

ROLLBACK;

-- 3. Остаток после отката
SELECT stock_quantity
FROM products
WHERE id = 10;

-- expect: same 1

-- 4. Запрет записи для app_reader
SET ROLE app_reader;

-- expect: error permission
INSERT INTO categories(name)
VALUES ('reader_forbidden_test');

RESET ROLE;

-- 5. Запрет прямой записи для app_writer
SET ROLE app_writer;

-- expect: error permission
INSERT INTO order_items(order_id, product_id, quantity, unit_price)
VALUES (1, 10, 1, 100);

-- 6. Запрет изменения остатков для app_writer
-- expect: error permission
UPDATE products
SET stock_quantity = 50
WHERE id = 10;

RESET ROLE;

-- [check]
SELECT stock_quantity = 22
   AND NOT EXISTS (
       SELECT 1
       FROM order_items
       WHERE order_id = 1 AND product_id = 10
   ) AS unchanged
FROM products
WHERE id = 10;

-- expect: true

-- [cleanup]
DELETE FROM order_items
WHERE order_id = 1 AND product_id = 10;

UPDATE products
SET stock_quantity = 22
WHERE id = 10;
