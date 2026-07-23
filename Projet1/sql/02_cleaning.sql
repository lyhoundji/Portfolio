-- ============================================================
-- NETTOYAGE DES DONNÉES : de raw_sales vers customers, products, orders
-- ============================================================

-- ------------------------------------------------------------
-- 1. CUSTOMERS
-- ------------------------------------------------------------
-- Aucune anomalie sur id/customer_name dans les donnees sources.
-- On extrait simplement les clients uniques, avec conversion de
-- type : id est en VARCHAR dans raw_sales, customer_id attend un
-- INTEGER dans la table finale.
-- ------------------------------------------------------------

INSERT INTO customers (customer_id, customer_name)
SELECT DISTINCT id::INTEGER, customer_name
FROM raw_sales;

-- ------------------------------------------------------------
-- 2. PRODUCTS
-- ------------------------------------------------------------

-- price_clean : calcule un prix de reference par produit.
-- La regex filtre les valeurs qui ne sont pas des nombres valides
-- (ex. "abd", "four hundred", "300$"), et on exclut aussi les
-- prix negatifs ou nuls, qui ne peuvent pas etre corrects.
-- On utilise la mediane plutot que la moyenne parce qu'un seul
-- prix aberrant (ex. 10000 au lieu de 40) fausserait fortement
-- une moyenne, alors que la mediane y reste insensible.
WITH price_clean AS (
    SELECT LOWER(product) AS product,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price::NUMERIC) AS median_price
    FROM raw_sales
    WHERE price ~ '^[0-9]+(\.[0-9]+)?$' AND price::NUMERIC > 0
    GROUP BY LOWER(product)
),

-- category_clean : determine la categorie la plus probable d'un
-- produit. Certains produits ont des categories differentes
-- selon les lignes (ex. Blender tantot "home", tantot
-- "electronic"), a cause d'erreurs de saisie ponctuelles. MODE()
-- garde la valeur majoritaire plutot que la premiere rencontree.
category_clean AS (
    SELECT LOWER(product) AS product,
        MODE() WITHIN GROUP (ORDER BY LOWER(category)) AS main_category
    FROM raw_sales
    WHERE category IS NOT NULL AND category != ''
    GROUP BY LOWER(product)
)

-- LOWER() est applique a la fois dans le SELECT et le GROUP BY
-- des deux CTE : sans ca, "Shoes" et "shoes" seraient traites
-- comme deux produits distincts.
-- product_id n'existe pas dans le CSV source, il est genere ici
-- avec ROW_NUMBER() puisqu'on a besoin d'une cle primaire stable.
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

-- product_prices : reprend les prix deja nettoyes dans products,
-- pour completer les commandes ou le prix est manquant ou invalide
-- dans raw_sales plutot que de recalculer une nouvelle mediane.
WITH product_prices AS (
    SELECT product_id, product_name, price FROM products
),

-- product_qty_median : meme logique que pour les prix, appliquee
-- cette fois aux quantites. Sert a completer les commandes dont
-- la quantite est manquante ou invalide.
product_qty_median AS (
    SELECT LOWER(product) AS product_name,
        ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY quantity::NUMERIC)) AS median_qty
    FROM raw_sales
    WHERE quantity ~ '^[0-9]+(\.[0-9]+)?$' AND quantity::NUMERIC > 0
    GROUP BY LOWER(product)
),

-- safe_cast : convertit price, quantity et total en nombres, mais
-- seulement quand la valeur est valide (verifiee par regex).
-- Un CAST direct (price::NUMERIC) aurait echoue et bloque toute
-- la requete des la premiere valeur non numerique rencontree
-- (ex. "abd"). Ici, une valeur invalide devient simplement NULL,
-- et sera completee plus loin par COALESCE.
-- Meme principe pour les dates : deux formats coexistent dans le
-- CSV (MM/DD/YYYY et Mon D YYYY), on detecte lequel s'applique
-- avant de convertir. Une date invalide (ex. "abc") devient NULL,
-- faute de moyen fiable de la deviner.
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

-- deduped : certaines commandes (meme order_id) apparaissent deux
-- fois dans raw_sales avec des valeurs legerement differentes.
-- On garde la ligne ou total correspond a price * quantity, qui
-- est la version coherente de la commande, et on ecarte l'autre
-- via ROW_NUMBER() (seul rang = 1 sera conserve plus bas).
deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY CASE WHEN total_num = (price_num * quantity_num) THEN 0 ELSE 1 END
        ) AS rang
    FROM safe_cast
)

-- Le total est toujours recalcule (price_final * quantity_final)
-- plutot que repris du CSV : certaines lignes ont un total
-- incoherent avec price * quantity meme hors doublons, mieux vaut
-- ne jamais lui faire confiance telle quelle.
-- COALESCE utilise la valeur d'origine quand elle est valide, et
-- ne retombe sur la mediane (prix ou quantite) que si elle est
-- NULL, donc uniquement pour les lignes reellement incompletes.
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