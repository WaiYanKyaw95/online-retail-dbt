with
    source as (
        select 
            Invoice, 
            StockCode, 
            Description, 
            Quantity, 
            InvoiceDate, 
            Price, 
            "Customer ID", 
            Country,
            'online_retail_2009_2010' as "source_file"
        from {{ source('raw', 'online_retail_2009_2010') }}
        union all
        select 
            Invoice, 
            StockCode, 
            Description, 
            Quantity, 
            InvoiceDate, 
            Price, 
            "Customer ID", 
            Country,
            'online_retail_2010_2011' as "source_file"
        from {{ source('raw', 'online_retail_2010_2011') }}
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
        Country as country,
        "source_file"
    from source
)
-- there are 22523 overlapping rows between the two tables during the date range 2010-12-01 to 2010-12-09, inclusive, keeping the 2009-2010 copy. 
select * from renamed
    where not (invoice_datetime >= '2010-12-01' AND invoice_datetime < '2010-12-10' AND source_file = 'online_retail_2010_2011')