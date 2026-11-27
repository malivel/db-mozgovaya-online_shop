
-- [setup]
UPDATE products SET stock_quantity = 10 WHERE id = 1;
UPDATE products SET stock_quantity = 10 WHERE id = 2;

-- [A]
BEGIN;

UPDATE products
SET stock_quantity = stock_quantity + 1
WHERE id = 1;

-- [B]
BEGIN;

UPDATE products
SET stock_quantity = stock_quantity + 1
WHERE id = 2;

-- [A]
-- expect: blocked
UPDATE products
SET stock_quantity = stock_quantity + 1
WHERE id = 2;

-- [B]
-- expect: error deadlock
UPDATE products
SET stock_quantity = stock_quantity + 1
WHERE id = 1;

ROLLBACK;

-- [A]
COMMIT;

-- [check]
SELECT stock_quantity = 11
FROM products
WHERE id = 1
  AND (SELECT stock_quantity = 11 FROM products WHERE id = 2);

-- expect: true

-- [cleanup]
UPDATE products SET stock_quantity = 10 WHERE id = 1;
UPDATE products SET stock_quantity = 10 WHERE id = 2;
