{{ config(materialized='table') }}

with registrations as (
    select *
    from {{ ref('int_registration_standardized') }}
),

project_lookup as (
    select
        mapping.mapping_id::integer as mapping_id,
        project.registration_project_key
    from {{ ref('registration_project_mapping') }} as mapping
    join {{ ref('dim_registration_project') }} as project
        on mapping.certificate_name = project.certificate_name
        and mapping.industry = project.industry
        and mapping.project = project.project
        and mapping.subproject = project.subproject
        and mapping.training_category = project.training_type
        and mapping.supervisory_authority = project.supervisory_authority
        and mapping.effective_start_date::date = project.effective_start_date
        and mapping.effective_end_date::date = project.effective_end_date
        and mapping.is_current = project.is_current
)

select
    ('x' || substr(md5(registration.registration_id), 1, 15))::bit(60)::bigint
        as training_record_key,
    registration.registration_id,
    registration.declared_class as actual_training_batch,
    coalesce(learner.learner_key, -1) as learner_key,
    coalesce(project_lookup.registration_project_key, -1)
        as registration_project_key,
    coalesce(stage.training_stage_key, -1) as training_stage_key,
    coalesce(to_char(registration.training_start_date, 'YYYYMMDD')::integer, -1)
        as training_start_date_key,
    coalesce(to_char(registration.training_end_date, 'YYYYMMDD')::integer, -1)
        as training_end_date_key,
    case
        when coalesce(registration.salesperson_note, '') ~ '(取消|迟到)'
            then '报名异常未参加'
        when registration.training_end_date < current_date then '已完成'
        when registration.training_end_date >= current_date then '进行中'
        else '培训日期为空无法判断'
    end as estimated_training_completion_status
from registrations as registration
left join {{ ref('dim_learner') }} as learner
    on registration.national_id = learner.national_id
left join project_lookup
    on registration.registration_project_mapping_id = project_lookup.mapping_id
left join {{ ref('dim_training_stage') }} as stage
    on registration.training_stage = stage.training_stage_name
