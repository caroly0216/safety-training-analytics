with unioned as (

    -- 1. Hazardous chemical management
    select
        concat(
            'hazardous_chemical_management-',
            raw_record_id
        ) as registration_id,

        'hazardous_chemical_management'::text
            as training_source,

        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        trainee_name,
        national_id,
        phone_number,
        education_level_raw,
        training_type_raw,
        company_name,
        job_title_raw,
        coordinator_name,
        amount,
        collection_status_raw,
        declared_class,
        null::text as certificate_number,
        contact_address,

        initial_certificate_date,
        certificate_validity_date
            as certificate_expiry_date,

        operation_category_raw,
        null::text as industry_category_raw,
        null::text as coordinator_note,

        null::date as training_start_date,
        null::date as training_end_date,

        null::text as operation_item_code_raw,
        null::text as operation_item_raw

    from {{ ref('stg_hazardous_chemical_management_training') }}

    union all

    -- 2. Occupational health
    select
        concat(
            'occupational_health-',
            raw_record_id
        ) as registration_id,

        'occupational_health'::text
            as training_source,

        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        trainee_name,
        national_id,
        phone_number,
        education_level_raw,
        training_type_raw,
        company_name,
        job_title_raw,
        coordinator_name,
        amount,
        collection_status_raw,
        declared_class,
        certificate_number,
        null::text as contact_address,

        null::date as initial_certificate_date,
        null::date as certificate_expiry_date,

        null::text as operation_category_raw,
        null::text as industry_category_raw,
        null::text as coordinator_note,

        null::date as training_start_date,
        null::date as training_end_date,

        null::text as operation_item_code_raw,
        null::text as operation_item_raw

    from {{ ref('stg_occupational_health_training') }}

    union all

    -- 3. Safety training online
    select
        concat(
            'safety_training_online-',
            raw_record_id
        ) as registration_id,

        'safety_training_online'::text
            as training_source,

        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        trainee_name,
        national_id,
        phone_number,
        education_level_raw,
        training_type_raw,
        company_name,
        job_position_raw as job_title_raw,
        coordinator_name,
        amount,
        collection_status_raw,
        declared_class,
        null::text as certificate_number,
        null::text as contact_address,

        null::date as initial_certificate_date,
        null::date as certificate_expiry_date,

        null::text as operation_category_raw,
        industry_category_raw,
        coordinator_note,

        training_start_date,
        training_end_date,

        null::text as operation_item_code_raw,
        null::text as operation_item_raw

    from {{ ref('stg_safety_training_certificate_summary') }}

    union all

    -- 4. Safety training offline
    select
        concat(
            'safety_training_offline-',
            raw_record_id
        ) as registration_id,

        'safety_training_offline'::text
            as training_source,

        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        trainee_name,
        national_id,
        phone_number,
        education_level_raw,
        training_type_raw,
        company_name,
        job_position_raw as job_title_raw,
        coordinator_name,
        amount,
        collection_status_raw,
        declared_class,
        certificate_number,
        null::text as contact_address,

        null::date as initial_certificate_date,
        null::date as certificate_expiry_date,

        null::text as operation_category_raw,
        industry_category_raw,
        null::text as coordinator_note,

        training_start_date,
        training_end_date,

        null::text as operation_item_code_raw,
        null::text as operation_item_raw

    from {{ ref('stg_safety_training_offline_class') }}

    union all

    -- 5. Special equipment
    select
        concat(
            'special_equipment-',
            raw_record_id
        ) as registration_id,

        'special_equipment'::text
            as training_source,

        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        trainee_name,
        national_id,
        phone_number,
        null::text as education_level_raw,
        training_type_raw,
        company_name,
        null::text as job_title_raw,
        coordinator_name,
        amount,
        collection_status_raw,
        null::text as declared_class,
        null::text as certificate_number,
        null::text as contact_address,

        null::date as initial_certificate_date,

        case
            when btrim(certificate_expiry_month)
                ~ '^[0-9]{4}-[0-9]{1,2}$'
            then to_date(
                btrim(certificate_expiry_month) || '-01',
                'YYYY-MM-DD'
            )

            when btrim(certificate_expiry_month)
                ~ '^[0-9]{4}/[0-9]{1,2}$'
            then to_date(
                replace(
                    btrim(certificate_expiry_month),
                    '/',
                    '-'
                ) || '-01',
                'YYYY-MM-DD'
            )

            else null
        end as certificate_expiry_date,

        null::text as operation_category_raw,
        null::text as industry_category_raw,
        null::text as coordinator_note,

        null::date as training_start_date,
        null::date as training_end_date,

        operation_item_code_raw,
        null::text as operation_item_raw

    from {{ ref('stg_special_equipment_training') }}

    union all

    -- 6. Special operation
    select
        concat(
            'special_operation-',
            raw_record_id
        ) as registration_id,

        'special_operation'::text
            as training_source,

        raw_record_id,
        source_file_name,
        source_sheet_name,
        source_row_number,
        ingestion_timestamp,

        trainee_name,
        national_id,
        phone_number,
        education_level_raw,
        training_type_raw,
        company_name,
        null::text as job_title_raw,
        coordinator_name,
        amount,
        collection_status_raw,
        null::text as declared_class,
        null::text as certificate_number,
        contact_address,

        case
            when btrim(initial_certificate_date_raw)
                ~ '^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$'
            then to_date(
                btrim(initial_certificate_date_raw),
                'YYYY-MM-DD'
            )

            when btrim(initial_certificate_date_raw)
                ~ '^[0-9]{4}/[0-9]{1,2}/[0-9]{1,2}$'
            then to_date(
                replace(
                    btrim(initial_certificate_date_raw),
                    '/',
                    '-'
                ),
                'YYYY-MM-DD'
            )

            when btrim(initial_certificate_date_raw)
                ~ '^[0-9]+([.]0)?$'
            then
                date '1899-12-30'
                + floor(
                    btrim(initial_certificate_date_raw)::numeric
                )::integer

            else null
        end as initial_certificate_date,

        null::date as certificate_expiry_date,

        null::text as operation_category_raw,
        null::text as industry_category_raw,
        coordinator_note,

        training_start_date,
        training_end_date,

        null::text as operation_item_code_raw,
        operation_item_raw

    from {{ ref('stg_special_operation_training') }}

)

select *
from unioned