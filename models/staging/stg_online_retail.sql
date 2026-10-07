with
    source as (
        select Invoice, StockCode, Description, Quantity, InvoiceDate, Price, "Customer ID", Country from raw.online_retail_2009_2010
        union all
        select Invoice, StockCode, Description, Quantity, InvoiceDate, Price, "Customer ID", Country from raw.online_retail_2010_2011
),

renamed as (
    select
        Invoice as invoice_number,
        StockCode as stock_code,
        Description as description,
        Quantity as quantity,
        strptime(InvoiceDate, '%m/%d/%Y %H:%M') as invoice_datetime,
        Price::decimal(10, 2) as unit_price,
        "Customer ID"::varchar as customer_id,
        Country as country
    from source
)

select * from renamed