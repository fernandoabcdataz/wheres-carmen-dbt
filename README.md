# Where's Carmen

## Project Overview
This project focuses on analyzing Carmen Sandiego sightings using a Snowflake environment and dbt for data transformations. Our goal is to create analytical views that provide clear insights into Carmen Sandiego's activities, helping us answer specific questions about her behaviors and whereabouts.

## Steps and Procedures

### 1. Create Snowflake Account
**Sign Up for a Trial Account**: Created a trial Snowflake account by accessing the [Snowflake Trial Signup Page](https://signup.snowflake.com/).  
**Access Snowflake**
**URL:** https://oqb18093.us-east-1.snowflakecomputing.com
**USER:** TRADEME
**PASS:** TradeMe123


### 2. Set Up Database and Schemas in Snowflake
**Create Database and Schemas**:
```sql
USE ROLE ACCOUNTADMIN;

-- NEW DB
CREATE DATABASE CARMEN;

-- NEW SCHEMAS
CREATE SCHEMA CARMEN.RAW_DATA;
CREATE SCHEMA CARMEN.STAGING;
CREATE SCHEMA CARMEN.MART;
CREATE SCHEMA CARMEN.ANALYTICS;
```

**Create Role and Grant Permissions**:
```sql
-- NEW ROLE
CREATE ROLE ENGINEER;

-- GRANT WAREHOUSE TO ROLE ENGINEER
GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE ENGINEER;
GRANT OPERATE ON WAREHOUSE COMPUTE_WH TO ROLE ENGINEER;

-- GRANT ALL PRIVILEGES ON DB TO ROLE ENGINEER
GRANT ALL PRIVILEGES ON DATABASE CARMEN TO ROLE ENGINEER;

-- GRANT ALL PRIVILEGES ON SCHEMAS TO ROLE ENGINEER
GRANT ALL PRIVILEGES ON SCHEMA CARMEN.RAW_DATA TO ROLE ENGINEER;
GRANT ALL PRIVILEGES ON SCHEMA CARMEN.STAGING TO ROLE ENGINEER;
GRANT ALL PRIVILEGES ON SCHEMA CARMEN.MART TO ROLE ENGINEER;
GRANT ALL PRIVILEGES ON SCHEMA CARMEN.ANALYTICS TO ROLE ENGINEER;

-- GRANT ENGINEER ROLE TO USER TRADEME
GRANT ROLE ENGINEER TO USER TRADEME;
```

### 3. Set Up dbt for Local Development
**Install dbt-Snowflake**:
```bash
python3 -m venv dbt-env
source dbt-env/bin/activate
pip install dbt-core dbt-snowflake
```

**Initialize a New dbt Project**:
```bash
dbt init carmen
```

### 4. Download and Prepare Source Data
**Download Excel File**: Downloaded the source data Excel file from GitHub.

**Create Python Script to Convert Excel to CSV**:
- Converted the Excel file to individual CSV files for each tab.
- Fixed encoding errors found in the ASIA and EUROPE tabs.
- Saved the CSV files under the seeds folder in the dbt project.

Script:
```python
import pandas as pd
import os

def process_and_export_excel(file_path, output_dir):
    # LOAD THE EXCEL FILE
    excel_file = pd.ExcelFile(file_path)
    
    # ITERATE THROUGH EACH SHEET AND SAVE AS CSV
    for sheet_name in excel_file.sheet_names:
        df = pd.read_excel(file_path, sheet_name=sheet_name)
        
        # RENAME COLUMNS FOR SPECIFIC SHEETS IF NECESSARY
        if sheet_name == 'ASIA':
            df.columns = ['sighting', 'report_date', 'citizen', 'officer', 'latitude', 'longitude', 'city', 'nation', 'city_interpol', 'has_weapon', 'has_hat', 'has_jacket', 'behavior']
        elif sheet_name == 'EUROPE':
            df.columns = ['date_witness', 'date_filed', 'witness', 'agent', 'lat_', 'long_', 'city', 'country', 'region_hq', 'armed', 'chapeau', 'coat', 'observed_action']
        
        # ENSURE THE DATA IS PROPERLY ENCODED AND REMOVE UNEXPECTED CHARACTERS
        df = df.applymap(lambda x: x.encode('utf-8', 'ignore').decode('utf-8') if isinstance(x, str) else x)
        
        # CREATE OUTPUT PATH
        output_path = os.path.join(output_dir, f'{sheet_name}.csv')
        
        # SAVE TO CSV WITH UTF-8 ENCODING
        df.to_csv(output_path, index=False, encoding='utf-8')

    print("Conversion to CSV completed.")

if __name__ == "__main__":
    # DEFINE PATHS
    excel_file_path = 'carmen_sightings_20220629061307.xlsx'
    seeds_output_dir = '../carmen/seeds'
    
    # PROCESS AND EXPORT THE EXCEL FILE
    process_and_export_excel(excel_file_path, seeds_output_dir)
```

### 5. Configure dbt Project for Seeds
**Update `dbt_project.yml`**:
```yaml
seeds:
  carmen:
    +schema: RAW_DATA
```

**Run dbt Seed Command**:
```bash
dbt seed
```

### 6. Create Staging Models
**Staging Models**:
- Created views to rename and cast columns to follow the standard defined.
- Example for AFRICA:
```sql
{{
  config(
    materialized = "view",
    schema="staging"
  )
}}

with africa as (
  select
    cast(date_witness as date) as date_witness,
    cast(witness as string) as witness,
    cast(agent as string) as agent,
    cast(date_agent as date) as date_agent,
    cast(region_hq as string) as city_agent,
    cast(country as string) as country,
    cast(city as string) as city,
    cast(latitude as float) as latitude,
    cast(longitude as float) as longitude,
    cast(has_weapon as boolean) as has_weapon,
    cast(has_hat as boolean) as has_hat,
    cast(has_jacket as boolean) as has_jacket,
    cast(behavior as string) as behavior
  from {{ source('carmen_sightings', 'africa') }}
)

select * from africa
```

![ERD Mart](/assets/mart-erd.png)


### 7. Create Global Staging Model
**Global Staging Model**:
- Created a union of all different regions into a single global view.
```sql
{{
  config(
    materialized = "table",
    schema="staging"
  )
}}

select 
  *
from {{ ref('stg_africa') }}
union
select
  *
from {{ ref('stg_america') }}
union
select
  *
from {{ ref('stg_asia') }}
union
select
  *
from {{ ref('stg_atlantic') }}
union
select
  *
from {{ ref('stg_australia') }}
union
select
  *
from {{ ref('stg_europe') }}
union
select
  *
from {{ ref('stg_indian') }}
union
select
  *
from {{ ref('stg_pacific') }}
```

### 8. Create Mart Models
**Dimension and Fact Tables**:
- Followed 3NF to create dimension tables and a fact table.
- Example for DIM_AGENT:
```sql
{{
  config(
    materialized = "table",
    schema="mart"
  )
}}

with agents as (
  select distinct
    agent
  from {{ref('stg_global')}}
)

select
  md5(agent) as dim_agent_key --surrogate key
  , agent
from agents
```

Example for FACT_SIGHTINGS:
```sql
{{
  config(
    materialized = "table",
    schema="mart"
  )
}}

with sightings as (
  select
    *
  from {{ ref('stg_global') }}
)

select
  dim_witness.dim_witness_key
  , sightings.date_witness as dim_witness_date_key
  , dim_agent.dim_agent_key
  , sightings.date_agent as dim_agent_date_key
  , dim_city_agent.dim_city_agent_key
  , dim_city.dim_city_key
  , sightings.has_weapon
  , sightings.has_hat
  , sightings.has_jacket
  , sightings.behavior
from 
  sightings
left join {{ ref('dim_witness') }} dim_witness 
  on 
    sightings.witness = dim_witness.witness
left join {{ ref('dim_agent') }} dim_agent
  on 
    sightings.agent = dim_agent.agent
left join {{ ref('dim_city_agent') }} dim_city_agent 
  on 
    sightings.city_agent = dim_city_agent.city_agent
left join {{ ref('dim_city') }} dim_city 
  on 
    sightings.city = dim_city.city and
    sightings.country = dim_city.country and
    sightings.latitude = dim_city.latitude and
    sightings.longitude = dim_city.longitude
```

### 9. Create Analytics Models
 - Created models to answer specific analytical questions based on the dimensions and fact tables.
 - Example for probability_armed_jacket_not_hat:
```sql
{{
  config(
    materialized = "view",
    schema="analytics"
  )
}}

with monthly_sightings as (
  select
    dim_date.month_of_year,
    dim_date.month_name,
    count(*) as total_sightings,
    count(
      case when 
        has_weapon 
        and has_jacket 
        and not has_hat 
      then 1 
      end
    ) as specific_sightings
  from 
    {{ ref('fact_sightings') }} fact_sightings
  join 
    {{ ref('dim_date') }} dim_date
    on fact_sightings.dim_witness_date_key = dim_date.date_day
  group by
    dim_date.month_of_year,
    dim_date.month_name
)

select
  month_of_year,
  month_name,
  total_sightings,
  specific_sightings,
  specific_sightings / total_sightings::float as probability
from
  monthly_sightings
```

### 10. Running Entire Project
```bash
dbt run
```

### 11. Data Lineage
```bash
dbt docs generate
dbt docs serve
```

