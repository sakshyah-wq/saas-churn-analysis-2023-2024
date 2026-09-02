## 📌 Project Background

RavenStack is an AI-powered collaboration platform serving mid-market and enterprise teams. Over the last few quarters, leadership has flagged a growing concern: **monthly churn has been creeping up.**

This project analyzes a SaaS company's operational data — accounts, subscriptions, feature usage, churn events, and support tickets — to answer a question every SaaS business cares about:

> **Who is churning, and why?**

## 📖 Overview

The project is built in two layers:

1. **SQL Analysis** — The core investigative work. Using SQL Server, I validated the dataset's integrity (checking for orphaned records, broken date logic, and inconsistent flags across tables), then built a series of analyses covering revenue (MRR/ARR trends, ARPU), churn (rate by industry, plan tier, and reason), feature usage, and customer support — using CTEs, window functions (`ROW_NUMBER`, `RANK`, `LAG`), and multi-table joins throughout.

2. **Power BI Dashboard** — A multi-page interactive dashboard that translates the validated SQL findings into a stakeholder-facing report, using DAX measures to replicate the underlying SQL logic (current MRR, churn rate, ARPU) so the numbers stay consistent between both layers.
