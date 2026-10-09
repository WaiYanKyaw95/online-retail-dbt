with
    renamed as (
        select
            invoice_number,
            stock_code,
            coalesce(customer_id, 'unknown') as customer_id,
            invoice_datetime::date as invoice_date,
            is_duplicate,
            (invoice_number like 'C%') as is_cancellation,
            country,
            quantity,
            unit_price,
            quantity * unit_price as line_amount
        from {{ ref('stg_online_retail') }}
    )

select * from renamed