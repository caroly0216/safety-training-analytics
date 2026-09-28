-- This assertion intentionally applies to the invented public demo dataset.
with summary as (
    select
        (select count(*) from {{ ref('fct_registration') }}) as registrations,
        (select count(*) from {{ ref('fct_payment') }}) as payments,
        (select sum(collected_amount) from {{ ref('fct_payment') }}) as collected,
        (select sum(agreed_amount) from {{ ref('fct_registration') }}
            where collection_status = 'Uncollected') as uncollected,
        (select count(*) from {{ ref('fct_learner_certificate') }}) as certificates,
        (select count(*) from {{ ref('fct_registration_status_change') }}) as changes
)
select * from summary
where registrations <> 13 or payments <> 7 or collected <> 3950
   or uncollected <> 2880 or certificates <> 7 or changes <> 1
