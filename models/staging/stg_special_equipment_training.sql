with source as (

    select *
    from {{ source('raw', 'special_equipment_training') }}

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
            btrim(replace(coordinator_name_raw, chr(160), ' ')),
            ''
        ) as coordinator_name,

        nullif(
            btrim(replace(training_type_raw, chr(160), ' ')),
            ''
        ) as training_type_raw,

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
            regexp_replace(
                btrim(replace(national_id_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as national_id,

        nullif(
            regexp_replace(
                btrim(replace(phone_number_raw, chr(160), ' ')),
                '[.]0$',
                ''
            ),
            ''
        ) as phone_number,

        nullif(
            btrim(replace(operation_item_code_raw, chr(160), ' ')),
            ''
        ) as operation_item_code_raw,

        nullif(
            btrim(
                replace(
                    certificate_expiry_date_raw,
                    chr(160),
                    ' '
                )
            ),
            ''
        ) as certificate_expiry_text,

        nullif(
            btrim(replace(company_name_raw, chr(160), ' ')),
            ''
        ) as company_name

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
        training_type_raw,
        trainee_name,
        national_id,
        phone_number,
        operation_item_code_raw,

        case
            when certificate_expiry_text
                ~ '^[0-9]{4}-(0?[1-9]|1[0-2])$'
            then to_char(
                to_date(certificate_expiry_text, 'YYYY-MM'),
                'YYYY-MM'
            )
            else null
        end as certificate_expiry_month,

        company_name

    from cleaned

)

select *
from final