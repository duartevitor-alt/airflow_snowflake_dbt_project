-- using a powerful role

CREATE TABLE IF NOT EXISTS MANAGED_DB.MOVIES.RAW_MOVIES_CONTENT (
        RAW_CONTENT VARIANT 
    ,   FILE_NAME   VARCHAR(300)
    );

    CREATE TABLE IF NOT EXISTS MANAGED_DB.MOVIES.REJECTED_COPY_MOVIES(
         ID NUMBER    AUTOINCREMENT START 1 INCREMENT 1
    ,    ERROR        VARCHAR(300)
    ,    "FILE"       VARCHAR(100)
    ,    STATUS       VARCHAR(100)
    ,    "ROW_NUMBER" VARCHAR(10)
    ,    ERROR_TIME   DATETIME
    );

CREATE OR REPLACE ROLE AIRFLOW_EXECUTOR;
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE AIRFLOW_EXECUTOR;
GRANT USAGE ON DATABASE  MANAGED_DB TO ROLE AIRFLOW_EXECUTOR;
GRANT USAGE ON ALL SCHEMAS IN DATABASE MANAGED_DB TO ROLE AIRFLOW_EXECUTOR;

--TABLES       
GRANT INSERT, SELECT ON TABLE MANAGED_DB.MOVIES.RAW_MOVIES_CONTENT         TO ROLE AIRFLOW_EXECUTOR;
GRANT INSERT, SELECT ON TABLE MANAGED_DB.MOVIES.REJECTED_COPY_MOVIES       TO ROLE AIRFLOW_EXECUTOR;
GRANT CREATE TABLE   ON SCHEMA MANAGED_DB.MOVIES                           TO ROLE AIRFLOW_EXECUTOR;
GRANT USAGE          ON PROCEDURE MANAGED_DB.MOVIES.USP_LOAD_MOVIES_DATA() TO ROLE AIRFLOW_EXECUTOR;


USE SCHEMA USE MANAGED_DB;
CREATE OR REPLACE FILE FORMAT FILE_FORMATS.JSON_FILE_FORMAT
    TYPE = JSON ;
    
--FILE FORMAT AND STAGES
GRANT USAGE ON FILE FORMAT FILE_FORMATS.JSON_FILE_FORMAT TO ROLE AIRFLOW_EXECUTOR;

CREATE STORAGE INTEGRATION azure_int
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER = 'AZURE'
ENABLED = TRUE
AZURE_TENANT_ID = '<TENANT_ID>'
STORAGE_ALLOWED_LOCATIONS = ('azure://PATH_TO_YOUR_CONTAINER');

-- CREATING STAGE
CREATE OR REPLACE STAGE ADLS_VITU144_STAGE_BRONZE
    STORAGE_INTEGRATION = azure_int
    FILE_FORMAT = MANAGED_DB.FILE_FORMATS.JSON_FILE_FORMAT
    URL = 'azure://PATH_TO_YOUR_CONTAINER'
    COPY_OPTIONS = (ON_ERROR = CONTINUE);

GRANT USAGE ON STAGE ADLS_VITU144_STAGE_BRONZE TO ROLE AIRFLOW_EXECUTOR;

CREATE OR REPLACE USER AIRFLOW 
    PASSWORD='airflow' 
    LOGIN_NAME='airflow' 
    MUST_CHANGE_PASSWORD=FALSE
    DEFAULT_ROLE = AIRFLOW_EXECUTOR;