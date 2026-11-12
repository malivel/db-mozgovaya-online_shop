
-- Представление 1: каталог товаров с категориями и остатками
CREATE OR REPLACE VIEW v_product_catalog AS
SELECT
    p.id AS product_id,
    p.name AS product_name,
    c.name AS category_name,
    p.price,
    p.stock_quantity,
    CASE
        WHEN p.stock_quantity = 0 THEN 'Нет в наличии'
        WHEN p.stock_quantity <= 5 THEN 'Мало'
        ELSE 'В наличии'
    END AS availability
FROM products p
INNER JOIN categories c ON c.id = p.category_id;


-- Представление 2: подробная информация о заказах
CREATE OR REPLACE VIEW v_order_details AS
SELECT
    o.id AS order_id,
    o.created_at,
    o.status,
    cu.name AS customer_name,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price AS item_total
FROM orders o
INNER JOIN customers cu ON cu.id = o.customer_id
INNER JOIN order_items oi ON oi.order_id = o.id
INNER JOIN products p ON p.id = oi.product_id;