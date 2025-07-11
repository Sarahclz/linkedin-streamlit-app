--Création des TABLES

-- Table des offres d’emploi LinkedIn
CREATE OR REPLACE TABLE job_postings (
    job_id STRING,                         -- Identifiant unique de l'offre d'emploi
    company_name STRING,                   -- Nom de l'entreprise associée
    title STRING,                          -- Intitulé du poste
    description STRING,                    -- Description de l'offre
    max_salary FLOAT,                      -- Salaire maximum proposé
    pay_period STRING,                     -- Périodicité de rémunération (Hourly, Monthly, etc.)
    formatted_work_type STRING,            -- Type d’emploi formaté (Temps plein, partiel, etc.)
    location STRING,                       -- Localisation de l’emploi
    applies INT,                           -- Nombre de candidatures reçues
    original_listed_time TIMESTAMP,        -- Date initiale de publication de l’offre
    remote_allowed BOOLEAN,                -- Télétravail autorisé ou non
    views INT,                             -- Nombre de vues de l’offre
    job_posting_url STRING,                -- URL de l’offre d’emploi
    application_url STRING,                -- URL du formulaire de candidature
    application_type STRING,               -- Type de candidature (simple, complexe, offsite)
    expiry TIMESTAMP,                      -- Date d’expiration de l’annonce
    closed_time TIMESTAMP,                 -- Date de clôture de l’offre
    formatted_experience_level STRING,     -- Niveau d’expérience requis
    skills_desc STRING,                    -- Description des compétences recherchées
    listed_time TIMESTAMP,                 -- Date d’affichage sur la plateforme
    posting_domain STRING,                 -- Domaine du site source
    sponsored BOOLEAN,                     -- Indique si le poste est sponsorisé
    work_type STRING,                      -- Type de poste (CDI, freelance, etc.)
    currency STRING,                       -- Devise utilisée pour le salaire
    compensation_type STRING               -- Type de rémunération (salaire, prime, etc.)
);

-- Table des avantages liés aux offres d’emploi
CREATE OR REPLACE TABLE benefits (
    job_id STRING,         -- Identifiant de l’offre
    inferred BOOLEAN,      -- Avantage deviné ou explicite
    type STRING            -- Type d’avantage (Mutuelle, 401K, etc.)
);

-- Table des entreprises
CREATE OR REPLACE TABLE companies (
    company_id STRING,       -- Identifiant unique de l’entreprise
    name STRING,             -- Nom de l’entreprise
    description STRING,      -- Description de l’entreprise
    company_size STRING,     -- Taille de l’entreprise (valeurs de 0 à 7)
    state STRING,            -- État (USA uniquement)
    country STRING,          -- Pays
    city STRING,             -- Ville
    zip_code STRING,         -- Code postal
    address STRING,          -- Adresse complète
    url STRING               -- Lien vers la page LinkedIn de l’entreprise
);

-- Table des effectifs et followers d’une entreprise
CREATE OR REPLACE TABLE employee_counts (
    company_id STRING,         -- Identifiant de l’entreprise
    employee_count INT,        -- Nombre d’employés
    follower_count INT,        -- Nombre de followers LinkedIn
    time_recorded FLOAT        -- Horodatage de l’enregistrement (format Unix)
);

-- Table des compétences liées aux offres
CREATE OR REPLACE TABLE job_skills (
    job_id STRING,            -- Identifiant de l’offre
    skill_abr STRING          -- Nom ou abréviation de la compétence
);

-- Table des secteurs d’activité associés à chaque offre
CREATE OR REPLACE TABLE job_industries (
    job_id STRING,            -- Identifiant de l’offre
    industry_id STRING        -- Identifiant du secteur
);

-- Table des secteurs d’activité associés aux entreprises
CREATE OR REPLACE TABLE company_industries (
    company_id STRING,        -- Identifiant de l’entreprise
    industry STRING           -- Secteur d’activité
);

-- Table des spécialités déclarées par entreprise
CREATE OR REPLACE TABLE company_specialities (
    company_id STRING,        -- Identifiant de l’entreprise
    speciality STRING         -- Spécialité (ex : cybersécurité, marketing digital)
);

-- Table manuelle de correspondance ID secteur -> nom lisible
CREATE OR REPLACE TABLE industries (
    industry_id STRING,       -- ID du secteur d’activité
    industry_name STRING      -- Nom clair et lisible du secteur
);

