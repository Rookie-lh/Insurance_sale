-- 工单编号：大数据-八维保险数据挖掘-03-财产保险业务看板
-- 按日统计保费收入
SELECT
    DATE(sub_time) AS date,
    SUM(sub_amount) AS daily_premium_income
FROM subscription_info
GROUP BY DATE(sub_time);

-- 按七日统计保费收入
SELECT
    DATE_FORMAT(sub_time, '%Y-%m-%d') AS yeargitgit_month_day,
    SUM(sub_amount) AS weekly_premium_income
FROM subscription_info
WHERE sub_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE_FORMAT(sub_time, '%Y-%m-%d');

-- 按月统计保费收入
SELECT
    DATE_FORMAT(sub_time, '%Y-%m') AS year_month,
    SUM(sub_amount) AS monthly_premium_income
FROM subscription_info
GROUP BY DATE_FORMAT(sub_time, '%Y-%m');

-- 按年统计保费收入
SELECT
    YEAR(sub_time) AS year,
    SUM(sub_amount) AS annual_premium_income
FROM subscription_info
GROUP BY YEAR(sub_time);

-- 按日统计理赔金额
SELECT
    DATE(claim_pay.pay_time) AS date,
    SUM(claim_audit.audit_amount) AS daily_claim_amount
FROM claim_audit
JOIN claim_pay ON claim_audit.claim_audit_id = claim_pay.claim_audit_id
GROUP BY DATE(claim_pay.pay_time);

-- 按七日统计理赔金额
SELECT
    DATE_FORMAT(claim_pay.pay_time, '%Y-%m-%d') AS year_month_day,
    SUM(claim_audit.audit_amount) AS weekly_claim_amount
FROM claim_audit
JOIN claim_pay ON claim_audit.claim_audit_id = claim_pay.claim_audit_id
WHERE claim_pay.pay_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE_FORMAT(claim_pay.pay_time, '%Y-%m-%d');

-- 按月统计理赔金额
SELECT
    DATE_FORMAT(claim_pay.pay_time, '%Y-%m') AS year_month,
    SUM(claim_audit.audit_amount) AS monthly_claim_amount
FROM claim_audit
JOIN claim_pay ON claim_audit.claim_audit_id = claim_pay.claim_audit_id
GROUP BY DATE_FORMAT(claim_pay.pay_time, '%Y-%m');

-- 按年统计理赔金额
SELECT
    YEAR(claim_pay.pay_time) AS year,
    SUM(claim_audit.audit_amount) AS annual_claim_amount
FROM claim_audit
JOIN claim_pay ON claim_audit.claim_audit_id = claim_pay.claim_audit_id
GROUP BY YEAR(claim_pay.pay_time);

-- 计算每日理赔率
SELECT
    si.date,
    si.daily_premium_income,
    ca.daily_claim_amount,
    (ca.daily_claim_amount / si.daily_premium_income) * 100 AS daily_claim_rate
FROM (
    SELECT DATE(sub_time) AS date, SUM(sub_amount) AS daily_premium_income
    FROM subscription_info
    GROUP BY DATE(sub_time)
) si
LEFT JOIN (
    SELECT DATE(claim_pay.pay_time) AS date, SUM(claim_audit.audit_amount) AS daily_claim_amount
    FROM claim_audit
    JOIN claim_pay ON claim_audit.claim_audit_id = claim_pay.claim_audit_id
    GROUP BY DATE(claim_pay.pay_time)
) ca ON si.date = ca.date;

-- 计算七日理赔率
SELECT
    si.year_month_day,
    si.weekly_premium_income,
    ca.weekly_claim_amount,
    (ca.weekly_claim_amount / si.weekly_premium_income) * 100 AS weekly_claim_rate
FROM (
    SELECT DATE_FORMAT(sub_time, '%Y-%m-%d') AS year_month_day, SUM(sub_amount) AS weekly_premium_income
    FROM subscription_info
    WHERE sub_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY DATE_FORMAT(sub_time, '%Y-%m-%d')
) si
LEFT JOIN (
    SELECT DATE_FORMAT(claim_pay.pay_time, '%Y-%m-%d') AS year_month_day, SUM(claim_audit.audit_amount) AS weekly_claim_amount
    FROM claim_audit
    JOIN claim_pay ON claim_audit.claim_audit_id = claim_pay.claim_audit_id
    WHERE claim_pay.pay_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
    GROUP BY DATE_FORMAT(claim_pay.pay_time, '%Y-%m-%d')
) ca ON si.year_month_day = ca.year_month_day;

-- 计算月理赔率
SELECT
    si.year_month,
    si.monthly_premium_income,
    ca.monthly_claim_amount,
    (ca.monthly_claim_amount / si.monthly_premium_income) * 100 AS monthly_claim_rate
FROM (
    SELECT DATE_FORMAT(sub_time, '%Y-%m') AS year_month, SUM(sub_amount) AS monthly_premium_income
    FROM subscription_info
    GROUP BY DATE_FORMAT(sub_time, '%Y-%m')
) si
LEFT JOIN (
    SELECT DATE_FORMAT(claim_pay.pay_time, '%Y-%m') AS year_month, SUM(claim_audit.audit_amount) AS monthly_claim_amount
    FROM claim_audit
    JOIN claim_pay ON claim_audit.claim_audit_id = claim_pay.claim_audit_id
    GROUP BY DATE_FORMAT(claim_pay.pay_time, '%Y-%m')
) ca ON si.year_month = ca.year_month;

-- 计算年理赔率
SELECT
    si.year,
    si.annual_premium_income,
    ca.annual_claim_amount,
    (ca.annual_claim_amount / si.annual_premium_income) * 100 AS annual_claim_rate
FROM (
    SELECT YEAR(sub_time) AS year, SUM(sub_amount) AS annual_premium_income
    FROM subscription_info
    GROUP BY YEAR(sub_time)
) si
LEFT JOIN (
    SELECT YEAR(claim_pay.pay_time) AS year, SUM(claim_audit.audit_amount) AS annual_claim_amount
    FROM claim_audit
    JOIN claim_pay ON claim_audit.claim_audit_id = claim_pay.claim_audit_id
    GROUP BY YEAR(claim_pay.pay_time)
) ca ON si.year = ca.year;

-- 按日统计新增投保数量
SELECT
    DATE(sub_time) AS date,
    COUNT(*) AS daily_new_subscriptions
FROM subscription_info
WHERE sub_time >= DATE_SUB(CURDATE(), INTERVAL 1 DAY)
GROUP BY DATE(sub_time);

-- 按七日统计新增投保数量
SELECT
    DATE_FORMAT(sub_time, '%Y-%m-%d') AS year_month_day,
    COUNT(*) AS weekly_new_subscriptions
FROM subscription_info
WHERE sub_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE_FORMAT(sub_time, '%Y-%m-%d');

-- 按月统计新增投保数量
SELECT
    DATE_FORMAT(sub_time, '%Y-%m') AS year_month,
    COUNT(*) AS monthly_new_subscriptions
FROM subscription_info
GROUP BY DATE_FORMAT(sub_time, '%Y-%m');

-- 按年统计新增投保数量
SELECT
    YEAR(sub_time) AS year,
    COUNT(*) AS annual_new_subscriptions
FROM subscription_info
GROUP BY YEAR(sub_time);

-- 统计有效保单数
SELECT
    COUNT(*) AS current_active_policies
FROM policy_info
WHERE policy_status = '正常生效';

-- 计算每日投保转化率（当日核保通过并生成保单的数量 ÷ 当日所有投保申请数量）
SELECT
    DATE(si.sub_time) AS date,
    (COUNT(pi.policy_id) / COUNT(si.subscription_id)) * 100 AS daily_conversion_rate
FROM subscription_info si
LEFT JOIN policy_info pi ON si.subscription_id = pi.subscription_id
WHERE DATE(si.sub_time) = DATE(CURDATE())
GROUP BY DATE(si.sub_time);

-- 计算七日投保转化率（近七日核保通过并生成保单的数量 ÷ 近七日所有投保申请数量）
SELECT
    (COUNT(pi.policy_id) / COUNT(si.subscription_id)) * 100 AS weekly_conversion_rate
FROM subscription_info si
LEFT JOIN policy_info pi ON si.subscription_id = pi.subscription_id
WHERE si.sub_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE_FORMAT(si.sub_time, '%Y-%m-%d');

-- 计算月投保转化率
SELECT
    DATE_FORMAT(si.sub_time, '%Y-%m') AS year_month,
    (COUNT(pi.policy_id) / COUNT(si.subscription_id)) * 100 AS monthly_conversion_rate
FROM subscription_info si
LEFT JOIN policy_info pi ON si.subscription_id = pi.subscription_id
GROUP BY DATE_FORMAT(si.sub_time, '%Y-%m');

-- 计算年投保转化率
SELECT
    YEAR(si.sub_time) AS year,
    (COUNT(pi.policy_id) / COUNT(si.subscription_id)) * 100 AS annual_conversion_rate
FROM subscription_info si
LEFT JOIN policy_info pi ON si.subscription_id = pi.subscription_id
GROUP BY YEAR(si.sub_time);

-- 计算月续保率（当月选择续保的保单数量 ÷ 当月应续保保单数量）
SELECT
    DATE_FORMAT(renew_time, '%Y-%m') AS year_month,
    (COUNT(CASE WHEN renew_status = '已续保' THEN 1 ELSE NULL END) / COUNT(*)) * 100 AS monthly_renewal_rate
FROM renew_info
WHERE renew_time >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY DATE_FORMAT(renew_time, '%Y-%m');

-- 计算年续保率
SELECT
    YEAR(renew_time) AS year,
    (COUNT(CASE WHEN renew_status = '已续保' THEN 1 ELSE NULL END) / COUNT(*)) * 100 AS annual_renewal_rate
FROM renew_info
GROUP BY YEAR(renew_time);