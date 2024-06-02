{{
  config(
    materialized = "view",
    schema="staging"
  )
}}

with atlantic as (
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
  from {{ source('carmen_sightings', 'atlantic') }}
)

select * from atlantic