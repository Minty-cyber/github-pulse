with source as (
    select * 
    from {{ source('github', 'daily_event_counts') }}
    where {{ dev_date_filter('event_date') }}
),

cleaned as (
    select 
        event_date as event_date,
        event_type as event_type,
        is_bot,
        event_count as event_count
    from source
    where event_date is not null and event_count is not null and event_type is not null
)

select * from cleaned