Voici ton `README.md` **complet et homogène**, prêt à être copié-collé dans ton projet.

```markdown
# Analyse LinkedIn – Projet Data avec Snowflake & Streamlit

## 👥 Membres du projet

- Sarah
- Marc
- Adrien
- Gaetan

---

## 🎯 Objectif

Ce projet vise à explorer et analyser des offres d’emploi issues de LinkedIn via Snowflake (entreposage de données) et Streamlit (visualisation interactive). Il s'agit d’un projet pédagogique intégrant la collecte, la structuration, l’analyse et la restitution de données RH.

---

## 🔧 Environnement & Outils

- **Snowflake** pour le stockage, la transformation et l’interrogation des données
- **Streamlit** pour la visualisation des KPI
- **Python** (Pandas, Plotly)
- **VS Code** comme éditeur principal

---

## 📁 Structure du projet

```

linkedin-streamlit-app/
├── app.py                       # Application Streamlit
├── 1\_initialisation.sql        # Création base, tables, formats
├── 2\_chargement.sql            # Chargement et corrections des données
├── 3\_analyses.sql              # Requêtes SQL pour les KPI
├── requirements.txt            # Dépendances Python
└── README.md                   # Documentation du projet

````

---

## ✅ Étapes réalisées

### 1. Initialisation (fichier `1_initialisation.sql`)

- Activation de l'entrepôt :  
  `USE WAREHOUSE COMPUTE_WH;`

- Création base & schéma :  
  `CREATE OR REPLACE DATABASE linkedin;`

- Création des formats de fichier et du stage S3

- Création des tables :
  - `job_postings`
  - `benefits`
  - `companies`
  - `employee_counts`
  - `job_skills`
  - `job_industries`
  - `company_industries`
  - `company_specialities`
  - `industries`
  - `company_size_labels`

---

### 2. Chargement des données (fichier `2_chargement.sql`)

- Fichiers CSV et JSON importés depuis un stage S3 (`linkedin_stage`)
- Commande `COPY INTO` utilisée avec les bons `FILE FORMAT`
- Gestion d'erreurs : `ON_ERROR = 'CONTINUE'`
- Normalisation de certaines tables (ex : `companies_complet` via `FLATTEN`)

---

### 3. Analyses SQL (fichier `3_analyses.sql`)

#### a) Top 10 titres par industrie

```sql
WITH job_title_ranking AS (
    SELECT 
        i.industry_name,
        LOWER(TRIM(jp.title)) AS job_title_normalized,
        COUNT(*) AS post_count,
        ROW_NUMBER() OVER (
            PARTITION BY i.industry_name
            ORDER BY COUNT(*) DESC
        ) AS rang
    FROM job_postings jp
    JOIN job_industries ji ON TRIM(jp.job_id) = TRIM(ji.job_id)
    JOIN industries i ON ji.industry_id = i.industry_id
    WHERE jp.title IS NOT NULL
    GROUP BY i.industry_name, LOWER(TRIM(jp.title))
)
SELECT 
    industry_name,
    INITCAP(job_title_normalized) AS job_title,
    post_count
FROM job_title_ranking
WHERE rang <= 10
ORDER BY industry_name, rang;
````

#### b) Postes les mieux rémunérés

```sql
WITH salaire_ranking AS (
    SELECT
        i.industry_name,
        jp.title AS job_title,
        jp.med_salary,
        ROW_NUMBER() OVER (
            PARTITION BY i.industry_name
            ORDER BY jp.med_salary DESC
        ) AS rang
    FROM job_postings jp
    JOIN job_industries ji ON TRIM(jp.job_id) = TRIM(ji.job_id)
    JOIN industries i ON ji.industry_id = i.industry_id
    WHERE jp.med_salary IS NOT NULL
)
SELECT 
    industry_name,
    job_title,
    med_salary
FROM salaire_ranking
WHERE rang <= 10
ORDER BY industry_name, med_salary DESC;
```

#### c) Répartition des offres par taille

```sql
SELECT
    lbl.label AS taille_entreprise,
    COUNT(*) AS nb_offres
FROM job_postings jp
JOIN companies_complet cc ON CAST(jp.company_id AS NUMBER) = cc.company_id
JOIN company_size_labels lbl ON cc.company_size = lbl.code
GROUP BY lbl.label
ORDER BY nb_offres DESC;
```

#### d) Répartition par secteur d’activité

```sql
SELECT 
    i.industry_name AS secteur_activite,
    COUNT(*) AS nb_offres
FROM job_postings jp
JOIN job_industries ji ON TRIM(jp.job_id) = TRIM(ji.job_id)
JOIN industries i ON ji.industry_id = i.industry_id
GROUP BY i.industry_name
ORDER BY nb_offres DESC;
```

#### e) Répartition par type d’emploi

```sql
SELECT 
    formatted_work_type AS type_emploi,
    COUNT(*) AS nb_offres
FROM job_postings
WHERE formatted_work_type IS NOT NULL
GROUP BY formatted_work_type
ORDER BY nb_offres DESC;
```

---

## 📊 Visualisations (app.py)

Chaque KPI est accessible via un menu Streamlit :

* Top 10 titres par industrie (barres horizontales)
* Top salaires par industrie (barres horizontales)
* Répartition par taille (camembert)
* Répartition par secteur (barres verticales)
* Répartition par type d’emploi (camembert)

Données extraites avec `snowflake.connector`, visualisées avec `plotly.express`.

---

## ⚠️ Problèmes rencontrés & Solutions

| Problème                               | Solution                                                  |
| -------------------------------------- | --------------------------------------------------------- |
| `post_count` introuvable dans `plotly` | Normalisation des noms de colonnes en `.lower()`          |
| Erreurs de chargement CSV              | Utilisation de `ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE`   |
| `company_id` non compatible            | CAST en `NUMBER` pour la jointure                         |
| Données JSON imbriquées                | Utilisation de `LATERAL FLATTEN`                          |
| Mauvais `industry_id`                  | Recréation de la table `industries` avec des ID cohérents |

---

## 📦 Installation & Lancement

### 1. Installer les dépendances :

```bash
pip install -r requirements.txt
```

### 2. Lancer l’application Streamlit :

```bash
streamlit run app.py
```

---

## 🧠 Répartition du travail

* Sarah : structure SQL, Streamlit, analyse KPI 1 & 2
* Marc : chargement de données, gestion JSON, KPI 3
* Adrien : KPI 4 & 5, doc technique
* Gaetan : tests, nettoyage, cohérence projet

---

## ✅ Résultat attendu

Une interface web simple, interactive et connectée en direct à la base Snowflake, capable d’explorer le marché de l’emploi LinkedIn selon différents axes (poste, salaire, taille entreprise, secteur…).

---

```

Souhaite-tu que je te le mette aussi dans un fichier `README.md` prêt à télécharger ?
```
