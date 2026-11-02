
-- Лаба 2. Запросы к данным интернет-магазина

-- 1. Какие товары продаются и к каким категориям они относятся?
SELECT
    p.id,
    p.name AS product_name,
    c.name AS category_name,
    p.price
FROM products p
INNER JOIN categories c ON c.id = p.category_id
ORDER BY c.name, p.name;

-- 2. Какие товары входят в заказы, кто их заказал и в каком количестве?
SELECT
    o.id AS order_id,
    cu.name AS customer_name,
    p.name AS product_name,
    oi.quantity,
    oi.unit_price
FROM orders o
INNER JOIN customers cu ON cu.id = o.customer_id
INNER JOIN order_items oi ON oi.order_id = o.id
INNER JOIN products p ON p.id = oi.product_id
ORDER BY o.id, p.name;

-- 3. Какие покупатели уже сделали заказы, включая покупателей с несколькими заказами?
SELECT
    cu.id AS customer_id,
    cu.name AS customer_name,
    o.id AS order_id,
    o.status,
    o.created_at
FROM customers cu
INNER JOIN orders o ON o.customer_id = cu.id
ORDER BY cu.id, o.created_at;

-- 4. Сколько товаров находится в каждой категории и какова их средняя цена?
SELECT
    c.id AS category_id,
    c.name AS category_name,
    COUNT(p.id) AS product_count,
    ROUND(AVG(p.price), 2) AS average_price
FROM categories c
INNER JOIN products p ON p.category_id = c.id
GROUP BY c.id, c.name
ORDER BY product_count DESC, c.name;

-- 5. В каких категориях больше одного товара?
SELECT
    c.name AS category_name,
    COUNT(p.id) AS product_count
FROM categories c
INNER JOIN products p ON p.category_id = c.id
GROUP BY c.id, c.name
HAVING COUNT(p.id) > 1
ORDER BY product_count DESC, c.name;

-- 6. Какие товары стоят дороже средней цены всех товаров?
SELECT
    p.name AS product_name,
    p.price
FROM products p
WHERE p.price > (
    SELECT AVG(price)
    FROM products
)
ORDER BY p.price DESC;

-- 7. Какие покупатели ещё ни разу не делали заказ?
SELECT
    c.id,
    c.name,
    c.email
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
WHERE o.id IS NULL
ORDER BY c.id
LIMIT 10;

-- 8. Какие покупатели хотя бы один раз делали заказ?
SELECT
    c.id,
    c.name,
    c.email
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.id
)
ORDER BY c.id;

-- 9. Можно ли добавить нового тестового покупателя?
BEGIN;

SELECT id, name, email
FROM customers
WHERE email = 'lab2_insert_test@example.com';

INSERT INTO customers (name, email)
VALUES ('Lab 2 Insert Test', 'lab2_insert_test@example.com');

SELECT id, name, email
FROM customers
WHERE email = 'lab2_insert_test@example.com';

ROLLBACK;

-- 10. Как изменится имя тестового покупателя после UPDATE?
BEGIN;

INSERT INTO customers (name, email)
VALUES ('Lab 2 Update Before', 'lab2_update_test@example.com');

SELECT id, name, email
FROM customers
WHERE email = 'lab2_update_test@example.com';

UPDATE customers
SET name = 'Lab 2 Update After'
WHERE email = 'lab2_update_test@example.com';

SELECT id, name, email
FROM customers
WHERE email = 'lab2_update_test@example.com';

ROLLBACK;

-- 11. Удалился ли тестовый покупатель после DELETE?
BEGIN;

INSERT INTO customers (name, email)
VALUES ('Lab 2 Delete Test', 'lab2_delete_test@example.com');

SELECT
    'До удаления' AS stage,
    COUNT(*) AS customer_count
FROM customers
WHERE email = 'lab2_delete_test@example.com';

DELETE FROM customers
WHERE email = 'lab2_delete_test@example.com';

SELECT
    'После удаления' AS stage,
    COUNT(*) AS customer_count
FROM customers
WHERE email = 'lab2_delete_test@example.com';

ROLLBACK;

-- 12. Какие пять товаров самые дорогие?
SELECT
    p.name AS product_name,
    c.name AS category_name,
    p.price
FROM products p
INNER JOIN categories c ON c.id = p.category_id
ORDER BY p.price DESC
LIMIT 5;

-- 13. Какие три самых дорогих товара есть в каждой категории?
WITH ranked_products AS (
    SELECT
        c.name AS category_name,
        p.name AS product_name,
        p.price,
        ROW_NUMBER() OVER (
            PARTITION BY c.id
            ORDER BY p.price DESC, p.id
        ) AS product_rank
    FROM products p
    INNER JOIN categories c ON c.id = p.category_id
)
SELECT
    category_name,
    product_name,
    price,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY category_name, product_rank;


-- 14. Как растёт накопительная стоимость товаров в заказах?
SELECT
    o.id AS order_id,
    o.created_at,
    oi.product_id,
    oi.quantity * oi.unit_price AS item_total,
    SUM(oi.quantity * oi.unit_price) OVER (
        ORDER BY o.created_at, o.id, oi.id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM orders o
INNER JOIN order_items oi ON oi.order_id = o.id
ORDER BY o.created_at, o.id, oi.id;

-- 15. Как менялась сумма продаж по месяцам в сравнении с предыдущим месяцем?
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', o.created_at) AS sales_month,
        SUM(oi.quantity * oi.unit_price) AS total_sales
    FROM orders o
    INNER JOIN order_items oi ON oi.order_id = o.id
    WHERE o.status IN ('paid', 'shipped')
    GROUP BY DATE_TRUNC('month', o.created_at)
),
sales_with_previous AS (
    SELECT
        sales_month,
        total_sales,
        LAG(total_sales) OVER (ORDER BY sales_month) AS previous_month_sales
    FROM monthly_sales
)
SELECT
    sales_month,
    total_sales,
    previous_month_sales,
    ROUND(
        100.0 * (total_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0),
        2
    ) AS change_percent
FROM sales_with_previous
ORDER BY sales_month;

-- 16. Сколько заказов было в каждый календарный день, включая дни без заказов?
WITH RECURSIVE calendar AS (
    SELECT MIN(created_at::date) AS calendar_date
    FROM orders

    UNION ALL

    SELECT calendar_date + 1
    FROM calendar
    WHERE calendar_date < (
        SELECT MAX(created_at::date)
        FROM orders
    )
)
SELECT
    c.calendar_date,
    COUNT(o.id) AS order_count
FROM calendar c
LEFT JOIN orders o
    ON o.created_at::date = c.calendar_date
GROUP BY c.calendar_date
ORDER BY c.calendar_date;