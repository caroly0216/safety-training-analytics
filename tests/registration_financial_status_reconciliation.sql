with registrations as (
    select
        count(*) filter (where collection_status = 'Collected') as collected_count,
        count(*) filter (
            where collection_status in ('Collected', 'Uncollected')
              and agreed_amount is null
        ) as missing_agreed_amount_count,
        sum(agreed_amount) filter (
            where collection_status = 'Collected'
        ) as collected_amount
    from {{ ref('fct_registration') }}
),

payments as (
    select
        count(*) as payment_count,
        sum(collected_amount) as collected_amount
    from {{ ref('fct_payment') }}
)

select registrations.*
from registrations
cross join payments
where registrations.collected_count <> payments.payment_count
   or registrations.missing_agreed_amount_count <> 0
   or registrations.collected_amount is distinct from payments.collected_amount
