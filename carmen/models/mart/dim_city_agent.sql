{{
  config(
    materialized = "table",
    schema="mart"
  )
}}

with hqs as (
  select distinct
    city_agent
  from {{ref('stg_global')}}
)

select
  md5(city_agent) as dim_city_agent_key --surrogate key
  , city_agent
from hqs