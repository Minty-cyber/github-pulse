# ADR 0001: Use BigQuery as the cloud data warehouse

## Status

Accepted. 2026-10-07.

## Context

The gh-pulse project needs a cloud data warehouse to:

1. Process ~5 TiB of raw GitHub event data (one-time backfill of 2020–2024)
2. Store derived aggregated tables (~200 GB after staging transforms)
3. Serve dashboard queries from Metabase with sub-second latency on
   pre-aggregated marts
4. Stay affordable on a solo-developer budget — ideally free during the
   build phase and under $5/month ongoing

Several constraints shaped the decision:

- **Budget constraint:** no established cloud account; $300 one-time free
  trial credit was the available budget for the backfill. Monthly ongoing
  cost needed to be essentially $0 after the trial expired.
- **Data constraint:** the primary data source
  (`bigquery-public-data.githubarchive`) is already hosted in BigQuery as a
  public dataset. Querying it elsewhere would require ingesting hundreds
  of gigabytes of gzipped JSON first.
- **Learning constraint:** this is a portfolio project. The chosen
  warehouse should be something a working analytics engineer would
  recognize and value seeing on a resume.
- **Operational constraint:** no team to manage infrastructure. The
  warehouse needed to be fully managed, with minimal operational overhead.

## Decision

**Use Google BigQuery** as the cloud data warehouse, with pay-per-scan
on-demand pricing (not slot reservations).

Specifically:
- All datasets created in the `US` multi-region (required for querying the
  `githubarchive` public dataset without cross-region costs)
- On-demand pricing: $6.25/TiB scanned, with 1 TiB/month free
- Storage: $0.02/GiB/month, with 10 GiB/month free
- Standard SQL dialect (not legacy SQL)

## Alternatives considered

### Snowflake

**Why considered:** industry-leading cloud warehouse, excellent for
analytical workloads, strong dbt ecosystem support.

**Why rejected:**
- Minimum compute cost: Snowflake bills by warehouse-second, with
  a one-minute minimum per query burst. Even light usage trends toward
  $60+/month minimum for a tiny warehouse running once a day.
- The free trial ($400 credit) is comparable to BigQuery's, but Snowflake
  doesn't host GH Archive — meaning the first ~$50 would be spent
  ingesting data that was already free elsewhere.
- Learning curve for Snowflake-specific features (virtual warehouses,
  resource monitors) would delay progress on the actual modeling work.

**Decision point:** cost model mismatch for a bursty, batch-oriented
hobbyist workload.

### Databricks

**Why considered:** strong for data engineering, popular in enterprise,
would signal familiarity with Lakehouse architecture on a resume.

**Why rejected:**
- Overkill for the project scope. Databricks shines when you need
  notebook-based data science, ML pipelines, or Delta Lake transactions.
  gh-pulse needs none of those.
- The managed Databricks workspace itself has non-trivial ongoing cost
  (~$0.15/DBU plus underlying compute).
- The learning curve (Spark concepts, Delta Lake, Unity Catalog) would
  distract from the dimensional modeling focus of the project.

**Decision point:** solving the wrong problem — Databricks is for
larger-than-single-machine distributed compute, which gh-pulse doesn't
need.

### DuckDB (local)

**Why considered:** completely free, blazingly fast on single-machine
analytical workloads, growing rapidly in the modern analytics stack.
Zero cloud setup.

**Why rejected:**
- The 5 TiB raw backfill scan doesn't fit on a laptop. Even downloading
  the GH Archive gzipped JSON files for 2020–2024 would take hundreds of
  GB of local disk and significant bandwidth.
- The staging aggregates (~200 GB) are workable on local disk but queries
  would be slower than on BigQuery's distributed engine.
- No managed component — if the laptop dies, the warehouse dies with it.
- Doesn't demonstrate cloud experience, which was a learning goal.

**Decision point:** physically can't fit the backfill on local hardware,
and loses the cloud-warehouse learning value.

**Note:** DuckDB would be the clear winner if the data fit on local
disk and cloud experience wasn't a goal. For many analytics projects at
sub-100-GB scale, DuckDB is now the right default.

### Amazon Redshift

**Why considered:** well-known cloud warehouse, mature dbt adapter.

**Why rejected:**
- GH Archive is in BigQuery, not S3. Loading it into Redshift would
  require either downloading via GCS or using a Redshift external table
  via Spectrum (which has its own pricing).
- Serverless Redshift is cheaper than classic Redshift but still has
  base-rate costs higher than BigQuery's free tier.
- AWS account setup overhead (billing, IAM, VPC) is significantly higher
  than GCP's for a solo project.

**Decision point:** wrong cloud for where the data lives.

### Postgres (self-hosted or managed)

**Why considered:** familiar, cheap, supported by dbt.

**Why rejected:**
- Not an analytical database. The 200 GB staging layer would be slow to
  query without significant indexing effort, and the 2 billion row
  `stg_github__daily_repo_activity` table would be painful.
- Doesn't signal "modern analytics engineering" on a resume the way a
  cloud warehouse does.

**Decision point:** wrong architecture (OLTP vs OLAP) for the workload.

## Consequences

### Positive

- **$0 out-of-pocket cost for the build phase.** The entire 5-year
  backfill (~5 TiB scanned, ~$8 of billable usage) was fully absorbed by
  the $300 free trial credit, with ~$291 of credit remaining when the
  trial expired.
- **GH Archive hosted alongside our marts.** No ingestion pipeline
  needed. Our queries reference `bigquery-public-data.githubarchive`
  directly.
- **Serverless with no operational overhead.** No cluster sizing, no
  warehouse scaling, no idle-time concerns.
- **Permanent free tier (1 TiB queries + 10 GiB storage per month)**
  covers the project's ongoing operational pattern (dashboard refresh,
  occasional exploration queries) indefinitely.
- **Industry-standard** for analytics engineering in 2026. The
  `dbt-bigquery` adapter is first-class in the dbt ecosystem.
- **Automatic long-term storage discount (50% off after 90 days
  unmodified)** will cut ongoing storage costs further in January 2027.

### Negative

- **Storage overage** from the 200 GB staging layer: ~$3.80/month
  ongoing. Manageable, but non-zero. Will drop to ~$0.15/month after
  cleanup of the two biggest staging tables (planned post-mart-build).
- **US multi-region requirement** limits future flexibility if the
  project ever needs to run queries against EU or Asia-based datasets.
  Not a current concern.
- **Pay-per-scan model requires discipline.** A single mistaken
  `SELECT * FROM githubarchive.year.2023` could scan 2 TiB and cost
  ~$12. Mitigated by project-level daily query quotas (100 GB) and
  per-query `maximum_bytes_billed` caps.
- **Vendor lock-in to Google Cloud.** Moving to another warehouse would
  require re-provisioning infrastructure and potentially re-ingesting
  data. Acceptable for a portfolio project; worth noting for production
  considerations.
- **No native data lineage visualization** — relies on `dbt docs` for
  this capability.

## Follow-up actions

- Set up cost guardrails before any significant queries run
  (see [ADR 0004](0004-console-first-infra.md) and
  [`docs/architecture.md`](../architecture.md#operational-notes))
- Document the exact query patterns and cost expectations in
  [`docs/cost_report.md`](../cost_report.md)
- Monitor the long-term storage discount application in January 2027
- Consider migration to `maximum_bytes_billed` in all dbt profile
  configurations

## References

- [BigQuery pricing documentation](https://cloud.google.com/bigquery/pricing)
- [GH Archive BigQuery public dataset](https://www.gharchive.org/)
- Internal: [`docs/architecture.md`](../architecture.md)
- Internal: [`docs/cost_report.md`](../cost_report.md)