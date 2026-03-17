{{ config(materialized='table') }}

select
    customer_type,
    gender,
    count(*) as total_transactions,
    sum(total) as total_sales,
    avg(rating) as avg_rating
from {{ ref('stg_sales') }}
group by customer_type, gender