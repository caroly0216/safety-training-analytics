{{ config(materialized='table') }}

with registrations as (
    select
        registration.*,
        case
            when coalesce(salesperson_note, '') ~ '(取消|迟到)' then 2
            else 1
        end as registration_status_key
    from {{ ref('int_registration_standardized') }}
        as registration
),

ordered_registrations as (
    select
        registration.*,
        lag(registration_id) over (
            partition by national_id, registration_project_mapping_id,
                training_source
            order by source_row_number, registration_id
        ) as previous_registration_id,
        lag(registration_status_key) over (
            partition by national_id, registration_project_mapping_id,
                training_source
            order by source_row_number, registration_id
        ) as previous_registration_status_key
    from registrations as registration
),

status_changes as (
    select
        previous.registration_id as original_registration_id,
        current_registration.registration_id as linked_new_registration_id,
        previous.national_id,
        previous.coordinator_name,
        current_registration.previous_registration_status_key
            as original_registration_status_key,
        current_registration.registration_status_key
            as new_registration_status_key,
        case
            when concat_ws(' ', previous.salesperson_note,
                current_registration.salesperson_note) ~ '迟到' then '迟到'
            when concat_ws(' ', previous.salesperson_note,
                current_registration.salesperson_note) ~ '改期' then '改期'
            else '取消'
        end as change_reason
    from ordered_registrations as current_registration
    join registrations as previous
        on current_registration.previous_registration_id
            = previous.registration_id
    where current_registration.previous_registration_status_key
        <> current_registration.registration_status_key
),

salesperson as (
    select salesperson_key
    from {{ ref('dim_salesperson') }}
    where salesperson_name = 'Example Salesperson'
)

select
    ('x' || substr(md5(original.original_registration_id || '|'
        || original.linked_new_registration_id), 1, 15))::bit(60)::bigint
        as registration_status_change_key,
    coalesce(learner.learner_key, -1) as learner_key,
    original.original_registration_id,
    original.original_registration_status_key,
    original.new_registration_status_key,
    coalesce(coordinator.coordinator_key, -1) as coordinator_key,
    coalesce(salesperson.salesperson_key, -1) as salesperson_key,
    original.change_reason,
    original.linked_new_registration_id

from status_changes as original
left join {{ ref('dim_learner') }} as learner
    on original.national_id = learner.national_id
left join {{ ref('dim_coordinator') }} as coordinator
    on original.coordinator_name = coordinator.coordinator_name
left join salesperson
    on true
