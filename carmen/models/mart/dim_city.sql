{{
  config(
    materialized = "table",
    schema="mart"
  )
}}

with cities as (
  select distinct
    city
    , country
    , latitude
    , longitude
  from {{ref('stg_global')}}
)

select
  md5(
    concat(
        coalesce(city, '')
      , coalesce(country, '')
      , coalesce(latitude, '')
      , coalesce(longitude, '')
    )
  ) as dim_city_key --surrogate key
  , city
  , country
  , latitude
  , longitude
from cities