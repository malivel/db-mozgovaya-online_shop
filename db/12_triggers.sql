-- Добавляем время последнего изменения товара
ALTER TABLE products
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp();


-- Функция автоматического обновления updated_at
CREATE OR REPLACE FUNCTION set_product_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := clock_timestamp();
    RETURN NEW;
END;
$$;


-- Триггер обновления времени изменения товара
DROP TRIGGER IF EXISTS trg_product_updated_at ON products;

CREATE TRIGGER trg_product_updated_at
BEFORE UPDATE ON products
FOR EACH ROW
EXECUTE FUNCTION set_product_updated_at();

-- Функция проверки остатка товара перед добавлением позиции заказа
CREATE OR REPLACE FUNCTION check_product_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock INTEGER;
BEGIN
    SELECT stock_quantity
    INTO v_stock
    FROM products
    WHERE id = NEW.product_id
    FOR UPDATE;

    -- Если товар не найден, позволяем внешнему ключу вернуть ошибку
    IF NOT FOUND THEN
        RETURN NEW;
    END IF;

    IF NEW.quantity > v_stock THEN
        RAISE EXCEPTION
            'Нет мест на складе: доступно %, запрошено %',
            v_stock,
            NEW.quantity;
    END IF;

    RETURN NEW;
END;
$$;


-- Проверяем остаток до добавления позиции заказа
DROP TRIGGER IF EXISTS trg_check_product_stock ON order_items;

CREATE TRIGGER trg_check_product_stock
BEFORE INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION check_product_stock();


-- Функция уменьшения остатка после добавления позиции заказа
CREATE OR REPLACE FUNCTION decrease_product_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE id = NEW.product_id;

    RETURN NEW;
END;
$$;


-- Уменьшаем остаток после успешного добавления позиции
DROP TRIGGER IF EXISTS trg_decrease_product_stock ON order_items;

CREATE TRIGGER trg_decrease_product_stock
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION decrease_product_stock();