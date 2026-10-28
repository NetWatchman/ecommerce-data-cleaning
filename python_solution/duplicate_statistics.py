import pandas as pd
import os
from pathlib import Path

file_path = Path(__file__).resolve().parent.parent / "orders_raw.csv"
df = pd.read_csv(file_path, encoding="utf-8-sig")

# 统计
total = len(df)
dup_all = int(df.duplicated().sum())               # 完全重复行数（整行相同）
dup_pk  = int(df.duplicated(subset=["order_id"]).sum())  # 主键重复行数
uniq_pk = df["order_id"].nunique()                 # 主键唯一值数

# 输出到项目根目录
out = pd.DataFrame([
    {"指标": "总行数", "数值": total},
    {"指标": "完全重复行数（整行相同）", "数值": dup_all},
    {"指标": "order_id重复行数（主键）", "数值": dup_pk},
    {"指标": "order_id唯一值数", "数值": uniq_pk},
])
out_csv = Path(__file__).resolve().parent.parent / "重复行统计结果.csv"
out.to_csv(out_csv, encoding="utf-8-sig", index=False)
print(f"✅ 结果已保存到：{out_csv}")

print(out.to_string(index=False))
