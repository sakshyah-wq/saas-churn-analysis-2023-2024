--1.Accounts should be 1 row per account
SELECT COUNT(*), COUNT(DISTINCT account_id) FROM ravenstack_accounts

--2.subscriptions 1 row per subscription
SELECT COUNT(*),COUNT(DISTINCT subscription_id) FROM ravenstack_subscriptions

--3.feature_usage check if usage_id is truly unique
SELECT COUNT(*), COUNT(DISTINCT usage_id) FROM ravenstack_feature_usage
SELECT subscription_id, feature_name, usage_date, COUNT(*)
FROM ravenstack_feature_usage
GROUP BY subscription_id, feature_name, usage_date
HAVING COUNT(*) > 1;

----------------------------------------------------Intergrity Checks---------------------------------------------------
-- 1. every subscription should map to a real account
SELECT COUNT(*) AS orphan_subscriptions
FROM ravenstack_subscriptions s
LEFT JOIN ravenstack_accounts a ON s.account_id = a.account_id
WHERE a.account_id IS NULL;

--2. every feature_usage row should map to a real subscription
SELECT COUNT(*) 
FROM ravenstack_feature_usage as f
LEFT JOIN ravenstack_subscriptions as s 
ON f.subscription_id = s.subscription_id
WHERE s.subscription_id IS NULL;

--3.every churn_event should map to a real account
SELECT COUNT(*) AS orphan_churn_events
FROM ravenstack_churn_events c
LEFT JOIN ravenstack_accounts a ON c.account_id = a.account_id
WHERE a.account_id IS NULL;

-- 4. every support_ticket should map to a real account
SELECT COUNT(*)
FROM ravenstack_support_tickets as t
left join ravenstack_accounts as a
ON t.account_id=a.account_id
WHERE a.account_id IS NULL

-----------------------------------------Date Checks-----------------------------------------------------------------------------
--1.churn_date should be after the account's signup_date
SELECT c.* FROM ravenstack_churn_events as c
JOIN ravenstack_accounts as a 
ON c.account_id=a.account_id 
WHERE c.churn_date<a.signup_date

--2.subscriptions date should be on/after account signup_date
SELECT s.* from ravenstack_subscriptions as s
JOIN ravenstack_accounts as a 
ON s.account_id=a.account_id
WHERE s.start_date<a.signup_date

--3.subscriptions end_date should never be before start_date
SELECT * FROM ravenstack_subscriptions WHERE end_date<start_date

--4.support_tickets closed_at should never be before submitted_at
SELECT * FROM ravenstack_support_tickets
WHERE closed_at<submitted_at

----------------------------------------------NULLs-----------------------------------------------------------------------
--1.subscriptions: is a NULL end_date meaning "still active"? 
SELECT COUNT(*) FROM ravenstack_subscriptions WHERE end_date IS NUll

SELECT s.account_id, s.subscription_id, s.end_date, c.churn_date
FROM ravenstack_subscriptions s
JOIN ravenstack_churn_events c ON s.account_id = c.account_id
WHERE s.end_date IS NULL;
--subscriptions.end_date cannot be used alone to determine active status — cross-referenced against churn_events

--2.Check nulls across key columns 
SELECT COUNT(*) FROM ravenstack_subscriptions WHERE account_id IS NULL;
SELECT COUNT(*) FROM ravenstack_feature_usage WHERE subscription_id IS NULL;

----------------------------------------------Duplicates------------------------------------------------------------------
 --can one account have overlapping active subscriptions? 
SELECT account_id, COUNT(*) 
FROM ravenstack_subscriptions
WHERE end_date IS NULL
GROUP BY account_id
HAVING COUNT(*) > 1;
--end_date is messy enough that you shouldn't lean on it at all.