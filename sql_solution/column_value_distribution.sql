-- gender 取值分布（发现问题：不止'男/女'，还有 M/male/F/1/2/0/-/未知）
SELECT gender, COUNT(*) AS cnt FROM orders_raw GROUP BY gender ORDER BY cnt DESC;

-- status 取值分布（发现问题：中英文混杂，'已完成'出现两次说明有全角空格）
SELECT status, COUNT(*) AS cnt FROM orders_raw GROUP BY status ORDER BY cnt DESC;

-- is_refund 取值分布
SELECT is_refund, COUNT(*) AS cnt FROM orders_raw GROUP BY is_refund;

-- rating 取值分布（发现问题：含'暂无'非数字文本）
SELECT rating, COUNT(*) AS cnt FROM orders_raw GROUP BY rating;

-- age 取值范围（发现问题：有-3、0、200等异常值）
SELECT MIN(age) AS min_age, MAX(age) AS max_age FROM orders_raw WHERE age IS NOT NULL;

-- amount 是否有负值（发现问题：存在负金额）
SELECT order_id, amount FROM orders_raw WHERE amount < 0;

-- 重复订单号检查
SELECT order_id, COUNT(*) AS cnt FROM orders_raw GROUP BY order_id HAVING COUNT(*) > 1;