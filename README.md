# 🛒 电商订单脏数据清洗与治理流水线 (Python + SQL)

<p align="left">
  <img src="https://img.shields.io/badge/Python-3.9+-blue.svg" alt="Python">
  <img src="https://img.shields.io/badge/Pandas-2.0+-150458.svg" alt="Pandas">
  <img src="https://img.shields.io/badge/SQL_Server-T--SQL-red.svg" alt="SQL Server">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License">
</p>

## 📖 项目简介

本项目针对电商订单原始数据（`orders_raw.csv`，共 306 行 × 19 列），分别使用 **Python (Pandas)** 与 **SQL (T-SQL)** 实现了一套完整的数据清洗流水线。同时，针对原始数据进行了多维度的数据质量探查（Profiling），从业务视角出发，精准解决了缺失、重复、异常值及同义多写等数据质量问题。

## ✨ 核心亮点

* **双栈实现**：提供 Python 脚本与 SQL 脚本两种独立清洗方案，适配不同的企业技术栈（应用层清洗 vs 数仓层清洗）。
* **业务驱动治理**：结合电商业务逻辑，精准划分「结构性缺失」（如未付款订单无支付时间）与「脏缺失」，避免误填；区分「完全重复」与「主键重复」（如多商品拆单），确保数据逻辑正确。
* **全链路探查**：包含 8 个独立的数据质量分析脚本，涵盖 dtype 检查、缺失率排序、异常值 describe 统计等，先探查后清洗。
* **工程化规范**：具备完善的依赖管理（`requirements.txt`）、版本忽略策略（`.gitignore`）及详尽的文档说明。

## 📊 清洗规则概览

| 字段 | 脏数据表现 | 清洗处理方式 |
| :--- | :--- | :--- |
| `unit_price` | 包含 `¥`、`元`、`,` 等符号 | 剥离符号，转为 Decimal 类型保留两位小数 |
| `phone` | 包含空格、横杠（如 `185-1380`） | 去除空格和横杠，统一纯数字格式 |
| `gender` | 中英文混杂（`男/M/male/1`） | 统一映射为：男 / 女 / 未知 |
| `age` | 出现负数、`200` 等异常值 | 仅保留 1~120，异常值转为 NULL |
| `rating` | 包含 `暂无`、`N/A` 等文本 | 合法数字保留，非法值转为 NULL |
| `amount` | 存在负金额（如 `-982.65`） | 取绝对值处理 |
| `status` | 中英混杂（`已完成/Completed`） | 统一归一化为中文状态 |
| 时间字段 | 格式混乱（`2024/2/1`、`20240517`）| `/` 替换为 `-`，统一转为标准 Datetime |
| `city` | 存在缺失值 | 填充为“未知” |
| 全局数据 | 存在完全重复行及主键重复 | 删除完全重复行，按订单号去重保留第一条 |

## 🪄 清洗效果对比（Before & After）

| 字段 | 清洗前（原始脏数据） | 清洗后（标准化数据） |
| :--- | :--- | :--- |
| **unit_price** | `"¥1,137.18"` / `"1835.59元"` | `1137.18` / `1835.59` |
| **gender** | `M` / `male` / `null` / `2` | `男` / `男` / `未知` / `女` |
| **phone** | `183 8282 2735` / `185-1380-5735` | `18382822735` / `18513805735` |
| **order_time** | `2024/2/1 12:07` / `20240517` | `2024-02-01 12:07:00` / `2024-05-17 00:00:00` |
| **amount** | `-982.65` | `982.65` (负数转正) |
| **status** | `Completed` / `paid` | `已完成` / `已支付` |

> 👉 **完整清洗结果**：请查看根目录下的 `cleaned_data_sample.csv` 文件。

## 📂 项目结构

```text
ecommerce-data-cleaning/
├── python_solution/             # Python 实现方案
│   ├── clean.py                 # 主清洗脚本
│   ├── shape_dtype.py           # 1. 数据类型检查
│   ├── missing_statistics.py    # 2. 缺失率统计
│   └── ... (其余数据探查脚本)
├── sql_solution/                # SQL (T-SQL) 实现方案
│   ├── 01_shape_dtype.sql       # 按编号顺序执行
│   ├── ...
│   └── 07_clean.sql             # 主清洗脚本，生成清洗表
├── orders_raw.csv               # 原始脏数据
├── cleaned_data_sample.csv      # 清洗后的成品数据示例
├── requirements.txt             # Python 依赖包
└── README.md
🚀 如何运行
1. Python 方案
bash
# 安装依赖
pip install -r requirements.txt

# 运行主清洗脚本
cd python_solution
python clean.py
(注：运行其他分析脚本可输出对应的数据质量探查报告。)

2. SQL 方案 (SQL Server)
建库 orders_clean，导入 orders_raw.csv 为表 dbo.orders_raw（所有列设为 VARCHAR）。

按编号顺序执行 sql_solution/ 下的脚本。

最后执行 clean.sql 将生成清洗结果表 dbo.sql_cleaned_data。

📄 声明
本项目中的 orders_raw.csv 数据为模拟生成，仅用于数据清洗技术的展示与交流。