{{ config(materialized='table') }}

with company_names as (

    select distinct
        company_name

    from {{ ref('int_registration_standardized') }}

    where company_name is not null
      and btrim(company_name) <> ''
      and lower(btrim(company_name)) not in (
          'unknown',
          'n/a',
          'not applicable'
      )
      and btrim(company_name) <> '无'

),

companies as (

    select
        (
            'x'
            || substr(
                md5(company_names.company_name),
                1,
                15
            )
        )::bit(60)::bigint as company_key,

        company_names.company_name,

        coalesce(
            company_group.company_group_name,
            company_names.company_name
        ) as company_group_name,

        coalesce(
            location.province,
            'Unknown'
        ) as province,

        coalesce(
            location.city,
            'Unknown'
        ) as city

    from company_names

    left join {{ ref('company_location_mapping') }}
        as location
        on company_names.company_name
            = location.company_name

    left join {{ ref('company_group_mapping') }}
        as company_group
        on company_names.company_name
            = company_group.company_name

),

special_members as (

    select
        -1::bigint as company_key,
        'Unknown'::text as company_name,
        'Unknown'::text as company_group_name,
        'Unknown'::text as province,
        'Unknown'::text as city

    union all

    select
        -2::bigint,
        'Not Applicable'::text,
        'Not Applicable'::text,
        'Not Applicable'::text,
        'Not Applicable'::text

)

select *
from special_members

union all

select *
from companies
