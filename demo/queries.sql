-- Run in safety_training_demo after a successful dbt build.
select collection_status, count(*) as registrations, sum(agreed_amount) as agreed_amount
from dbt_demo_marts.fct_registration
group by collection_status order by collection_status;

select company.company_group_name, sum(payment.collected_amount) as collected_amount
from dbt_demo_marts.fct_payment payment
join dbt_demo_marts.dim_company company
  on company.company_key = payment.learner_company_key
group by company.company_group_name;

select
  count(*) filter (where dates.full_date < current_date) as expired,
  count(*) filter (where dates.full_date between current_date and current_date + 90) as expiring_in_90_days,
  count(*) filter (where dates.full_date is null) as unknown_expiry
from dbt_demo_marts.fct_learner_certificate certificate
left join dbt_demo_marts.dim_date dates
  on dates.date_key = certificate.certificate_expiry_date_key;
