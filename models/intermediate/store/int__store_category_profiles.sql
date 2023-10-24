WITH profiles AS (
    
SELECT 
    store_number,
    store_name,
    category,
    category_name,
    COUNT(*) AS num_months,
    MIN(sales_month) AS min_date,
    MAX(sales_month) AS max_date
FROM {{ ref('int__monthly_category_sales') }}
GROUP BY
    store_number, store_name,
    category, category_name

)

SELECT * FROM profiles