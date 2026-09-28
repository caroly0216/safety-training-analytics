{{ config(materialized='table') }}

with joined as (
    select
        registration.registration_id,
        registration.learner_key,
        registration.registration_project_key,
        registration.training_stage_key,
        registration.registration_status_key,
        source.collection_status,
        coalesce(
            training.estimated_training_completion_status,
            '培训日期为空无法判断'
        ) as estimated_training_completion_status,
        coalesce(training.training_start_date_key, -1)
            as training_start_date_key,
        coalesce(training.training_end_date_key, -1)
            as training_end_date_key,
        payment.collected_amount
    from {{ ref('fct_registration') }} as registration
    join {{ ref('int_registration_standardized') }} as source
        on registration.registration_id = source.registration_id
    left join {{ ref('fct_payment') }} as payment
        on registration.registration_id = payment.registration_id
    left join {{ ref('fct_training_execution') }} as training
        on registration.registration_id = training.registration_id
),

classified as (
    select
        joined.*,
        case
            when registration_status_key = 1 then '已完成'
            when registration_status_key = 2 then '异常'
            else '待核查'
        end as registration_step_status,
        case
            when collection_status = 'Collected' then '已完成'
            when collection_status = 'Uncollected' then '未完成'
            when collection_status = 'Not Applicable'
                and registration_status_key = 2 then '不适用'
            else '待核查'
        end as payment_step_status,
        case estimated_training_completion_status
            when '已完成' then '预计已完成'
            when '进行中' then '未完成'
            when '报名异常未参加' then '异常未参加'
            else '无法判断'
        end as training_step_status
    from joined
)

select
    registration_id,
    learner_key,
    registration_project_key,
    training_stage_key,
    to_char(current_date, 'YYYYMMDD')::integer as snapshot_as_of_date_key,
    registration_status_key,
    collection_status,
    estimated_training_completion_status,
    registration_step_status,
    payment_step_status,
    training_step_status,
    training_start_date_key,
    training_end_date_key,
    collected_amount,
    1::integer as registration_count,
    case when registration_step_status = '已完成' then 1 else 0 end
        as registration_completed_count,
    case when payment_step_status = '已完成' then 1 else 0 end
        as payment_completed_count,
    case when training_step_status = '预计已完成' then 1 else 0 end
        as training_estimated_completed_count
from classified
