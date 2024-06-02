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