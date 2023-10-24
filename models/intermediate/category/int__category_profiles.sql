WITH source_data AS (

SELECT  
  category, 
  COUNT(DISTINCT(category_name)) AS num_names,
  MODE(category_name) AS category_name,
--   approx_top_k(category_name, 5) AS top_names,
  COUNT(DISTINCT(item_number)) AS num_unique_items, 
  COUNT(DISTINCT(store_number)) AS num_unique_stores,
  SUM(sale_dollars) AS total_sales,
  SUM(volume_sold_gallons) as total_gallons
FROM {{ ref('int__iowa_liquor_sales') }}
GROUP BY category
ORDER BY total_sales desc
)

SELECT *
FROM source_data