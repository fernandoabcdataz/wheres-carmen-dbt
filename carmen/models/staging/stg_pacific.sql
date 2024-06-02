{{
  config(
    materialized = "view",
    schema="staging"
  )
}}

with pacific as (
  select
    cast(sight_on as date) as date_witness,
    cast(sighter as string) as witness,
    cast(filer as string) as agent,
    cast(file_on as date) as date_agent,
    cast(report_office as string) as city_agent,
    cast(nation as string) as country,
    cast(town as string) as city,
    cast(lat as float) as latitude,
    cast(long as float) as longitude,
    cast(has_weapon as boolean) as has_weapon,
    cast(has_hat as boolean) as has_hat,
    cast(has_jacket as boolean) as has_jacket,
    cast(behavior as string) as behavior
  from {{ source('carmen_sightings', 'pacific') }}
)

select * from pacific