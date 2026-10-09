with
    spine as (
        {{ dbt_utils.date_spine(
            datepart="day",
            start_date="cast('2009-01-01' as date)",
            end_date="cast('2012-01-01' as date)"
        ) }}
    ),

    date_formatted as (
        select date_day::date as date_day from spine
    ),

    enriched as (
        select
            date_day as date_key,
            extract (year from date_day) as year,
            extract (quarter from date_day) as quarter,
            extract (month from date_day) as month_number,
            monthname(date_day) as month_name,
            dayname(date_day) as day_name,
            -- dow for duckdb is 0 for Sun, and 6 for Sat.
            -- to note it for bigquery, 1 for Sun, and 7 for Sat.
            extract (dow from date_day) as day_of_week,
            extract (dow from date_day) in (0, 6) as is_weekend
        from date_formatted
    )

select * from enriched