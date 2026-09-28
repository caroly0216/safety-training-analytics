-- ============================================================
-- Special equipment training raw data profile
-- One query, one normalized result table
-- ============================================================

with source_data as (

    select *
    from {{ source('raw', 'special_equipment_training') }}

),

field_values as (

    select
        field_name,
        field_value

    from source_data

    cross join lateral (
        values
            ('amount_raw', amount_raw),
            ('collection_status_raw', collection_status_raw),
            ('coordinator_name_raw', coordinator_name_raw),
            ('declared_class_raw', declared_class_raw),
            ('training_type_raw', training_type_raw),
            ('trainee_name_raw', trainee_name_raw),
            ('national_id_raw', national_id_raw),
            ('phone_number_raw', phone_number_raw),
            ('operation_item_code_raw', operation_item_code_raw),
            ('certificate_expiry_date_raw', certificate_expiry_date_raw),
            ('company_name_raw', company_name_raw),
            ('session_end_date_raw', session_end_date_raw),
            ('sub_organization_raw', sub_organization_raw),
            ('payment_status_raw', payment_status_raw),
            ('learning_card_type_code_raw', learning_card_type_code_raw)
    ) as fields(field_name, field_value)

),

column_profile as (

    select
        field_name,
        count(*) as total_rows,

        sum(
            case
                when nullif(btrim(field_value), '') is null then 1
                else 0
            end
        ) as missing_rows,

        sum(
            case
                when nullif(btrim(field_value), '') is not null then 1
                else 0
            end
        ) as populated_rows,

        count(
            distinct nullif(btrim(field_value), '')
        ) as distinct_values

    from field_values
    group by field_name

),

category_values as (

    select
        field_name,
        coalesce(nullif(btrim(field_value), ''), '[Blank]') as observed_value,
        count(*) as row_count

    from source_data

    cross join lateral (
        values
            ('collection_status_raw', collection_status_raw),
            ('declared_class_raw', declared_class_raw),
            ('training_type_raw', training_type_raw),
            ('operation_item_code_raw', operation_item_code_raw),
            ('certificate_expiry_date_raw', certificate_expiry_date_raw),
            ('session_end_date_raw', session_end_date_raw),
            ('sub_organization_raw', sub_organization_raw),
            ('payment_status_raw', payment_status_raw),
            ('learning_card_type_code_raw', learning_card_type_code_raw)
    ) as categories(field_name, field_value)

    group by
        field_name,
        coalesce(nullif(btrim(field_value), ''), '[Blank]')

),

format_profile as (

    select
        'amount_raw' as field_name,
        'Nonstandard format' as observed_value,
        sum(
            case
                when nullif(btrim(amount_raw), '') is not null
                    and btrim(amount_raw) !~ '^[0-9]+([.][0-9]+)?$'
                then 1
                else 0
            end
        ) as row_count

    from source_data

    union all

    select
        'national_id_raw',
        'Nonstandard format',
        sum(
            case
                when nullif(btrim(national_id_raw), '') is not null
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
        'Nonstandard format',
        sum(
            case
                when nullif(btrim(phone_number_raw), '') is not null
                    and btrim(phone_number_raw) !~ '^1[0-9]{10}$'
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
        declared_class_raw,
        training_type_raw,
        trainee_name_raw,
        national_id_raw,
        phone_number_raw,
        operation_item_code_raw,
        certificate_expiry_date_raw,
        company_name_raw,
        session_end_date_raw,
        sub_organization_raw,
        payment_status_raw,
        learning_card_type_code_raw

    having count(*) > 1

),

duplicate_profile as (

    select
        count(*) as duplicate_groups,
        coalesce(sum(group_row_count - 1), 0) as excess_duplicate_rows

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