--Chargement des données 

-- Chargement des données dans la table des offres d’emploi
COPY INTO job_postings
FROM @linkedin_stage/job_postings.csv
FILE_FORMAT = (FORMAT_NAME = csv_format, ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE)
ON_ERROR = 'CONTINUE'
FORCE = TRUE;

-- Chargement des données dans la table des avantages
COPY INTO benefits
FROM @linkedin_stage/benefits.csv
FILE_FORMAT = (FORMAT_NAME = csv_format, ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE)
ON_ERROR = 'CONTINUE'
FORCE = TRUE;

-- Chargement des données dans la table des entreprises (JSON)
COPY INTO companies
FROM @linkedin_stage/companies.json
FILE_FORMAT = (FORMAT_NAME = json_format)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
FORCE = TRUE;

-- Chargement des données dans la table des effectifs
COPY INTO employee_counts
FROM @linkedin_stage/employee_counts.csv
FILE_FORMAT = (FORMAT_NAME = csv_format, ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE)
ON_ERROR = 'CONTINUE'
FORCE = TRUE;

-- Chargement des compétences liées aux offres
COPY INTO job_skills
FROM @linkedin_stage/job_skills.csv
FILE_FORMAT = (FORMAT_NAME = csv_format, ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE)
ON_ERROR = 'CONTINUE'
FORCE = TRUE;

-- Chargement des secteurs d'activité des offres (JSON)
COPY INTO job_industries
FROM @linkedin_stage/job_industries.json
FILE_FORMAT = (FORMAT_NAME = json_format)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
FORCE = TRUE;

-- Chargement des secteurs d’activité des entreprises (JSON)
COPY INTO company_industries
FROM @linkedin_stage/company_industries.json
FILE_FORMAT = (FORMAT_NAME = json_format)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
FORCE = TRUE;

-- Chargement des spécialités des entreprises (JSON)
COPY INTO company_specialities
FROM @linkedin_stage/company_specialities.json
FILE_FORMAT = (FORMAT_NAME = json_format)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
FORCE = TRUE;

--Erreur de chargement job_postings correction 

-- Vérification du contenu du fichier
SELECT 
    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
    $11, $12, $13, $14, $15, $16, $17, $18, $19, $20,
    $21, $22, $23, $24, $25, $26, $27
FROM @linkedin_stage/job_postings.csv
(FILE_FORMAT => csv_format)
LIMIT 5;

-- Création de la table job_postings avec les 27 colonnes alignées avec le fichier CSV
CREATE OR REPLACE TABLE job_postings (
    job_id STRING,
    company_id STRING,
    title STRING,
    description STRING,
    max_salary FLOAT,
    med_salary FLOAT,
    min_salary FLOAT,
    pay_period STRING,
    formatted_work_type STRING,
    location STRING,
    applies FLOAT,
    original_listed_time FLOAT,
    remote_allowed STRING,
    views FLOAT,
    job_posting_url STRING,
    application_url STRING,
    application_type STRING,
    expiry FLOAT,
    closed_time FLOAT,
    formatted_experience_level STRING,
    skills_desc STRING,
    listed_time FLOAT,
    posting_domain STRING,
    sponsored BOOLEAN,
    work_type STRING,
    currency STRING,
    compensation_type STRING
);

-- Chargement des données avec gestion des erreurs et tolérance sur les types
COPY INTO job_postings
FROM @linkedin_stage/job_postings.csv
FILE_FORMAT = (
  FORMAT_NAME = csv_format,
  ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE
)
ON_ERROR = 'CONTINUE'
FORCE = TRUE;

-- Vérifie le nombre de lignes importées
SELECT COUNT(*) AS nb_lignes_job_postings FROM job_postings;


--Vérification du contenu des tables 

-- Aperçu de la table job_postings
SELECT * FROM job_postings LIMIT 10;

-- Aperçu de la table benefits
SELECT * FROM benefits LIMIT 10;

-- Aperçu de la table companies_complet (ou companies si tu l’as utilisée)
SELECT * FROM companies_complet LIMIT 10;

-- Aperçu de la table employee_counts
SELECT * FROM employee_counts LIMIT 10;

-- Aperçu de la table job_skills
SELECT * FROM job_skills LIMIT 10;

-- Aperçu de la table job_industries
SELECT * FROM job_industries LIMIT 10;

-- Aperçu de la table company_specialities
SELECT * FROM company_specialities LIMIT 10;

-- Aperçu de la table company_industries
SELECT * FROM company_industries LIMIT 10;

-- Aperçu de la table industries
SELECT * FROM industries LIMIT 10;

-- Aperçu de la table temporaire des tailles d’entreprises (si créée)
SELECT * FROM company_size_labels LIMIT 10;


--Correction erreur affichage des données 

-- Crée une table contenant uniquement les colonnes utiles de companies.json
CREATE OR REPLACE TABLE companies_complet AS
SELECT
  value:company_id::NUMBER AS company_id,
  value:name::STRING AS company_name,
  value:company_size::STRING AS company_size
FROM @linkedin_stage/companies.json
  (FILE_FORMAT => json_format),
  LATERAL FLATTEN(input => parse_json($1));

  -- Recharge les secteurs d’activité liés aux offres d’emploi
COPY INTO job_industries
FROM @linkedin_stage/job_industries.json
FILE_FORMAT = (FORMAT_NAME = json_format)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
FORCE = TRUE;

-- Recharge les spécialités des entreprises
COPY INTO company_specialities
FROM @linkedin_stage/company_specialities.json
FILE_FORMAT = (FORMAT_NAME = json_format)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
FORCE = TRUE;

-- Recharge les secteurs d’activité liés aux entreprises (via FLATTEN)
INSERT INTO company_industries (company_id, industry)
SELECT 
  value:company_id::STRING,
  value:industry::STRING
FROM @linkedin_stage/company_industries.json
  (FILE_FORMAT => json_format),
  LATERAL FLATTEN(input => parse_json($1));

  -- Crée la table industries (si absente)
CREATE OR REPLACE TABLE industries (
    industry_id STRING,
    industry_name STRING
);

-- Ajoute les correspondances ID → nom
INSERT INTO industries (industry_id, industry_name) VALUES
('81149246', 'Higher Education'),
('10033339', 'Information Technology & Services'),
('6049228', 'Accounting'),
('2641066', 'Electrical & Electronic Manufacturing'),
('96649998', 'Marketing & Advertising'),
('82684341', 'Hospital & Health Care'),
('82296828', 'Information Technology & Services'),
('86746333', 'Logistics & Supply Chain'),
('718651', 'Medical Practice'),
('4781041', 'Mental Health Care');


-- Crée une table temporaire de correspondance code → libellé
CREATE OR REPLACE TEMP TABLE company_size_labels (
  code STRING,
  label STRING
);

-- Ajoute les libellés pour chaque code de taille
INSERT INTO company_size_labels VALUES
('0', 'Self-employed'),
('1', '1-10 employees'),
('2', '11-50 employees'),
('3', '51-200 employees'),
('4', '201-500 employees'),
('5', '501-1000 employees'),
('6', '1001-5000 employees'),
('7', '5000+ employees');

--Nouvelles vérifications 

-- Vérifie les 10 premières lignes de la table job_postings
SELECT * FROM job_postings LIMIT 10;

-- Vérifie les 10 premières lignes de la table benefits
SELECT * FROM benefits LIMIT 10;

-- Vérifie les 10 premières lignes de la table employee_counts
SELECT * FROM employee_counts LIMIT 10;

-- Vérifie les 10 premières lignes de la table job_skills
SELECT * FROM job_skills LIMIT 10;

-- Vérifie la table companies_complet
SELECT * FROM companies_complet LIMIT 10;

-- Vérifie la table job_industries
SELECT * FROM job_industries LIMIT 10;

-- Vérifie la table company_specialities
SELECT * FROM company_specialities LIMIT 10;

-- Vérifie la table company_industries
SELECT * FROM company_industries LIMIT 10;

-- Vérifie la table industries
SELECT * FROM industries LIMIT 10;

-- Vérifie la table temporaire des libellés de taille d’entreprise
SELECT * FROM company_size_labels LIMIT 10;


--Correction chargements

-- Vider la table job_industries
TRUNCATE TABLE job_industries;

-- Vider la table company_specialities
TRUNCATE TABLE company_specialities;

-- Chargement manuel des données dans job_industries
INSERT INTO job_industries (job_id, industry_id)
SELECT 
  value:job_id::STRING,
  value:industry_id::STRING
FROM @linkedin_stage/job_industries.json (FILE_FORMAT => json_format),
     LATERAL FLATTEN(input => PARSE_JSON($1));

-- Chargement manuel des données dans company_specialities
INSERT INTO company_specialities (company_id, speciality)
SELECT 
  value:company_id::STRING,
  value:speciality::STRING
FROM @linkedin_stage/company_specialities.json (FILE_FORMAT => json_format),
     LATERAL FLATTEN(input => PARSE_JSON($1));

-- Vérifie les 10 premières lignes de chaque table
SELECT * FROM job_industries LIMIT 10;
SELECT * FROM company_specialities LIMIT 10;


-- Vérification des données rechargées
SELECT * FROM job_industries LIMIT 10;
SELECT * FROM company_specialities LIMIT 10;


--Check final des tables 

-- 1. Offres d’emploi
SELECT * FROM job_postings LIMIT 10;

-- 2. Avantages associés aux offres
SELECT * FROM benefits LIMIT 10;

-- 3. Entreprises (version simplifiée depuis JSON)
SELECT * FROM companies_complet LIMIT 10;

-- 4. Compétences liées aux offres
SELECT * FROM job_skills LIMIT 10;

-- 5. Données sur les effectifs et followers des entreprises
SELECT * FROM employee_counts LIMIT 10;

-- 6. Secteurs d’activité associés aux offres
SELECT * FROM job_industries LIMIT 10;

-- 7. Secteurs d’activité associés aux entreprises
SELECT * FROM company_industries LIMIT 10;

-- 8. Spécialités des entreprises
SELECT * FROM company_specialities LIMIT 10;

-- 9. Dictionnaire des noms d’industries
SELECT * FROM industries LIMIT 10;

-- 10. Table temporaire pour décoder les tailles d’entreprises
SELECT * FROM company_size_labels LIMIT 10;


-- Dernier check avant analyses 

-- job_postings ↔ job_industries
SELECT COUNT(*) AS matches_jobs_industries
FROM job_postings jp
JOIN job_industries ji ON TRIM(jp.job_id) = TRIM(ji.job_id);

-- job_industries ↔ industries
SELECT COUNT(*) AS matches_industries
FROM job_industries ji
JOIN industries i ON ji.industry_id = i.industry_id;

-- job_postings ↔ companies_complet
SELECT COUNT(*) AS matches_companies
FROM job_postings jp
JOIN companies_complet cc
  ON CAST(jp.company_id AS NUMBER) = cc.company_id;

-- companies_complet ↔ company_size_labels (si utilisée)
SELECT COUNT(*) AS matches_company_sizes
FROM companies_complet cc
JOIN company_size_labels lbl ON cc.company_size = lbl.code;


--Correction erreur correspondances 


-- Voir les industry_id présents dans job_industries
SELECT DISTINCT industry_id
FROM job_industries
LIMIT 10;

-- Voir les industry_id présents dans industries
SELECT DISTINCT industry_id
FROM industries
LIMIT 10;

-- 🔁 Recréation de la table industries avec des IDs cohérents
CREATE OR REPLACE TABLE industries (
  industry_id STRING,
  industry_name STRING
);

-- ✅ Insertion des bons couples (tu peux enrichir la liste après test)
INSERT INTO industries (industry_id, industry_name) VALUES
('68', 'Higher Education'),
('96', 'Information Technology & Services'),
('47', 'Accounting'),
('112', 'Electrical & Electronic Manufacturing'),
('80', 'Marketing & Advertising'),
('14', 'Hospital & Health Care'),
('116', 'Logistics & Supply Chain'),
('13', 'Medical Practice'),
('87', 'Mental Health Care'),
('139', 'Human Resources');


--Test jointures industries 
SELECT COUNT(*) AS matches_industries
FROM job_industries ji
JOIN industries i ON ji.industry_id = i.industry_id;