-- ★ Материализованное представление: продажи по категориям
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_category_sales AS
SELECT
    c.id AS category_id,
    c.name AS category_name,
    COUNT(DISTINCT o.id) AS order_count,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0)::NUMERIC(12,2) AS revenue
FROM categories c
LEFT JOIN products p ON p.category_id = c.id
LEFT JOIN order_items oi ON oi.product_id = p.id
LEFT JOIN orders o ON o.id = oi.order_id
GROUP BY c.id, c.name;

-- ★ Функция фильтрации товаров
CREATE OR REPLACE FUNCTION get_products_filtered(
    p_category_id INTEGER DEFAULT NULL,
    p_min_price NUMERIC DEFAULT NULL,
    p_max_price NUMERIC DEFAULT NULL,
    p_in_stock BOOLEAN DEFAULT NULL
)
RETURNS TABLE (
    product_id INTEGER,
    product_name VARCHAR,
    category_name VARCHAR,
    price NUMERIC,
    stock_quantity INTEGER
)
LANGUAGE SQL
AS $$
    SELECT
        p.id,
        p.name,
        c.name,
        p.price,
        p.stock_quantity
    FROM products p
    INNER JOIN categories c ON c.id = p.category_id
    WHERE
        (p_category_id IS NULL OR p.category_id = p_category_id)
        AND (p_min_price IS NULL OR p.price >= p_min_price)
        AND (p_max_price IS NULL OR p.price <= p_max_price)
        AND (
            p_in_stock IS NULL
            OR (p_in_stock = TRUE AND p.stock_quantity > 0)
            OR (p_in_stock = FALSE AND p.stock_quantity = 0)
        )
    ORDER BY p.id;
$$;