# Useful Commands for the Project.


## BigQuery CLI command for checking monthly free GB of queries left against the GB of queries ran.
```python
bq query --use_legacy_sql=false --project_id=gh-pulse-510620 '
select
  round(sum(total_bytes_billed) / pow(1024, 3), 2) as gb_billed_this_month,
  round(1024 - sum(total_bytes_billed) / pow(1024, 3), 2) as gb_free_remaining
from `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
where creation_time >= timestamp_trunc(current_timestamp(), month)
  and job_type = "QUERY"
  and state = "DONE"
  and (statement_type != "SCRIPT" or statement_type is null)
'
```
