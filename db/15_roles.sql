\getenv reader_password APP_READER_PASSWORD
\getenv writer_password APP_WRITER_PASSWORD

-- Роли приложения
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_reader') THEN
        CREATE ROLE app_reader LOGIN;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_writer') THEN
        CREATE ROLE app_writer LOGIN IN ROLE app_reader;
    END IF;
END
$$;

ALTER ROLE app_reader PASSWORD :'reader_password';
ALTER ROLE app_writer PASSWORD :'writer_password';

-- Запрещаем приложению прямые изменения таблиц
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM app_reader, app_writer;

-- Читатель может читать только представления
GRANT USAGE ON SCHEMA public TO app_reader;
GRANT SELECT ON v_product_catalog, v_order_details TO app_reader;

-- Писатель наследует права читателя, но изменяет данные только через функцию
GRANT USAGE ON SCHEMA public TO app_writer;

-- Убираем стандартное право PUBLIC на выполнение функций
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public FROM PUBLIC;
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public FROM app_reader, app_writer;

-- Разрешаем оформление покупки через бизнес-функцию
ALTER FUNCTION buy_product(integer, integer, integer)
    SECURITY DEFINER;

ALTER FUNCTION buy_product(integer, integer, integer)
    SET search_path = public, pg_temp;

GRANT EXECUTE ON FUNCTION buy_product(integer, integer, integer)
    TO app_writer;