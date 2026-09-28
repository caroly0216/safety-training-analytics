-- ============================================================
-- Occupational health raw data profile
-- Source: raw.occupational_health_training
-- ============================================================


-- 1. Row count and column completeness
select
    count(*) as total_rows,

    count(nullif(btrim(amount_raw), ''))
        as populated_amount,

    count(nullif(btrim(collection_status_raw), ''))
        as populated_collection_status,

    count(nullif(btrim(coordinator_name_raw), ''))
        as populated_coordinator,

    count(nullif(btrim(declared_class_raw), ''))
        as populated_declared_class,

    count(nullif(btrim(company_name_raw), ''))
        as populated_company,

    count(nullif(btrim(trainee_name_raw), ''))
        as populated_trainee,

    count(nullif(btrim(training_date_raw), ''))
        as populated_training_date,

    count(nullif(btrim(gender_raw), ''))
        as populated_gender,

    count(nullif(btrim(job_title_raw), ''))
        as populated_job_title,

    count(nullif(btrim(education_level_raw), ''))
        as populated_education_level,

    count(nullif(btrim(assessment_result_raw), ''))
        as populated_assessment_result,

    count(nullif(btrim(certificate_number_raw), ''))
        as populated_certificate_number,

    count(nullif(btrim(national_id_raw), ''))
        as populated_national_id,

    count(nullif(btrim(phone_number_raw), ''))
        as populated_phone_number,

    count(nullif(btrim(training_type_raw), ''))
        as populated_training_type

from {{ source('raw', 'occupational_health_training') }};


-- 2. Basic format profiling
-- These are anomaly candidates, not automatic claims that the data is invalid.
select
    count(*) as total_rows,

    sum(
        case
            when nullif(btrim(amount_raw), '') is not null
             and btrim(amount_raw) !~ '^[0-9]+([.][0-9]+)?$'
                then 1
            else 0
        end
    ) as nonstandard_amount_format,

    sum(
        case
            when nullif(btrim(national_id_raw), '') is not null
             and btrim(national_id_raw) !~ '^[0-9]{17}[0-9Xx]$'
                then 1
            else 0
        end
    ) as nonstandard_national_id_format,

    sum(
        case
            when nullif(btrim(phone_number_raw), '') is not null
             and btrim(phone_number_raw) !~ '^[0-9]{11}$'
                then 1
            else 0
        end
    ) as nonstandard_phone_format,

    sum(
        case
            when nullif(btrim(training_date_raw), '') is not null
             and btrim(training_date_raw)
                 !~ '^[0-9]{4}[-/.年][0-9]{1,2}[-/.月][0-9]{1,2}日?$'
                then 1
            else 0
        end
    ) as nonstandard_training_date_format

from {{ source('raw', 'occupational_health_training') }};


-- 3. Value distributions for categorical fields
with categorical_values as (

    select
        'collection_status_raw' as field_name,
        collection_status_raw as raw_value
    from {{ source('raw', 'occupational_health_training') }}

    union all

    select
        'gender_raw',
        gender_raw
    from {{ source('raw', 'occupational_health_training') }}

    union all

    select
        'job_title_raw',
        job_title_raw
    from {{ source('raw', 'occupational_health_training') }}

    union all

    select
        'education_level_raw',
        education_level_raw
    from {{ source('raw', 'occupational_health_training') }}

    union all

    select
        'assessment_result_raw',
        assessment_result_raw
    from {{ source('raw', 'occupational_health_training') }}

    union all

    select
        'training_type_raw',
        training_type_raw
    from {{ source('raw', 'occupational_health_training') }}

)

select
    field_name,

    case
        when nullif(btrim(raw_value), '') is null
            then '<NULL_OR_BLANK>'
        else btrim(raw_value)
    end as raw_value,

    count(*) as row_count

from categorical_values

group by
    field_name,
    case
        when nullif(btrim(raw_value), '') is null
            then '<NULL_OR_BLANK>'
        else btrim(raw_value)
    end

order by
    field_name,
    row_count desc,
    raw_value;


-- 4. Exact duplicate profiling
with duplicate_groups as (

    select
        amount_raw,
        collection_status_raw,
        coordinator_name_raw,
        declared_class_raw,
        company_name_raw,
        trainee_name_raw,
        training_date_raw,
        gender_raw,
        job_title_raw,
        education_level_raw,
        assessment_result_raw,
        certificate_number_raw,
        national_id_raw,
        phone_number_raw,
        training_type_raw,
        count(*) as group_row_count

    from {{ source('raw', 'occupational_health_training') }}

    group by
        amount_raw,
        collection_status_raw,
        coordinator_name_raw,
        declared_class_raw,
        company_name_raw,
        trainee_name_raw,
        training_date_raw,
        gender_raw,
        job_title_raw,
        education_level_raw,
        assessment_result_raw,
        certificate_number_raw,
        national_id_raw,
        phone_number_raw,
        training_type_raw

)

select
    sum(
        case
            when group_row_count > 1 then 1
            else 0
        end
    ) as duplicate_groups,

    sum(
        case
            when group_row_count > 1 then group_row_count - 1
            else 0
        end
    ) as excess_duplicate_rows

from duplicate_groups;