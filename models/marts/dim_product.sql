with
    full_list as (
        select
            distinct stock_code
        from {{ ref('stg_online_retail') }}
    ),
    
    description_count as (
        select
            stock_code,
            description,
            count(*) as usage_count
        from {{ ref('stg_online_retail') }}
        where description is not null
        group by stock_code, description
    ),

    filtered as (
        select
            stock_code,
            description
        from description_count
        qualify row_number() over(
                partition by stock_code
                order by usage_count desc, description desc
            ) = 1
    ),

    products as (
        select
            fl.stock_code as stock_code,
            coalesce(s.category, 'product') as product_category,
            coalesce(s.category, 'product') = 'product' as is_product,
            coalesce(f.description, 'Unknown') as description
        from full_list fl
        left join filtered f on fl.stock_code = f.stock_code
        left join {{ ref('special_stock_codes') }} s on fl.stock_code = s.stock_code
    )

select * from products