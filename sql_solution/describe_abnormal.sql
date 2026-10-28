-- ============================================
-- 需求5：对数值列跑describe()，找出"明显超出常识的取值"
-- ============================================

USE orders_clean;
GO

-- 数值列包括：age, quantity, unit_price, amount, rating, is_refund
-- pandas的describe()会返回：count, mean, std, min, 25%, 50%, 75%, max
-- SQL中用聚合函数实现类似功能

-- 5.1 age（年龄）描述统计
SELECT 
    COUNT(*) AS [计数],
    COUNT(age) AS [非空计数],
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS [缺失数],
    MIN(age) AS [最小值],
    MAX(age) AS [最大值],
    ROUND(AVG(CAST(age AS FLOAT)), 2) AS [平均值],
    COUNT(DISTINCT age) AS [不同值数]
FROM dbo.sql_cleaned_data
WHERE age IS NOT NULL;
GO

-- 查看超出常识的age值（年龄应该在18~80之间，电商用户一般不低于18岁）
SELECT age, COUNT(*) AS [出现次数]
FROM dbo.sql_cleaned_data
WHERE age IS NOT NULL
  AND (age < 18 OR age > 100)
GROUP BY age
ORDER BY age;
GO

-- 5.2 quantity（购买数量）描述统计
SELECT 
    COUNT(*) AS [计数],
    COUNT(quantity) AS [非空计数],
    MIN(quantity) AS [最小值],
    MAX(quantity) AS [最大值],
    ROUND(AVG(CAST(quantity AS FLOAT)), 2) AS [平均值],
    COUNT(DISTINCT quantity) AS [不同值数]
FROM dbo.sql_cleaned_data
WHERE quantity IS NOT NULL;
GO

-- 查看超出常识的quantity值（数量应该是正整数，一般不会超过100）
SELECT quantity, COUNT(*) AS [出现次数]
FROM dbo.sql_cleaned_data
WHERE quantity IS NOT NULL
  AND (quantity <= 0 OR quantity > 100)
GROUP BY quantity
ORDER BY quantity;
GO

-- 5.3 unit_price（单价）描述统计
SELECT 
    COUNT(*) AS [计数],
    COUNT(unit_price) AS [非空计数],
    MIN(unit_price) AS [最小值],
    MAX(unit_price) AS [最大值],
    ROUND(AVG(CAST(unit_price AS FLOAT)), 2) AS [平均值],
    COUNT(DISTINCT unit_price) AS [不同值数]
FROM dbo.sql_cleaned_data
WHERE unit_price IS NOT NULL;
GO

-- 查看超出常识的unit_price值（单价应该是正数，一般不会超过100万）
SELECT unit_price, COUNT(*) AS [出现次数]
FROM dbo.sql_cleaned_data
WHERE unit_price IS NOT NULL
  AND (unit_price <= 0 OR unit_price > 1000000)
GROUP BY unit_price
ORDER BY unit_price;
GO

-- 5.4 amount（金额）描述统计
SELECT 
    COUNT(*) AS [计数],
    COUNT(amount) AS [非空计数],
    MIN(amount) AS [最小值],
    MAX(amount) AS [最大值],
    ROUND(AVG(CAST(amount AS FLOAT)), 2) AS [平均值],
    COUNT(DISTINCT amount) AS [不同值数]
FROM dbo.sql_cleaned_data
WHERE amount IS NOT NULL;
GO

-- 查看超出常识的amount值（金额应该是正数，一般不会超过100万）
SELECT amount, COUNT(*) AS [出现次数]
FROM dbo.sql_cleaned_data
WHERE amount IS NOT NULL
  AND (amount <= 0 OR amount > 1000000)
GROUP BY amount
ORDER BY amount;
GO

-- 5.5 rating（评分）描述统计
-- 评分范围应该是0.0~5.0
SELECT 
    COUNT(*) AS [计数],
    COUNT(rating) AS [非空计数],
    MIN(rating) AS [最小值],
    MAX(rating) AS [最大值],
    ROUND(AVG(CAST(rating AS FLOAT)), 2) AS [平均值],
    COUNT(DISTINCT rating) AS [不同值数]
FROM dbo.sql_cleaned_data
WHERE rating IS NOT NULL;
GO

-- 查看超出常识的rating值（评分应该在0.0~5.0之间）
SELECT rating, COUNT(*) AS [出现次数]
FROM dbo.sql_cleaned_data
WHERE rating IS NOT NULL
  AND (rating < 0 OR rating > 5)
GROUP BY rating
ORDER BY rating;
GO

-- 5.6 is_refund（是否退款）描述统计
-- 值应该是0或1
SELECT 
    COUNT(*) AS [计数],
    COUNT(is_refund) AS [非空计数],
    MIN(is_refund) AS [最小值],
    MAX(is_refund) AS [最大值],
    COUNT(DISTINCT is_refund) AS [不同值数],
    SUM(CASE WHEN is_refund = 0 THEN 1 ELSE 0 END) AS [值=0的个数],
    SUM(CASE WHEN is_refund = 1 THEN 1 ELSE 0 END) AS [值=1的个数]
FROM dbo.sql_cleaned_data;
GO

-- 查看超出常识的is_refund值（应该是0或1）
SELECT is_refund, COUNT(*) AS [出现次数]
FROM dbo.sql_cleaned_data
WHERE is_refund IS NOT NULL
  AND is_refund NOT IN (0, 1)
GROUP BY is_refund;
GO

-- ============================================
-- 分析说明（明显超出常识的取值）：
-- ============================================
-- 运行上面的查询后，重点关注以下异常：
--
-- 1. age（年龄）异常值可能包括：
--    - age < 18：未成年用户（电商注册通常要求年满18岁）
--    - age > 100：极端高龄（数据录入错误，可能把"25"录成"125"）
--    - age = 0：可能是占位符或默认值
--
-- 2. quantity（数量）异常值可能包括：
--    - quantity <= 0：购买数量不可能为0或负数
--    - quantity > 100：单次购买上百件（可能是批发/刷单）
--
-- 3. unit_price（单价）异常值可能包括：
--    - unit_price <= 0：商品价格不可能为0或负数（除非是赠品）
--    - unit_price > 1000000：单价超过100万（可能是录入错误，多打了个0）
--
-- 4. amount（金额）异常值可能包括：
--    - amount <= 0：订单金额不可能为0或负数
--    - amount > 1000000：订单金额超过100万
--
-- 5. rating（评分）异常值可能包括：
--    - rating < 0 或 rating > 5：评分超出0~5星范围
--
-- 6. is_refund（是否退款）异常值可能包括：
--    - 值不是0或1（如NULL、2、-1等）
--
-- 注意：发现异常值后先记录下来，后续再决定是删除、修正还是保留
-- ============================================