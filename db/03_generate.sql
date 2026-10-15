-- Лаба 1. Генерация дополнительных тестовых данных.
-- Создаём 1000 покупателей с уникальными email.

INSERT INTO customers (name, email)
SELECT
    'Generated Customer ' || n,
    'generated_customer_' || n || '@example.com'
FROM generate_series(1, 1000) AS series(n)
ON CONFLICT (email) DO NOTHING;