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
    city_agent,
    count(*) as total_reports
  from 
    {{ ref('fact_sightings') }} fact_sightings
  join  
    {{ ref('dim_city_agent') }} dim_city_agent
    on fact_sightings.dim_city_agent_key = dim_city_agent.dim_city_agent_key
  join 
    {{ ref('dim_date') }} dim_date
    on fact_sightings.dim_agent_date_key = dim_date.date_day
  group by
    dim_date.month_of_year,
    dim_date.month_name,
    city_agent
),
ranked_regions as (
  select
    *,
    row_number() over (partition by month_name order by total_reports desc) as rank
  from 
    monthly_sightings
)

select
  month_of_year,
  month_name,
  city_agent as most_likely_region,
  total_reports
from
  ranked_regions
where
  rank = 1