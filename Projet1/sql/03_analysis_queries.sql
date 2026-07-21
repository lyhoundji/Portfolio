-- ============================================================
-- REQUÊTES D'ANALYSE BUSINESS
-- Répondent aux questions posées par le gérant de la boutique
-- ============================================================

-- ------------------------------------------------------------
-- 1. Top 5 produits par chiffre d'affaires et par quantité vendue
-- ------------------------------------------------------------
-- Question du gérant : "Quels sont nos produits qui rapportent le
-- plus de chiffre d'affaires, et lesquels se vendent le plus en
-- quantité ?"
-- ------------------------------------------------------------

-- Tri par chiffre d'affaires (rentabilité)
SELECT
    p.product_name,
    SUM(o.total) AS chiffre_affaires,
    SUM(o.quantity) AS quantite_vendue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY chiffre_affaires DESC
LIMIT 5;

-- Tri par quantité vendue (popularité)
SELECT
    p.product_name,
    SUM(o.total) AS chiffre_affaires,
    SUM(o.quantity) AS quantite_vendue
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY quantite_vendue DESC
LIMIT 5;

-- ------------------------------------------------------------
-- 2. SEGMENTATION — catégories les plus attractives et rentables
-- ------------------------------------------------------------
-- Question du gérant : "Quelles catégories de produits
-- attirent le plus de clients, et lesquelles génèrent le plus de
-- chiffre d'affaires ?"
-- ------------------------------------------------------------

SELECT
    p.category,
    SUM(o.total) AS chiffre_affaires,
    COUNT(DISTINCT o.customer_id) AS clients
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY chiffre_affaires DESC;

-- ------------------------------------------------------------
-- 3. SAISONNALITÉ — évolution du chiffre d'affaires par mois
-- ------------------------------------------------------------
-- Question du gérant : "Nos ventes varient-elles selon les mois ?"
-- ------------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM order_date) AS annee,
    EXTRACT(MONTH FROM order_date) AS mois,
    SUM(o.total) AS chiffre_affaires
FROM orders o
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY annee ASC, mois ASC;