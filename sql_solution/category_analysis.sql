-- ============================================
-- 需求6：对分类列打印unique()，找出"同一含义被写成多种形式"的情况
-- 分类列：gender, status, pay_method, province
-- ============================================

USE orders_clean;
GO

-- 6.1 gender（性别）的唯一值
-- 清洗后应该只有'男'、'女'、'未知'，但原始数据可能有多种写法
SELECT DISTINCT gender AS [性别唯一值]
FROM dbo.sql_cleaned_data
ORDER BY gender;
GO

-- 查看原始表中gender的未清洗值（如果有orders_raw表）
-- 注意：orders_raw表中gender是VARCHAR，可能含多种写法
SELECT DISTINCT 
    REPLACE(REPLACE(REPLACE(REPLACE(gender, ' ', ''), CHAR(13), ''), CHAR(10), ''), CHAR(9), '') AS [原始性别_去空格],
    LOWER(REPLACE(REPLACE(REPLACE(REPLACE(gender, ' ', ''), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) AS [原始性别_小写]
FROM dbo.orders_raw;
GO

-- ============================================
-- 同一含义被写成多种形式（gender）举例：
-- ============================================
-- 原始数据中可能的写法：
--   "男"、"Male"、"male"、"M"、"m"、"Boy"、"boy"、"1"、" Masculino"（带空格）
--   以上都表示"男性"，但写法不同
--   清洗逻辑：统一转小写->映射为'男'
--
-- 举例：
--   "Male" -> 英文大写 -> 应归为"男"
--   "m"    -> 英文缩写小写 -> 应归为"男"
-- ============================================

-- 6.2 status（订单状态）的唯一值
SELECT DISTINCT status AS [订单状态唯一值]
FROM dbo.sql_cleaned_data
ORDER BY status;
GO

-- 查看原始表中status的未清洗值
SELECT DISTINCT 
    REPLACE(REPLACE(REPLACE(REPLACE(status, ' ', ''), CHAR(13), ''), CHAR(10), ''), CHAR(9), '') AS [原始状态_去空格],
    LOWER(REPLACE(REPLACE(REPLACE(REPLACE(status, ' ', ''), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) AS [原始状态_小写]
FROM dbo.orders_raw;
GO

-- ============================================
-- 同一含义被写成多种形式（status）举例：
-- ============================================
-- 原始数据中可能的写法：
--   "已完成"、"Completed"、"completed"、"COMPLETED"、"完成"、"Finish"
--   以上都表示订单已完成，但写法不同
--   清洗逻辑：统一转小写->映射为'已完成'
--
-- 举例：
--   "Completed" -> 英文大写 -> 应归为"已完成"
--   "completed" -> 英文小写 -> 应归为"已完成"
-- ============================================

-- 6.3 pay_method（支付方式）的唯一值
SELECT DISTINCT pay_method AS [支付方式唯一值]
FROM dbo.sql_cleaned_data
ORDER BY pay_method;
GO

-- 查看原始表中pay_method的未清洗值
SELECT DISTINCT 
    REPLACE(REPLACE(REPLACE(REPLACE(pay_method, ' ', ''), CHAR(13), ''), CHAR(10), ''), CHAR(9), '') AS [原始支付方式_去空格],
    LOWER(REPLACE(REPLACE(REPLACE(REPLACE(pay_method, ' ', ''), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) AS [原始支付方式_小写]
FROM dbo.orders_raw;
GO

-- ============================================
-- 同一含义被写成多种形式（pay_method）举例：
-- ============================================
-- 原始数据中可能的写法：
--   "支付宝"、"Alipay"、"alipay"、"ALIPAY"、"阿里支付"、"zhifubao"
--   "微信支付"、"WeChat Pay"、"weixin"、"微信"
--   以上分别表示相同的支付方式，但写法不同
--   清洗逻辑：去空格->统一写法
--
-- 举例：
--   "Alipay"    -> 英文驼峰 -> 应归为"支付宝"
--   "alipay"    -> 英文小写 -> 应归为"支付宝"
-- ============================================

-- 6.4 province（省份）的唯一值
SELECT DISTINCT province AS [省份唯一值]
FROM dbo.sql_cleaned_data
ORDER BY province;
GO

-- 查看原始表中province的未清洗值
SELECT DISTINCT 
    REPLACE(REPLACE(REPLACE(REPLACE(province, ' ', ''), CHAR(13), ''), CHAR(10), ''), CHAR(9), '') AS [原始省份_去空格],
    LOWER(REPLACE(REPLACE(REPLACE(REPLACE(province, ' ', ''), CHAR(13), ''), CHAR(10), ''), CHAR(9), '')) AS [原始省份_小写]
FROM dbo.orders_raw;
GO

-- ============================================
-- 同一含义被写成多种形式（province）举例：
-- ============================================
-- 原始数据中可能的写法：
--   "北京市"、"北京"、"北京市市"、"北京省"
--   "上海市"、"上海"、"上海市市"
--   "广东"、"广东省"、"广东省广州市"（省+市混用）
--   "GD"、"gd"、"广东"（缩写vs全称）
--   以上分别表示相同的省份，但写法不同
--
-- 举例：
--   "北京"  -> 简称 -> 应归为"北京市"
--   "北京市" -> 全称 -> 应归为"北京市"
-- ============================================

-- ============================================
-- 汇总：查看清洗后各分类列的分布统计
-- ============================================

-- gender分布
SELECT gender AS [性别], COUNT(*) AS [人数], 
       ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM dbo.sql_cleaned_data) * 100, 2) AS [占比(%)]
FROM dbo.sql_cleaned_data
GROUP BY gender
ORDER BY [人数] DESC;
GO

-- status分布
SELECT status AS [订单状态], COUNT(*) AS [订单数], 
       ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM dbo.sql_cleaned_data) * 100, 2) AS [占比(%)]
FROM dbo.sql_cleaned_data
GROUP BY status
ORDER BY [订单数] DESC;
GO

-- pay_method分布
SELECT pay_method AS [支付方式], COUNT(*) AS [订单数], 
       ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM dbo.sql_cleaned_data) * 100, 2) AS [占比(%)]
FROM dbo.sql_cleaned_data
GROUP BY pay_method
ORDER BY [订单数] DESC;
GO

-- province分布
SELECT province AS [省份], COUNT(*) AS [订单数], 
       ROUND(CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM dbo.sql_cleaned_data) * 100, 2) AS [占比(%)]
FROM dbo.sql_cleaned_data
GROUP BY province
ORDER BY [订单数] DESC;
GO