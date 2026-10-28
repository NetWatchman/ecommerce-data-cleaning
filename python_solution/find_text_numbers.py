#筛出疑似文本型数值列
import pandas as pd
import re
import os

def detect_text_numeric_columns(file_path, threshold=0.8):
    """
    读取 CSV 文件，返回疑似文本型数值列的列表及其示例脏值。
    
    Parameters:
        file_path (str): CSV 文件路径
        threshold (float): 能成功清洗并转为 float 的比例阈值，超过则认为该列是数值列
    
    Returns:
        dict: {列名: [脏值样例]}
    """
    # 读取 CSV，强制所有列为 object 以避免自动类型推断干扰
    df = pd.read_csv(file_path, dtype=str, keep_default_na=False)
    
    # 定义常见的“数字伪装”模式，按顺序清理
    def clean_number(s):
        if not isinstance(s, str) or s.strip() == '':
            return None
        s = s.strip()
        # 去除两侧引号
        s = s.strip('"\'')
        # 替换常见货币符号、中文单位、百分号等
        s = re.sub(r'[￥¥$€£元,%]', '', s)
        # 去除千分位逗号（注意保留小数点）
        s = s.replace(',', '')
        # 去除多余空格
        s = s.replace(' ', '')
        # 尝试转为 float
        try:
            return float(s)
        except:
            return None
    results = {}
    for col in df.columns:
        series = df[col].astype(str).replace(['nan', '', 'null', 'None', 'N/A', 'NA'], pd.NA)
        non_null = series.dropna()
        if len(non_null) == 0:
            continue
        
        # 计算能成功转为数字的比例
        cleaned = non_null.apply(clean_number)
        valid_count = cleaned.notna().sum()
        ratio = valid_count / len(non_null)
        
        # 如果比例高且原列中存在非纯数字的值（即包含字母、符号等），视为文本型数值列
        if ratio >= threshold:
            original_values = non_null.tolist()
            dirty_examples = []
            for v in original_values[:20]:  # 最多取20个样例
                if clean_number(v) is not None and not v.replace('.','').replace('-','').isdigit():
                    dirty_examples.append(v)
                    if len(dirty_examples) >= 5:
                        break
            if dirty_examples:
                results[col] = dirty_examples
    
    return results

# 主程序入口
if __name__ == "__main__":
    # 源csv文件路径（相对本脚本定位：项目根目录下的 orders_raw.csv）
    from pathlib import Path
    file_path = Path(__file__).resolve().parent.parent / "orders_raw.csv"
    result = detect_text_numeric_columns(file_path)

    # 控制台打印查看
    print("疑似文本型数值列及其脏值样例：")
    for col, samples in result.items():
        print(f"列名: {col}")
        for s in samples:
            print(f"  脏值: {repr(s)}")

    # --------------------输出CSV保存到项目根目录----------------------
    out_list = []
    for col, sample_list in result.items():
        out_list.append({
            "列名": col,
            "脏值样例(多个用分号隔开)": "; ".join(sample_list)
        })
    out_df = pd.DataFrame(out_list)
    csv_save_path = Path(__file__).resolve().parent.parent / "文本型数值检测结果.csv"
    # utf-8-sig：Excel打开中文不乱码，index=False不输出行号
    out_df.to_csv(csv_save_path, encoding="utf-8-sig", index=False)

    print(f"\n✅ CSV文件已经保存到项目根目录：{csv_save_path}")
