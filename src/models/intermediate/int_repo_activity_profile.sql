with repo_activity as (

    select
        repo_id,
        date_trunc(event_date, month)   as activity_month,
        event_type,
        is_bot,
        event_count
    from {{ ref('stg_github__repo_activity') }}

),

repo_month_types as (

    select
        repo_id,
        activity_month,
        event_type,
        sum(event_count)                            as events,
        sum(if(is_bot, event_count, 0))             as bot_events
    from repo_activity
    group by repo_id, activity_month, event_type

),

repo_months as (

    select
        repo_id,
        activity_month,
        sum(events)             as events,
        sum(bot_events)         as bot_events,
        max(events)             as top_type_events
    from repo_month_types
    group by repo_id, activity_month

),

repo_month_shares as (

    select
        repo_id,
        activity_month,
        events,
        safe_divide(top_type_events, events)    as top_type_share,
        safe_divide(bot_events, events)         as bot_share
    from repo_months

),

flagged_months as (

    select
        repo_id,
        activity_month,
        events,
        events >= {{ var('automation_repo_monthly_events') }}
        and (
            top_type_share >= {{ var('automation_repo_top_type_share') }}
            or bot_share >= {{ var('automation_repo_bot_share') }}
        )                                       as is_automated_month
    from repo_month_shares

)

select
    repo_id,
    logical_or(is_automated_month)  as is_automated,
    countif(is_automated_month)     as automated_months,
    max(events)                     as max_monthly_events
from flagged_months
group by repo_id