{{ config(materialized='table') }}

select
    product_line,
    sum(quantity) as total_quantity,
    sum(total) as total_sales,
    avg(unit_price) as avg_price
from {{ ref('stg_sales') }}
group by product_line