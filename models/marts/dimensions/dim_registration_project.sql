{{ config(materialized='table') }}

with mapped_projects as (

    select
        min(mapping_id)::bigint
            as registration_project_key,

        certificate_name,
        industry,
        project,
        subproject,

        training_category
            as training_type,

        supervisory_authority,

        effective_start_date::date
            as effective_start_date,

        effective_end_date::date
            as effective_end_date,

        is_current

    from {{ ref('registration_project_mapping') }}

    group by
        certificate_name,
        industry,
        project,
        subproject,
        training_category,
        supervisory_authority,
        effective_start_date,
        effective_end_date,
        is_current

),

special_members as (

    select
        -1::bigint
            as registration_project_key,

        'Unknown'::text
            as certificate_name,

        'Unknown'::text
            as industry,

        'Unknown'::text
            as project,

        'Unknown'::text
            as subproject,

        'Unknown'::text
            as training_type,

        'Unknown'::text
            as supervisory_authority,

        date '1900-01-01'
            as effective_start_date,

        date '2099-12-31'
            as effective_end_date,

        'Y'::text
            as is_current

    union all

    select
        -2::bigint,
        'Not Applicable'::text,
        'Not Applicable'::text,
        'Not Applicable'::text,
        'Not Applicable'::text,
        'Not Applicable'::text,
        'Not Applicable'::text,
        date '1900-01-01',
        date '2099-12-31',
        'Y'::text

),

final as (

    select *
    from special_members

    union all

    select *
    from mapped_projects

)

select *
from final