{{ config(materialized='table') }}

select
    -2::integer as certificate_processing_type_key,
    'Not Applicable'::text as certificate_processing_type_name

union all

select
    -1::integer,
    'Unknown'::text

union all

select
    1::integer,
    '初次申领'::text

union all

select
    2::integer,
    '到期更新（不换证）'::text

union all

select
    3::integer,
    '到期换证（可发实体证）'::text

union all

select
    4::integer,
    '复审记录/合格证'::text