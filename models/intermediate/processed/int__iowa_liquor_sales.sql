WITH source_data as (
    SELECT 
	"Invoice/Item Number" as invoice_and_item_number,
	TO_DATE("Date") as date,
	"Store Number" as store_number,
	"Store Name" as store_name,
	"Address" as address,
	"City" as city,
	"Zip Code" as zip_code,
	"Store Location" as store_location,
	"County Number" as county_number,
	"County" as county,
	"Category" as category,
	"Category Name" as category_name,
	"Vendor Number" as vendor_number,
	"Vendor Name" as vendor_name,
	"Item Number" as item_number,
	"Item Description" as item_description,
	"Pack" as pack,
	"Bottle Volume (ml)" as bottle_volume_ml,
	"State Bottle Cost" as state_bottle_cost,
	"State Bottle Retail" as state_bottle_retail,
	"Bottles Sold" as bottles_sold,
	"Sale (Dollars)" as sale_dollars,
	"Volume Sold (Liters)" as volume_sold_liters,
	"Volume Sold (Gallons)" as volume_sold_gallons
    FROM {{ ref('stg__iowa_liquor_sales') }}
)
SELECT * FROM source_data