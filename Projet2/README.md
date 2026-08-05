# Projet 2 - Marché immobilier en Ille-et-Vilaine : exploration Python & data storytelling

## Mise en situation

Une agence immobilière implantée à Rennes veut objectiver son discours commercial. Ses conseillers s'appuient aujourd'hui sur leur intuition du marché, mais les clients arrivent de plus en plus informés et demandent des chiffres. L'agence dispose d'une source fiable et publique, les Demandes de Valeurs Foncières (DVF) publiées par l'État, qui recensent toutes les ventes immobilières.

Elle a besoin d'une analyse claire du marché de l'Ille-et-Vilaine pour appuyer ses conseils, et se pose les questions suivantes :

* Comment les prix au m² ont-ils évolué en Ille-et-Vilaine entre 2021 et 2025 ?
* Quelles communes du département sont les plus chères, lesquelles restent les plus abordables, et où se situe Rennes dans ce classement ?
* Quel écart de prix existe entre maisons et appartements sur cette période, et lequel des deux marchés est le plus dynamique en volume de ventes ?
* La surface d'un bien influence-t-elle son prix au m² ?
* Les ventes se concentrent-elles sur certaines périodes de l'année entre 2021 et 2025 ?

**Ma mission :** partir des données brutes DVF, isoler le périmètre pertinent (Ille-et-Vilaine, 2021-2025), nettoyer et explorer ce jeu de données, puis produire une analyse visuelle et écrite répondant à ces questions.

## Dataset

Source : [Demandes de valeurs foncières géolocalisées](https://www.data.gouv.fr/datasets/demandes-de-valeurs-foncieres-geolocalisees) (data.gouv.fr / DGFiP)

Périmètre retenu : département d'Ille-et-Vilaine (35), transactions entre 2021 et 2025.

Colonnes principales utilisées :

| Colonne | Description |
|---|---|
| `date_mutation` | Date de la vente |
| `valeur_fonciere` | Montant de la vente |
| `type_local` | Type de bien (maison, appartement) |
| `surface_reelle_bati` | Surface habitable du bien |
| `code_commune` / `nom_commune` | Localisation du bien (commune) |
| `longitude` / `latitude` | Coordonnées géographiques de la parcelle |
| `annee` | Année de la vente (ajoutée au chargement, une par fichier source) |

Note méthodologique : la colonne `nature_mutation` a été utilisée pour ne conserver que les transactions de type "Vente" (en excluant échanges, expropriations, adjudications, et ventes en l'état futur d'achèvement), puis retirée du jeu de données final.

Les fichiers bruts couvrent toute la France : un premier travail consistera à filtrer sur le département 35, sélectionner les colonnes utiles, et écarter les types de biens hors sujet (locaux commerciaux, terrains non bâtis) pour se concentrer sur les logements.

## Démarche

1. Récupération des fichiers DVF géolocalisés (2021 à 2025) et filtrage sur l'Ille-et-Vilaine
2. Exploration initiale : structure du fichier, types de colonnes, valeurs manquantes, doublons
3. Nettoyage : valeurs aberrantes (prix ou surfaces incohérents), doublons de mutation, filtrage sur les types de biens pertinents (maisons et appartements)
4. Calcul du prix au m² par transaction
5. Analyse exploratoire : évolution temporelle des prix, comparaison des communes, écarts maison/appartement, effet de la surface, saisonnalité des ventes
6. Visualisations avec matplotlib et seaborn
7. Carte choroplèthe des prix par commune avec geopandas
8. Rédaction du récit final (data storytelling) à partir des résultats obtenus

## Résultats

À compléter au fil de l'avancement du projet.