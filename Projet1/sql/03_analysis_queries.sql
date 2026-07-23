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

-- Les deux tris sont calcules separement car un produit tres
-- vendu n'est pas forcement celui qui rapporte le plus, et
-- inversement.
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

-- Resultat : blender arrive en tete sur les deux classements,
-- c'est le produit le plus solide de la boutique. Science
-- apparait dans le top quantite mais pas dans le top CA (se vend
-- souvent, a faible valeur unitaire). Basketball est dans le top
-- CA mais pas dans le top quantite (se vend moins, mais rapporte
-- plus par unite).


-- ------------------------------------------------------------
-- 2. SEGMENTATION — catégories les plus attractives et rentables
-- ------------------------------------------------------------
-- Question du gérant : "Quelles catégories de produits
-- attirent le plus de clients, et lesquelles génèrent le plus de
-- chiffre d'affaires ?"

-- Note : une segmentation par frequence d'achat n'est pas
-- possible sur ce dataset, 97 des 100 clients n'ont passe qu'une
-- seule commande. On segmente donc par categorie achetee plutot
-- que par comportement d'achat repete.
-- ------------------------------------------------------------

SELECT
    p.category,
    SUM(o.total) AS chiffre_affaires,
    COUNT(DISTINCT o.customer_id) AS clients
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY chiffre_affaires DESC;

-- Resultat : home est la categorie la plus rentable, en total
-- comme en nombre de clients. L'ecart est encore plus net une
-- fois ramene au client : environ 3176 de CA moyen par client
-- pour home, contre 959 pour electronics, soit plus de 3 fois
-- plus.


-- ------------------------------------------------------------
-- 3. SAISONNALITÉ — évolution du chiffre d'affaires par mois
-- ------------------------------------------------------------
-- Question du gérant : "Nos ventes varient-elles selon les mois ?"

-- Annee et mois sont combines dans le GROUP BY, pas seulement le
-- mois, pour ne pas confondre un meme mois d'annees differentes
-- (janvier 2024 et janvier 2025 comptent comme deux groupes distincts).
-- ------------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM order_date) AS annee,
    EXTRACT(MONTH FROM order_date) AS mois,
    SUM(o.total) AS chiffre_affaires
FROM orders o
GROUP BY EXTRACT(YEAR FROM order_date), EXTRACT(MONTH FROM order_date)
ORDER BY annee ASC, mois ASC;

-- Resultat : fevrier 2025 se distingue avec un CA largement
-- superieur aux autres mois (66329 contre environ 12000 en
-- moyenne). Ce pic ne se reproduit ni en fevrier 2023 ni en
-- fevrier 2024, ce qui suggere quelques commandes ponctuelles a
-- forte valeur plutot qu'une vraie saisonnalite. Le faible volume
-- de donnees (100 commandes sur environ 3 ans) limite de toute
-- facon la fiabilite d'une telle analyse ici.


-- ------------------------------------------------------------
-- 4. CHIFFRE D'AFFAIRES GLOBAL
-- ------------------------------------------------------------
-- Question du gérant : "Quel est notre chiffre d'affaires total,
-- et comment évolue-t-il ?"

-- Le total est calcule ici, l'evolution mois par mois est deja
-- couverte par la requete de saisonnalite ci-dessus.
-- ------------------------------------------------------------

SELECT SUM(o.total) AS chiffre_affaires_total
FROM orders o;

-- Resultat : chiffre d'affaires total de 200892,93 sur l'ensemble
-- de la periode couverte par le dataset.