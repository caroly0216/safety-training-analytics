with base as (

    select *
    from {{ ref('int_registration_base') }}

),

prepared as (

    select
        base.*,

        btrim(
            base.coordinator_name
        ) as coordinator_name_match_key,

        regexp_replace(
            btrim(base.collection_status_raw),
            '[.]0$',
            ''
        ) as payment_value,

        nullif(
            btrim(base.certificate_number),
            ''
        ) as certificate_number_value

    from base

),

mapped as (

    select
        prepared.*,

        coordinator_map.coordinator_name
            as coordinator_name_mapped,

        coordinator_map.salesperson_note
            as coordinator_mapping_note

    from prepared

    left join {{ ref('coordinator_name_mapping') }}
        as coordinator_map

        on prepared.training_source
            = coordinator_map.training_source

        and prepared.coordinator_name_match_key
            = btrim(
                coordinator_map.raw_coordinator_value
            )

),

standardized as (

    select
        mapped.*,

        coalesce(
            mapped.coordinator_name_mapped,
            mapped.coordinator_name
        ) as coordinator_name_standardized,

        case
            when mapped.collection_status_raw is null
                then 'Unknown'

            when mapped.collection_status_raw like '%未%'
                or mapped.collection_status_raw = '待交费用'
                then 'Uncollected'

            when mapped.payment_value
                ~ '^([0-9]{7}|[0-9]{12})$'
                then 'Collected'

            when mapped.collection_status_raw like '%已%'
                or mapped.collection_status_raw like '%收款%'
                or mapped.collection_status_raw like '%二维码%'
                then 'Collected'

            when mapped.collection_status_raw
                ~ '^[0-9]+([.][0-9]+)?$'
                then 'Collected'

            else 'Unknown'
        end as collection_status,

        case
            when mapped.payment_value
                ~ '^([0-9]{7}|[0-9]{12})$'
                then mapped.payment_value

            else null
        end as payment_reference_number,

        case
            when mapped.collection_status_raw
                    ~ '^[0-9]+([.][0-9]+)?$'

                 and mapped.payment_value
                    !~ '^([0-9]{7}|[0-9]{12})$'

                then mapped.collection_status_raw::numeric

            else mapped.amount
        end as amount_standardized,

        case
            when mapped.certificate_number_value is null
                then null

            when mapped.certificate_number_value
                ~ '^[0-9]+$'
                then mapped.certificate_number_value

            when mapped.certificate_number_value
                    ~ '^[A-Za-z0-9]+$'

                 and mapped.certificate_number_value
                    ~ '[A-Za-z]'

                 and mapped.certificate_number_value
                    ~ '[0-9]'

                then mapped.certificate_number_value

            else null
        end as certificate_number_standardized,

        case
            when mapped.certificate_number_value is not null

                 and not (
                     mapped.certificate_number_value
                         ~ '^[0-9]+$'

                     or (
                         mapped.certificate_number_value
                             ~ '^[A-Za-z0-9]+$'

                         and mapped.certificate_number_value
                             ~ '[A-Za-z]'

                         and mapped.certificate_number_value
                             ~ '[0-9]'
                     )
                 )

                then
                    'Invalid certificate number: '
                    || mapped.certificate_number_value

            else null
        end as certificate_number_note,

        case
            when mapped.collection_status_raw is null
                then null

            when mapped.collection_status_raw like '%未%'
                or mapped.collection_status_raw = '待交费用'
                then null

            when mapped.payment_value
                ~ '^([0-9]{7}|[0-9]{12})$'
                then null

            when mapped.collection_status_raw like '%已%'
                or mapped.collection_status_raw like '%收款%'
                or mapped.collection_status_raw like '%二维码%'
                then null

            when mapped.collection_status_raw
                ~ '^[0-9]+([.][0-9]+)?$'
                then null

            else mapped.collection_status_raw
        end as collection_status_note,

        case
            when mapped.initial_certificate_date is not null
             and mapped.certificate_expiry_date is not null
             and mapped.initial_certificate_date
                    > mapped.certificate_expiry_date
                then null

            else mapped.initial_certificate_date
        end as initial_certificate_date_standardized,

        case
            when mapped.initial_certificate_date is not null
             and mapped.certificate_expiry_date is not null
             and mapped.initial_certificate_date
                    > mapped.certificate_expiry_date
                then null

            else mapped.certificate_expiry_date
        end as certificate_expiry_date_standardized,

        case
            when mapped.initial_certificate_date is not null
             and mapped.certificate_expiry_date is not null
             and mapped.initial_certificate_date
                    > mapped.certificate_expiry_date

                then concat(
                    '证书日期异常：',
                    to_char(
                        mapped.initial_certificate_date,
                        'YYYY-MM-DD'
                    ),
                    ' 至 ',
                    to_char(
                        mapped.certificate_expiry_date,
                        'YYYY-MM-DD'
                    )
                )

            else null
        end as certificate_date_note,

        case
            when mapped.training_start_date is not null
             and mapped.training_end_date is not null
             and mapped.training_start_date
                    > mapped.training_end_date
                then null

            else mapped.training_start_date
        end as training_start_date_standardized,

        case
            when mapped.training_start_date is not null
             and mapped.training_end_date is not null
             and mapped.training_start_date
                    > mapped.training_end_date
                then null

            else mapped.training_end_date
        end as training_end_date_standardized,

        case
            when mapped.training_start_date is not null
             and mapped.training_end_date is not null
             and mapped.training_start_date
                    > mapped.training_end_date

                then concat(
                    '培训日期异常：',
                    to_char(
                        mapped.training_start_date,
                        'YYYY-MM-DD'
                    ),
                    ' 至 ',
                    to_char(
                        mapped.training_end_date,
                        'YYYY-MM-DD'
                    )
                )

            else null
        end as training_date_note

    from mapped

),

final as (

    select
        standardized.registration_id,
        standardized.training_source,

        standardized.raw_record_id,
        standardized.source_file_name,
        standardized.source_sheet_name,
        standardized.source_row_number,
        standardized.ingestion_timestamp,

        standardized.trainee_name,
        standardized.national_id,
        standardized.phone_number,

        standardized.education_level_raw,
        standardized.training_type_raw,

        standardized.company_name,
        standardized.job_title_raw,

        standardized.coordinator_name_standardized
            as coordinator_name,

        standardized.amount_standardized
            as amount,

        case
            when standardized.collection_status = 'Unknown'
                and coalesce(notes.salesperson_note, '') ~ '(取消|不算费用)'
                then 'Not Applicable'
            else standardized.collection_status
        end as collection_status,
        standardized.payment_reference_number,

        standardized.declared_class,

        standardized.certificate_number_standardized
            as certificate_number,

        standardized.contact_address,

        standardized.initial_certificate_date_standardized
            as initial_certificate_date,

        standardized.certificate_expiry_date_standardized
            as certificate_expiry_date,

        standardized.operation_category_raw,
        standardized.industry_category_raw,

        standardized.training_start_date_standardized
            as training_start_date,

        standardized.training_end_date_standardized
            as training_end_date,

        standardized.operation_item_code_raw,
        standardized.operation_item_raw,

        notes.salesperson_note

    from standardized

    left join lateral (

        select
            string_agg(
                note_value,
                '；'
                order by first_position
            ) as salesperson_note

        from (

            select
                note_value,
                min(note_position) as first_position

            from (
                values
                    (
                        1,
                        nullif(
                            btrim(
                                standardized.coordinator_note
                            ),
                            ''
                        )
                    ),
                    (
                        2,
                        nullif(
                            btrim(
                                standardized.coordinator_mapping_note
                            ),
                            ''
                        )
                    ),
                    (
                        3,
                        standardized.certificate_number_note
                    ),
                    (
                        4,
                        standardized.collection_status_note
                    ),
                    (
                        5,
                        standardized.certificate_date_note
                    ),
                    (
                        6,
                        standardized.training_date_note
                    )
            ) as note_values (
                note_position,
                note_value
            )

            where note_value is not null

            group by note_value

        ) as distinct_notes

    ) as notes on true

)

select *
from final
