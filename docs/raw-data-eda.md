# Exploratory Data Analysis: Raw Layer Findings

Data-quality findings for the raw tables which hold daily aggregates extracted from the public GH Archive dataset for 2020-01-01 to 2024-12-31.

## Scope and method

| Table | Grain | Rows |
|---|---|---|
| `daily_repo_activity` | date × repo × event type × bot flag | ~2.07 billion |
| `daily_actor_activity` | date × actor login × event type | ~1.50 billion |
| `daily_stars` | one row per star (`WatchEvent`) | 303,483,844 |
| `daily_event_counts` | date × event type × bot flag | ~48,000 |

To keep query costs low, checks on the three large tables were run on **December 2024** only. Checks on coverage, event types, bot share and daily volume used the full five years, via partition metadata or the small `daily_event_counts` table.


## 1. Coverage

- All four tables span 2020-01-01 to 2024-12-31 but contain **1,819 of 1,827 days**. The same **8 days are missing** from every table, consistent with gaps in the source rather than the extraction:

| Date | Incident |
|---|---|
| 2020-08-22 | August 2020 outage |
| 2021-05-08 | May 2021 outage |
| 2021-05-10 | May 2021 outage |
| 2021-05-11 | May 2021 outage |
| 2021-08-26 | August 2021 outage |
| 2021-10-26 | October 2021 outage |
| 2021-10-27 | October 2021 outage |
| 2021-10-28 | October 2021 outage |

- Daily volume varies far more than weekly or seasonal patterns explain. The smallest day in `daily_repo_activity` has 35,675 rows against a maximum of 3.9 million.

## 2. Partial days

Low days fall into two kinds: outages, where most of the day's data is absent, and holidays.

**Outages.** Six incidents leave 28 partial days in addition to the 8 missing days listed above. All 36 are recorded in the `data_quality_dates` seed.

| Incident | Dates | What the data shows |
|---|---|---|
| June 2020 | 10 Jun | About half of a normal day |
| August 2020 | 21–23 Aug | 22 Aug missing; 21 Aug about a third and 23 Aug about a fifth of normal |
| March 2021 | 9–10 Mar | About a third of normal each day |
| May 2021 | 7–11 May | 8, 10 and 11 May missing; 7 May about half of normal |
| August 2021 | 26–27 Aug | 26 Aug missing; 27 Aug under 5% of normal |
| October 2021 | 6–29 Oct | 24 days affected; see below |

**The October 2021 outage runs from 6 to 29 October.** It has four stages:

- **6 Oct:** about a tenth of a normal day.
- **7–21 Oct:** flat at about 1.0–1.4 million events a day regardless of weekday, well below the roughly 2.9–3.1 million of other 2021 months.
- **22–25 Oct:** severe, under a tenth of normal.
- **26–28 Oct:** no data in the source.
- **29 Oct:** about a sixth of normal, the last affected day.

Only 1–5 October and 30–31 October look normal.

**Why a median check missed it.** Comparing each day with its own month's median missed most of October. The outage covers most of the month, so the month's median fell to about 1.08 million events and the depressed days looked ordinary against it. Only the days at the edges of the outage stood out.

**Holidays**, where activity falls to around half of normal: 1 January, 4 July and 25–26 December. These reflect real behaviour, not missing data.

## 3. Event types

Fifteen event types occur in the data. `PushEvent` alone accounts for about 56% of all events.

| Event type | Total events |
|---|---|
| PushEvent | 3,540,698,508 |
| CreateEvent | 890,482,041 |
| PullRequestEvent | 523,557,249 |
| IssueCommentEvent | 312,555,585 |
| WatchEvent | 303,483,844 |
| DeleteEvent | 208,102,946 |
| IssuesEvent | 151,398,414 |
| PullRequestReviewEvent | 132,446,673 |
| PullRequestReviewCommentEvent | 93,197,216 |
| ForkEvent | 92,452,037 |
| ReleaseEvent | 34,260,678 |
| CommitCommentEvent | 25,486,771 |
| PublicEvent | 20,023,038 |
| MemberEvent | 19,968,349 |
| GollumEvent | 12,693,257 |

- **`PullRequestReviewEvent` only appears from 2020-08-18.** Earlier periods contain no review events, so any trend including this type shows an artificial jump in August 2020.
- `PullRequestReviewThreadEvent` and `SponsorshipEvent`, both documented GitHub event types, do not occur in this period.
- Total `WatchEvent`s exactly equal the row count of `daily_stars` (303,483,844), so the stars and activity extractions are consistent.

## 4. Bots and automation

### Declared bots

Accounts whose login ends in `[bot]` produced a rising share of all events, from **7.4% in January 2020 to 28.1% in December 2024**. The highest months were February 2022 (33.3%), November 2024 (32.7%) and December 2022 (31.7%).

The February 2022 peak came from a single bot. `dependabot[bot]` rose from 8.1 million events in January 2022 to **25.7 million** in February, while other bots stayed flat (`github-actions[bot]` went from 6.7 to 6.4 million).

### Automation without the `[bot]` suffix

For accounts without `[bot]`, daily activity in December 2024 was:

| p50 | p90 | p99 | p99.9 | max |
|---|---|---|---|---|
| 2 | 9 | 37 | 181 | 49,909 |

Many accounts sit far above this range. The most active, `frdpzk2`, produced 1.07 million events in the month, about 34,000 a day. These accounts fall into two groups:

- **Bot accounts without the suffix**, such as `regro-cf-autotick-bot`, `codeforIATIbot`, `robocdnjs` and `anonymousthebot`.
- **Scheduled scripts running under personal accounts**, such as `frdpzk2`, `CelestiaNFT`, `freecall2019`, `hotspotlab` and `SoliSpirit`. Their names give no indication; only their volume does.

### Automated repositories

All 30 of the most active repositories in December 2024 show signs of automation. Most use only one or two event types and serve purposes such as proxy lists, IP lists and hourly data updates (for example `frdpzk2/ppub`, `SoliSpirit/v2ray-configs`, `kpnsec/iplist`, `hotspotlab/hourly`). Some are entirely bot activity, but most show no `[bot]` events at all, because their commits are made under personal accounts.

## 5. Stars (December 2024)

| Measure | Value |
|---|---|
| Star rows | 6,100,201 |
| Exact duplicate rows | 2,342 (0.04%) |
| Distinct repo–actor pairs | 5,987,149 |
| Pairs starred more than once | 83,090 (1.4%) |
| …of which at different times | 82,923 |
| Stars from burst minutes (≥ 20 stars by one account in one minute) | 232,712 (3.81%) |

- **Exact duplicates are rare** and match the duplicate event IDs present in the GH Archive source. Because the aggregated tables count every source event, they carry the same small inflation.
- **Nearly all repeat stars are genuine re-stars** at different times, not duplicates.
- **Scripted starring is visible.** The largest bursts reached 436 repos in one minute (`andrey-safetycli`) and about 1,580 repos in nine minutes (`anonymousthebot`). Burst stars are concentrated on particular repositories rather than spread evenly.

## 6. Names and logins (December 2024)

- **Repository names** all split cleanly into `owner/name`, with no surrounding whitespace.
- **Repository names are not unique.** Deleted and recreated repositories reuse names under new `repo_id`s.
- **The login `ghost`**, GitHub's placeholder for deleted accounts, appears with 54 events.
- **Some accounts appear under several capitalisations** of the same login (for example `xskayne` and `xSKAYNE`). GitHub logins are case-insensitive, so these are the same account.

## 7. Model assumptions

- Every starred repository also appears in `daily_repo_activity`.
- Every stargazer also appears in `daily_actor_activity`.

Both checks returned zero exceptions, so repository and actor lists can each be built from a single activity table.

## Summary

| Area | Finding |
|---|---|
| Coverage | 8 days missing in all tables |
| Partial days | 28 partial days across six incidents; the October 2021 outage runs 6–29 Oct |
| Event types | 15 types; PR reviews recorded only from 2020-08-18 |
| Declared bots | 7.4% → 28.1% of events; Dependabot surge in Feb 2022 |
| Hidden automation | Accounts and repositories at up to 34,000 events/day without `[bot]` |
| Top repositories | All of the 30 most active are automated |
| Stars | 0.04% duplicates, 1.4% re-starred pairs, 3.81% burst stars |
| Logins | Case variants of the same account; `ghost` for deleted users |
| Assumptions | Stars fully covered by activity tables |