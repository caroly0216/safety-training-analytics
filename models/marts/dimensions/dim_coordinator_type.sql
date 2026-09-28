{{ config(materialized='table') }}

select -2::integer as coordinator_type_key,
       'Not Applicable'::text as coordinator_type_name

union all
select -1, 'Unknown'

union all
select 1, '个人'

union all
select 2, '单位'

union all
select 3, '中介'
