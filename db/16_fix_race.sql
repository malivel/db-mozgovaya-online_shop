-- Исправление гонки при покупке товара.
-- Блокируем строку товара до проверки остатка.

CREATE OR REPLACE FUNCTION public.check_product_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_stock INTEGER;
BEGIN
    SELECT stock_quantity
    INTO v_stock
    FROM public.products
    WHERE id = NEW.product_id
    FOR UPDATE;

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

DROP TRIGGER IF EXISTS trg_check_product_stock ON public.order_items;

CREATE TRIGGER trg_check_product_stock
BEFORE INSERT ON public.order_items
FOR EACH ROW
EXECUTE FUNCTION public.check_product_stock();