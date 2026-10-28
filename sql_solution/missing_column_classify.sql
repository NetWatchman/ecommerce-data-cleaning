-- ============================================
-- 需求3：把缺失列分成两类，并说明理由
--   - 结构性缺失：业务上本来就不该有值，不能填
--   - 脏缺失：本该有值却丢了，要处理
-- ============================================

USE orders_clean;
GO

-- 3.1 先查看各列的缺失情况（结合需求2的结果）
DECLARE @total INT;
SELECT @total = COUNT(*) FROM dbo.sql_cleaned_data;

SELECT 
    col_name AS [列名],
    null_count AS [缺失数],
    ROUND(CAST(null_count AS FLOAT) / @total * 100, 2) AS [缺失率(%)]
FROM (
    SELECT 'age' AS col_name, SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS null_count FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'city', SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'order_time', SUM(CASE WHEN order_time IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'pay_time', SUM(CASE WHEN pay_time IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'quantity', SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'unit_price', SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'amount', SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'phone', SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'rating', SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data
) AS t
WHERE null_count > 0
ORDER BY [缺失率(%)] DESC;
GO

-- 3.2 查看缺失行的具体数据，辅助判断缺失原因
-- 查看age为空的行，了解是什么样的数据导致无法转换
SELECT TOP 10 order_id, user_id, age, user_name 
FROM dbo.sql_cleaned_data 
WHERE age IS NULL;
GO

-- 查看rating为空的行
SELECT TOP 10 order_id, user_id, rating, status, order_time 
FROM dbo.sql_cleaned_data 
WHERE rating IS NULL;
GO

-- 查看order_time为空的行
SELECT TOP 10 order_id, order_time, status, pay_time 
FROM dbo.sql_cleaned_data 
WHERE order_time IS NULL;
GO

-- ============================================
-- 分析说明（缺失值分类）：
-- ============================================
-- 【结构性缺失】（业务上本来就不该有值，不能填）
-- ------------------------------------------------
-- 1. rating（评分）
--    理由：在电商业务中，并非所有订单都会产生评分。
--    只有用户收到货并满意后主动评价的订单才有rating。
--    刚发货的订单、尚未收货的订单、已取消的订单都不会有评分。
--    这是业务规则决定的结构性缺失，不应填充，应保留为NULL。
--
--
-- 【脏缺失】（本该有值却丢了，需要处理）
-- ------------------------------------------------
-- 1. age（年龄）
--    理由：每个订单都关联一个用户，用户应该有年龄信息。
--    出现NULL是因为原始CSV中该字段包含无法转换为整数的值
--    （如空字符串、"未知"、字母等），属于数据质量问题。
--    处理方式：可填充为中位数年龄，或标记为"未知"。
--
-- 2. order_time（下单时间）
--    理由：订单必须有下单时间，这是订单的核心字段。
--    出现NULL是因为原始日期格式不标准导致TRY_CONVERT转换失败。
--    处理方式：尝试用更宽松的日期解析方式修复，或标记为"未知"。
--
-- 3. pay_time（支付时间）
--    理由：已完成/已支付的订单应该有支付时间。
--    出现NULL可能是因为支付时间与下单时间相同被覆盖，
--    或原始数据格式问题导致转换失败。
--    处理方式：同order_time。
--
-- 4. quantity（购买数量）
--    理由：任何订单都必须有购买数量，不可能为0或空。
--    出现NULL是因为原始值无法转换为整数。
--    处理方式：填充为1（最小购买单位）或根据同user_id的其他订单推断。
--
-- 5. unit_price（单价）
--    理由：订单中的商品必须有价格。
--    出现NULL是因为原始值含特殊字符导致转换失败。
--    处理方式：填充为该商品的平均单价。
--
-- 6. amount（金额）
--    理由：订单必须有金额。
--    出现NULL是因为原始值含特殊字符或负号导致转换失败。
--    处理方式：quantity * unit_price 重新计算，或填充为中位数。
--
-- 7. phone（手机号）
--    理由：用户联系信息是订单必备字段。
--    出现NULL是因为原始CSV中该字段确实为空。
--    处理方式：无法合理填充（不知道真实手机号），可标记为"未知"或直接删除该行。
-- ============================================