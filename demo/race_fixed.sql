-- [setup]
DELETE FROM order_items
WHERE product_id = 10 AND order_id IN (1, 2);

UPDATE products
SET stock_quantity = 1
WHERE id = 10;

-- [A]
BEGIN;

INSERT INTO order_items(order_id, product_id, quantity, unit_price)
VALUES (1, 10, 1, 100);

-- [B]
BEGIN;

-- expect: blocked
INSERT INTO order_items(order_id, product_id, quantity, unit_price)
VALUES (2, 10, 1, 100);

-- [A]
COMMIT;

-- [B]
COMMIT;

-- [check]
SELECT stock_quantity >= 0
   AND stock_quantity = 0
   AND EXISTS (
       SELECT 1
       FROM order_items
       WHERE order_id = 1 AND product_id = 10
   )
   AND NOT EXISTS (
       SELECT 1
       FROM order_items
       WHERE order_id = 2 AND product_id = 10
   ) AS result
FROM products
WHERE id = 10;

-- expect: true

-- [cleanup]
DELETE FROM order_items
WHERE product_id = 10 AND order_id IN (1, 2);

UPDATE products
SET stock_quantity = 22
WHERE id = 10;