-- Лабораторная работа 3: представления, функции и триггеры

-- 1. Представление: каталог товаров
SELECT *
FROM v_product_catalog
ORDER BY product_id
LIMIT 5;

-- 2. Представление: информация о заказах
SELECT *
FROM v_order_details
ORDER BY order_id
LIMIT 5;

-- 3. Функция: общая стоимость заказа
SELECT get_order_total(1) AS order_total;

-- 4. Функция: покупка товара
-- Тестируем покупку внутри транзакции, затем отменяем её
BEGIN;

SELECT buy_product(1, 10, 1) AS new_order_item_id;

SELECT id, name, stock_quantity, updated_at
FROM products
WHERE id = 10;

ROLLBACK;

-- 5. Триггер: запрет покупки сверх остатка
-- expect: error "Нет мест на складе"
SELECT buy_product(1, 10, 23);

-- 6. Проверяем, что тестовая покупка отменена
SELECT id, name, stock_quantity
FROM products
WHERE id = 10;

-- ★ Обновление материализованного отчёта
REFRESH MATERIALIZED VIEW mv_category_sales;

SELECT *
FROM mv_category_sales
ORDER BY category_id;

-- ★ Фильтрация товаров: цена от 500, товар в наличии
SELECT *
FROM get_products_filtered(
    p_min_price => 500,
    p_in_stock => TRUE
);

-- ★★ Проверка журнала истории изменений JSONB
BEGIN;

-- Изменяем цену товара
UPDATE products
SET price = price + 1
WHERE id = 10;

-- Проверяем, что триггер записал старое и новое состояние
SELECT
    product_id,
    operation,
    old_data->>'price' AS old_price,
    new_data->>'price' AS new_price,
    changed_by
FROM product_history
WHERE product_id = 10
ORDER BY id DESC
LIMIT 1;

-- ★★ Проверяем восстановление состояния на прошлый момент
SELECT
    get_product_state_at(
        10,
        clock_timestamp() - INTERVAL '1 second'
    )->>'price' AS previous_price;

ROLLBACK;