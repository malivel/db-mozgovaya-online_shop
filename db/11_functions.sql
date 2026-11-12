-- Функция 1: расчёт общей стоимости заказа
CREATE OR REPLACE FUNCTION get_order_total(p_order_id INTEGER)
RETURNS NUMERIC(10,2)
LANGUAGE SQL
AS $$
    SELECT COALESCE(
        SUM(quantity * unit_price),
        0
    )::NUMERIC(10,2)
    FROM order_items
    WHERE order_id = p_order_id;
$$;


-- Функция 2: добавление товара в заказ
CREATE OR REPLACE FUNCTION buy_product(
    p_order_id INTEGER,
    p_product_id INTEGER,
    p_quantity INTEGER
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_price NUMERIC(10,2);
    v_item_id INTEGER;
BEGIN
    IF p_quantity <= 0 THEN
        RAISE EXCEPTION 'Quantity must be greater than zero';
    END IF;

    SELECT price
    INTO v_price
    FROM products
    WHERE id = p_product_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Product with id % not found', p_product_id;
    END IF;

    INSERT INTO order_items (
        order_id,
        product_id,
        quantity,
        unit_price
    )
    VALUES (
        p_order_id,
        p_product_id,
        p_quantity,
        v_price
    )
    RETURNING id INTO v_item_id;

    RETURN v_item_id;
END;
$$;