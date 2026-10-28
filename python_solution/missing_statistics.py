# -*- coding: utf-8 -*-
"""
电商订单脏数据缺失统计
目标：计算每列缺失数量、缺失率，按缺失率降序排序
缺失判定：np.nan、空字符串、'null'、'NA'、'-'、空白字符串全部视为缺失值
输出文件直接保存到电脑桌面
"""
import pandas as pd
import numpy as np
import os

# ----------------------1.读取csv原始订单文件（相对本脚本定位）----------------------
from pathlib import Path

df = pd.read_csv(Path(__file__).resolve().parent.parent / "orders_raw.csv")

# ----------------------2.脏标记统一替换为np.nan缺失值----------------------
missing_tags = ["null", "NA", "-", "N/A", "暂无", ""]
for tag in missing_tags:
    df.replace(tag, np.nan, inplace=True)

# 处理全空格空白单元格
df = df.apply(lambda x: x.astype(str).str.strip().replace("", np.nan) if x.dtype == "object" else x)

# ----------------------3.逐列计算缺失统计指标----------------------
result_list = []
total_rows = df.shape[0]  # 获取总行数

for col in df.columns:
    miss_count = df[col].isna().sum()
    miss_rate = miss_count / total_rows
    result_list.append({
        "列名": col,
        "缺失数": miss_count,
        "缺失率": round(miss_rate, 4),
        "缺失率_百分比": f"{miss_rate*100:.2f}%"
    })

# ----------------------4.转为DataFrame，按缺失率降序排序----------------------
result_df = pd.DataFrame(result_list)
result_df = result_df.sort_values(by="缺失率", ascending=False).reset_index(drop=True)

# ----------------------5.控制台打印结果----------------------
print("======各字段缺失统计（按缺失率降序）======")
print(result_df.to_string(index=False))

# ----------------------6.保存到项目根目录----------------------
save_path = Path(__file__).resolve().parent.parent / "缺失统计结果.csv"
result_df.to_csv(save_path, encoding="utf-8-sig", index=False)

# Excel导出，openpyxl没装好就保持注释，不启用
# result_df.to_excel(Path(__file__).resolve().parent.parent / "缺失统计结果.xlsx", index=False, engine="openpyxl")

print(f"\n✅ 文件已经保存到项目根目录！完整路径：{save_path}")
