with repo_activity as (
    select
        repo_id,
        repo_full_name,
        repo_owner,
        repo_name, 
        event_date
    from {{ ref('stg_github__repo_activity') }}
),

summarised as (
    select
        repo_id,
        array_agg(
            struct(repo_full_name, repo_owner, repo_name)
            order by event_date desc, repo_full_name
            limit 1
        )[offset(0)]                                        as latest,
        min(event_date)                                     as first_activity_date,
        max(event_date)                                     as latest_activity_date,
        count(distinct repo_full_name) -1                   as name_change_count
    from repo_activity
    group by repo_id
)

select 
    repo_id,
    latest.repo_full_name, 
    latest.repo_owner,
    latest.repo_name,
    name_change_count,
    first_activity_date,
    latest_activity_date
from summarised
