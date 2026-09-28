with source as (

    select *
    from {{ ref('int_registration_classified') }}

),

prepared as (

    select
        source.*,

        regexp_replace(
            btrim(
                replace(
                    source.education_level_raw,
                    chr(160),
                    ' '
                )
            ),
            '[[:space:]]+',
            '',
            'g'
        ) as education_level_match_key,

        regexp_replace(
            btrim(
                replace(
                    source.training_type_raw,
                    chr(160),
                    ' '
                )
            ),
            '[[:space:]]+',
            '',
            'g'
        ) as training_stage_match_key,

        regexp_replace(
            replace(
                replace(
                    btrim(
                        replace(
                            source.company_name,
                            chr(160),
                            ' '
                        )
                    ),
                    '（',
                    '('
                ),
                '）',
                ')'
            ),
            '[[:space:]]+',
            '',
            'g'
        ) as company_name_match_key

    from source

),

education_mapping as (

    select
        regexp_replace(
            btrim(
                replace(
                    raw_value,
                    chr(160),
                    ' '
                )
            ),
            '[[:space:]]+',
            '',
            'g'
        ) as education_level_match_key,

        standardized_value

    from {{ ref('education_level_mapping') }}

),

training_stage_mapping as (

    select
        regexp_replace(
            btrim(
                replace(
                    raw_value,
                    chr(160),
                    ' '
                )
            ),
            '[[:space:]]+',
            '',
            'g'
        ) as training_stage_match_key,

        standardized_value

    from {{ ref('training_type_mapping') }}

),

company_mapping as (

    select
        regexp_replace(
            replace(
                replace(
                    btrim(
                        replace(
                            raw_company_name,
                            chr(160),
                            ' '
                        )
                    ),
                    '（',
                    '('
                ),
                '）',
                ')'
            ),
            '[[:space:]]+',
            '',
            'g'
        ) as company_name_match_key,

        standardized_company_name

    from {{ ref('company_name_mapping') }}

),

mapped as (

    select
        prepared.*,

        case
            when prepared.education_level_raw is null
                or btrim(prepared.education_level_raw) = ''
                then 'Unknown'

            else education_mapping.standardized_value
        end as education_level,

        case
            when prepared.training_type_raw is null
                or btrim(prepared.training_type_raw) = ''
                then 'Unknown'

            else training_stage_mapping.standardized_value
        end as training_stage,

        regexp_replace(
            replace(
                replace(
                    coalesce(
                        company_mapping.standardized_company_name,
                        prepared.company_name
                    ),
                    '(',
                    '（'
                ),
                ')',
                '）'
            ),
            '[[:space:]]+',
            '',
            'g'
        ) as standardized_company_name

    from prepared

    left join education_mapping
        on prepared.education_level_match_key
            = education_mapping.education_level_match_key

    left join training_stage_mapping
        on prepared.training_stage_match_key
            = training_stage_mapping.training_stage_match_key

    left join company_mapping
        on prepared.company_name_match_key
            = company_mapping.company_name_match_key

),

final as (

    select
        registration_id,
        training_source,
        raw_record_id,

        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        trainee_name,
        national_id,
        phone_number,

        education_level,
        training_stage,

        standardized_company_name as company_name,

        job_title_raw,
        coordinator_name,

        amount,
        collection_status,
        payment_reference_number,

        declared_class,
        certificate_number,
        contact_address,

        initial_certificate_date,
        certificate_expiry_date,

        training_start_date,
        training_end_date,

        salesperson_note,

        registration_project_mapping_id,

        certificate_name,
        industry,
        project,
        subproject,
        training_category,
        project_code

    from mapped

)

select *
from final