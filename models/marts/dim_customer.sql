with
    aggregated as (
        select
            customer_id,
            min(case when is_cancellation = false then invoice_date end) as first_purchase_date,
            max(case when is_cancellation = false then invoice_date end) as last_purchase_date,
            sum(line_amount) as net_revenue
        from {{ ref('fct_sales') }}
        where is_duplicate = false
        group by customer_id
    )

select * from aggregated
