{{
  config(
    materialized = "table",
    schema="mart"
  )
}}

{{ dbt_date.get_date_dimension("1980-01-01", "2030-12-31") }}