{{
  config(
    materialized = "view",
    schema="analytics"
  )
}}

with behavior_counts as (
  select
    behavior,
    count(*) as occurrences
  from 
    {{ ref('fact_sightings') }}
  group by
    behavior
),
ranked_behaviors as (
  select
    *,
    row_number() over (order by occurrences desc) as rank
  from 
    behavior_counts
)

select
  behavior,
  occurrences
from
  ranked_behaviors
where
  rank <= 3