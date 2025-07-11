# app.py

import streamlit as st
import snowflake.connector
import pandas as pd
import plotly.express as px

# -----------------------------
# Connexion à Snowflake (local)
# -----------------------------
def connect_snowflake():
    conn = snowflake.connector.connect(
        user="SARAH",
        password="Sarahsnowflake25!",
        account="dtc90237.us-east-1",
        warehouse="COMPUTE_WH",
        database="LINKEDIN",
        schema="PROJET_LINKEDIN"
    )
    return conn

def run_query(query):
    conn = connect_snowflake()
    cur = conn.cursor()
    cur.execute(query)
    df = cur.fetch_pandas_all()
    df.columns = df.columns.str.lower()  # normalise les colonnes
    cur.close()
    return df

# -----------------------------
# Interface Streamlit
# -----------------------------
st.set_page_config(page_title="Analyse LinkedIn", layout="wide")
st.title("📊 Analyse des Offres d’Emploi LinkedIn")

menu = st.sidebar.radio("Sélectionner un KPI :", [
    "🏠 Accueil",
    "📌 Top 10 Titres par Industrie",
    "💰 Salaires par Industrie",
    "🏢 Répartition par Taille",
    "🌐 Répartition par Secteur",
    "🕒 Répartition par Type d’Emploi"
])

# -----------------------------
# Accueil
# -----------------------------
if menu == "🏠 Accueil":
    st.subheader("Bienvenue !")
    st.markdown("Explorez les données LinkedIn avec 5 indicateurs clés du marché de l’emploi.")

# -----------------------------
# KPI 1 : Titres par Industrie
# -----------------------------
elif menu == "📌 Top 10 Titres par Industrie":
    industries = run_query("SELECT DISTINCT industry_name FROM industries WHERE industry_name IS NOT NULL ORDER BY industry_name")
    selected = st.selectbox("Sélectionnez une industrie :", industries["industry_name"])
    query = f"""
        SELECT INITCAP(LOWER(TRIM(jp.title))) AS job_title, COUNT(*) AS post_count
        FROM job_postings jp
        JOIN job_industries ji ON TRIM(jp.job_id) = TRIM(ji.job_id)
        JOIN industries i ON ji.industry_id = i.industry_id
        WHERE i.industry_name = '{selected}' AND jp.title IS NOT NULL
        GROUP BY job_title
        ORDER BY post_count DESC
        LIMIT 10;
    """
    df = run_query(query)
    st.dataframe(df)
    if not df.empty:
        fig = px.bar(df, x="post_count", y="job_title", orientation="h", title=f"Top 10 titres - {selected}")
        st.plotly_chart(fig)

# -----------------------------
# KPI 2 : Salaires par Industrie
# -----------------------------
elif menu == "💰 Salaires par Industrie":
    industries = run_query("SELECT DISTINCT industry_name FROM industries WHERE industry_name IS NOT NULL ORDER BY industry_name")
    selected = st.selectbox("Sélectionnez une industrie :", industries["industry_name"], key="salaires")
    query = f"""
        SELECT INITCAP(jp.title) AS job_title, jp.med_salary
        FROM job_postings jp
        JOIN job_industries ji ON TRIM(jp.job_id) = TRIM(ji.job_id)
        JOIN industries i ON ji.industry_id = i.industry_id
        WHERE i.industry_name = '{selected}' AND jp.med_salary IS NOT NULL
        ORDER BY jp.med_salary DESC
        LIMIT 10;
    """
    df = run_query(query)
    st.dataframe(df)
    if not df.empty:
        fig = px.bar(df.sort_values("med_salary"), x="med_salary", y="job_title", orientation="h", title=f"Salaire médian - {selected}")
        st.plotly_chart(fig)

# -----------------------------
# KPI 3 : Répartition par taille
# -----------------------------
elif menu == "🏢 Répartition par Taille":
    query = """
        SELECT CASE cc.company_size
            WHEN '0' THEN 'Self-employed'
            WHEN '1' THEN '1-10'
            WHEN '2' THEN '11-50'
            WHEN '3' THEN '51-200'
            WHEN '4' THEN '201-500'
            WHEN '5' THEN '501-1000'
            WHEN '6' THEN '1001-5000'
            WHEN '7' THEN '5000+'
            ELSE 'Inconnu' END AS size_label,
            COUNT(*) AS nb_offres
        FROM job_postings jp
        JOIN companies_complet cc ON TRY_CAST(jp.company_id AS NUMBER) = cc.company_id
        GROUP BY size_label
        ORDER BY nb_offres DESC;
    """
    df = run_query(query)
    st.dataframe(df)
    if not df.empty:
        fig = px.pie(df, names="size_label", values="nb_offres", title="Répartition des offres par taille")
        st.plotly_chart(fig)

# -----------------------------
# KPI 4 : Répartition par Secteur
# -----------------------------
elif menu == "🌐 Répartition par Secteur":
    query = """
        SELECT i.industry_name AS secteur, COUNT(*) AS nb_offres
        FROM job_postings jp
        JOIN job_industries ji ON TRIM(jp.job_id) = TRIM(ji.job_id)
        JOIN industries i ON ji.industry_id = i.industry_id
        GROUP BY i.industry_name
        ORDER BY nb_offres DESC
        LIMIT 10;
    """
    df = run_query(query)
    st.dataframe(df)
    if not df.empty:
        fig = px.bar(df, x="secteur", y="nb_offres", title="Top 10 secteurs les plus représentés")
        st.plotly_chart(fig)

# -----------------------------
# KPI 5 : Répartition par Type d’Emploi
# -----------------------------
elif menu == "🕒 Répartition par Type d’Emploi":
    query = """
        SELECT formatted_work_type AS type_emploi, COUNT(*) AS nb_offres
        FROM job_postings
        WHERE formatted_work_type IS NOT NULL
        GROUP BY formatted_work_type
        ORDER BY nb_offres DESC;
    """
    df = run_query(query)
    st.dataframe(df)
    if not df.empty:
        fig = px.pie(df, names="type_emploi", values="nb_offres", title="Répartition par type d’emploi")
        st.plotly_chart(fig)
