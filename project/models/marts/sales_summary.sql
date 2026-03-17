{{ config(materialized='table') }}

select
    city,
    product_line,
    sum(total) as total_sales,
    sum(quantity) as total_quantity,
    avg(rating) as avg_rating
from {{ ref('stg_sales') }}
group by city, product_line