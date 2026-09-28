with source as (

    select *
    from {{ ref('int_registration_enriched') }}

),

prepared as (

    select
        source.*,

        coalesce(
            source.training_start_date,
            source.initial_certificate_date,
            source.ingestion_timestamp::date
        ) as classification_date,

        regexp_replace(
            replace(
                replace(
                    replace(
                        replace(
                            btrim(source.operation_category_raw),
                            '—',
                            '-'
                        ),
                        '–',
                        '-'
                    ),
                    '－',
                    '-'
                ),
                '−',
                '-'
            ),
            '[[:space:]]+',
            '',
            'g'
        ) as operation_category_match_key,

        regexp_replace(
            replace(
                replace(
                    replace(
                        replace(
                            btrim(source.operation_item_raw),
                            '—',
                            '-'
                        ),
                        '–',
                        '-'
                    ),
                    '－',
                    '-'
                ),
                '−',
                '-'
            ),
            '[[:space:]]+',
            '',
            'g'
        ) as operation_item_match_key,

        upper(
            regexp_replace(
                btrim(source.operation_item_code_raw),
                '[.]0$',
                ''
            )
        ) as operation_item_code_match_key

    from source

),

derived as (

    select
        prepared.*,

        case
            when training_source
                = 'hazardous_chemical_management'
            then
                case
                    when operation_category_match_key
                        like '%安全管理人员'
                        then '安全管理人员'

                    when operation_category_match_key
                        like '%主要负责人'
                        then '主要负责人'

                    else null
                end

            when training_source = 'occupational_health'
                then '职业卫生'

            when training_source in (
                'safety_training_online',
                'safety_training_offline'
            )
                then '其他从业人员'

            when training_source = 'special_equipment'
                then '特种设备'

            when training_source = 'special_operation'
                then '特种作业'

            else null
        end as certificate_name_match,

        case
            when training_source
                = 'hazardous_chemical_management'
            then
                case
                    when operation_category_match_key
                        like '危险化学品经营单位%'
                        then '危化品（经营单位）'

                    when operation_category_match_key
                        like '危险化学品生产单位%'
                        then '危化品（生产单位）'

                    when operation_category_match_key
                        like '%安全管理人员'
                        then regexp_replace(
                            operation_category_match_key,
                            '安全管理人员$',
                            ''
                        )

                    when operation_category_match_key
                        like '%主要负责人'
                        then regexp_replace(
                            operation_category_match_key,
                            '主要负责人$',
                            ''
                        )

                    else split_part(
                        operation_category_match_key,
                        '-',
                        1
                    )
                end

            else 'N/A'
        end as industry_match,

        case
            when training_source = 'special_operation'
                then split_part(
                    operation_item_match_key,
                    '-',
                    1
                )

            else 'N/A'
        end as project_match,

        case
            when training_source = 'special_operation'
                then split_part(
                    operation_item_match_key,
                    '-',
                    2
                )

            else 'N/A'
        end as subproject_match,

        case
            when training_source in (
                'safety_training_online',
                'safety_training_offline'
            )
            then
                case
                    when job_title_raw like '%有限空间%'
                        then '有限空间'

                    when industry_category_raw
                        like '%危险化学品%'
                        or industry_category_raw
                            like '%危化%'
                        then '危险化学品'

                    else '其他'
                end

            else 'N/A'
        end as training_category_match

    from prepared

),

mapping as (

    select
        mapping_id::integer as mapping_id,
        training_source,
        certificate_name,
        industry,
        project,
        subproject,
        training_category,

        upper(
            regexp_replace(
                btrim(project_code),
                '[.]0$',
                ''
            )
        ) as project_code,

        effective_start_date::date
            as effective_start_date,

        effective_end_date::date
            as effective_end_date,

        regexp_replace(
            replace(
                replace(
                    certificate_name,
                    '（',
                    '('
                ),
                '）',
                ')'
            ),
            '[[:space:]、，,（）()]',
            '',
            'g'
        ) as certificate_name_match_key,

        regexp_replace(
            replace(
                replace(
                    industry,
                    '（',
                    '('
                ),
                '）',
                ')'
            ),
            '[[:space:]、，,（）()]',
            '',
            'g'
        ) as industry_match_key,

        regexp_replace(
            replace(
                replace(
                    project,
                    '（',
                    '('
                ),
                '）',
                ')'
            ),
            '[[:space:]、，,（）()]',
            '',
            'g'
        ) as project_match_key,

        regexp_replace(
            replace(
                replace(
                    subproject,
                    '（',
                    '('
                ),
                '）',
                ')'
            ),
            '[[:space:]、，,（）()]',
            '',
            'g'
        ) as subproject_match_key,

        regexp_replace(
            replace(
                replace(
                    training_category,
                    '（',
                    '('
                ),
                '）',
                ')'
            ),
            '[[:space:]、，,（）()]',
            '',
            'g'
        ) as training_category_match_key

    from {{ ref('registration_project_mapping') }}

),

matched as (

    select
        derived.*,

        mapping.mapping_id
            as registration_project_mapping_id,

        mapping.certificate_name,
        mapping.industry,
        mapping.project,
        mapping.subproject,
        mapping.training_category,
        mapping.project_code

    from derived

    left join mapping
        on derived.training_source
            = mapping.training_source

        and derived.classification_date
            >= mapping.effective_start_date

        and derived.classification_date
            < mapping.effective_end_date

        and (
            (
                derived.training_source
                    = 'hazardous_chemical_management'

                and regexp_replace(
                    replace(
                        replace(
                            derived.certificate_name_match,
                            '（',
                            '('
                        ),
                        '）',
                        ')'
                    ),
                    '[[:space:]、，,（）()]',
                    '',
                    'g'
                )
                    = mapping.certificate_name_match_key

                and regexp_replace(
                    replace(
                        replace(
                            derived.industry_match,
                            '（',
                            '('
                        ),
                        '）',
                        ')'
                    ),
                    '[[:space:]、，,（）()]',
                    '',
                    'g'
                )
                    = mapping.industry_match_key
            )

            or derived.training_source
                = 'occupational_health'

            or (
                derived.training_source in (
                    'safety_training_online',
                    'safety_training_offline'
                )

                and regexp_replace(
                    replace(
                        replace(
                            derived.training_category_match,
                            '（',
                            '('
                        ),
                        '）',
                        ')'
                    ),
                    '[[:space:]、，,（）()]',
                    '',
                    'g'
                )
                    = mapping.training_category_match_key
            )

            or (
                derived.training_source
                    = 'special_equipment'

                and derived.operation_item_code_match_key
                    = mapping.project_code
            )

            or (
                derived.training_source
                    = 'special_operation'

                and regexp_replace(
                    replace(
                        replace(
                            derived.project_match,
                            '（',
                            '('
                        ),
                        '）',
                        ')'
                    ),
                    '[[:space:]、，,（）()]',
                    '',
                    'g'
                )
                    = mapping.project_match_key

                and regexp_replace(
                    replace(
                        replace(
                            derived.subproject_match,
                            '（',
                            '('
                        ),
                        '）',
                        ')'
                    ),
                    '[[:space:]、，,（）()]',
                    '',
                    'g'
                )
                    = mapping.subproject_match_key
            )
        )

),

final as (

    select
        registration_id,
        training_source,
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
        collection_status,
        payment_reference_number,

        declared_class,
        certificate_number,
        contact_address,

        initial_certificate_date,
        certificate_expiry_date,

        training_start_date,
        training_end_date,

        salesperson_note,

        registration_project_mapping_id,

        certificate_name,
        industry,
        project,
        subproject,
        training_category,
        project_code

    from matched

)

select *
from final