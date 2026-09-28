{{ config(materialized='table') }}

with special_members as (

    select
        -2::integer as certificate_update_policy_key,
        'Not Applicable'::text as certificate_name,
        'Not Applicable'::text as certificate_number_rule,
        'Not Applicable'::text as industry,
        null::integer as review_cycle_months,
        'Not Applicable'::text as review_record_format,
        null::integer as certificate_update_cycle_months,
        null::integer as replacement_cycle_months,
        'Not Applicable'::text as replaces_physical_certificate,
        'Not Applicable'::text as certificate_number_changes,
        null::integer as advance_reminder_days,
        'Not Applicable'::text as supervisory_authority,
        '1900-01-01'::date as effective_start_date,
        '2099-01-01'::date as effective_end_date,
        'Y'::text as is_current

    union all

    select
        -1,
        'Unknown',
        'Unknown',
        'Unknown',
        null,
        'Unknown',
        null,
        null,
        'Unknown',
        'Unknown',
        null,
        'Unknown',
        '1900-01-01'::date,
        '2099-01-01'::date,
        'Y'
),

policy_members as (

    select
        certificate_update_policy_key::integer,
        certificate_name::text,
        certificate_number_rule::text,
        industry::text,
        nullif(review_cycle_months::text, 'N/A')::integer as review_cycle_months,
        review_record_format::text,
        nullif(certificate_update_cycle_months::text, 'N/A')::integer
            as certificate_update_cycle_months,
        nullif(replacement_cycle_months::text, 'N/A')::integer
            as replacement_cycle_months,
        replaces_physical_certificate::text,
        certificate_number_changes::text,
        nullif(advance_reminder_days::text, 'N/A')::integer
            as advance_reminder_days,
        supervisory_authority::text,
        effective_start_date::date,
        effective_end_date::date,
        is_current::text
    from {{ ref('certificate_update_policy_mapping') }}
)

select * from special_members

union all

select * from policy_members
