with source as (

    select *
    from {{ source('raw', 'occupational_health_training') }}

),

cleaned as (

    select
        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        nullif(
            btrim(replace(amount_raw, chr(160), ' ')),
            ''
        ) as amount_text,

        nullif(
            btrim(replace(collection_status_raw, chr(160), ' ')),
            ''
        )::text as collection_status_raw,

        nullif(
            btrim(replace(coordinator_name_raw, chr(160), ' ')),
            ''
        ) as coordinator_name,

        nullif(
            btrim(
                regexp_replace(
                    replace(declared_class_raw, chr(160), ' '),
                    '^加入[[:space:]]*',
                    ''
                )
            ),
            ''
        ) as declared_class,

        nullif(
            btrim(replace(company_name_raw, chr(160), ' ')),
            ''
        ) as company_name,

        nullif(
            regexp_replace(
                replace(trainee_name_raw, chr(160), ' '),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as trainee_name,

        nullif(
            btrim(replace(job_title_raw, chr(160), ' ')),
            ''
        ) as job_title_raw,

        nullif(
            btrim(replace(education_level_raw, chr(160), ' ')),
            ''
        ) as education_level_raw,

        nullif(
            btrim(replace(certificate_number_raw, chr(160), ' ')),
            ''
        )::text as certificate_number,

        nullif(
            regexp_replace(
                btrim(replace(national_id_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        )::text as national_id,

        nullif(
            regexp_replace(
                btrim(replace(phone_number_raw, chr(160), ' ')),
                '[.]0$',
                ''
            ),
            ''
        )::text as phone_number,

        nullif(
            btrim(replace(training_type_raw, chr(160), ' ')),
            ''
        ) as training_type_raw

    from source

),

final as (

    select
        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        amount_text::numeric as amount,
        collection_status_raw,
        coordinator_name,
        declared_class,
        company_name,
        trainee_name,
        job_title_raw,
        education_level_raw,
        certificate_number,
        national_id,
        phone_number,
        training_type_raw

    from cleaned

)

select *
from final