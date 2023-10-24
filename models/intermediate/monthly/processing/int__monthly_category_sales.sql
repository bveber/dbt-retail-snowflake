WITH source_data AS (

SELECT  
  store_number,
  MODE(store_name) as store_name,
  category,
  MODE(category_name) AS category_name,

  COUNT(DISTINCT(invoice_and_item_number)) AS num_purchases,
  COUNT(DISTINCT(item_number)) AS num_unique_items, 
  SUM(sale_dollars) AS total_sales,
  SUM(volume_sold_gallons) AS total_gallons,
  SUM(volume_sold_liters) AS total_liters,

  DATE_FROM_PARTS(EXTRACT(year FROM date), EXTRACT(month FROM date), 1)  as sales_month
FROM {{ ref('int__iowa_liquor_sales') }}
GROUP BY store_number, category, sales_month
ORDER BY sales_month, total_sales desc

)

SELECT *
FROM source_data