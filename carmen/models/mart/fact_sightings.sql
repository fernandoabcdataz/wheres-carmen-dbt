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
