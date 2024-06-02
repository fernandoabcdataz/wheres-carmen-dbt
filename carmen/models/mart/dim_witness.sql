{{
  config(
    materialized = "table",
    schema="mart"
  )
}}

with witnesses as (
  select distinct
    witness
  from {{ref('stg_global')}}
)

select
  md5(witness) as dim_witness_key --surrogate key
  , witness
from witnesses