{{
  config(
    materialized = "view",
    schema="analytics"
  )
}}

with occurring_behaviors as (
  select
    dim_agent_key
    , behavior
    , count(*) occurrences
  from {{ ref('fact_sightings') }}
  group by 
    dim_agent_key
    , behavior
)
, 
calc as (
  select 
    dim_agent_key
    , behavior
    , occurrences
    , rank() over (partition by dim_agent_key order by occurrences desc) as rk
  from occurring_behaviors
)

select
  dim_agent.agent
  , calc.behavior
  , calc.occurrences
from calc 
  join {{ ref('dim_agent') }} dim_agent
    on calc.dim_agent_key = dim_agent.dim_agent_key
where calc.rk <= 3