with source as (
    select *
    from {{ source('github', 'daily_stars') }}
    where {{ dev_date_filter('event_date') }}
),

cleaned as (
    select
        event_date,
        repo_id,
        trim(repo_name)                                as repo_full_name,
        lower(starring_actor    )                      as actor_login,
        {{ is_bot('starring_actor') }}                 as is_bot,
        starred_at
    from source
    where
        event_date is not null
        and repo_id is not null
        and starring_actor is not null
        and starred_at is not null
),

deduplicated as (
    select * 
    from cleaned
    qualify row_number() over(
        partition by repo_id, actor_login, starred_at
        order by repo_full_name
    ) = 1
)

select * from deduplicated
