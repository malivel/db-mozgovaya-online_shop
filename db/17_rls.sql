
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'customer_1') THEN
        CREATE ROLE customer_1;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'customer_2') THEN
        CREATE ROLE customer_2;
    END IF;
END
$$;

ALTER TABLE customers
ADD COLUMN IF NOT EXISTS owner_role TEXT;

UPDATE customers
SET owner_role = CASE
    WHEN id % 2 = 1 THEN 'customer_1'
    ELSE 'customer_2'
END
WHERE owner_role IS NULL;

ALTER TABLE customers
ALTER COLUMN owner_role SET NOT NULL;

ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS customers_owner_policy ON customers;

CREATE POLICY customers_owner_policy
ON customers
FOR SELECT
USING (owner_role = current_user);

GRANT USAGE ON SCHEMA public TO customer_1, customer_2;
GRANT SELECT ON customers TO customer_1, customer_2;
