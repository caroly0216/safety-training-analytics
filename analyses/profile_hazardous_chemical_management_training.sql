-- ============================================================
-- Hazardous chemical management training profile
-- Source: raw.hazardous_chemical_management_training
-- ============================================================

with source_data as (

    select *
    from {{ source('raw', 'hazardous_chemical_management_training') }}

),

field_values as (

    select
        field_name,
        nullif(
            btrim(replace(field_value, chr(160), ' ')),
            ''
        ) as cleaned_value

    from source_data

    cross join lateral (
        values
            ('amount_raw', amount_raw),
            ('collection_status_raw', collection_status_raw),
            ('coordinator_name_raw', coordinator_name_raw),
            ('training_time_raw', training_time_raw),
            ('certificate_validity_raw', certificate_validity_raw),
            ('sequence_number_raw', sequence_number_raw),
            ('written_report_number_raw', written_report_number_raw),
            ('trainee_name_raw', trainee_name_raw),
            ('gender_raw', gender_raw),
            ('birth_date_raw', birth_date_raw),
            ('national_id_raw', national_id_raw),
            ('education_level_raw', education_level_raw),
            ('phone_number_raw', phone_number_raw),
            ('contact_address_raw', contact_address_raw),
            ('job_title_raw', job_title_raw),
            ('professional_title_raw', professional_title_raw),
            ('initial_certificate_date_raw', initial_certificate_date_raw),
            ('operation_category_raw', operation_category_raw),
            ('operation_item_raw', operation_item_raw),
            ('training_type_raw', training_type_raw),
            ('training_provider_raw', training_provider_raw),
            ('training_days_raw', training_days_raw),
            ('exam_type_raw', exam_type_raw),
            ('practical_exam_score_raw', practical_exam_score_raw),
            ('company_name_raw', company_name_raw),
            ('company_nature_raw', company_nature_raw),
            ('enterprise_category_raw', enterprise_category_raw),
            ('company_region_raw', company_region_raw),
            ('invoice_type_raw', invoice_type_raw),
            ('invoice_company_name_raw', invoice_company_name_raw),
            ('invoice_tax_number_raw', invoice_tax_number_raw),
            ('remarks_raw', remarks_raw)
    ) as fields(field_name, field_value)

),

column_profile as (

    select
        field_name,

        sum(
            case when cleaned_value is null then 1 else 0 end
        ) as missing_rows,

        sum(
            case when cleaned_value is not null then 1 else 0 end
        ) as populated_rows,

        count(distinct cleaned_value) as distinct_values

    from field_values
    group by field_name

),

category_values as (

    select
        field_name,

        coalesce(
            nullif(
                btrim(replace(field_value, chr(160), ' ')),
                ''
            ),
            '[Blank]'
        ) as observed_value,

        count(*) as row_count

    from source_data

    cross join lateral (
        values
            ('collection_status_raw', collection_status_raw),
            ('gender_raw', gender_raw),
            ('education_level_raw', education_level_raw),
            ('job_title_raw', job_title_raw),
            ('professional_title_raw', professional_title_raw),
            ('operation_category_raw', operation_category_raw),
            ('operation_item_raw', operation_item_raw),
            ('training_type_raw', training_type_raw),
            ('training_provider_raw', training_provider_raw),
            ('exam_type_raw', exam_type_raw),
            ('company_nature_raw', company_nature_raw),
            ('enterprise_category_raw', enterprise_category_raw),
            ('company_region_raw', company_region_raw),
            ('invoice_type_raw', invoice_type_raw),
            ('remarks_raw', remarks_raw)
    ) as categories(field_name, field_value)

    group by
        field_name,
        coalesce(
            nullif(
                btrim(replace(field_value, chr(160), ' ')),
                ''
            ),
            '[Blank]'
        )

),

format_profile as (

    select
        'amount_raw' as field_name,
        'Nonstandard numeric format' as observed_value,

        sum(
            case
                when nullif(
                    btrim(replace(amount_raw, chr(160), ' ')),
                    ''
                ) is not null
                and btrim(amount_raw)
                    !~ '^[0-9]+([.][0-9]+)?$'
                then 1
                else 0
            end
        ) as row_count

    from source_data

    union all

    select
        'national_id_raw',
        'Nonstandard 18-character format',

        sum(
            case
                when nullif(
                    btrim(replace(national_id_raw, chr(160), ' ')),
                    ''
                ) is not null
                and upper(btrim(national_id_raw))
                    !~ '^[0-9]{17}[0-9X]$'
                then 1
                else 0
            end
        )

    from source_data

    union all

    select
        'phone_number_raw',
        'Nonstandard 11-digit format',

        sum(
            case
                when nullif(
                    btrim(replace(phone_number_raw, chr(160), ' ')),
                    ''
                ) is not null
                and btrim(phone_number_raw)
                    !~ '^1[0-9]{10}$'
                then 1
                else 0
            end
        )

    from source_data

    union all

    select
        'training_days_raw',
        'Nonstandard numeric format',

        sum(
            case
                when nullif(
                    btrim(replace(training_days_raw, chr(160), ' ')),
                    ''
                ) is not null
                and btrim(training_days_raw)
                    !~ '^[0-9]+([.][0-9]+)?$'
                then 1
                else 0
            end
        )

    from source_data

    union all

    select
        'practical_exam_score_raw',
        'Nonstandard numeric format',

        sum(
            case
                when nullif(
                    btrim(replace(practical_exam_score_raw, chr(160), ' ')),
                    ''
                ) is not null
                and btrim(practical_exam_score_raw)
                    !~ '^[0-9]+([.][0-9]+)?$'
                then 1
                else 0
            end
        )

    from source_data

),

duplicate_groups as (

    select
        count(*) as group_row_count

    from source_data

    group by
        amount_raw,
        collection_status_raw,
        coordinator_name_raw,
        training_time_raw,
        certificate_validity_raw,
        sequence_number_raw,
        written_report_number_raw,
        trainee_name_raw,
        gender_raw,
        birth_date_raw,
        national_id_raw,
        education_level_raw,
        phone_number_raw,
        contact_address_raw,
        job_title_raw,
        professional_title_raw,
        initial_certificate_date_raw,
        operation_category_raw,
        operation_item_raw,
        training_type_raw,
        training_provider_raw,
        training_days_raw,
        exam_type_raw,
        practical_exam_score_raw,
        company_name_raw,
        company_nature_raw,
        enterprise_category_raw,
        company_region_raw,
        invoice_type_raw,
        invoice_company_name_raw,
        invoice_tax_number_raw,
        remarks_raw

    having count(*) > 1

),

duplicate_profile as (

    select
        count(*) as duplicate_groups,
        coalesce(sum(group_row_count - 1), 0)
            as excess_duplicate_rows

    from duplicate_groups

),

profile_result as (

    select
        1 as section_order,
        'Dataset' as section,
        'all_columns' as field_name,
        'Total rows' as metric,
        null::text as observed_value,
        count(*)::bigint as row_count

    from source_data

    union all

    select
        2,
        'Completeness',
        field_name,
        'Populated rows',
        null,
        populated_rows

    from column_profile

    union all

    select
        2,
        'Completeness',
        field_name,
        'Missing rows',
        null,
        missing_rows

    from column_profile

    union all

    select
        3,
        'Cardinality',
        field_name,
        'Distinct nonblank values',
        null,
        distinct_values

    from column_profile

    union all

    select
        4,
        'Format',
        field_name,
        'Nonstandard rows',
        observed_value,
        row_count

    from format_profile

    union all

    select
        5,
        'Value distribution',
        field_name,
        'Observed value',
        observed_value,
        row_count

    from category_values

    union all

    select
        6,
        'Duplicates',
        'all_business_fields',
        'Duplicate groups',
        null,
        duplicate_groups

    from duplicate_profile

    union all

    select
        6,
        'Duplicates',
        'all_business_fields',
        'Excess duplicate rows',
        null,
        excess_duplicate_rows

    from duplicate_profile

)

select
    section,
    field_name,
    metric,
    observed_value,
    row_count

from profile_result

order by
    section_order,
    field_name,
    metric,
    row_count desc,
    observed_value;