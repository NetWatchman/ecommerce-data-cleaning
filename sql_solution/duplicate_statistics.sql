-- ============================================
-- 需求4：统计"完全重复行数"和"主键（order_id）重复数"
-- 两者为什么可能不相等？
-- ============================================

USE orders_clean;
GO

-- 4.1 统计完全重复行数
-- 方法：用所有列做GROUP BY，找出出现次数>1的组合，然后统计这些重复行的总数
-- 注意：需要在原始表 orders_raw 上执行（清洗表已去重）
-- 如果orders_raw表不存在，可以用sql_cleaned_data代替

-- 先找出哪些行是完全重复的（所有列值都一样）
SELECT 
    order_id, user_id, user_name, phone, gender, age,
    province, city, order_time, pay_time, product_name,
    category, quantity, unit_price, amount, pay_method,
    status, is_refund, rating,
    COUNT(*) AS [重复次数]
FROM dbo.orders_raw
GROUP BY order_id, user_id, user_name, phone, gender, age,
         province, city, order_time, pay_time, product_name,
         category, quantity, unit_price, amount, pay_method,
         status, is_refund, rating
HAVING COUNT(*) > 1;
GO

-- 统计完全重复行的总数（不含第一份）
DECLARE @dup_full_count INT;
SELECT @dup_full_count = ISNULL(SUM(cnt - 1), 0)
FROM (
    SELECT COUNT(*) AS cnt
    FROM dbo.orders_raw
    GROUP BY order_id, user_id, user_name, phone, gender, age,
             province, city, order_time, pay_time, product_name,
             category, quantity, unit_price, amount, pay_method,
             status, is_refund, rating
    HAVING COUNT(*) > 1
) AS t;

SELECT @dup_full_count AS [完全重复行数（需删除的冗余行）];
GO

-- 4.2 统计主键（order_id）重复数
-- 找出order_id重复的行
SELECT order_id, COUNT(*) AS [同order_id的行数]
FROM dbo.orders_raw
GROUP BY order_id
HAVING COUNT(*) > 1;
GO

-- 统计有多少个order_id是重复的
SELECT COUNT(DISTINCT order_id) AS [重复的order_id数量]
FROM (
    SELECT order_id FROM dbo.orders_raw
    GROUP BY order_id
    HAVING COUNT(*) > 1
) AS t;
GO

-- 统计重复的order_id对应的总行数
SELECT SUM(cnt) AS [重复order_id对应的总行数]
FROM (
    SELECT order_id, COUNT(*) AS cnt
    FROM dbo.orders_raw
    GROUP BY order_id
    HAVING COUNT(*) > 1
) AS t;
GO

-- ============================================
-- 分析说明（两者为什么可能不相等）：
-- ============================================
-- 
-- "完全重复行" vs "主键(order_id)重复数" 的区别：
--
-- 1. 完全重复行 = 所有列的值都完全相同的行
--    例：行A和行B的order_id、user_id、product_name、amount...所有列都一样
--    -> 这才是真正的"重复数据"，应该删除冗余行
--
-- 2. order_id重复 = 只要order_id相同就算重复，其他列可以不同
--    例：同一order_id下买了不同商品（多商品订单拆分成多行）
--    -> 这不一定是不正常的！电商场景中一个订单可以包含多个商品
--
-- 3. 两者不相等的原因举例：
--    场景1：真正的重复数据
--      行1: order_id=001, product=手机, amount=5999
--      行2: order_id=001, product=手机, amount=5999
--      -> 完全重复=1行, order_id重复=1个(order_id=001)
--      -> 两者相等
--
--    场景2：同一订单买了不同商品（正常业务）
--      行1: order_id=002, product=手机, amount=5999
--      行2: order_id=002, product=耳机, amount=299
--      -> 完全重复=0行(两行不完全相同), order_id重复=1个
--      -> 两者不相等！order_id重复但并非脏数据
--
--    场景3：混合情况
--      行1: order_id=003, product=手机, amount=5999
--      行2: order_id=003, product=手机, amount=5999
--      行3: order_id=003, product=耳机, amount=299
--      -> 完全重复=1行(行1和行2完全相同), order_id重复=1个
--      -> 两者不相等！order_id=003有3行但只有2行是完全重复的
--
-- 结论：
-- - 完全重复行数 <= order_id重复行数（完全重复一定是order_id重复的子集）
-- - 当两者相等时，说明所有order_id重复的行都是完全一样的（真正的重复数据）
-- - 当两者不相等时，说明有些order_id重复的行在其他列上有差异（可能是多商品订单）
-- - 清洗策略：删除完全重复行（保留一份），但保留order_id重复但内容不同的行
-- ============================================