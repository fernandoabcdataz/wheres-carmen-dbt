{{
  config(
    materialized = "view",
    schema="staging"
  )
}}

with asia as (
  select
    cast(sighting as date) as date_witness,
    cast(citizen as string) as witness,
    cast(officer as string) as agent,
    cast(report_date as date) as date_agent,
    cast(city_interpol as string) as city_agent,
    cast(nation as string) as country,
    cast(city as string) as city,
    cast(latitude as float) as latitude,
    cast(longitude as float) as longitude,
    cast(has_weapon as boolean) as has_weapon,
    cast(has_hat as boolean) as has_hat,
    cast(has_jacket as boolean) as has_jacket,
    cast(behavior as string) as behavior
  from {{ source('carmen_sightings', 'asia') }}
)

select * from asia