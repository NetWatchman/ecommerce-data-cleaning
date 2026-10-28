import pandas as pd
import os
from pathlib import Path

# 读取原始数据（相对本脚本定位：项目根目录下的 orders_raw.csv）
file_path = Path(__file__).resolve().parent.parent / "orders_raw.csv"
df = pd.read_csv(file_path, encoding="utf-8-sig")

# 需要检查的分类列列表
cat_cols = ["gender", "status", "pay_method", "province"]

# 保存unique结果
unique_result_list = []
# 保存同一含义多种写法的问题记录
issue_list = []

print("="*70)
for col in cat_cols:
    print(f"\n----------【{col}】全部unique取值 ----------")
    vals = df[col].unique()
    print(vals)
    # 存入结果
    for v in vals:
        unique_result_list.append({
            "列名": col,
            "取值": v
        })

# ----------------识别同一含义多种写法（业务脏问题）----------------
# 1.gender性别：男 /M；女/F；还有数字、null等
issue_list.append({"列名":"gender","问题描述":"同一含义多种书写形式","例子1":"'男' 和 'M' 都代表男性","例子2":"'女' 和 'F' 都代表女性"})

# 2.status订单状态：已完成 / Completed；已支付 / paid / PAID
issue_list.append({"列名":"status","问题描述":"同一含义多种书写形式","例子1":"'已完成' 和 'Completed' 代表订单完成","例子2":"'已支付' 和 'paid'/'PAID' 代表已经付款"})

# 3.pay_method支付方式：微信支付 / WX；支付宝 / alipay
issue_list.append({"列名":"pay_method","问题描述":"同一含义多种书写形式","例子1":"'微信支付' 和 'WX' 代表微信支付","例子2":"'支付宝' 和 'alipay' 代表支付宝支付"})

# 4.province省份：广东省 / 广东；zhejiang / ZHEJIANG（拼音和中文混用）
issue_list.append({"列名":"province","问题描述":"同一含义多种书写形式","例子1":"'广东省' 和 '广东' 是同一个省份","例子2":"'zhejiang' 和 'ZHEJIANG' 拼音大小写代表浙江"})

# 转为DataFrame
df_unique = pd.DataFrame(unique_result_list)
df_issue = pd.DataFrame(issue_list)

print("\n"+"="*70)
print("【分类列 同一含义多种形式汇总】")
print(df_issue.to_string(index=False))

# ----------------输出文件保存到项目根目录----------------
project_root = Path(__file__).resolve().parent.parent
# 全部unique取值
out1 = project_root / "分类列unique全部取值.csv"
df_unique.to_csv(out1, encoding="utf-8-sig", index=False)
# 语义不一致问题清单
out2 = project_root / "分类列语义多形式问题清单.csv"
df_issue.to_csv(out2, encoding="utf-8-sig", index=False)

print(f"\n✅文件已保存到项目根目录：")
print(out1)
print(out2)
print(f" 1. {out1}")
print(f" 2. {out2}")
