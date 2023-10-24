WITH source_data AS (
    SELECT  
    store_number,
    MODE(store_name) AS store_name,
    COUNT(DISTINCT(DATE_TRUNC("MONTH", date))) AS num_months,
    MIN(date) AS min_date,
    MAX(date) AS max_date,
    COUNT(DISTINCT(category)) AS num_unique_categories, 
    COUNT(DISTINCT(item_number)) AS num_unique_items, 
    SUM(sale_dollars) AS total_sales,
    SUM(volume_sold_gallons) AS total_gallons,
    SUM(volume_sold_liters) AS total_liters
    FROM {{ ref('int__iowa_liquor_sales') }}
    GROUP BY store_number
    ORDER BY num_months desc
)
SELECT *
FROM source_data