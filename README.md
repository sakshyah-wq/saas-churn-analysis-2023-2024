## 📌 Project Background

RavenStack is an AI-powered collaboration platform serving mid-market and enterprise teams. Over the last few quarters, leadership has flagged a growing concern: **monthly churn has been creeping up.**

This project analyzes a SaaS company's operational data — accounts, subscriptions, feature usage, churn events, and support tickets — to answer a question every SaaS business cares about:

> **Who is churning, and why?**

## 📖 Overview

The project is built in two layers:

1. **SQL Analysis** — The core investigative work. Using SQL Server, I validated the dataset's integrity (checking for orphaned records, broken date logic, and inconsistent flags across tables), then built a series of analyses covering revenue (MRR/ARR trends, ARPU), churn (rate by industry, plan tier, and reason), feature usage, and customer support — using CTEs, window functions (`ROW_NUMBER`, `RANK`, `LAG`), and multi-table joins throughout.

2. **Power BI Dashboard** — A multi-page interactive dashboard that translates the validated SQL findings into a stakeholder-facing report, using DAX measures to replicate the underlying SQL logic (current MRR, churn rate, ARPU) so the numbers stay consistent between both layers.

> 📁 The original dataset can be found here: [Dataset Source](https://www.kaggle.com/datasets/rivalytics/saas-subscription-and-churn-analytics-dataset)
>
> 📊 The interactive dashboard can be downloaded here: [RavenStack_Dashboard.pbix](https://github.com/sakshyah-wq/saas-churn-analysis-2023-2024/blob/main/Power%20BI%20Churn%20analysis.pbix)
>
> 📄 The SQL queries utilized to inspect and perform quality checks can be found [here](https://github.com/sakshyah-wq/saas-churn-analysis-2023-2024/blob/main/SQLChurn3.sql)
>
> 📄 Targeted SQL queries regarding various business questions can be found [here](https://github.com/sakshyah-wq/saas-churn-analysis-2023-2024/blob/main/SQLChurn2.sql)


## 🗂️ Data Structure 

RavenStack's database consists of five tables: `accounts`, `subscriptions`, `churn_events`, `feature_usage`, and `support_tickets`.

<img width="1142" height="755" alt="image" src="https://github.com/user-attachments/assets/0bd15f28-ffb5-465d-b246-71605812d167" />

## Executive Summary

### Overview of Findings
Revenue is growing strongly — current MRR stands at **$1.33M** (ARR: **$16M**), with ARPU at **$3,423** per account. But that growth sits alongside a **22% overall churn rate**, and the risk isn't evenly spread: **DevTools accounts churn at nearly double the rate of the most stable industries (31% vs. 16%)**, while plan tier shows no meaningful effect on retention.The following sections will implore additional contributing factors and highlight key opportunity areas for improvement.

Below is the overview page from the PowerBI dashboard and more examples are included throughout the report. The entire interactive dashboard can be downloaded [here](https://github.com/sakshyah-wq/saas-churn-analysis-2023-2024/blob/main/Power%20BI%20Churn%20analysis.pbix).

<img width="802" height="587" alt="image" src="https://github.com/user-attachments/assets/e499876d-3328-41f1-815a-74e3701f1cca" />

## Revenue and Subscription Analysis
- **MRR grew from ~$4,700 (Jan 2023) to $1.33M (Dec 2024)**, reflecting strong, consistent revenue growth over the two-year period.
- New subscription volume grew **steadily every month** (137 → 1,074), ruling out reduced signups as the cause of isolated month-over-month MRR dips observed in **June 2023, September 2023, June 2024, and August 2024**. Overall revenue growth remained strong throughout the period.
- These MRR dips were **not explained by signup volume** — cross-checked against churn volume in the [Churn Analysis](#churn--retention-analysis) section.

## Churn & Retention Analysis
- **Overall churn rate: 22%** across all accounts
- **Industry is the strongest churn signal identified in this analysis** — DevTools accounts churn at **31%**, nearly double Cybersecurity's **16%**, across comparably sized account groups (79–113 accounts each)
- **Plan tier shows no meaningful effect on churn** — Basic, Pro, and Enterprise all sit within a narrow 21.9–22.1% range, ruling this out as a retention lever
- Churn volume grew substantially over the analysis period. Cross-checked against the MRR dips identified in the [Revenue & Subscription Analysis](#revenue--subscription-analysis) section: only **June 2024** showed a churn spike matching a corresponding MRR dip — the other dip months (June 2023, September 2023, August 2024) are **not** explained by churn volume alone

<img width="810" height="572" alt="image" src="https://github.com/user-attachments/assets/d8ec820e-5e24-4340-a173-3c8af4320544" />

## Other Analysis

- **Top 5 features — usage is evenly distributed, not top-heavy**  
  The top 5 features (**6,536–6,686 uses**) are clustered within about 2% of each other. There's no single "hero" feature dominating usage — engagement is spread fairly evenly across the top features rather than being concentrated in one or two. This is a healthy sign for product stickiness, as users aren't relying on just one feature.

- **High-priority tickets take the longest to resolve**  
  The key finding is that **"High" priority tickets take the longest to resolve — even longer than "Low" priority tickets.** Only **"Urgent"** tickets receive meaningfully faster treatment.

- **Feature engagement shows a weak but noticeable relationship with churn**  
  Customers with **High feature engagement have the lowest churn rate (~7.8%)**, compared with approximately **10% for Low and Medium engagement**. However, **No Usage customers show a slightly lower churn rate (~9%)**, suggesting that feature engagement alone is not a strong enough predictor of churn and that other factors may be influencing customer retention.

<img width="495" height="347" alt="image" src="https://github.com/user-attachments/assets/ec379933-6138-4954-a285-2a56a268a15a" />

