{{ config(materialized='table') }}

select -2::integer as registration_status_key,
       'Not Applicable'::text as registration_status_name

union all
select -1, 'Unknown'

union all
select 1, '正常'

union all
select 2, '取消'