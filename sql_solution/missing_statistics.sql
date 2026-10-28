-- ============================================
-- 需求2：计算每列"缺失数+缺失率"，按缺失率从高到低排序
-- ============================================

USE orders_clean;
GO

-- 先获取总行数
DECLARE @total INT;
SELECT @total = COUNT(*) FROM dbo.sql_cleaned_data;

-- 逐列统计缺失数、缺失率，按缺失率降序排列
SELECT 
    col_name AS [列名],
    null_count AS [缺失数],
    @total AS [总行数],
    ROUND(CAST(null_count AS FLOAT) / @total * 100, 2) AS [缺失率(%)],
    CASE 
        WHEN null_count = 0 THEN '无缺失'
        WHEN CAST(null_count AS FLOAT) / @total * 100 < 1 THEN '缺失率<1%（轻微）'
        WHEN CAST(null_count AS FLOAT) / @total * 100 < 5 THEN '缺失率1%~5%（中等）'
        WHEN CAST(null_count AS FLOAT) / @total * 100 < 10 THEN '缺失率5%~10%（严重）'
        ELSE '缺失率>=10%（极严重）'
    END AS [缺失程度评估]
FROM (
    SELECT 'order_id' AS col_name, SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_count FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'user_id', SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'user_name', SUM(CASE WHEN user_name IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'phone', SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'gender', SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'age', SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'province', SUM(CASE WHEN province IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'city', SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'order_time', SUM(CASE WHEN order_time IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'pay_time', SUM(CASE WHEN pay_time IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'product_name', SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'category', SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'quantity', SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'unit_price', SUM(CASE WHEN unit_price IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'amount', SUM(CASE WHEN amount IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'pay_method', SUM(CASE WHEN pay_method IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'status', SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'is_refund', SUM(CASE WHEN is_refund IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data UNION ALL
    SELECT 'rating', SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) FROM dbo.sql_cleaned_data
) AS t
ORDER BY [缺失率(%)] DESC;
GO

-- ============================================
-- 分析说明：
-- ============================================
-- 运行上面的查询后，观察结果：
--
-- 1. 如果某列缺失率=0%，说明清洗逻辑已经妥善处理了该列的空值
--    （例如：gender列用了CASE WHEN...ELSE'未知'，city列用了ISNULL(NULLIF(...),'未知')）
--
-- 2. 如果某列缺失率>0%，需要进一步分析缺失原因：
--    - 是业务上允许为空？（结构性缺失 -> 需求3分析）
--    - 还是数据质量问题？（脏缺失 -> 需要填充或剔除）
--
-- 3. 常见缺失列及原因：
--    - rating: 用户未评分 -> 可能是结构性缺失
--    - age: 年龄字段无法转换为数字 -> 可能是脏缺失
--    - order_time/pay_time: 日期转换失败 -> 可能是脏缺失
--    - phone: 原始数据即为空 -> 可能是脏缺失
-- ============================================