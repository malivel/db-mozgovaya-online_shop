-- ★★ Журнал истории изменений товаров
CREATE TABLE IF NOT EXISTS product_history (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id INTEGER NOT NULL,
    operation VARCHAR(10) NOT NULL,
    old_data JSONB,
    new_data JSONB,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    changed_by TEXT NOT NULL DEFAULT session_user
);

-- Функция записи истории изменений
CREATE OR REPLACE FUNCTION log_product_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        INSERT INTO product_history (
            product_id,
            operation,
            old_data,
            new_data
        )
        VALUES (
            OLD.id,
            'UPDATE',
            to_jsonb(OLD),
            to_jsonb(NEW)
        );

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO product_history (
            product_id,
            operation,
            old_data,
            new_data
        )
        VALUES (
            OLD.id,
            'DELETE',
            to_jsonb(OLD),
            NULL
        );

        RETURN OLD;
    END IF;

    RETURN NULL;
END;
$$;

-- Триггер журналирования UPDATE и DELETE
DROP TRIGGER IF EXISTS trg_product_history ON products;

CREATE TRIGGER trg_product_history
AFTER UPDATE OR DELETE ON products
FOR EACH ROW
EXECUTE FUNCTION log_product_changes();

-- ★★ Получение состояния товара на заданный момент времени
CREATE OR REPLACE FUNCTION get_product_state_at(
    p_product_id INTEGER,
    p_as_of TIMESTAMPTZ
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_state JSONB;
BEGIN
    -- Ищем первое изменение после указанного момента.
    -- Старое состояние этого изменения и есть состояние на дату.
    SELECT old_data
    INTO v_state
    FROM product_history
    WHERE product_id = p_product_id
      AND changed_at > p_as_of
    ORDER BY changed_at ASC, id ASC
    LIMIT 1;

    IF FOUND THEN
        RETURN v_state;
    END IF;

    -- Если будущих изменений нет, возвращаем текущее состояние.
    SELECT to_jsonb(p)
    INTO v_state
    FROM products p
    WHERE p.id = p_product_id;

    RETURN v_state;
END;
$$;