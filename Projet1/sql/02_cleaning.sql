-- ============================================================
-- NETTOYAGE DES DONNÉES : de raw_sales vers customers, products, orders
-- ============================================================

-- ------------------------------------------------------------
-- 1. CUSTOMERS
-- ------------------------------------------------------------
INSERT INTO customers (customer_id, customer_name)
SELECT DISTINCT id::INTEGER, customer_name
FROM raw_sales;

-- ------------------------------------------------------------
-- 2. PRODUCTS
-- ------------------------------------------------------------
WITH price_clean AS (
    SELECT LOWER(product) AS product,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price::NUMERIC) AS median_price
    FROM raw_sales
    WHERE price ~ '^[0-9]+(\.[0-9]+)?$' AND price::NUMERIC > 0
    GROUP BY LOWER(product)
),
category_clean AS (
    SELECT LOWER(product) AS product,
        MODE() WITHIN GROUP (ORDER BY LOWER(category)) AS main_category
    FROM raw_sales
    WHERE category IS NOT NULL AND category != ''
    GROUP BY LOWER(product)
)
INSERT INTO products (product_id, product_name, category, price)
SELECT ROW_NUMBER() OVER (ORDER BY p.product) AS product_id,
    p.product,
    c.main_category,
    p.median_price
FROM price_clean p
JOIN category_clean c ON p.product = c.product;

-- ------------------------------------------------------------
-- 3. ORDERS
-- ------------------------------------------------------------
WITH product_prices AS (
    SELECT product_id, product_name, price FROM products
),
product_qty_median AS (
    SELECT LOWER(product) AS product_name,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY quantity::NUMERIC)) AS median_qty
    FROM raw_sales
    WHERE quantity ~ '^[0-9]+(\.[0-9]+)?$' AND quantity::NUMERIC > 0
    GROUP BY LOWER(product)
),
safe_cast AS (
    SELECT *,
        CASE WHEN price ~ '^[0-9]+(\.[0-9]+)?$' THEN price::NUMERIC ELSE NULL END AS price_num,
        CASE WHEN quantity ~ '^[0-9]+(\.[0-9]+)?$' THEN quantity::NUMERIC ELSE NULL END AS quantity_num,
        CASE WHEN total ~ '^[0-9]+(\.[0-9]+)?$' THEN total::NUMERIC ELSE NULL END AS total_num,
        CASE
            WHEN order_date ~ '^\d{1,2}/\d{1,2}/\d{4}$' THEN TO_DATE(order_date, 'MM/DD/YYYY')
            WHEN order_date ~ '^[A-Za-z]{3} \d{1,2} \d{4}$' THEN TO_DATE(order_date, 'Mon DD YYYY')
            ELSE NULL
        END AS order_date_clean
    FROM raw_sales
),
deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY CASE WHEN total_num = (price_num * quantity_num) THEN 0 ELSE 1 END
        ) AS rang
    FROM safe_cast
)
INSERT INTO orders (order_id, customer_id, product_id, order_date, quantity, total, payment_method, status)
SELECT
    d.order_id,
    d.id::INTEGER,
    pp.product_id,
    d.order_date_clean,
    COALESCE(d.quantity_num, pqm.median_qty)::INTEGER,
    COALESCE(d.price_num, pp.price) * COALESCE(d.quantity_num, pqm.median_qty),
    d.payment_method,
    d.status
FROM deduped d
LEFT JOIN product_prices pp ON pp.product_name = LOWER(d.product)
LEFT JOIN product_qty_median pqm ON pqm.product_name = LOWER(d.product)
WHERE d.rang = 1;