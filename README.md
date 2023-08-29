Voce pode preparar um belo readme.md para mim? Em ingles por favor


Movies project
O objetivo do projeto foi testar alguns conhecimentos adquiridos no snowflake, interando-o com o airflow e realizando algumas transformacoes com o dbt.

-Source:
A source escolhida foi sobre foi API, rapidAPI, onde basicamente o conteudo (dados) escolhidos sao filmes/series da netflix e hulu.
Essa API 'e consumida por um pythonoperator no airflow. Para replicar voce deve criar sua conta na rapidAPI e subscrever-se neste link https://rapidapi.com/StreamlineWatch/api/streamlinewatch-streaming-guide.

-Local file storage:
Usado so para escrever (.json) a response da API. Como foi criada um novo folder "outputmovies" para que o airflow tenha acesso 'e necessario incluir uma nova linha na dockerfile.

-Data Lake:
Azure ADLS Gen2 - Escolhido apenas porque eu ja tinha configuracoes feitas entre o snowflake e azure (storage integration). Apos o .json cair no lake ele 'e apagado do storage local.

-Snowflake:
Apos o .json ser posto no ADLS, uma stored procedure 'e executada para copiar esse dados para uma table raw e em caso de error copiar para uma tabela de 'error'. Aqui foi-se criado um role e user para o airflow, todo o processo de caso deixo em snowflake_queries/GRANT.sql e a stored procedure em snowflake_queries/USP.sql

-dbt:
O dbt ir'a olhar para essa tabela raw do snoflake e normaliza-la (raw_stag),  depois remover duplicadas (raw_init), construir dimensoes e fato (silver) e realizar uma agregacao (gold). Processo simples apenas para ilustrar uma trransformacao completa dos dados. Todos os dados foram materializados como tabelas (Transient by default). Ainda falta alguns data quality checks mas isso sera feito em posterior. Data lineage visto nas imagens, cuidado apenas pois por default o dbt usa a porta 8080 (mesma do airflow) para criar os docs (dbt docs generate and then dbt docs serve --port <choice_a_porte>). Para melhor uso do dbt no airflow uso-se a framework cosmos

-Observacoes:
Pode ser que algum objetivo seja preciso criar no snowflake, 'e normal;
As conexoes do airflow sao relativamente tranquilas de serem feitas (encontra-se facil na net);
profiles.yml necessidade de edicao;
O airflow foi deployed localmente com o astro cli (mantive o readme da astronome abaixo)
O objetivo do projeto foi mesmo por em pratica algumas coisas que aprendi nos ultimos dias, entao para uma replicacao 100% o melhor seria contactar-me :).

Referencias:
snowflake doc: https://docs.snowflake.com/
marc lamberti video (muito bom): https://www.youtube.com/watch?v=DzxtCxi4YaA&t=1933s
https://registry.astronomer.io/providers/apache-airflow-providers-microsoft-azure/versions/6.2.2/modules/LocalFilesystemToADLSOperator
https://registry.astronomer.io/providers/apache-airflow-providers-snowflake/versions/4.4.2/modules/SnowflakeOperator

-Proximos passos:
Uma boa opcoes seria criar um sensor customizado para realizar uma ingestao em batch (local - ADLS);
Modificar/incluir astro_sdk em alguns locais do pipeline. 



Overview
========

Welcome to Astronomer! This project was generated after you ran 'astro dev init' using the Astronomer CLI. This readme describes the contents of the project, as well as how to run Apache Airflow on your local machine.

Project Contents
================

Your Astro project contains the following files and folders:

- dags: This folder contains the Python files for your Airflow DAGs. By default, this directory includes two example DAGs:
    - `example_dag_basic`: This DAG shows a simple ETL data pipeline example with three TaskFlow API tasks that run daily.
    - `example_dag_advanced`: This advanced DAG showcases a variety of Airflow features like branching, Jinja templates, task groups and several Airflow operators.
- Dockerfile: This file contains a versioned Astro Runtime Docker image that provides a differentiated Airflow experience. If you want to execute other commands or overrides at runtime, specify them here.
- include: This folder contains any additional files that you want to include as part of your project. It is empty by default.
- packages.txt: Install OS-level packages needed for your project by adding them to this file. It is empty by default.
- requirements.txt: Install Python packages needed for your project by adding them to this file. It is empty by default.
- plugins: Add custom or community plugins for your project to this file. It is empty by default.
- airflow_settings.yaml: Use this local-only file to specify Airflow Connections, Variables, and Pools instead of entering them in the Airflow UI as you develop DAGs in this project.

Deploy Your Project Locally
===========================

1. Start Airflow on your local machine by running 'astro dev start'.

This command will spin up 4 Docker containers on your machine, each for a different Airflow component:

- Postgres: Airflow's Metadata Database
- Webserver: The Airflow component responsible for rendering the Airflow UI
- Scheduler: The Airflow component responsible for monitoring and triggering tasks
- Triggerer: The Airflow component responsible for triggering deferred tasks

2. Verify that all 4 Docker containers were created by running 'docker ps'.

Note: Running 'astro dev start' will start your project with the Airflow Webserver exposed at port 8080 and Postgres exposed at port 5432. If you already have either of those ports allocated, you can either [stop your existing Docker containers or change the port](https://docs.astronomer.io/astro/test-and-troubleshoot-locally#ports-are-not-available).

3. Access the Airflow UI for your local Airflow project. To do so, go to http://localhost:8080/ and log in with 'admin' for both your Username and Password.

You should also be able to access your Postgres Database at 'localhost:5432/postgres'.

Deploy Your Project to Astronomer
=================================

If you have an Astronomer account, pushing code to a Deployment on Astronomer is simple. For deploying instructions, refer to Astronomer documentation: https://docs.astronomer.io/cloud/deploy-code/

Contact
=======

The Astronomer CLI is maintained with love by the Astronomer team. To report a bug or suggest a change, reach out to our support.
