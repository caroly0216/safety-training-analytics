{{ config(materialized='table') }}

select -2::integer as registration_service_scope_key,
       'Not Applicable'::text as registration_service_scope_name

union all
select -1, 'Unknown'

union all
select 1, '培训'

union all
select 2, '考试'

union all
select 3, '培训及考试'