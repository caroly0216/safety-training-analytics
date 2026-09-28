{{ config(materialized='table') }}

with coordinator_names as (

    select distinct
        coordinator_name

    from {{ ref('int_registration_standardized') }}

    where coordinator_name is not null
      and btrim(coordinator_name) <> ''
      and lower(btrim(coordinator_name)) not in (
          'unknown',
          'n/a',
          'not applicable'
      )
      and btrim(coordinator_name) <> '无'

),

coordinators as (

    select
        (
            'x'
            || substr(
                md5(coordinator_name),
                1,
                15
            )
        )::bit(60)::bigint as coordinator_key,

        coordinator_name

    from coordinator_names

),

special_members as (

    select
        -1::bigint as coordinator_key,
        'Unknown'::text as coordinator_name

    union all

    select
        -2::bigint,
        'Not Applicable'::text

)

select *
from special_members

union all

select *
from coordinators