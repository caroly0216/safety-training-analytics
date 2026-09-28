with source as (

    select *
    from {{ source('raw', 'hazardous_chemical_management_training') }}

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
        ) as collection_status_raw,

        nullif(
            regexp_replace(
                btrim(replace(coordinator_name_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as coordinator_name,

        nullif(
            regexp_replace(
                btrim(replace(training_time_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as declared_class,

        nullif(
            btrim(replace(certificate_validity_raw, chr(160), ' ')),
            ''
        ) as certificate_validity_text,

        nullif(
            regexp_replace(
                replace(trainee_name_raw, chr(160), ' '),
                '[[:space:]]+',
                '',
                'g'
            ),
            ''
        ) as trainee_name,

        nullif(
            regexp_replace(
                btrim(replace(national_id_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as national_id,

        nullif(
            btrim(replace(education_level_raw, chr(160), ' ')),
            ''
        ) as education_level_raw,

        nullif(
            regexp_replace(
                replace(
                    btrim(replace(phone_number_raw, chr(160), ' ')),
                    chr(8237),
                    ''
                ),
                '[.]0$',
                ''
            ),
            ''
        ) as phone_number,

        nullif(
            regexp_replace(
                btrim(replace(contact_address_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as contact_address,

        nullif(
            btrim(replace(job_title_raw, chr(160), ' ')),
            ''
        ) as job_title_raw,

        nullif(
            btrim(
                replace(
                    initial_certificate_date_raw,
                    chr(160),
                    ' '
                )
            ),
            ''
        ) as initial_certificate_date_text,

        nullif(
            btrim(replace(operation_category_raw, chr(160), ' ')),
            ''
        ) as operation_category_raw,

        nullif(
            btrim(replace(training_type_raw, chr(160), ' ')),
            ''
        ) as training_type_raw,

        nullif(
            btrim(replace(company_name_raw, chr(160), ' ')),
            ''
        ) as company_name

    from source

),

typed as (

    select
        *,

        case
            when certificate_validity_text
                ~ '^[0-9]+([.]0)?$'
            then
                date '1899-12-30'
                + floor(
                    certificate_validity_text::numeric
                )::integer

            when certificate_validity_text
                ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
            then
                to_date(
                    certificate_validity_text,
                    'YYYY-MM-DD'
                )

            else null
        end as certificate_validity_date,

        case
            when initial_certificate_date_text
                ~ '^[0-9]+([.]0)?$'
            then
                date '1899-12-30'
                + floor(
                    initial_certificate_date_text::numeric
                )::integer

            when initial_certificate_date_text
                ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
            then
                to_date(
                    initial_certificate_date_text,
                    'YYYY-MM-DD'
                )

            else null
        end as initial_certificate_date

    from cleaned

),

final as (

    select
        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        case
            when amount_text is null then null
            else amount_text::numeric
        end as amount,

        collection_status_raw,
        coordinator_name,
        declared_class,
        certificate_validity_date,
        trainee_name,
        national_id,
        education_level_raw,
        phone_number,
        contact_address,
        job_title_raw,
        initial_certificate_date,
        operation_category_raw,
        training_type_raw,
        company_name

    from typed

)

select *
from final