-- =============================================
-- 终极防报错版：电商订单数据清洗脚本 
-- =============================================
-- 使用说明：请确保已经将CSV数据成功导入到 [orders_raw] 表中，且所有列都为文本(VARCHAR)格式。
-- =============================================

USE orders_clean;
GO

-- =============================================
-- 1. 如果之前运行过，先删除清洗后的结果表
-- =============================================
IF OBJECT_ID('sql_cleaned_data', 'U') IS NOT NULL
    DROP TABLE sql_cleaned_data;
GO

-- =============================================
-- 2. 创建目标清洗结果表 (19个字段)
-- =============================================
CREATE TABLE sql_cleaned_data (
    order_id VARCHAR(50), user_id VARCHAR(50), user_name VARCHAR(100),
    phone VARCHAR(20), gender VARCHAR(10), age INT,
    province VARCHAR(50), city VARCHAR(50), order_time DATETIME,
    pay_time DATETIME, product_name VARCHAR(100), category VARCHAR(50),
    quantity INT, unit_price DECIMAL(12,2), amount DECIMAL(12,2),
    pay_method VARCHAR(20), status VARCHAR(20), is_refund INT,
    rating DECIMAL(2,1)
);
GO

-- =============================================
-- 3. 执行清洗逻辑（万能防报错版）
-- =============================================
;WITH RawDataCleaned AS (
    SELECT
        order_id,
        user_id,
        
        -- 用户姓名：去首尾空格
        LTRIM(RTRIM(user_name)) AS user_name,
        
        -- 手机号：去空格和横杠
        REPLACE(REPLACE(phone, ' ', ''), '-', '') AS phone,
        
        -- 性别：统一为 男/女/未知
        CASE 
            WHEN gender IN ('男', 'M', 'male', '1') THEN '男'
            WHEN gender IN ('女', 'F', 'female', '2') THEN '女'
            ELSE '未知'
        END AS gender,
        
        -- 年龄防报错清洗：确保只转换纯数字，遇到 '??' 等非法字符自动设为 NULL
        CASE 
            WHEN age NOT LIKE '%[^0-9]%' AND LEN(age) > 0 
                 AND CAST(age AS INT) BETWEEN 1 AND 120 
            THEN CAST(age AS INT)
            ELSE NULL 
        END AS age,
        
        -- 省份：去首尾空格
        LTRIM(RTRIM(province)) AS province,
        
        -- 城市：缺失值填充为 '未知'
        ISNULL(NULLIF(LTRIM(RTRIM(city)), ''), '未知') AS city,
        
        -- 下单时间：统一格式转换
        TRY_CONVERT(DATETIME, REPLACE(order_time, '/', '-'), 120) AS order_time,
        
        -- 支付时间：统一格式转换
        TRY_CONVERT(DATETIME, REPLACE(pay_time, '/', '-'), 120) AS pay_time,
        
        -- 商品名称：去首尾空格
        LTRIM(RTRIM(product_name)) AS product_name,
        
        category,
        
        -- 数量防报错清洗
        CASE 
            WHEN quantity NOT LIKE '%[^0-9]%' AND LEN(quantity) > 0 
            THEN CAST(quantity AS INT)
            ELSE NULL 
        END AS quantity,
        
        -- 单价：去掉符号转数字
        TRY_CAST(REPLACE(REPLACE(REPLACE(unit_price, '¥', ''), '元', ''), ',', '') AS DECIMAL(12,2)) AS unit_price,
        
        -- 金额：负数取绝对值
        ABS(TRY_CAST(amount AS DECIMAL(12,2))) AS amount,
        
        -- 支付方式：去空格
        REPLACE(LTRIM(RTRIM(pay_method)), ' ', '') AS pay_method,
        
        -- 订单状态：统一中文表述
        CASE 
            WHEN status IN ('已完成', 'Completed', 'completed') THEN '已完成'
            WHEN status IN ('已支付', 'paid', 'PAID', '已付款') THEN '已支付'
            WHEN status IN ('退款中', 'Refunding', 'refund') THEN '退款中'
            WHEN status IN ('已取消', 'Cancelled', 'cancel') THEN '已取消'
            ELSE '未知'
        END AS status,
        
        -- 是否退款：转为 1/0
        CASE WHEN is_refund = '是' THEN 1 ELSE 0 END AS is_refund,
        
        -- 评分防报错清洗：'暂无'转为NULL，否则尝试转为小数
        CASE
            WHEN rating IN ('暂无', 'NULL', '') THEN NULL
            WHEN rating NOT LIKE '%[^0-9.]%' AND LEN(rating) > 0 
            THEN TRY_CAST(rating AS DECIMAL(2,1))
            ELSE NULL 
        END AS rating
    FROM orders_raw
),
-- 根据订单号 order_id 去重，保留第一条
Deduplicated AS (
    SELECT *,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY (SELECT NULL)) AS row_num
    FROM RawDataCleaned
)
-- 将清洗去重后的数据插入目标表
INSERT INTO sql_cleaned_data
SELECT 
    order_id, user_id, user_name, phone, gender, age, province, city, 
    order_time, pay_time, product_name, category, quantity, 
    unit_price, amount, pay_method, status, is_refund, rating
FROM Deduplicated 
WHERE row_num = 1;
GO

-- =============================================
-- 4. 打印最终清洗结果
-- =============================================
SELECT '总行数' AS '检查项', COUNT(*) AS '数量' FROM sql_cleaned_data
UNION ALL
SELECT '不重复订单数', COUNT(DISTINCT order_id) FROM sql_cleaned_data;
GO