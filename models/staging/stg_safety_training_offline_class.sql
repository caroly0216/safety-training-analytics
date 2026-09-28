with source as (

    select *
    from {{ source('raw', 'safety_training_offline_class') }}

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
                btrim(replace(class_title_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as first_class_title,

        nullif(
            btrim(replace(unnamed_a_raw, chr(160), ' ')),
            ''
        ) as amount_text,

        nullif(
            regexp_replace(
                btrim(replace(unnamed_b_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as unnamed_b_cleaned,

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
                btrim(replace(coordinator_name_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as coordinator_name,

        nullif(
            btrim(replace(collection_status_raw, chr(160), ' ')),
            ''
        ) as collection_status_raw,

        nullif(
            regexp_replace(
                btrim(replace(training_period_raw, chr(160), ' ')),
                '[\r\n[:space:]]',
                '',
                'g'
            ),
            ''
        ) as training_period_raw,

        nullif(
            regexp_replace(
                btrim(replace(exam_time_raw, chr(160), ' ')),
                '[\r\n]',
                '',
                'g'
            ),
            ''
        ) as exam_time_text

    from source

),

identified as (

    select
        *,

        case
            when trainee_name is null
                 and unnamed_b_cleaned is not null
            then 1
            else 0
        end as is_title_row

    from cleaned

),

filled_titles as (

    select
        *,

        max(
            case
                when is_title_row = 1
                then unnamed_b_cleaned
            end
        ) over (
            order by source_row_number
            rows between unbounded preceding
                and current row
        ) as embedded_class_title

    from identified

),

typed as (

    select
        *,

        case
            when training_period_raw
                ~ '^[0-9]{4}年[0-9]{1,2}月[0-9]{1,2}日[至—-][0-9]{1,2}月[0-9]{1,2}日?$'
            then make_date(
                substring(
                    training_period_raw
                    from '^([0-9]{4})年'
                )::integer,

                substring(
                    training_period_raw
                    from '^[0-9]{4}年([0-9]{1,2})月'
                )::integer,

                substring(
                    training_period_raw
                    from '^[0-9]{4}年[0-9]{1,2}月([0-9]{1,2})日'
                )::integer
            )

            else null
        end as training_start_date,

        case
            when training_period_raw
                ~ '^[0-9]{4}年[0-9]{1,2}月[0-9]{1,2}日[至—-][0-9]{1,2}月[0-9]{1,2}日?$'
            then make_date(
                substring(
                    training_period_raw
                    from '^([0-9]{4})年'
                )::integer,

                substring(
                    training_period_raw
                    from '[至—-]([0-9]{1,2})月'
                )::integer,

                substring(
                    training_period_raw
                    from '[至—-][0-9]{1,2}月([0-9]{1,2})日?$'
                )::integer
            )

            else null
        end as training_end_date

    from filled_titles

),

final as (

    select
        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        amount_text::numeric as amount,

        case
            when embedded_class_title is not null
                then embedded_class_title
            else first_class_title
        end as declared_class,

        unnamed_b_cleaned as certificate_number,
        trainee_name,
        national_id,
        phone_number,
        job_position_raw,
        education_level_raw,
        training_type_raw,
        company_name,
        industry_category_raw,
        coordinator_name,
        collection_status_raw,

        training_period_raw,
        training_start_date,
        training_end_date,

        case
            when exam_time_text ~ '^[0-9]+([.]0)?$'
            then to_char(
                date '1899-12-30'
                + floor(exam_time_text::numeric)::integer,
                'YYYY-MM-DD'
            )
            else exam_time_text
        end as exam_time_raw

    from typed

    where is_title_row = 0
      and trainee_name is not null

)

select *
from final