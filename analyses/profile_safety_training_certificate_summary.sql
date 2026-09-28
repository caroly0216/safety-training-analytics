-- ============================================================
-- Safety training certificate summary profile
-- Source sheet: 线上班次
-- ============================================================

with source_data as (

    select *
    from {{ source('raw', 'safety_training_certificate_summary') }}

),

field_values as (

    select
        field_name,
        field_value

    from source_data

    cross join lateral (
        values
            ('sequence_number_raw', sequence_number_raw),
            ('certificate_number_raw', certificate_number_raw),
            ('trainee_name_raw', trainee_name_raw),
            ('gender_raw', gender_raw),
            ('unnamed_e_raw', unnamed_e_raw),
            ('birth_date_raw', birth_date_raw),
            ('phone_number_raw', phone_number_raw),
            ('job_position_raw', job_position_raw),
            ('education_level_raw', education_level_raw),
            ('score_raw', score_raw),
            ('training_type_raw', training_type_raw),
            ('initial_certificate_date_raw', initial_certificate_date_raw),
            ('validity_start_date_raw', validity_start_date_raw),
            ('validity_end_date_raw', validity_end_date_raw),
            ('retraining_date_raw', retraining_date_raw),
            ('training_provider_raw', training_provider_raw),
            ('training_days_raw', training_days_raw),
            ('company_name_raw', company_name_raw),
            ('industry_category_raw', industry_category_raw),
            ('remarks_raw', remarks_raw),
            ('amount_raw', amount_raw),
            ('declared_class_raw', declared_class_raw),
            ('collection_status_raw', collection_status_raw),
            ('training_period_raw', training_period_raw),
            ('unnamed_y_raw', unnamed_y_raw),
            ('unnamed_z_raw', unnamed_z_raw)
    ) as fields(field_name, field_value)

),

column_profile as (

    select
        field_name,

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
        coalesce(
            nullif(btrim(field_value), ''),
            '[Blank]'
        ) as observed_value,
        count(*) as row_count

    from source_data

    cross join lateral (
        values
            ('gender_raw', gender_raw),
            ('job_position_raw', job_position_raw),
            ('education_level_raw', education_level_raw),
            ('training_type_raw', training_type_raw),
            ('training_provider_raw', training_provider_raw),
            ('industry_category_raw', industry_category_raw),
            ('remarks_raw', remarks_raw),
            ('declared_class_raw', declared_class_raw),
            ('collection_status_raw', collection_status_raw)
    ) as categories(field_name, field_value)

    group by
        field_name,
        coalesce(
            nullif(btrim(field_value), ''),
            '[Blank]'
        )

),

format_profile as (

    select
        'amount_raw' as field_name,
        'Nonstandard numeric format' as observed_value,

        sum(
            case
                when nullif(btrim(amount_raw), '') is not null
                     and btrim(amount_raw)
                         !~ '^[0-9]+([.][0-9]+)?$'
                then 1
                else 0
            end
        ) as row_count

    from source_data

    union all

    select
        'phone_number_raw',
        'Nonstandard 11-digit format',

        sum(
            case
                when nullif(btrim(phone_number_raw), '') is not null
                     and btrim(phone_number_raw)
                         !~ '^1[0-9]{10}$'
                then 1
                else 0
            end
        )

    from source_data

    union all

    select
        'score_raw',
        'Nonstandard numeric format',

        sum(
            case
                when nullif(btrim(score_raw), '') is not null
                     and btrim(score_raw)
                         !~ '^[0-9]+([.][0-9]+)?$'
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
                when nullif(btrim(training_days_raw), '') is not null
                     and btrim(training_days_raw)
                         !~ '^[0-9]+([.][0-9]+)?$'
                then 1
                else 0
            end
        )

    from source_data

),

unnamed_values as (

    select
        field_name,
        field_value

    from source_data

    cross join lateral (
        values
            ('unnamed_e_raw', unnamed_e_raw),
            ('unnamed_y_raw', unnamed_y_raw),
            ('unnamed_z_raw', unnamed_z_raw)
    ) as unnamed_fields(field_name, field_value)

),

unnamed_patterns as (

    select
        field_name,

        case
            when nullif(btrim(field_value), '') is null
                then 'Blank'

            when upper(btrim(field_value))
                ~ '^[0-9]{17}[0-9X]$'
                then '18-character ID pattern'

            when btrim(field_value)
                ~ '^1[0-9]{10}$'
                then '11-digit phone pattern'

            when btrim(field_value)
                ~ '^[0-9]{4}[-/.][0-9]{1,2}([-/\.][0-9]{1,2})?'
                then 'Date-like pattern'

            when btrim(field_value)
                ~ '^[0-9]+([.][0-9]+)?$'
                then 'Numeric pattern'

            else 'Text or mixed pattern'
        end as observed_value,

        count(*) as row_count

    from unnamed_values

    group by
        field_name,
        case
            when nullif(btrim(field_value), '') is null
                then 'Blank'

            when upper(btrim(field_value))
                ~ '^[0-9]{17}[0-9X]$'
                then '18-character ID pattern'

            when btrim(field_value)
                ~ '^1[0-9]{10}$'
                then '11-digit phone pattern'

            when btrim(field_value)
                ~ '^[0-9]{4}[-/.][0-9]{1,2}([-/\.][0-9]{1,2})?'
                then 'Date-like pattern'

            when btrim(field_value)
                ~ '^[0-9]+([.][0-9]+)?$'
                then 'Numeric pattern'

            else 'Text or mixed pattern'
        end

),

unnamed_distinct_values as (

    select distinct
        field_name,
        btrim(field_value) as field_value

    from unnamed_values

    where nullif(btrim(field_value), '') is not null

),

unnamed_ranked_samples as (

    select
        field_name,
        field_value,
        row_number() over (
            partition by field_name
            order by field_value
        ) as sample_number

    from unnamed_distinct_values

),

duplicate_groups as (

    select
        count(*) as group_row_count

    from source_data

    group by
        sequence_number_raw,
        certificate_number_raw,
        trainee_name_raw,
        gender_raw,
        unnamed_e_raw,
        birth_date_raw,
        phone_number_raw,
        job_position_raw,
        education_level_raw,
        score_raw,
        training_type_raw,
        initial_certificate_date_raw,
        validity_start_date_raw,
        validity_end_date_raw,
        retraining_date_raw,
        training_provider_raw,
        training_days_raw,
        company_name_raw,
        industry_category_raw,
        remarks_raw,
        amount_raw,
        declared_class_raw,
        collection_status_raw,
        training_period_raw,
        unnamed_y_raw,
        unnamed_z_raw

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
        'Unnamed field pattern',
        field_name,
        'Detected pattern',
        observed_value,
        row_count

    from unnamed_patterns

    union all

    select
        7,
        'Unnamed field sample',
        field_name,
        'Sample value',
        field_value,
        1::bigint

    from unnamed_ranked_samples
    where sample_number <= 10

    union all

    select
        8,
        'Duplicates',
        'all_business_fields',
        'Duplicate groups',
        null,
        duplicate_groups

    from duplicate_profile

    union all

    select
        8,
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