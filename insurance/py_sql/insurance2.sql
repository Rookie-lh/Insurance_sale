-- 客户信息表
CREATE TABLE customer_info (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    gender CHAR(1),
    id_number VARCHAR(18),
    contact_info VARCHAR(50),
    address VARCHAR(100)
);
-- 保险产品信息表
CREATE TABLE product_info (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    duty VARCHAR(200),
    ex_duty VARCHAR(200),
    period INT,
    pre_cal_way VARCHAR(50)
);

-- 投保信息表
CREATE TABLE subscription_info (
    subscription_id INT PRIMARY KEY,
    customer_id INT,
    insured_id INT,
    product_id INT,
    sub_time DATETIME,
    sub_amount DECIMAL(10,2),
    subscription_channel VARCHAR(50),
    initial_audit_status VARCHAR(20),
    FOREIGN KEY (customer_id) REFERENCES customer_info(customer_id),
    FOREIGN KEY (insured_id) REFERENCES customer_info(customer_id),
    FOREIGN KEY (product_id) REFERENCES product_info(product_id)
);

-- 核保信息表
CREATE TABLE nucleation_info (
    nucleation_id INT PRIMARY KEY,
    subscription_id INT,
    nucleation_time DATETIME,
    nucleation_result VARCHAR(20),
    nucleation_remarks VARCHAR(200),
    FOREIGN KEY (subscription_id) REFERENCES subscription_info(subscription_id)
);

-- 保单信息表
CREATE TABLE policy_info (
    policy_id INT PRIMARY KEY,
    subscription_id INT,
    effective_date DATE,
    decay_date DATE,
    pre_amount DECIMAL(10,2),
    policy_status VARCHAR(20),
    FOREIGN KEY (subscription_id) REFERENCES subscription_info(subscription_id)
);

-- 理赔申请表
CREATE TABLE claim_application (
    claim_id INT PRIMARY KEY,
    policy_id INT,
    claim_time DATETIME,
    claim_amount DECIMAL(10,2),
    claim_desc VARCHAR(200),
    FOREIGN KEY (policy_id) REFERENCES policy_info(policy_id)
);

-- 理赔审核表
CREATE TABLE claim_audit (
    claim_audit_id INT PRIMARY KEY,
    claim_id INT,
    audit_time DATETIME,
    audit_result VARCHAR(20),
    audit_amount DECIMAL(10,2),
    audit_remarks VARCHAR(200),
    FOREIGN KEY (claim_id) REFERENCES claim_application(claim_id)
);

-- 索赔信息表
CREATE TABLE claim_pay (
    pay_id INT PRIMARY KEY,
    claim_audit_id INT,
    pay_time DATETIME,
    pay_account VARCHAR(50),
    FOREIGN KEY (claim_audit_id) REFERENCES claim_audit(claim_audit_id)
);

-- 续保信息表
CREATE TABLE renew_info (
    renew_id INT PRIMARY KEY,
    policy_id INT,
    renew_time DATETIME,
    renew_status VARCHAR(20),
    FOREIGN KEY (policy_id) REFERENCES policy_info(policy_id)
);

-- 客户信息表示例数据
INSERT INTO customer_info (customer_id, customer_name, gender, id_number, contact_info, address) VALUES
(1, '张三', 'M', '110105199001010011', '13800138000', '北京市海淀区'),
(2, '李四', 'F', '110105199102020022', '13900139000', '北京市朝阳区'),
(3, '王五', 'M', '110105199203030033', '13900139001', '上海市浦东新区'),
(4, '赵六', 'F', '110105199304040044', '13900139002', '上海市黄浦区');

-- 保险产品信息表示例数据
INSERT INTO product_info (product_id, product_name, duty, ex_duty, period, pre_cal_way) VALUES
(101, '经典寿险', '在保险期间内提供身故保障', '自杀行为发生在保险合同生效后两年内', 20, '固定金额'),
(102, '两全寿险', '满期生存返还保额', '战争、军事冲突等造成的身故', 30, '年缴按比例计算'),
(103, '分红寿险', '除身故保障外，还提供红利分配', '退保后的现金价值较低', 25, '首年按固定金额，之后按比例');

-- 投保信息表示例数据
INSERT INTO subscription_info (subscription_id, customer_id, insured_id, product_id, sub_time, sub_amount, subscription_channel, initial_audit_status) VALUES
(1001, 1, 1, 101, '2023-01-01 10:00:00', 50000, '线上官网', '审核通过'),
(1002, 2, 2, 102, '2023-01-02 11:00:00', 60000, '线下代理人', '审核中'),
(1003, 3, 4, 103, '2023-01-03 12:00:00', 70000, '线上移动端', '审核驳回'),
(1004, 4, 3, 101, '2023-01-04 13:00:00', 80000, '线下营业厅', '审核通过');

-- 核保信息表示例数据
INSERT INTO nucleation_info (nucleation_id, subscription_id, nucleation_time, nucleation_result, nucleation_remarks) VALUES
(2001, 1001, '2023-01-01 10:30:00', '通过', '核保过程顺利'),
(2002, 1002, '2023-01-02 11:30:00', '通过', '需补充健康证明'),
(2003, 1003, '2023-01-03 12:30:00', '拒保', '被保人风险过高'),
(2004, 1004, '2023-01-04 13:30:00', '通过', '无异常情况');

-- 保单信息表示例数据
INSERT INTO policy_info (policy_id, subscription_id, effective_date, decay_date, pre_amount, policy_status) VALUES
(3001, 1001, '2023-02-01', '2043-02-01', 50000, '正常生效'),
(3002, 1002, '2023-02-02', '2053-02-02', 60000, '正常生效'),
(3003, 1003, NULL, NULL, 70000, '已拒保'),
(3004, 1004, '2023-02-04', '2043-02-04', 80000, '正常生效');

-- 理赔申请表示例数据
INSERT INTO claim_application (claim_id, policy_id, claim_time, claim_amount, claim_desc) VALUES
(4001, 3001, '2023-03-01 09:00:00', 50000, '被保人因意外身故'),
(4002, 3002, '2023-03-02 10:00:00', 60000, '被保人因重疾身故'),
(4003, 3004, '2023-03-03 11:00:00', 80000, '被保人因疾病身故');

-- 索赔支付表示例数据
INSERT INTO claim_pay (pay_id, claim_audit_id, pay_time, pay_account) VALUES
(6001, 5001, '2023-03-01 09:45:00', '1234567890123456'),
(6002, 5002, '2023-03-02 10:45:00', '2345678901234567'),
(6003, 5003, '2023-03-03 11:45:00', '3456789012345678');

-- 续保信息表示例数据
INSERT INTO renew_info (renew_id, policy_id, renew_time, renew_status) VALUES
(7001, 3001, '2042-01-01 08:00:00', '已续保'),
(7002, 3002, '2052-01-01 08:00:00', '已续保'),
(7003, 3004, '2043-01-04 08:00:00', '未续保');







































