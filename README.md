# Where's Carmen

## Project Overview
This project involves creating a data mart from a given dataset of Carmen Sandiego sightings, transforming the data through various stages, and finalizing it into a normalized schema suitable for analytics. The process includes setting up a Snowflake environment, utilizing dbt for transformations, and ensuring data integrity through proper encoding and normalization.

## Steps and Procedures
### 1. Create Snowflake Account
Sign Up for a Trial Account: Created a trial Snowflake account by accessing the Snowflake Trial Signup Page.
Access Snowflake: Logged into Snowflake using the provided URL, username, and password.

### 2. Set Up Database and Schemas in Snowflake
Create Database and Schemas:
sql
Copy code
CREATE DATABASE CARMEN;
CREATE SCHEMA CARMEN.SOURCE;
CREATE SCHEMA CARMEN.STAGING;
CREATE SCHEMA CARMEN.MART;
Create Role and Grant Permissions:
sql
Copy code
CREATE ROLE ANALYTICS;
GRANT ALL PRIVILEGES ON DATABASE CARMEN TO ROLE ANALYTICS;
GRANT ALL PRIVILEGES ON SCHEMA CARMEN.SOURCE TO ROLE ANALYTICS;
GRANT ALL PRIVILEGES ON SCHEMA CARMEN.STAGING TO ROLE ANALYTICS;
GRANT ALL PRIVILEGES ON SCHEMA CARMEN.MART TO ROLE ANALYTICS;
GRANT ROLE ANALYTICS TO USER TRADEME;

### 3. Set Up dbt for Local Development
Install dbt-Snowflake:
bash
Copy code
python3 -m venv dbt-env
source dbt-env/bin/activate
pip install dbt-core dbt-snowflake
Initialize a New dbt Project:
bash
Copy code
dbt init carmen

### 4. Download and Prepare Source Data
Download Excel File: Downloaded the source data Excel file from GitHub.
Create Python Script to Convert Excel to CSV:
Converted the Excel file to individual CSV files for each tab.
Fixed encoding errors found in the ASIA and EUROPE tabs.
Saved the CSV files under the seeds folder in the dbt project.

### 5. Configure dbt Project for Seeds
Update dbt_project.yml:
yaml
Copy code
seeds:
  carmen:
    +schema: RAW_DATA
Run dbt Seed Command:
bash
Copy code
dbt seed

### 6. Create Staging Models
Staging Models:
Created views to rename and cast columns to follow the standard defined.
Example for AFRICA:
sql
Copy code
{{
  config(
    materialized = "view",
    schema="staging"
  )
}}

with africa as (
    select
        cast(report_date as date) as date_witness,
        cast(citizen as string) as witness,
        cast(officer as string) as agent,
        cast(report_date as date) as date_agent,
        cast(city as string) as city_agent,
        cast(nation as string) as country,
        cast(city as string) as city,
        cast(latitude as float) as latitude,
        cast(longitude as float) as longitude,
        cast(has_weapon as boolean) as has_weapon,
        cast(has_hat as boolean) as has_hat,
        cast(has_jacket as boolean) as has_jacket,
        cast(behavior as string) as behavior
    from {{ source('carmen_sightings', 'africa') }}
)

select * from africa;

### 7. Create Global Staging Model
Global Staging Model:
Created a union of all different regions into a single global view.
Example:
sql
Copy code
create or replace view carmen.staging.stg_global as
select
    s.date_witness,
    s.witness,
    s.agent,
    s.date_agent,
    s.city_agent,
    s.country,
    s.city,
    s.latitude,
    s.longitude,
    s.has_weapon,
    s.has_hat,
    s.has_jacket,
    s.behavior
from 
    carmen.staging.stg_africa s
union all
select
    ...

### 8. Create Mart Models
Dimension and Fact Tables:
Followed 3NF to create dimension tables and a fact table.
Example for DIM_AGENT:
sql
Copy code
create or replace table mart.dim_agent as
select distinct 
    agent,
    city_agent
from 
    carmen.staging.stg_africa
order by 
    agent;
Example for FACT_SIGHTINGS:
sql
Copy code
create or replace table mart.fact_sightings as
select
    w.witness as dim_witness_key,
    d.date_witness as dim_witness_date_key,
    a.agent as dim_agent_key,
    d.date_agent as dim_agent_date_key,
    ca.city_agent as dim_agent_city_key,
    c.city as dim_city_key,
    s.has_weapon,
    s.has_hat,
    s.has_jacket,
    s.behavior
from 
    carmen.staging.stg_africa s
left join 
    mart.dim_witness w on s.witness = w.witness
left join 
    mart.dim_agent a on s.agent = a.agent
left join 
    mart.dim_city_agent ca on s.city_agent = ca.city_agent
left join 
    mart.dim_city c on s.city = c.city
left join 
    mart.dim_date d on s.date_witness = d.date_witness and s.date_agent = d.date_agent;

### 9. Create Analytics Models
Analytics Models:
Created models to answer specific analytical questions based on the dimensions and fact tables.

## Conclusion
This project demonstrates the process of transforming raw data into a structured data mart using Snowflake and dbt. The final schema follows the 3NF design principles, ensuring data integrity and efficiency for analytical queries.