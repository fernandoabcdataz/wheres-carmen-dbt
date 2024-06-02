{{
  config(
    materialized = "view",
    schema="analytics"
  )
}}

with top_behaviors as (
  select
    behavior
  from 
    {{ ref('top_three_behaviors') }}
),
monthly_sightings as (
  select
    dim_date.month_of_year,
    dim_date.month_name,
    count(*) as total_sightings,
    count(case when behavior in (select behavior from top_behaviors) then 1 end) as top_behavior_sightings
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
  top_behavior_sightings / total_sightings::float as probability
from
  monthly_sightings