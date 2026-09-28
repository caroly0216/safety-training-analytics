{{ config(materialized='table') }}

select
    -2::integer as training_stage_key,
    'Not Applicable'::text as training_stage_name

union all

select
    -1::integer,
    'Unknown'::text

union all

select
    1::integer,
    '新训'::text

union all

select
    2::integer,
    '复训'::text

union all

select
    3::integer,
    '换证'::text