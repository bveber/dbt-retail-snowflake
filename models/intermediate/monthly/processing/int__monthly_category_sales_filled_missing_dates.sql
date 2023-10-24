{{ config(
    materialized="table",
    cluster_by=["store_number", "category"]
) }}

WITH min_max_dates AS (

SELECT 
    MIN(sales_month) AS min_date,
    max(sales_month) AS max_date
FROM {{ ref('int__monthly_category_sales') }}

),
unique_stores AS (

SELECT distinct store_number
FROM {{ ref('int__monthly_category_sales') }}

),
unique_categories as (

SELECT distinct category
FROM {{ ref('int__monthly_category_sales') }}

),
months as (
SELECT
    date_trunc('month', dateadd('month', r.rn, d.start_date)) as month
FROM (
    SELECT 
        min(date) as start_date,
        max(date) as end_date,
        datediff('month', start_date, end_date) as m
    FROM {{ ref('int__iowa_liquor_sales') }}
) as d
JOIN (
    SELECT row_number() over (order by null)-1 as rn
    FROM table(generator(ROWCOUNT => 1000))
) as r ON r.rn <= d.m
ORDER BY d.start_date, month
),
base AS (

SELECT distinct
    unique_stores.store_number,
    unique_categories.category,
    m.month AS sales_month
FROM 
  unique_stores,
  unique_categories,
  months m
),
filled AS (

SELECT 
  base.store_number,
  sp.store_name,
  base.category,
  cp.category_name,

  s.num_purchases,
  s.num_unique_items, 
  s.total_sales,
  s.total_gallons,
  s.total_liters,

  base.sales_month
FROM base 
LEFT JOIN {{ ref('int__monthly_category_sales') }} s
  ON s.store_number = base.store_number
  AND s.category = base.category
  AND s.sales_month = base.sales_month
JOIN {{ ref('int__store_profiles') }} sp 
ON sp.store_number = base.store_number
JOIN {{ ref('int__category_profiles') }} cp
ON cp.category = base.category

)
SELECT * FROM filled