import pandas as pd
import os
from pathlib import Path

file_path = Path(__file__).resolve().parent.parent / "orders_raw.csv"
df = pd.read_csv(file_path, encoding="utf-8-sig")

num_cols = ["age", "quantity", "unit_price", "amount"]

# 安全转为数值，无法转的变成 NaN
for c in num_cols:
    df[c] = pd.to_numeric(df[c], errors="coerce")

desc_result = df[num_cols].describe()
print("==========数值列 describe() 统计==========")
print(desc_result)

abnormal_list = []

# age 异常
age_abn = df[(df["age"] < 0) | (df["age"] > 120)]
for idx, row in age_abn.iterrows():
    abnormal_list.append({
        "列名": "age",
        "异常值": row["age"],
        "order_id": row["order_id"],
        "异常说明": "年龄超出人类常识范围(0~120)"
    })

# quantity 异常
qty_abn = df[df["quantity"] <= 0]
for idx, row in qty_abn.iterrows():
    abnormal_list.append({
        "列名": "quantity",
        "异常值": row["quantity"],
        "order_id": row["order_id"],
        "异常说明": "购买数量小于等于0，不符合业务常识"
    })

# unit_price 异常
up_abn = df[df["unit_price"] < 0]
for idx, row in up_abn.iterrows():
    abnormal_list.append({
        "列名": "unit_price",
        "异常值": row["unit_price"],
        "order_id": row["order_id"],
        "异常说明": "单价为负数，不符合业务常识"
    })

# amount 异常
amt_abn = df[df["amount"] < 0]
for idx, row in amt_abn.iterrows():
    abnormal_list.append({
        "列名": "amount",
        "异常值": row["amount"],
        "order_id": row["order_id"],
        "异常说明": "订单总金额为负数，不符合业务常识"
    })

abnormal_df = pd.DataFrame(abnormal_list)
print("\n==========明显超出常识的取值记录==========")
if len(abnormal_df) > 0:
    print(abnormal_df.to_string(index=False))
else:
    print("未检测到常识异常值")

# 保存到项目根目录
project_root = Path(__file__).resolve().parent.parent
desc_out_path = project_root / "数值列describe统计.csv"
desc_result.to_csv(desc_out_path, encoding="utf-8-sig")

abn_out_path = project_root / "数值列常识异常值清单.csv"
abnormal_df.to_csv(abn_out_path, encoding="utf-8-sig", index=False)

print(f"\n✅ describe统计文件：{desc_out_path}")
print(f"✅ 异常值清单文件：{abn_out_path}")
