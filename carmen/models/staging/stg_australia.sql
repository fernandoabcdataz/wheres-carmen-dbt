{{
  config(
    materialized = "view",
    schema="staging"
  )
}}

with australia as (
  select
    cast(witnessed as date) as date_witness,
    cast(observer as string) as witness,
    cast(field_chap as string) as agent,
    cast(reported as date) as date_agent,
    cast(interpol_spot as string) as city_agent,
    cast(nation as string) as country,
    cast(place as string) as city,
    cast(lat as float) as latitude,
    cast(long as float) as longitude,
    cast(has_weapon as boolean) as has_weapon,
    cast(has_hat as boolean) as has_hat,
    cast(has_jacket as boolean) as has_jacket,
    cast(state_of_mind as string) as behavior
  from {{ source('carmen_sightings', 'australia') }}
)

select * from australia