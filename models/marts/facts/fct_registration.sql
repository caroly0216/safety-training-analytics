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
    registration.registration_id,

    coalesce(coordinator.coordinator_key, -1) as coordinator_key,
    coalesce(project_lookup.registration_project_key, -1)
        as registration_project_key,
    coalesce(learner.learner_key, -1) as learner_key,
    coalesce(stage.training_stage_key, -1) as training_stage_key,

    case
        when extract(year from registration.ingestion_timestamp) = 2026
            then 1
        else -1
    end as registration_service_scope_key,

    case
        when btrim(registration.company_name) = '无' then -2
        else coalesce(company.company_key, -1)
    end as company_key,

    case
        when btrim(registration.company_name) = '无' then 1
        else 2
    end as subject_type_key,

    case
        when registration.salesperson_note ~ '(取消|迟到)' then 2
        else 1
    end as registration_status_key,

    coalesce(price.price_key, -1) as price_key,

    coalesce(policy.training_policy_key, -1) as training_policy_key,

    registration.amount as agreed_amount,
    registration.collection_status

from registrations as registration

left join {{ ref('dim_coordinator') }} as coordinator
    on registration.coordinator_name = coordinator.coordinator_name

left join project_lookup
    on registration.registration_project_mapping_id
        = project_lookup.mapping_id

left join {{ ref('dim_registration_project') }} as project_detail
    on project_lookup.registration_project_key
        = project_detail.registration_project_key

left join {{ ref('dim_learner') }} as learner
    on registration.national_id = learner.national_id

left join {{ ref('dim_training_stage') }} as stage
    on registration.training_stage = stage.training_stage_name

left join {{ ref('dim_company') }} as company
    on registration.company_name = company.company_name

left join {{ ref('dim_price') }} as price
    on project_lookup.registration_project_key = price.registration_project_key
    and registration.training_stage = price.training_stage
    and price.fee_category = '培训费'
    and registration.ingestion_timestamp::date >= price.effective_start_date
    and registration.ingestion_timestamp::date <= price.effective_end_date

left join lateral (
    select candidate.training_policy_key
    from {{ ref('dim_training_policy') }} as candidate
    where candidate.training_policy_key > 0
      and candidate.certificate_name = project_detail.certificate_name
      and candidate.training_stage = registration.training_stage
      and (
          candidate.industry = project_detail.industry
          or candidate.industry = '默认'
      )
      and (
          candidate.project = project_detail.project
          or candidate.project = '默认'
          or (
              candidate.certificate_name = '特种作业'
              and candidate.project = 'N/A'
          )
      )
      and (
          candidate.subproject = project_detail.subproject
          or candidate.subproject = '默认'
          or (
              candidate.certificate_name = '特种作业'
              and candidate.subproject = 'N/A'
          )
      )
      and (
          candidate.training_type = project_detail.training_type
          or candidate.training_type = '默认'
      )
      and registration.ingestion_timestamp::date
          between candidate.effective_start_date
          and candidate.effective_end_date
    order by
        (
            (candidate.industry = project_detail.industry)::integer
            + (candidate.project = project_detail.project)::integer
            + (candidate.subproject = project_detail.subproject)::integer
            + (candidate.training_type = project_detail.training_type)::integer
        ) desc,
        candidate.effective_start_date desc,
        candidate.training_policy_key
    limit 1
) as policy on true
