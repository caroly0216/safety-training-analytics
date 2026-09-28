with source as (

    select *
    from {{ source('raw', 'safety_training_certificate_summary') }}

),

cleaned as (

    select
        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

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
                btrim(replace(unnamed_e_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as national_id,

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
            btrim(replace(job_position_raw, chr(160), ' ')),
            ''
        ) as job_position_raw,

        nullif(
            btrim(replace(education_level_raw, chr(160), ' ')),
            ''
        ) as education_level_raw,

        nullif(
            btrim(replace(training_type_raw, chr(160), ' ')),
            ''
        ) as training_type_raw,

        nullif(
            btrim(replace(company_name_raw, chr(160), ' ')),
            ''
        ) as company_name,

        nullif(
            btrim(replace(industry_category_raw, chr(160), ' ')),
            ''
        ) as industry_category_raw,

        nullif(
            regexp_replace(
                btrim(replace(remarks_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as coordinator_text,

        nullif(
            btrim(replace(amount_raw, chr(160), ' ')),
            ''
        ) as amount_text,

        nullif(
            btrim(replace(declared_class_raw, chr(160), ' ')),
            ''
        ) as declared_class,

        nullif(
            btrim(replace(collection_status_raw, chr(160), ' ')),
            ''
        ) as collection_status_raw,

        nullif(
            regexp_replace(
                replace(
                    btrim(replace(training_period_raw, chr(160), ' ')),
                    '/',
                    '-'
                ),
                '[[:space:]]+',
                '',
                'g'
            ),
            ''
        ) as training_period_text,

        nullif(
            btrim(replace(unnamed_y_raw, chr(160), ' ')),
            ''
        ) as training_end_serial

    from source

),

parsed as (

    select
        *,

        nullif(
            btrim(
                regexp_replace(
                    coordinator_text,
                    '[（(].*$',
                    ''
                )
            ),
            ''
        ) as coordinator_name,

        case
            when coordinator_text ~ '[（(].*[）)]'
            then nullif(
                btrim(
                    regexp_replace(
                        coordinator_text,
                        '^.*[（(]([^）)]*)[）)].*$',
                        '\1'
                    )
                ),
                ''
            )
            else null
        end as coordinator_note

    from cleaned

),

typed as (

    select
        *,

        case
            when training_period_text
                ~ '^[0-9]+([.]0)?$'
            then
                date '1899-12-30'
                + floor(training_period_text::numeric)::integer

            when split_part(training_period_text, '至', 1)
                ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
            then
                to_date(
                    split_part(training_period_text, '至', 1),
                    'YYYY-MM-DD'
                )

            else null
        end as training_start_date,

        case
            when training_period_text like '%至%'
                 and split_part(training_period_text, '至', 2)
                     ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
            then
                to_date(
                    split_part(training_period_text, '至', 2),
                    'YYYY-MM-DD'
                )

            when training_end_serial
                ~ '^[0-9]+([.]0)?$'
            then
                date '1899-12-30'
                + floor(training_end_serial::numeric)::integer

            else null
        end as training_end_date

    from parsed

),

final as (

    select
        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        trainee_name,
        national_id,
        phone_number,
        job_position_raw,
        education_level_raw,
        training_type_raw,
        company_name,
        industry_category_raw,
        coordinator_name,
        coordinator_note,

        amount_text::numeric as amount,

        declared_class,
        collection_status_raw,
        training_start_date,
        training_end_date

    from typed

)

select *
from final