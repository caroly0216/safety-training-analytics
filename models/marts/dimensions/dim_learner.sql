{{ config(materialized='table') }}

with ranked_learners as (

    select
        national_id,
        trainee_name,
        education_level,
        phone_number,
        contact_address,

        row_number() over (
            partition by national_id

            order by
                ingestion_timestamp desc,
                source_file_name desc,
                source_sheet_name desc,
                source_row_number desc
        ) as row_number

    from {{ ref('int_registration_standardized') }}

    where national_id is not null
      and btrim(national_id) <> ''
      and national_id <> 'Unknown'

),

learners as (

    select
        (
            'x'
            || substr(
                md5(national_id),
                1,
                15
            )
        )::bit(60)::bigint as learner_key,

        trainee_name as learner_name,
        national_id,

        coalesce(
            nullif(education_level, ''),
            'Unknown'
        ) as education_level,

        coalesce(
            nullif(phone_number, ''),
            'Unknown'
        ) as phone_number,

        coalesce(
            nullif(contact_address, ''),
            'Unknown'
        ) as contact_address

    from ranked_learners

    where row_number = 1

),

special_members as (

    select
        -1::bigint as learner_key,
        'Unknown'::text as learner_name,
        'Unknown'::text as national_id,
        'Unknown'::text as education_level,
        'Unknown'::text as phone_number,
        'Unknown'::text as contact_address

    union all

    select
        -2::bigint,
        'Not Applicable'::text,
        'Not Applicable'::text,
        'Not Applicable'::text,
        'Not Applicable'::text,
        'Not Applicable'::text

)

select *
from special_members

union all

select *
from learners