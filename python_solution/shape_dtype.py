#读入数据，打印 'shape'，逐列确认 'dtype'
import pandas as pd
import os
from pathlib import Path

file_path = Path(__file__).resolve().parent.parent / "orders_raw.csv"
df = pd.read_csv(file_path, encoding="utf-8-sig")
print(df.shape)
print(df.dtypes)
out_df = pd.DataFrame({"列名":df.columns, "dtype":df.dtypes.astype(str)})
out_df.loc[len(out_df)] = ["shape(行数,列数)", str(df.shape)]
# 结果保存到项目根目录（与本脚本同级目录的上一级）
save_path = Path(__file__).resolve().parent.parent / "shape_dtype结果.csv"
out_df.to_csv(save_path, encoding="utf-8-sig", index=False)
