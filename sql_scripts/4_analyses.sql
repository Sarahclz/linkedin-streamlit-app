Parfait, tu as maintenant tous les éléments pour structurer un fichier `README.md` clair, homogène, et prêt à présenter. Voici une version **sans tableau**, **sans emojis**, **commentée et structurée**, que tu peux **facilement adapter ou compléter** :

---

````markdown
# Projet LinkedIn - Analyse de données avec Snowflake et Streamlit

## Membres du projet

Sarah, Marc, Adrien, Gaetan

## Objectif du projet

Ce projet vise à analyser des offres d’emploi extraites de LinkedIn. Les données sont stockées et manipulées dans Snowflake. Les indicateurs sont affichés dans une application web réalisée avec Streamlit.

## Outils utilisés

- Snowflake (base de données cloud)
- Python
- Streamlit
- Bibliothèques : pandas, plotly, snowflake-connector-python

## Organisation des fichiers

- `1_initialisation.sql` : activation de l'entrepôt, création du stage et des formats de fichiers
- `2_création_tables.sql` : création des tables (job_postings, companies, job_skills, etc.)
- `3_chargement_data.sql` : chargement des fichiers CSV/JSON depuis un stage S3
- `4_analyses.sql` : requêtes analytiques SQL (Top 10 postes, salaires, secteurs, etc.)
- `app.py` : application Streamlit avec affichage des KPI
- `requirements.txt` : dépendances Python
- `README.md` : documentation

---

## Étapes réalisées

### 1. Initialisation

- Activation de l'entrepôt : `USE WAREHOUSE COMPUTE_WH`
- Création de la base `linkedin` et du schéma `projet_linkedin`
- Déclaration du stage externe vers S3 : `linkedin_stage`
- Définition des formats de fichier : `csv_format` et `json_format`

### 2. Création des tables

- Tables créées :
  - `job_postings` : données principales des offres
  - `benefits`, `companies`, `employee_counts`
  - `job_skills`, `job_industries`, `company_industries`, `company_specialities`
  - `industries` : dictionnaire des secteurs
  - `company_size_labels` : table temporaire de correspondance taille/libellé

### 3. Chargement des données

- Utilisation des commandes `COPY INTO` pour charger les fichiers CSV et JSON
- Certains fichiers JSON nécessitent une transformation avec `LATERAL FLATTEN`
- Gestion des erreurs de colonnes : `ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE`
- Création de la table `companies_complet` à partir du JSON d'entreprises
- Correction des correspondances d’industries avec une version nettoyée de la table `industries`

### 4. Analyses réalisées

Les requêtes SQL sont dans le fichier `4_analyses.sql`. Voici les indicateurs extraits :

- Top 10 titres de postes les plus fréquents par secteur
- Top 10 salaires médians par secteur
- Répartition des offres par taille d’entreprise (en se basant sur `company_size_labels`)
- Répartition des offres par secteur d’activité (via `industries`)
- Répartition des offres par type d’emploi (`formatted_work_type`)

---

## Application Streamlit

Le fichier `app.py` contient l'application. Elle utilise :

- Une connexion directe à Snowflake
- La fonction `run_query()` pour exécuter les requêtes SQL
- Un menu latéral Streamlit permettant de naviguer entre les 5 KPI :
  - Top titres
  - Salaires
  - Répartition par taille
  - Répartition par secteur
  - Répartition par type d’emploi

Chaque indicateur est visualisé via `plotly.express` sous forme de graphique (barres, camembert) et affiché sous forme de tableau (`st.dataframe`).

---

## Problèmes rencontrés

- Mauvais mapping des `industry_id` : la table `industries` a été recréée avec les bons identifiants
- JSON imbriqués : nécessité d’utiliser `LATERAL FLATTEN` pour extraire correctement les données
- Données mal formatées dans certains CSV : gestion via `ERROR_ON_COLUMN_COUNT_MISMATCH`
- Problème de jointure avec `company_id` : conversion explicite avec `CAST(... AS NUMBER)`
- Normalisation des noms de colonnes pour l'affichage graphique : passage en `.lower()`

---

## Exécution

### Installation

Assurez-vous d’avoir installé les dépendances :

```bash
pip install -r requirements.txt
````

### Lancement de l'application

```bash
streamlit run app.py
```

---

## Répartition du travail

* Sarah : Streamlit, structuration SQL, visualisations
* Marc : préparation JSON, chargement des données, analyses
* Adrien : requêtes analytiques, vérification des indicateurs
* Gaetan : nettoyage, cohérence SQL, tests finaux

---

## Résultat

L’application permet une analyse complète et interactive des offres d’emploi via Streamlit, en se basant sur des requêtes exécutées en direct depuis Snowflake. Chaque KPI correspond à une question RH stratégique : postes les plus courants, niveaux de salaires, secteurs dynamiques, etc.

---
