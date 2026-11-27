-- [setup]
DELETE FROM order_items
WHERE product_id = 10 AND order_id IN (1, 2);

UPDATE products
SET stock_quantity = 1
WHERE id = 10;

ALTER TABLE products
DROP CONSTRAINT products_stock_quantity_check;

DROP TRIGGER trg_check_product_stock ON order_items;

-- [A]
BEGIN;

INSERT INTO order_items(order_id, product_id, quantity, unit_price)
VALUES (1, 10, 1, 100);

-- [B]
BEGIN;

INSERT INTO order_items(order_id, product_id, quantity, unit_price)
VALUES (2, 10, 1, 100);

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check]
SELECT stock_quantity >= 0 AS result
FROM products
WHERE id = 10;

-- expect: false

-- [cleanup]
DELETE FROM order_items
WHERE product_id = 10 AND order_id IN (1, 2);

UPDATE products
SET stock_quantity = 22
WHERE id = 10;

ALTER TABLE products
ADD CONSTRAINT products_stock_quantity_check
CHECK (stock_quantity >= 0);

CREATE TRIGGER trg_check_product_stock
BEFORE INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION check_product_stock();