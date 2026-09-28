with date_spine as (

    select
        generated_date::date as full_date

    from generate_series(
        date '1900-01-01',
        date '2099-12-31',
        interval '1 day'
    ) as generated_date

),

standard_dates as (

    select
        to_char(full_date, 'YYYYMMDD')::integer as date_key,
        full_date,
        extract(year from full_date)::integer as year,
        extract(quarter from full_date)::integer as quarter,
        extract(month from full_date)::integer as month,
        to_char(full_date, 'FMMonth') as month_name,
        extract(day from full_date)::integer as day,
        extract(isodow from full_date)::integer as day_of_week,
        to_char(full_date, 'FMDay') as day_name

    from date_spine

),

special_dates as (

    select
        -1 as date_key,
        null::date as full_date,
        null::integer as year,
        null::integer as quarter,
        null::integer as month,
        'Unknown'::text as month_name,
        null::integer as day,
        null::integer as day_of_week,
        'Unknown'::text as day_name

    union all

    select
        -2,
        null::date,
        null::integer,
        null::integer,
        null::integer,
        'Not Applicable'::text,
        null::integer,
        null::integer,
        'Not Applicable'::text

)

select *
from special_dates

union all

select *
from standard_dates