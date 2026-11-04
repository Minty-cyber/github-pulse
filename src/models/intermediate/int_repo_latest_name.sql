-- In the data repo is identified by repo_id but it is a name that changes over time.
-- Owners of the repo can change the name at any point in time or transfer it to another account or organisation,
-- so in the stg_github__repo_activity, the same repo can appear under several names.

-- The intermediate model here applies Slowly Changing Dimension Type 1 (SCD 1) to keep the latest name
-- and drop the historical names but keep the number of times that the repo name was changed.

with repo_activity as (
    select 
        repo_id,
        repo_full_name,
        repo_name, 
        repo_owner,
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
        )[offset(0)]                                       as latest,
        min(event_date)                                    as first_activity_date,
        max(event_date)                                    as latest_activity_date,
        count(distinct repo_full_name) -1                  as name_change_count
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