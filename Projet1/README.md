# Projet 1 - Analyse e-commerce : SQL & nettoyage de données

## Mise en situation

Le gérant d'une boutique en ligne exporte régulièrement ses données de vente depuis son système de commande, mais cet export brut n'a jamais été vérifié ni nettoyé : dates dans des formats différents, prix parfois saisis en texte, quantités négatives, catégories mal orthographiées ou incohérentes, doublons de commandes...

Avant de pouvoir piloter son activité, il a besoin de réponses fiables à ces questions :

* Quels sont nos produits qui rapportent le plus de chiffre d'affaires, et lesquels se vendent le plus en quantité ?
* Quels types de clients achètent le plus, et à quelle fréquence ?
* Nos ventes varient-elles selon les mois ?
* Quel est notre chiffre d'affaires total, et comment évolue-t-il ?

**Ma mission :** partir de cet export brut, concevoir une base de données relationnelle propre, identifier et corriger les problèmes de qualité des données, puis produire les requêtes SQL répondant à ces questions.

## Dataset

Source : [Messy E-Commerce Sales Dataset](https://www.kaggle.com/datasets/kandeelai22/messy-e-commerce-sales-dataset) (Kaggle)

| Colonne | Description |
|---|---|
| `ID` | Identifiant de la ligne |
| `Customer_Name` | Nom du client |
| `Order_ID` | Identifiant de la commande |
| `Order_Date` | Date de la commande |
| `Product` | Nom du produit |
| `Category` | Catégorie du produit |
| `Quantity` | Quantité commandée |
| `Price` | Prix unitaire |
| `Payment_Method` | Moyen de paiement |
| `Status` | Statut de la commande |
| `Total` | Montant total de la ligne |

## Schéma de la base

Trois tables reliées entre elles (*customers*, *products*, *orders*) voir *sql/01_create_tables.sql*.

## Démarche

1. Exploration du fichier brut : colonnes, types, premiers problèmes de qualité
2. Conception du schéma relationnel (*customers*, *products*, *orders*)
3. Création des tables dans PostgreSQL (*sql/01_create_tables.sql*)
4. Import des données brutes dans une table de staging (*raw_sales*) sans modification
5. Nettoyage des données vers les tables finales (*sql/02_cleaning.sql*) :
   * Doublons de commandes détectés et résolus par cohérence *total = price × quantity*
   * Casse incohérente sur produits/catégories uniformisée (*LOWER()*)
   * Catégories contradictoires par produit résolues par la valeur majoritaire (*MODE()*)
   * Prix/quantités invalides ou manquants complétés par la médiane des valeurs valides du même produit
   * Dates dans des formats hétérogènes uniformisées (*TO_DATE()*), valeurs invalides mises à *NULL*
6. Requêtes d'analyse business répondant aux questions du gérant (*sql/03_analysis_queries.sql*)
7. Export SQLite de la base nettoyée

## Résultats

*À compléter au fil des requêtes d'analyse.*

