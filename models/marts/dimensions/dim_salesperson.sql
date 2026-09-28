{{ config(materialized='table') }}

select
    -2::integer as salesperson_key,
    'Not Applicable'::text as salesperson_name,
    'Not Applicable'::text as phone_number,
    'Not Applicable'::text as employment_status

union all

select
    -1::integer,
    'Unknown'::text,
    'Unknown'::text,
    'Unknown'::text

union all

select
    1::integer,
    'Example Salesperson'::text,
    'Not Applicable'::text,
    'Unknown'::text
