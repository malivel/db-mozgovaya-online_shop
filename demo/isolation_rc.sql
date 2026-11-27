
-- [setup]
UPDATE orders
SET status = 'new'
WHERE id = 1;

-- [A]
BEGIN ISOLATION LEVEL READ COMMITTED;

-- [A]
SELECT status
FROM orders
WHERE id = 1;

-- expect: value new

-- [B]
BEGIN;

UPDATE orders
SET status = 'paid'
WHERE id = 1;

COMMIT;

-- [A]
SELECT status
FROM orders
WHERE id = 1;

-- expect: value paid

-- [A]
COMMIT;

-- [check]
SELECT status = 'paid'
FROM orders
WHERE id = 1;

-- expect: true

-- [cleanup]
UPDATE orders
SET status = 'new'
WHERE id = 1;
