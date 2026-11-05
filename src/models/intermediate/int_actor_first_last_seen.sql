with actor_activity as (

    select
        actor_login,
        is_bot,
        event_date,
        event_count
    from {{ ref('stg_github__actor_activity') }}

),

actor_days as (
    select 
        actor_login,
        event_date,
        logical_or(is_bot)          as is_bot_suffix,
        sum(event_count)            as daily_events
    from actor_activity
    group by actor_login, event_date
),

summarised as (

    select
        actor_login,
        logical_or(is_bot_suffix)               as is_bot_suffix,
        min(event_date)                         as first_activity_date,
        max(event_date)                         as latest_activity_date,
        count(*)                                as active_days,
        sum(daily_events)                       as total_events,
        max(daily_events)                       as max_daily_events
    from actor_days
    group by actor_login

),

known_bots as (
    select
        actor_login
    from {{ ref('known_bots') }}
)

select 
    s.actor_login,
    (s.is_bot_suffix or k.actor_login is not null)                              as is_bot,
    s.max_daily_events >= {{ var('automation_actor_daily_events') }}            as is_suspected_automation,
    s.first_activity_date,
    s.latest_activity_date,
    s.active_days,
    s.total_events,
    s.max_daily_events
from summarised s
left join known_bots k
    on s.actor_login = k.actor_login