-- 分层开发代码示例：先在 ODS 层进行数据清洗和整合，再在 ADS 层计算指标
-- 创建 ODS 层表：ods_subscription_cleaned
CREATE TABLE ods_subscription_cleaned AS
SELECT
    s.subscription_id,
    c.customer_id AS policyholder_id,
    ci.customer_id AS insured_id,
    s.product_id,
    s.sub_time,
    s.sub_amount,
    s.subscription_channel,
    s.initial_audit_status
FROM subscription_info s
JOIN customer_info c ON s.customer_id = c.customer_id
JOIN customer_info ci ON s.insured_id = ci.customer_id;

-- 创建 ODS 层表：ods_policy_cleaned
CREATE TABLE ods_policy_cleaned AS
SELECT
    p.policy_id,
    p.subscription_id,
    p.effective_date,
    p.decay_date,
    p.pre_amount,
    p.policy_status,
    n.nucleation_result,
    n.nucleation_remarks
FROM policy_info p
JOIN nucleation_info n ON p.subscription_id = n.subscription_id;

-- 创建 ODS 层表：ods_claim_cleaned
CREATE TABLE ods_claim_cleaned AS
SELECT
    c.claim_id,
    c.policy_id,
    ca.claim_time,
    ca.claim_amount,
    ca.claim_desc,
    a.claim_audit_id,
    a.audit_time,
    a.audit_result,
    a.audit_amount,
    a.audit_remarks,
    p.pay_id,
    p.pay_time,
    p.pay_account
FROM claim_application c
JOIN claim_audit a ON c.claim_id = a.claim_id
JOIN claim_pay p ON a.claim_audit_id = p.claim_audit_id;



-- 按日统计保费收入（ADS 层）
CREATE TABLE ads_daily_premium_income AS
SELECT
    DATE(sub_time) AS date,
    SUM(sub_amount) AS daily_premium_income
FROM ods_subscription_cleaned
GROUP BY DATE(sub_time);

-- 按七日统计保费收入（ADS 层）
CREATE TABLE ads_weekly_premium_income AS
SELECT
    DATE_FORMAT(sub_time, '%Y-%m-%d') AS year_month_day,
    SUM(sub_amount) AS weekly_premium_income
FROM ods_subscription_cleaned
WHERE sub_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE_FORMAT(sub_time, '%Y-%m-%d');

-- 按月统计保费收入（ADS 层）
CREATE TABLE ads_monthly_premium_income AS
SELECT
    DATE_FORMAT(sub_time, '%Y-%m') AS year_month,
    SUM(sub_amount) AS monthly_premium_income
FROM ods_subscription_cleaned
GROUP BY DATE_FORMAT(sub_time, '%Y-%m');

-- 按年统计保费收入（ADS 层）
CREATE TABLE ads_annual_premium_income AS
SELECT
    YEAR(sub_time) AS year,
    SUM(sub_amount) AS annual_premium_income
FROM ods_subscription_cleaned
GROUP BY YEAR(sub_time);

-- 按日统计理赔金额（ADS 层）
CREATE TABLE ads_daily_claim_amount AS
SELECT
    DATE(pay_time) AS date,
    SUM(audit_amount) AS daily_claim_amount
FROM ods_claim_cleaned
GROUP BY DATE(pay_time);

-- 按七日统计理赔金额（ADS 层）
CREATE TABLE ads_weekly_claim_amount AS
SELECT
    DATE_FORMAT(pay_time, '%Y-%m-%d') AS year_month_day,
    SUM(audit_amount) AS weekly_claim_amount
FROM ods_claim_cleaned
WHERE pay_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE_FORMAT(pay_time, '%Y-%m-%d');

-- 按月统计理赔金额（ADS 层）
CREATE TABLE ads_monthly_claim_amount AS
SELECT
    DATE_FORMAT(pay_time, '%Y-%m') AS year_month,
    SUM(audit_amount) AS monthly_claim_amount
FROM ods_claim_cleaned
GROUP BY DATE_FORMAT(pay_time, '%Y-%m');

-- 按年统计理赔金额（ADS 层）
CREATE TABLE ads_annual_claim_amount AS
SELECT
    YEAR(pay_time) AS year,
    SUM(audit_amount) AS annual_claim_amount
FROM ods_claim_cleaned
GROUP BY YEAR(pay_time);

-- 计算每日理赔率（ADS 层）
CREATE TABLE ads_daily_claim_rate AS
SELECT
    dpi.date,
    dpi.daily_premium_income,
    dca.daily_claim_amount,
    (dca.daily_claim_amount / dpi.daily_premium_income) * 100 AS daily_claim_rate
FROM ads_daily_premium_income dpi
LEFT JOIN ads_daily_claim_amount dca ON dpi.date = dca.date;

-- 计算七日理赔率（ADS 层）
CREATE TABLE ads_weekly_claim_rate AS
SELECT
    wpi.year_month_day,
    wpi.weekly_premium_income,
    wca.weekly_claim_amount,
    (wca.weekly_claim_amount / wpi.weekly_premium_income) * 100 AS weekly_claim_rate
FROM ads_weekly_premium_income wpi
LEFT JOIN ads_weekly_claim_amount wca ON wpi.year_month_day = wca.year_month_day;

-- 计算月理赔率（ADS 层）
CREATE TABLE ads_monthly_claim_rate AS
SELECT
    mbi.year_month,
    mbi.monthly_premium_income,
    mca.monthly_claim_amount,
    (mca.monthly_claim_amount / mbi.monthly_premium_income) * 100 AS monthly_claim_rate
FROM ads_monthly_premium_income mbi
LEFT JOIN ads_monthly_claim_amount mca ON mbi.year_month = mca.year_month;

-- 计算年理赔率（ADS 层）
CREATE TABLE ads_annual_claim_rate AS
SELECT
    abi.year,
    abi.annual_premium_income,
    aca.annual_claim_amount,
    (aca.annual_claim_amount / abi.annual_premium_income) * 100 AS annual_claim_rate
FROM ads_annual_premium_income abi
LEFT JOIN ads_annual_claim_amount aca ON abi.year = aca.year;

-- 按日统计新增投保数量（ADS 层）
CREATE TABLE ads_daily_new_subscriptions AS
SELECT
    DATE(sub_time) AS date,
    COUNT(*) AS daily_new_subscriptions
FROM ods_subscription_cleaned
WHERE sub_time >= DATE_SUB(CURDATE(), INTERVAL 1 DAY)
GROUP BY DATE(sub_time);

-- 按七日统计新增投保数量（ADS 层）
CREATE TABLE ads_weekly_new_subscriptions AS
SELECT
    DATE_FORMAT(sub_time, '%Y-%m-%d') AS year_month_day,
    COUNT(*) AS weekly_new_subscriptions
FROM ods_subscription_cleaned
WHERE sub_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE_FORMAT(sub_time, '%Y-%m-%d');

-- 按月统计新增投保数量（ADS 层）
CREATE TABLE ads_monthly_new_subscriptions AS
SELECT
    DATE_FORMAT(sub_time, '%Y-%m') AS year_month,
    COUNT(*) AS monthly_new_subscriptions
FROM ods_subscription_cleaned
GROUP BY DATE_FORMAT(sub_time, '%Y-%m');

-- 按年统计新增投保数量（ADS 层）
CREATE TABLE ads_annual_new_subscriptions AS
SELECT
    YEAR(sub_time) AS year,
    COUNT(*) AS annual_new_subscriptions
FROM ods_subscription_cleaned
GROUP BY YEAR(sub_time);

-- 统计有效保单数（ADS 层）
CREATE TABLE ads_current_active_policies AS
SELECT
    COUNT(*) AS current_active_policies
FROM ods_policy_cleaned
WHERE policy_status = '正常生效';

-- 计算每日投保转化率（ADS 层）
CREATE TABLE ads_daily_conversion_rate AS
SELECT
    DATE(sub_time) AS date,
    (COUNT(policy_id) / COUNT(subscription_id)) * 100 AS daily_conversion_rate
FROM ods_subscription_cleaned
WHERE DATE(sub_time) = DATE(CURDATE())
GROUP BY DATE(sub_time);

-- 计算七日投保转化率（ADS 层）
CREATE TABLE ads_weekly_conversion_rate AS
SELECT
    (COUNT(policy_id) / COUNT(subscription_id)) * 100 AS weekly_conversion_rate
FROM ods_subscription_cleaned
WHERE sub_time >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY DATE_FORMAT(sub_time, '%Y-%m-%d');

-- 计算月投保转化率（ADS 层）
CREATE TABLE ads_monthly_conversion_rate AS
SELECT
    DATE_FORMAT(sub_time, '%Y-%m') AS year_month,
    (COUNT(policy_id) / COUNT(subscription_id)) * 100 AS monthly_conversion_rate
FROM ods_subscription_cleaned
GROUP BY DATE_FORMAT(sub_time, '%Y-%m');

-- 计算年投保转化率（ADS 层）
CREATE TABLE ads_annual_conversion_rate AS
SELECT
    YEAR(sub_time) AS year,
    (COUNT(policy_id) / COUNT(subscription_id)) * 100 AS annual_conversion_rate
FROM ods_subscription_cleaned
GROUP BY YEAR(sub_time);

-- 计算月续保率（ADS 层）
CREATE TABLE ads_monthly_renewal_rate AS
SELECT
    DATE_FORMAT(renew_time, '%Y-%m') AS year_month,
    (COUNT(CASE WHEN renew_status = '已续保' THEN 1 ELSE NULL END) / COUNT(*)) * 100 AS monthly_renewal_rate
FROM ods_renew_info
WHERE renew_time >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY DATE_FORMAT(renew_time, '%Y-%m');

-- 计算年续保率（ADS 层）
CREATE TABLE ads_annual_renewal_rate AS
SELECT
    YEAR(renew_time) AS year,
    (COUNT(CASE WHEN renew_status = '已续保' THEN 1 ELSE NULL END) / COUNT(*)) * 100 AS annual_renewal_rate
FROM ods_renew_info
GROUP BY YEAR(renew_time);
