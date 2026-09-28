-- ============================================================
-- Safety training offline class profile
-- Source sheet: 线下班次
-- ============================================================

with source_data as (

    select *
    from {{ source('raw', 'safety_training_offline_class') }}

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
            ('class_title_raw', class_title_raw),
            ('unnamed_a_raw', unnamed_a_raw),
            ('unnamed_b_raw', unnamed_b_raw),
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
            ('coordinator_name_raw', coordinator_name_raw),
            ('unit_price_raw', unit_price_raw),
            ('declared_class_raw', declared_class_raw),
            ('collection_status_raw', collection_status_raw),
            ('training_period_raw', training_period_raw),
            ('exam_time_raw', exam_time_raw)
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
            ('gender_raw', gender_raw),
            ('job_position_raw', job_position_raw),
            ('education_level_raw', education_level_raw),
            ('training_type_raw', training_type_raw),
            ('training_provider_raw', training_provider_raw),
            ('industry_category_raw', industry_category_raw),
            ('remarks_raw', remarks_raw),
            ('coordinator_name_raw', coordinator_name_raw),
            ('declared_class_raw', declared_class_raw),
            ('collection_status_raw', collection_status_raw)
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
        'phone_number_raw' as field_name,
        'Nonstandard 11-digit format' as observed_value,

        sum(
            case
                when nullif(
                    btrim(replace(phone_number_raw, chr(160), ' ')),
                    ''
                ) is not null
                and btrim(phone_number_raw) !~ '^1[0-9]{10}$'
                then 1
                else 0
            end
        ) as row_count

    from source_data

    union all

    select
        'score_raw',
        'Nonstandard numeric format',

        sum(
            case
                when nullif(
                    btrim(replace(score_raw, chr(160), ' ')),
                    ''
                ) is not null
                and btrim(score_raw) !~ '^[0-9]+([.][0-9]+)?$'
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
        'unit_price_raw',
        'Nonstandard numeric format',

        sum(
            case
                when nullif(
                    btrim(replace(unit_price_raw, chr(160), ' ')),
                    ''
                ) is not null
                and btrim(unit_price_raw)
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
        nullif(
            btrim(replace(field_value, chr(160), ' ')),
            ''
        ) as cleaned_value

    from source_data

    cross join lateral (
        values
            ('unnamed_a_raw', unnamed_a_raw),
            ('unnamed_b_raw', unnamed_b_raw),
            ('unnamed_e_raw', unnamed_e_raw)
    ) as unnamed_fields(field_name, field_value)

),

unnamed_patterns as (

    select
        field_name,

        case
            when cleaned_value is null
                then 'Blank'

            when upper(cleaned_value)
                ~ '^[0-9]{17}[0-9X]$'
                then '18-character ID pattern'

            when cleaned_value
                ~ '^1[0-9]{10}$'
                then '11-digit phone pattern'

            when cleaned_value
                ~ '^[0-9]{4}[-/.][0-9]{1,2}([-/\.][0-9]{1,2})?'
                then 'Date-like pattern'

            when cleaned_value
                ~ '^[0-9]+([.][0-9]+)?$'
                then 'Numeric pattern'

            else 'Text or mixed pattern'
        end as observed_value,

        count(*) as row_count

    from unnamed_values

    group by
        field_name,
        case
            when cleaned_value is null
                then 'Blank'

            when upper(cleaned_value)
                ~ '^[0-9]{17}[0-9X]$'
                then '18-character ID pattern'

            when cleaned_value
                ~ '^1[0-9]{10}$'
                then '11-digit phone pattern'

            when cleaned_value
                ~ '^[0-9]{4}[-/.][0-9]{1,2}([-/\.][0-9]{1,2})?'
                then 'Date-like pattern'

            when cleaned_value
                ~ '^[0-9]+([.][0-9]+)?$'
                then 'Numeric pattern'

            else 'Text or mixed pattern'
        end

),

unnamed_distinct_values as (

    select distinct
        field_name,
        cleaned_value

    from unnamed_values

    where cleaned_value is not null

),

unnamed_ranked_samples as (

    select
        field_name,
        cleaned_value,
        row_number() over (
            partition by field_name
            order by cleaned_value
        ) as sample_number

    from unnamed_distinct_values

),

duplicate_groups as (

    select
        count(*) as group_row_count

    from source_data

    group by
        class_title_raw,
        unnamed_a_raw,
        unnamed_b_raw,
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
        coordinator_name_raw,
        unit_price_raw,
        declared_class_raw,
        collection_status_raw,
        training_period_raw,
        exam_time_raw

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
        cleaned_value,
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