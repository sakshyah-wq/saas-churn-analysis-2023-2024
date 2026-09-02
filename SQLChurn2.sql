--------------------------------------Revenue / Subscription Analysis---------------------------------------
--Total MRR/ARR generated across all subscriptions (historical)
SELECT plan_tier, SUM(mrr_amount) AS Total_MRR,
SUM(arr_amount) as total_ARR
FROM ravenstack_subscriptions
GROUP BY plan_tier

--Current active MRR/Current active MRR
WITH ranked_sub as
( SELECT account_id,
         plan_tier,
         mrr_amount,
         arr_amount,
         start_date,
         ROW_NUMBER()OVER(Partition by account_id Order by start_date DESC) AS rn
         FROM ravenstack_subscriptions
)
Select  plan_tier,
       SUM(mrr_amount) AS current_MRR,
       SUM(arr_amount) AS current_ARR
FROM ranked_sub
WHERE rn = 1
GROUP BY plan_tier;

--How has MRR trended over time (by month)?
with monthly_mrr as
(SELECT 
    FORMAT(start_date, 'yyyy-MM') AS month,
    SUM(mrr_amount) AS total_mrr
FROM ravenstack_subscriptions
GROUP BY FORMAT(start_date, 'yyyy-MM')
)
SELECT 
    month,
    total_mrr,
    LAG(total_mrr) OVER (ORDER BY month) AS prev_month_mrr,
    ROUND(
        100.0 * (total_mrr - LAG(total_mrr) OVER (ORDER BY month)) 
        / NULLIF(LAG(total_mrr) OVER (ORDER BY month), 0), 
        1
    ) AS pct_change
    FROM monthly_mrr
ORDER BY month;

--new subscriptions started in June vs other months
SELECT 
     FORMAT(start_date, 'MM') AS month_num, 
     COUNT(*) AS new_subs
FROM ravenstack_subscriptions
GROUP BY FORMAT(start_date, 'MM')
ORDER BY month_num;


------------------------------------------Churn/Retention analysis------------------------------------------------------------

-- the overall churn rate
SELECT 
SUM(CASE WHEN churn_flag = 1 then 1 else 0 end)*1.0/COUNT (*) AS churn_rate
FROM ravenstack_accounts

--Churn rate by industry
WITH ranked AS (
    SELECT industry,
           SUM(CASE WHEN churn_flag = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) AS churn_rate,
           COUNT(*) AS account_count
    FROM ravenstack_accounts
    GROUP BY industry
)
SELECT industry, churn_rate, account_count,
       RANK() OVER (ORDER BY churn_rate DESC) AS rn
FROM ranked;

--Churn rate by plan_tier
WITH ranked as (
     SELECT plan_tier,
            SUM(CASE WHEN churn_flag=1 then 1 else 0 end)* 1.0/count(*) as churn_rate,
            COUNT(*) as account_count
     From ravenstack_accounts
     GROUP BY plan_tier
)
SELECT plan_tier,churn_rate, account_count,
       RANK() OVER (ORDER BY churn_rate DESC) AS rn
FROM ranked;

--How has churn volume trended month over month
with churn_vol AS(
      SELECT FORMAT(churn_date,'yyyy-MM') AS Month,
             COUNT(*) AS total_churn
      FROM ravenstack_churn_events
      GROUP BY FORMAT(churn_date,'yyyy-MM') 
)
SELECT month,
    total_churn,
    LAG(total_churn) OVER (ORDER BY month) AS prev_month_churn,
    ROUND(100.0*(total_churn-LAG(total_churn) OVER (ORDER BY month))/LAG(total_churn) OVER (ORDER BY month),2) AS month_change 
    FROM churn_vol
    ORDER BY Month

--Explains the MRR dip in June 2023, as this proved that there was a spike in churn for the same month

--Top churn reason per plan_tier
with reason as(
      SELECT a.plan_tier,c.reason_code, COUNT(*) AS reason_count
      FROM ravenstack_accounts as a
      JOIN ravenstack_churn_events as c
      ON a.account_id=c.account_id
      GROUP BY a.plan_tier,c.reason_code
)
SELECT plan_tier,reason_code,reason_count
FROM (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY plan_tier ORDER BY reason_count DESC) AS rn
    FROM reason
) ranked
WHERE rn = 1;

---------------------------------------------Feature Usage analysis-----------------------------------------
--Top 5 most-used features overall
SELECT TOP 5 feature_name,SUM(usage_count)
from ravenstack_feature_usage
GROUP BY feature_name
ORDER BY SUM(usage_count)DESC

--Beta vs. non-beta error rate comparison
SELECT is_beta_feature,
       COUNT(*) AS usage_rows,
       AVG(CAST(error_count AS FLOAT)) AS avg_errors
FROM ravenstack_feature_usage
GROUP BY is_beta_feature;

--Rank accounts by number of distinct features used
WITH account_features as
(SELECT s.account_id,
       COUNT(DISTINCT f.feature_name) AS distinct_features
FROM ravenstack_feature_usage f
JOIN ravenstack_subscriptions s ON f.subscription_id = s.subscription_id
GROUP BY s.account_id
)
SELECT account_id, distinct_features,
       RANK() OVER (ORDER BY distinct_features DESC) AS rn
FROM account_features;

---------------------------------------Support Analysis-------------------------------------------------------

--Avg resolution time by priority, ranked
with c as
(SELECT priority, 
AVG (resolution_time_hours) as avg_resolution_t
FROM ravenstack_support_tickets
GROUP BY priority
)
SELECT priority,avg_resolution_t,
RANK() OVER(order by avg_resolution_t DESC)
FROM c

--Running count of tickets opened per month 

WITH monthly_tickets AS
(
    SELECT CAST(FORMAT(submitted_at, 'yyyy-MM') AS VARCHAR(7)) AS month,
           COUNT(*) AS tickets_opened
    FROM ravenstack_support_tickets
    GROUP BY CAST(FORMAT(submitted_at, 'yyyy-MM') AS VARCHAR(7)) 
)
SELECT month,
       tickets_opened,
       SUM(tickets_opened) OVER (ORDER BY month) AS running_total
FROM monthly_tickets
ORDER BY month;

--Do churned accounts' most recent tickets show lower satisfaction than active accounts' most recent tickets?
WITH ranked_tickets AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY account_id ORDER BY submitted_at DESC) AS rn
    FROM ravenstack_support_tickets
)
SELECT *
FROM ranked_tickets
JOIN ravenstack_accounts ON 
WHERE rn = 1;

----------------------------------------------Cross-cutting Churn Drivers--------------------------------------

--Compare avg support tickets: churned vs. active accounts
WITH total_count AS (
    SELECT account_id, COUNT(*) AS ticket_count
    FROM ravenstack_support_tickets
    GROUP BY account_id
)
SELECT a.churn_flag,
       AVG(CAST(ISNULL(t.ticket_count, 0) AS FLOAT)) AS avg_tickets
FROM ravenstack_accounts a
LEFT JOIN total_count t ON a.account_id = t.account_id
GROUP BY a.churn_flag;

--Compare avg distinct features used: churned vs. active accounts

WITH account_features AS (
    SELECT s.account_id,
           COUNT(DISTINCT f.feature_name) AS distinct_features
    FROM ravenstack_feature_usage f
    JOIN ravenstack_subscriptions s ON f.subscription_id = s.subscription_id
    GROUP BY s.account_id
)
SELECT a.churn_flag,
       AVG(CAST(ISNULL(af.distinct_features, 0) AS FLOAT)) AS avg_distinct_features
FROM ravenstack_accounts a
LEFT JOIN account_features af ON a.account_id = af.account_id
GROUP BY a.churn_flag;