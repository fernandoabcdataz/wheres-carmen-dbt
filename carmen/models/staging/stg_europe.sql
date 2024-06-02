{{
  config(
    materialized = "view",
    schema="staging"
  )
}}

with europe as (
  select
    cast(date_witness as date) as date_witness,
    cast(witness as string) as witness,
    cast(agent as string) as agent,
    cast(date_filed as date) as date_agent,
    cast(region_hq as string) as city_agent,
    cast(country as string) as country,
    cast(city as string) as city,
    cast(lat_ as float) as latitude,
    cast(long_ as float) as longitude,
    cast(armed as boolean) as has_weapon,
    cast(chapeau as boolean) as has_hat,
    cast(coat as boolean) as has_jacket,
    cast(observed_action as string) as behavior
  from {{ source('carmen_sightings', 'europe') }}
)

select * from europe