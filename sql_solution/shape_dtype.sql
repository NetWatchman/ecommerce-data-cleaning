-- 逐列检查：非空数、唯一值数、NULL数
SELECT
    COUNT(*)                         AS total,
    COUNT(order_id)                  AS order_id_nok,
    COUNT(user_id)                   AS user_id_nok,
    COUNT(user_name)                 AS user_name_nok,
    COUNT(phone)                     AS phone_nok,
    COUNT(gender)                    AS gender_nok,
    COUNT(age)                       AS age_nok,
    COUNT(province)                  AS province_nok,
    COUNT(city)                      AS city_nok,
    COUNT(order_time)                AS order_time_nok,
    COUNT(pay_time)                  AS pay_time_nok,
    COUNT(product_name)              AS product_name_nok,
    COUNT(category)                  AS category_nok,
    COUNT(quantity)                  AS quantity_nok,
    COUNT(unit_price)                AS unit_price_nok,
    COUNT(amount)                    AS amount_nok,
    COUNT(pay_method)                AS pay_method_nok,
    COUNT(status)                    AS status_nok,
    COUNT(is_refund)                 AS is_refund_nok,
    COUNT(rating)                    AS rating_nok
FROM orders_raw;