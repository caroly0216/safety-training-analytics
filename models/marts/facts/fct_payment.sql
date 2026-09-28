{{ config(materialized='table') }}

with paid_registrations as (
    select *
    from {{ ref('int_registration_standardized') }}
    where collection_status = 'Collected'
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
    coalesce(coordinator.coordinator_key, -1) as settlement_coordinator_key,
    coalesce(project_lookup.registration_project_key, -1)
        as registration_project_key,
    coalesce(stage.training_stage_key, -1) as training_stage_key,
    1::integer as registration_service_scope_key,
    registration.registration_id,
    registration.payment_reference_number as payment_receipt_number,
    coalesce(learner.learner_key, -1) as learner_key,
    registration.amount as collected_amount,
    ('x' || substr(md5(registration.registration_id), 1, 15))::bit(60)::bigint
        as payment_record_key,
    case
        when btrim(registration.payment_reference_number) ~ '^[0-9]{12}$'
            then 1
        else 2
    end as payment_method_key,
    case
        when btrim(registration.company_name) = '无' then 1
        else 2
    end as settlement_subject_type_key,
    case
        when btrim(registration.company_name) = '无' then -2
        else coalesce(company.company_key, -1)
    end as learner_company_key,
    case
        when btrim(registration.company_name) = '无' then -2
        else coalesce(company.company_key, -1)
    end as settlement_company_key

from paid_registrations as registration
left join {{ ref('dim_coordinator') }} as coordinator
    on registration.coordinator_name = coordinator.coordinator_name
left join project_lookup
    on registration.registration_project_mapping_id = project_lookup.mapping_id
left join {{ ref('dim_training_stage') }} as stage
    on registration.training_stage = stage.training_stage_name
left join {{ ref('dim_learner') }} as learner
    on registration.national_id = learner.national_id
left join {{ ref('dim_company') }} as company
    on registration.company_name = company.company_name
