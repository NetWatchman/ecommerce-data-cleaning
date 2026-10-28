# -*- coding: utf-8 -*-
"""
电商订单缺失列分类，结果保存到桌面表格文件
1) 结构性缺失：业务上本来就不该有值 → 不能填
2) 脏缺失：本该有值却丢了 → 需要处理
"""
import pandas as pd
import numpy as np
import os
from pathlib import Path

# ---------------------- 1.读取数据 ----------------------
df = pd.read_csv(Path(__file__).resolve().parent.parent / "orders_raw.csv")

# ---------------------- 2.统一识别各类缺失标记 ----------------------
# 空白字符串替换为NaN
df = df.replace(r'^\s*$', np.nan, regex=True)
# 业务脏标记替换为NaN
df = df.replace(["null", "NA", "N/A", "暂无", "-"], np.nan)
# status去除前后空格，统一状态文本
df["status"] = df["status"].astype(str).str.strip()

# ---------------------- 3.业务规则：哪些订单状态下该字段业务允许为空 ----------------------
structural_rules = {
    "pay_time":   ["已取消", "退款中", "未支付"],
    "pay_method": ["已取消", "退款中", "未支付"],
    "rating":     ["已取消", "退款中", "已支付", "已付款", "paid", "PAID"],
    "gender":     [],
    "age":        [],
    "city":       [],
}

# ---------------------- 4.统计每一类缺失数量 ----------------------
total = len(df)
out_rows = []

for col in df.columns:
    n_miss = int(df[col].isna().sum())
    if n_miss == 0:
        continue

    miss_mask = df[col].isna()
    allow_states = structural_rules.get(col, [])

    if len(allow_states) > 0:
        n_structural = int(df.loc[miss_mask, "status"].isin(allow_states).sum())
    else:
        n_structural = 0

    n_dirty = n_miss - n_structural
    miss_rate_pct = round(n_miss / total * 100, 2)

    # 判断分类
    if len(allow_states) == 0:
        category = "脏缺失（需要处理）"
    elif n_structural / n_miss >= 0.8:
        category = "结构性缺失（业务允许为空，不可填充）"
    else:
        category = "混合型（既有结构性也有脏缺失）"

    out_rows.append({
        "列名": col,
        "总缺失数": n_miss,
        "缺失率(%)": miss_rate_pct,
        "结构性缺失数": n_structural,
        "脏缺失数": n_dirty,
        "缺失分类": category
    })

result_df = pd.DataFrame(out_rows)
# 按缺失率从高到低排序
result_df = result_df.sort_values(by="缺失率(%)", ascending=False).reset_index(drop=True)

# ---------------------- 5.保存到项目根目录 ----------------------
save_file = Path(__file__).resolve().parent.parent / "缺失分类结果.csv"

result_df.to_csv(save_file, encoding="utf-8-sig", index=False)

# 控制台打印预览
print("====缺失分类结果====")
print(result_df.to_string(index=False))
print(f"\n✅ 表格已经保存到桌面：{save_file}")
