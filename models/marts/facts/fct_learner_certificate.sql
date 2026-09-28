{{ config(materialized='table') }}

with certificate_candidates as (
    select
        registration.*,
        case
            when registration.certificate_name = '其他从业人员'
                and registration.training_category = '有限空间'
                then '有限空间'
            else registration.certificate_name
        end as policy_certificate_name,
        case
            when registration.certificate_name in ('主要负责人', '安全管理人员')
                and registration.industry like '危化品%'
                then '危化品'
            when registration.certificate_name in ('主要负责人', '安全管理人员')
                then '其他行业'
            else 'N/A'
        end as policy_industry
    from {{ ref('int_registration_standardized') }} as registration
    where registration.certificate_number is not null
       or registration.initial_certificate_date is not null
       or registration.certificate_expiry_date is not null
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
),

matched as (
    select
        registration.*,
        coalesce(learner.learner_key, -1) as learner_key,
        coalesce(project_lookup.registration_project_key, -1)
            as registration_project_key,
        coalesce(policy.certificate_update_policy_key, -1)
            as certificate_update_policy_key,
        case
            when registration.certificate_expiry_date is not null
                then registration.certificate_expiry_date
            when registration.initial_certificate_date is not null
                and coalesce(
                    policy.certificate_update_cycle_months,
                    policy.replacement_cycle_months
                ) is not null
                then (
                    registration.initial_certificate_date
                    + make_interval(months => coalesce(
                        policy.certificate_update_cycle_months,
                        policy.replacement_cycle_months
                    ))
                )::date
            else null::date
        end as resolved_certificate_expiry_date
    from certificate_candidates as registration
    left join {{ ref('dim_learner') }} as learner
        on registration.national_id = learner.national_id
    left join project_lookup
        on registration.registration_project_mapping_id = project_lookup.mapping_id
    left join {{ ref('dim_certificate_update_policy') }} as policy
        on registration.policy_certificate_name = policy.certificate_name
        and registration.policy_industry = policy.industry
        and coalesce(
            registration.initial_certificate_date,
            registration.ingestion_timestamp::date
        ) between policy.effective_start_date and policy.effective_end_date
        and policy.certificate_update_policy_key > 0
),

validated as (
    select
        matched.*,
        initial_certificate_date is not null
            and certificate_expiry_date is not null
            and certificate_expiry_date
                > (initial_certificate_date + interval '6 years')::date
            as excessive_certificate_date_span
    from matched
)

select
    ('x' || substr(md5(registration_id), 1, 15))::bit(60)::bigint
        as certificate_record_key,
    registration_id,
    learner_key,
    registration_project_key,
    certificate_update_policy_key,
    coalesce(nullif(btrim(certificate_number), ''), 'Unknown')
        as certificate_number,
    case
        when excessive_certificate_date_span then -1
        else coalesce(to_char(initial_certificate_date, 'YYYYMMDD')::integer, -1)
    end
        as initial_certificate_date_key,
    case
        when excessive_certificate_date_span then -1
        else coalesce(
            to_char(resolved_certificate_expiry_date, 'YYYYMMDD')::integer,
            -1
        )
    end
        as certificate_expiry_date_key,
    case
        when excessive_certificate_date_span
            or resolved_certificate_expiry_date is null then -1
        when resolved_certificate_expiry_date >= current_date then 1
        else 2
    end as certificate_status_key
from validated
