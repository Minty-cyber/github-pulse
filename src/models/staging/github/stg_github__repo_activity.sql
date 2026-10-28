with source as (
    select *
    from {{ source('github', 'daily_repo_activity') }}
    where {{ dev_date_filter('event_date') }}
),

cleaned as (
    select 
        event_date as event_date,
        repo_id as repo_id,
        repo_name as repo_full_name,
        split(repo_name, '/')[safe_offset(0)] as repo_owner,
        split(repo_name, '/')[safe_offset(1)] as repo_name,
        event_type as event_type,
        is_bot,
        event_count as event_count
    from source 
    where repo_id is not null and event_type is not null and event_date is not null
)

select * from cleaned