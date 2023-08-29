Movies Project Readme
The purpose of this project was to apply various concepts and technologies, including Snowflake, Airflow, and dbt, to perform data transformations.

Source
The chosen data source for this project is the RapidAPI service. Specifically, the data comes from the StreamlineWatch Streaming Guide API, which provides information about movies and TV series on platforms like Netflix and Hulu. The API is consumed using a PythonOperator in Airflow. To replicate this, you need to create an account on RapidAPI and subscribe to the API here.

Local File Storage
Local file storage is utilized temporarily to write the API response in JSON format. A new folder named "outputmovies" was created for this purpose. To enable Airflow's access to this folder, a new line needs to be added to the Dockerfile.

Data Lake
Azure ADLS Gen2 was chosen as the data lake for this project. This choice was based on existing configurations between Snowflake and Azure (storage integration). Once the JSON data is written to the lake, it is deleted from the local storage.

Snowflake
After the JSON data is stored in ADLS, a stored procedure is executed in Snowflake. This procedure copies the data to a raw table. In case of an error, the data is copied to an "error" table. A dedicated role and user were created in Snowflake for Airflow. The SQL commands for these processes are stored in snowflake_queries/GRANT.sql, and the stored procedure is defined in snowflake_queries/USP.sql.

dbt
dbt (data build tool) is used to perform transformations on the raw Snowflake data. The process involves normalizing the data (raw_stag), removing duplicates (raw_init), building dimensions and facts (silver), and performing aggregation (gold). The transformed data is materialized into tables (transient by default). Some data quality checks are pending and will be implemented later. Data lineage can be observed in the provided images. Note that dbt uses port 8080 by default, which conflicts with Airflow's port. To overcome this, use the command dbt docs generate followed by dbt docs serve --port <your_chosen_port>. For seamless integration of dbt with Airflow, the Cosmos framework is used.

Notes
It might be necessary to create certain objects in Snowflake to replicate the project.
Establishing Airflow connections should be straightforward (resources are available online).
profiles.yml needs to be edited according to your environment.
The local deployment of Airflow was achieved using the Astro CLI. Refer to the provided Astronomer readme for details.
References
Snowflake Documentation: https://docs.snowflake.com/
Marc Lamberti's YouTube Video: https://www.youtube.com/watch?v=DzxtCxi4YaA&t=1933s
Airflow Azure Provider LocalFilesystemToADLSOperator: Link
Airflow Snowflake Provider SnowflakeOperator: Link
Next Steps
Consider creating a custom sensor for batch ingestion from local storage to ADLS.
Explore the inclusion of astro_sdk in various parts of the pipeline for enhanced functionality.

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
