{{ config(materialized='table') }}

select -2::integer as certificate_status_key,
       'Not Applicable'::text as certificate_status_name

union all
select -1, 'Unknown'

union all
select 1, '有效'

union all
select 2, '失效'