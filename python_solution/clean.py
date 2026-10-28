# -*- coding: utf-8 -*-
"""
清洗需求清单：
1. unit_price：去掉 ¥、元、逗号，转为小数
2. phone：去掉空格、横杠
3. gender：统一映射成 男 / 女 / 未知
4. age：只保留 1~120，其他异常（负数、200）变成 NaN（NULL）
5. rating：合法数字保留，“暂无”、非法值变成 NaN
6. amount：负数取绝对值
7. status：中英文状态统一归一
8. order_time、pay_time：`/` 换成 `-`，转成时间格式
9. city：缺失填充为 “未知”
10.删除完全重复行

输入：脚本上一级文件夹 orders_raw.csv
输出：脚本上一级文件夹 cleaned_data.csv
"""
import pandas as pd
import numpy as np
import os

# 路径：py脚本在src子文件夹，csv在上一级
base_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(base_dir)

raw_file = os.path.join(parent_dir, "orders_raw.csv")
out_file = os.path.join(parent_dir, "py_cleaned_data.csv")

df = pd.read_csv(raw_file, encoding="utf-8-sig")

# 1. unit_price：去掉 ¥、元、逗号，转为小数
df["unit_price"] = df["unit_price"].astype(str)
df["unit_price"] = df["unit_price"].str.replace("¥", "", regex=False)
df["unit_price"] = df["unit_price"].str.replace("元", "", regex=False)
df["unit_price"] = df["unit_price"].str.replace(",", "", regex=False)
df["unit_price"] = pd.to_numeric(df["unit_price"], errors="coerce").round(2)

# 2. phone：去掉空格、横杠
df["phone"] = df["phone"].astype(str)
df["phone"] = df["phone"].str.replace(" ", "", regex=False)
df["phone"] = df["phone"].str.replace("-", "", regex=False)

# 3. gender：统一映射成 男 / 女 / 未知
def clean_gender(x):
    if pd.isna(x):
        return "未知"
    s = str(x).strip()
    if s in {"男", "M", "male", "1", "0"}:
        return "男"
    elif s in {"女", "F", "female", "2"}:
        return "女"
    else:
        return "未知"
df["gender"] = df["gender"].apply(clean_gender)

# 4. age：只保留1~120，其他异常变成NaN
df["age"] = pd.to_numeric(df["age"], errors="coerce")
df["age"] = df["age"].where((df["age"] >= 1) & (df["age"] <= 120), np.nan)

# 5. rating：合法数字保留，暂无、非法值变成NaN
def clean_rating(x):
    if pd.isna(x):
        return np.nan
    s = str(x).strip()
    if s in {"暂无", "N/A", "NA"}:
        return np.nan
    num = pd.to_numeric(s, errors="coerce")
    if pd.notna(num):
        return round(num,1)
    return np.nan
df["rating"] = df["rating"].apply(clean_rating)

# 6. amount：负数取绝对值
df["amount"] = pd.to_numeric(df["amount"], errors="coerce")
df["amount"] = df["amount"].abs().round(2)

# 7. status：中英文状态统一归一
def clean_status(x):
    if pd.isna(x):
        return x
    s = str(x).strip()
    mapping = {
        "Completed":"已完成",
        "completed":"已完成",
        "paid":"已支付",
        "PAID":"已支付",
        "已付款":"已支付"
    }
    return mapping.get(s, s)
df["status"] = df["status"].apply(clean_status)

# 8. order_time、pay_time：/换成-，转成时间格式
def clean_datetime(x):
    if pd.isna(x):
        return pd.NaT
    s = str(x).strip().replace("/", "-")
    try:
        return pd.to_datetime(s)
    except:
        return pd.NaT

df["order_time"] = df["order_time"].apply(clean_datetime)
df["pay_time"] = df["pay_time"].apply(clean_datetime)

# 9. city：缺失填充为“未知”
df["city"] = df["city"].fillna("未知")

# 10. 删除完全重复行，保留第一条
row_before = len(df)
df = df.drop_duplicates(keep="first").reset_index(drop=True)
row_after = len(df)

# 输出结果
df.to_csv(out_file, encoding="utf-8-sig", index=False)

print(f"✅清洗完成！原始行数：{row_before}，去重后行数：{row_after}")
print(f"输出文件路径：{out_file}")
