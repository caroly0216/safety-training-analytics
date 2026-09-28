{{ config(materialized='table') }}

with special_members as (

    select
        -2::integer as training_policy_key,
        'Not Applicable'::text as certificate_name,
        'Not Applicable'::text as industry,
        'Not Applicable'::text as project,
        'Not Applicable'::text as subproject,
        'Not Applicable'::text as training_type,
        'Not Applicable'::text as training_stage,
        'Not Applicable'::text as training_required,
        'Not Applicable'::text as training_format,
        '1900-01-01'::date as effective_start_date,
        '2099-01-01'::date as effective_end_date,
        'Y'::text as is_current

    union all

    select
        -1,
        'Unknown',
        'Unknown',
        'Unknown',
        'Unknown',
        'Unknown',
        'Unknown',
        'Unknown',
        'Unknown',
        '1900-01-01'::date,
        '2099-01-01'::date,
        'Y'
),

policy_members as (

    select
        training_policy_key::integer,
        certificate_name::text,
        industry::text,
        project::text,
        subproject::text,
        training_type::text,
        training_stage::text,
        training_required::text,
        training_format::text,
        effective_start_date::date,
        effective_end_date::date,
        is_current::text
    from {{ ref('training_policy_mapping') }}
)

select * from special_members

union all

select * from policy_members
