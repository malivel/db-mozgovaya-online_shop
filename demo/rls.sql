
-- [A]
SET ROLE customer_1;

SELECT bool_and(owner_role = current_user)
FROM customers;

-- expect: true

-- [A]
RESET ROLE;

-- [A]
SET ROLE customer_2;

SELECT bool_and(owner_role = current_user)
FROM customers;

-- expect: true

-- [A]
RESET ROLE;

-- [A]
SELECT count(*) = 1010
FROM customers;

-- expect: true
