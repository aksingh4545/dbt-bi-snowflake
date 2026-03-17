{{ config(materialized='table') }}

select
    payment,
    count(*) as transactions,
    sum(total) as total_sales
from {{ ref('stg_sales') }}
group by payment