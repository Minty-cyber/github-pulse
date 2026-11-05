with actor_activity as (

    select
        actor_login,
        is_bot,
        event_date
    from {{ ref('stg_github__actor_activity') }}

),

summarised as (

    select
        actor_login,
        logical_or(is_bot)    as is_bot,
        min(event_date)       as first_activity_date,
        max(event_date)       as last_activity_date
    from actor_activity
    group by actor_login

)

select * from summarised