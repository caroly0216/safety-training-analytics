{{ config(materialized='table') }}

select
    -2::integer as payment_method_key,
    'Not Applicable'::text as payment_method_name

union all

select
    -1::integer,
    'Unknown'::text

union all

select
    1::integer,
    '对公转账'::text

union all

select
    2::integer,
    '其他方式'::text