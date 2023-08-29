FROM quay.io/astronomer/astro-runtime:8.2.0

USER astro

RUN chmod 777 /usr/local/airflow/outputmovies
