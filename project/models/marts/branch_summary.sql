{{ config(materialized='table') }}

select
    branch,
    city,
    sum(total) as total_sales,
    sum(quantity) as total_qty
from {{ ref('stg_sales') }}
group by branch, city