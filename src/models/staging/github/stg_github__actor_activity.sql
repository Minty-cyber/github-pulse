with source as (
    select *
    from {{ source('github', 'daily_actor_activity') }}
    where {{ github_pulse.dev_date_filter('event_date') }}
),

cleaned as (
    select
        event_date,
        actor_login,
        event_type,
        event_count,
        {{ is_bot('actor_login') }} as is_bot
    from source
    where event_date is not null and event_type is not null
)

select * from cleaned
