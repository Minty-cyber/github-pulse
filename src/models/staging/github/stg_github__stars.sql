with source as (
    select *
    from {{ source('github', 'daily_stars') }}
    where {{ dev_date_filter('event_date') }}
),

cleaned as (
    select
        event_date,
        repo_id,
        repo_name as repo_full_name,
        starring_actor as actor_login,
        {{ is_bot('starring_actor') }} as is_bot,
        starred_at
    from source
    where
        event_date is not null
        and repo_name is not null
        and starring_actor is not null
        and starred_at is not null
    qualify row_number() over (
        partition by repo_id, starring_actor, starred_at
        order by event_date
    ) = 1
)

select * from cleaned
