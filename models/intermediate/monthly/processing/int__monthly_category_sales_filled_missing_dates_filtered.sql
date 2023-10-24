WITH source_data AS (
SELECT
    store_number,
    category,
    
    CASE WHEN total_sales IS NULL THEN 0 ELSE total_sales END AS total_sales,
    CASE WHEN total_gallons IS NULL THEN 0 ELSE total_gallons END AS total_gallons,
    
    sales_month
FROM {{ ref('int__monthly_category_sales_filled_missing_dates') }}
WHERE store_number in ('4004', '2633')
)

SELECT * FROM source_data