{{ config(materialized='table') }}

select -2::integer as subject_type_key,
       'Not Applicable'::text as subject_type_name

union all
select -1, 'Unknown'

union all
select 1, '个人报名'

union all
select 2, '单位报名'