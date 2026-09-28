with source as (

    select *
    from {{ source('raw', 'special_operation_training') }}

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
                '[[:space:]]+00:00:00$',
                ''
            ),
            ''
        ) as training_time_raw,

        nullif(
            btrim(replace(amount_raw, chr(160), ' ')),
            ''
        ) as amount_text,

        nullif(
            btrim(replace(collection_notes_raw, chr(160), ' ')),
            ''
        ) as collection_status_raw,

        nullif(
            regexp_replace(
                btrim(replace(trainee_name_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as trainee_name,

        nullif(
            btrim(replace(gender_raw, chr(160), ' ')),
            ''
        ) as gender,

        nullif(
            btrim(replace(birth_date_raw, chr(160), ' ')),
            ''
        ) as birth_date_raw,

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
                btrim(replace(phone_number_raw, chr(160), ' ')),
                '[.]0$',
                ''
            ),
            ''
        ) as phone_number,

        nullif(
            btrim(replace(contact_address_raw, chr(160), ' ')),
            ''
        ) as contact_address,

        nullif(
            btrim(replace(operation_item_raw, chr(160), ' ')),
            ''
        ) as operation_item_raw,

        nullif(
            btrim(replace(training_type_raw, chr(160), ' ')),
            ''
        ) as training_type_raw,

        nullif(
            btrim(
                replace(
                    initial_certificate_date_raw,
                    chr(160),
                    ' '
                )
            ),
            ''
        ) as initial_certificate_date_raw,

        nullif(
            btrim(replace(company_name_raw, chr(160), ' ')),
            ''
        ) as company_name

    from source

),

parsed as (

    select
        *,

        case
            -- Complete ISO date, for example 2026-01-28
            when training_time_raw
                ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
            then to_date(
                training_time_raw,
                'YYYY-MM-DD'
            )

            -- Chinese month and day, with optional text
            when training_time_raw
                ~ '[0-9]{1,2}月[0-9]{1,2}'
            then make_date(
                2026,

                substring(
                    training_time_raw
                    from '([0-9]{1,2})月'
                )::integer,

                substring(
                    training_time_raw
                    from '[0-9]{1,2}月([0-9]{1,2})'
                )::integer
            )

            else null
        end as training_start_date,

        case
            -- Range such as 3月7日-3月13日
            when training_time_raw
                ~ '[0-9]{1,2}月[0-9]{1,2}日?[至—-][0-9]{1,2}月[0-9]{1,2}'
            then make_date(
                2026,

                substring(
                    training_time_raw
                    from '[至—-]([0-9]{1,2})月'
                )::integer,

                substring(
                    training_time_raw
                    from '[至—-][0-9]{1,2}月([0-9]{1,2})'
                )::integer
            )

            -- Range such as 7月11-7-25
            when training_time_raw
                ~ '[0-9]{1,2}月[0-9]{1,2}-[0-9]{1,2}-[0-9]{1,2}'
            then make_date(
                2026,

                substring(
                    training_time_raw
                    from '-([0-9]{1,2})-[0-9]{1,2}'
                )::integer,

                substring(
                    training_time_raw
                    from '-[0-9]{1,2}-([0-9]{1,2})'
                )::integer
            )

            else null
        end as training_end_date,

        nullif(
            btrim(
                regexp_replace(
                    regexp_replace(
                        training_time_raw,

                        '[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}'
                        ||
                        '|[0-9]{1,2}月[0-9]{1,2}日?'
                        ||
                        '(-[0-9]{1,2}-[0-9]{1,2}'
                        ||
                        '|[至—-][0-9]{1,2}月[0-9]{1,2}日?)?',

                        '',
                        'g'
                    ),
                    '[[:space:]]+',
                    '',
                    'g'
                )
            ),
            ''
        ) as coordinator_note

    from cleaned

),

final as (

    select
        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        coordinator_name,
        training_time_raw,
        training_start_date,
        training_end_date,
        coordinator_note,

        case
            when amount_text is null
                then null
            else amount_text::numeric
        end as amount,

        collection_status_raw,
        trainee_name,
        gender,
        birth_date_raw,
        national_id,
        education_level_raw,
        phone_number,
        contact_address,
        operation_item_raw,
        training_type_raw,
        initial_certificate_date_raw,
        company_name

    from parsed

)

select *
from final