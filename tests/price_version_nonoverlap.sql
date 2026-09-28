select
    earlier.price_key as earlier_price_key,
    later.price_key as later_price_key
from {{ ref('dim_price') }} as earlier
join {{ ref('dim_price') }} as later
 on earlier.registration_project_key = later.registration_project_key
 and earlier.training_stage = later.training_stage
 and earlier.fee_category = later.fee_category
 and earlier.price_key < later.price_key
 and earlier.effective_start_date <= later.effective_end_date
 and later.effective_start_date <= earlier.effective_end_date
where earlier.price_key > 0
  and later.price_key > 0
