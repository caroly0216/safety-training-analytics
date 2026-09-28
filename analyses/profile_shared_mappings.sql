with mapping_values as (

    -- Occupational health

    select
        'occupational_health' as source_model,
        field_group,
        raw_value

    from {{ ref('stg_occupational_health_training') }}

    cross join lateral (
        values
            ('training_type', training_type_raw),
            ('education_level', education_level_raw),
            ('company_name', company_name),
            ('job_role', job_title_raw),
            ('payment_status', collection_status_raw)
    ) as fields(field_group, raw_value)


    union all


    -- Special equipment

    select
        'special_equipment',
        field_group,
        raw_value

    from {{ ref('stg_special_equipment_training') }}

    cross join lateral (
        values
            ('training_type', training_type_raw),
            ('company_name', company_name),
            ('payment_status', collection_status_raw),
            ('operation', operation_item_code_raw)
    ) as fields(field_group, raw_value)


    union all


    -- Special operation

    select
        'special_operation',
        field_group,
        raw_value

    from {{ ref('stg_special_operation_training') }}

    cross join lateral (
        values
            ('training_type', training_type_raw),
            ('education_level', education_level_raw),
            ('company_name', company_name),
            ('payment_status', collection_status_raw),
            ('operation', operation_item_raw)
    ) as fields(field_group, raw_value)


    union all


    -- Online safety training

    select
        'safety_training_online',
        field_group,
        raw_value

    from {{ ref('stg_safety_training_certificate_summary') }}

    cross join lateral (
        values
            ('training_type', training_type_raw),
            ('education_level', education_level_raw),
            ('company_name', company_name),
            ('job_role', job_position_raw),
            ('payment_status', collection_status_raw),
            ('industry_category', industry_category_raw)
    ) as fields(field_group, raw_value)


    union all


    -- Offline safety training

    select
        'safety_training_offline',
        field_group,
        raw_value

    from {{ ref('stg_safety_training_offline_class') }}

    cross join lateral (
        values
            ('training_type', training_type_raw),
            ('education_level', education_level_raw),
            ('company_name', company_name),
            ('job_role', job_position_raw),
            ('payment_status', collection_status_raw),
            ('industry_category', industry_category_raw)
    ) as fields(field_group, raw_value)


    union all


    -- Hazardous chemical management

    select
        'hazardous_chemical_management',
        field_group,
        raw_value

    from {{ ref('stg_hazardous_chemical_management_training') }}

    cross join lateral (
        values
            ('training_type', training_type_raw),
            ('education_level', education_level_raw),
            ('company_name', company_name),
            ('job_role', job_title_raw),
            ('payment_status', collection_status_raw),
            ('operation', operation_category_raw)
    ) as fields(field_group, raw_value)

),

normalized as (

    select
        source_model,
        field_group,

        coalesce(
            nullif(
                btrim(replace(raw_value, chr(160), ' ')),
                ''
            ),
            '[NULL]'
        ) as raw_value

    from mapping_values

)

select
    field_group,
    raw_value,
    source_model,
    count(*) as row_count

from normalized

group by
    field_group,
    raw_value,
    source_model

order by
    field_group,
    raw_value,
    source_model;