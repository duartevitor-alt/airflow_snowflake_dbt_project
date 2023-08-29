# Movies Project Readme

The aim of this project was to put into practice various skills by integrating Snowflake with Airflow and performing data transformations using dbt.

![image](https://github.com/duartevitor-alt/airflow_snowflake_dbt_project/assets/82652783/a032eec1-62f1-4f3d-aa33-e25c21b08062)


## Source

The selected data source for this project is the RapidAPI service. Specifically, data is obtained from the StreamlineWatch Streaming Guide API, which offers information about movies and TV series available on platforms like Netflix and Hulu. The API is accessed through a PythonOperator in Airflow. To replicate this process, you need to create a RapidAPI account and subscribe to the API [here](https://rapidapi.com/StreamlineWatch/api/streamlinewatch-streaming-guide).

## Local File Storage

Local file storage is briefly used to save the API response in JSON format. A new folder named "outputmovies" is created for this purpose. To allow Airflow access to this folder, an additional line should be added to the Dockerfile.

## Data Lake

Azure ADLS Gen2 is utilized as the data lake for this project. This choice is based on existing configurations between Snowflake and Azure (storage integration). Once the JSON data is stored in the data lake, it is deleted from local storage.

## Snowflake

Upon storing the JSON data in ADLS, a stored procedure is executed in Snowflake. This procedure copies the data into a raw table. If any errors occur, the data is redirected to an "error" table. A dedicated role and user were established in Snowflake for Airflow. The SQL commands for these processes are available in `snowflake_queries/GRANT.sql`, and the stored procedure is defined in `snowflake_queries/USP.sql`.

## dbt

dbt (data build tool) is employed to transform the raw Snowflake data. The process involves normalizing the data (raw_stag), eliminating duplicates (raw_init), building dimensions and facts (silver), and performing aggregation (gold). The transformed data is materialized into tables (transient by default). Some data quality checks remain outstanding and will be implemented in the future. Data lineage is visible in the provided images. Note that dbt defaults to port 8080, which conflicts with Airflow's port. To resolve this, utilize the command `dbt docs generate` followed by `dbt docs serve --port <your_chosen_port>`. For seamless dbt-Airflow integration, the Cosmos framework is recommended.

![image](https://github.com/duartevitor-alt/airflow_snowflake_dbt_project/assets/82652783/e8f465ca-ccfa-4444-96c9-0dfc655a2708)


## Notes

- Certain Snowflake objects might need to be created for full replication.
- Establishing Airflow connections is typically straightforward (resources are available online).
- Edit `profiles.yml` as per your environment requirements.
- Local Airflow deployment was achieved using the Astro CLI. Refer to the included Astronomer readme for detailed instructions.

## References

- [Snowflake Documentation](https://docs.snowflake.com/)
- [Marc Lamberti's YouTube Video](https://www.youtube.com/watch?v=DzxtCxi4YaA&t=1933s)
- [Airflow Azure Provider LocalFilesystemToADLSOperator](https://registry.astronomer.io/providers/apache-airflow-providers-microsoft-azure/versions/6.2.2/modules/LocalFilesystemToADLSOperator)
- [Airflow Snowflake Provider SnowflakeOperator](https://registry.astronomer.io/providers/apache-airflow-providers-snowflake/versions/4.4.2/modules/SnowflakeOperator)

## Next Steps

- Consider developing a custom sensor for batch ingestion from local storage to ADLS.
- Explore incorporating `astro_sdk` at various pipeline stages for enhanced functionality.


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
