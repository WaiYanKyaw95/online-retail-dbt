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
            'online_retail_2009_2010' as source_file
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
            'online_retail_2010_2011' as source_file
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
        source_file
    from source
),

-- there are 22523 overlapping rows between the two tables during the date range 2010-12-01 to 2010-12-09, inclusive, keeping the 2009-2010 copy. 
deduplicated_overlap as (
    select * from renamed
        where not (invoice_datetime >= '2010-12-01' AND invoice_datetime < '2010-12-10' AND source_file = 'online_retail_2010_2011')
),

-- there are 11,812 duplicated rows, having same values for all columns.
-- add a flag is_duplicate so the model preserves the data as they may be real repeat scans and the timestamp only go to minute
-- with the flag, during analysis the user can filter it specifically, such as is_duplicate = false.
flagged as (
    select 
        *,
        ROW_NUMBER() over (
            partition by
                invoice_number,
                stock_code,
                description,
                quantity,
                invoice_datetime,
                unit_price,
                customer_id,
                country,
                source_file
        ) > 1 as is_duplicate
    from deduplicated_overlap
)

select * from flagged