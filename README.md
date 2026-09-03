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
Revenue is growing strongly — current MRR stands at **$1.33M** (ARR: **$16M**), with ARPU at **$3,423** per account. But that growth sits alongside a **22% overall churn rate**, and the risk isn't evenly spread: **DevTools accounts churn at nearly double the rate of the most stable industries (31% vs. 16%)**, while plan tier shows no meaningful effect on retention.

