{{
  config(
    materialized = "table",
    schema="staging"
  )
}}

select 
  *
from {{ ref('stg_africa') }}
union
select
  *
from {{ ref('stg_america') }}
union
select
  *
from {{ ref('stg_asia') }}
union
select
  *
from {{ ref('stg_atlantic') }}
union
select
  *
from {{ ref('stg_australia') }}
union
select
  *
from {{ ref('stg_europe') }}
union
select
  *
from {{ ref('stg_indian') }}
union
select
  *
from {{ ref('stg_pacific') }}