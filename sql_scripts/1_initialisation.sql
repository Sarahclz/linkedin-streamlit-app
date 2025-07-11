-- Activation de l'entrepôt
USE WAREHOUSE COMPUTE_WH;

-- Création de la base de données et du schéma
CREATE OR REPLACE DATABASE linkedin;
USE DATABASE linkedin;

CREATE OR REPLACE SCHEMA projet_linkedin;
USE SCHEMA projet_linkedin;

-- Création du stage externe pointant vers S3
CREATE OR REPLACE STAGE linkedin_stage
URL = 's3://snowflake-lab-bucket/';

-- Définition des formats de fichiers
CREATE OR REPLACE FILE FORMAT csv_format
TYPE = 'CSV'
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"';

CREATE OR REPLACE FILE FORMAT json_format
TYPE = 'JSON';