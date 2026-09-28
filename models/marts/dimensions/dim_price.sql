{{ config(materialized='table') }}

with raw_prices as (
    select
        price_key::bigint as price_key,
        registration_project_key::bigint as registration_project_key,
        certificate_name::text as certificate_name,
        industry::text as industry,
        project::text as project,
        subproject::text as subproject,
        training_type::text as training_type,
        training_stage::text as training_stage,
        fee_category::text as fee_category,
        nullif(nullif(nullif(market_price, 'Unknown'), 'N/A'), '')::numeric as market_price,
        case
            when market_price = 'N/A' then 'N/A'
            when market_price = 'Unknown' or market_price = '' then 'Unknown'
            else 'Quoted'
        end::text as price_status,
        effective_start_date::date as effective_start_date,
        effective_end_date::date as effective_end_date
    from {{ ref('price_mapping') }}
),

renewal_prices as (
    select
        raw_prices.*,
        max(market_price) filter (where training_stage = '换证') over (
            partition by registration_project_key, fee_category,
                effective_start_date, effective_end_date
        ) as replacement_market_price,
        max(market_price) filter (where training_stage = '复训') over (
            partition by registration_project_key, fee_category,
                effective_start_date, effective_end_date
        ) as refresher_market_price
    from raw_prices
),

mapped as (
    select
        price_key,
        registration_project_key,
        certificate_name,
        industry,
        project,
        subproject,
        training_type,
        training_stage,
        fee_category,
        case
            when certificate_name in ('特种设备', '特种作业')
                and fee_category = '培训费'
                and training_stage in ('复训', '换证')
            then coalesce(replacement_market_price, refresher_market_price)
            else market_price
        end as market_price,
        case
            when certificate_name in ('特种设备', '特种作业')
                and fee_category = '培训费'
                and training_stage in ('复训', '换证')
            then case
                when coalesce(replacement_market_price, refresher_market_price)
                    is not null then 'Quoted'
                else 'Unknown'
            end
            else price_status
        end as price_status,
        effective_start_date,
        effective_end_date
    from renewal_prices
),

special_members as (
    select
        member_key::bigint as price_key,
        member_key::bigint as registration_project_key,
        member_name::text as certificate_name,
        member_name::text as industry,
        member_name::text as project,
        member_name::text as subproject,
        member_name::text as training_type,
        member_name::text as training_stage,
        member_name::text as fee_category,
        null::numeric as market_price,
        member_name::text as price_status,
        date '1900-01-01' as effective_start_date,
        date '2099-12-31' as effective_end_date
    from (values (-1, 'Unknown'), (-2, 'Not Applicable'))
        as members(member_key, member_name)
)

select * from special_members
union all
select * from mapped
