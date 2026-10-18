import os
import pandas as pd

# 配置
input_file = "com_overlap_block.txt"  # 输入文件
base_dir = "./"  # 样本文件夹的根目录
output_file = os.path.join(base_dir, "com_true_del_block.txt")  # 输出文件

# 读取 com_overlap_del_block.txt 文件
data = pd.read_csv(input_file, sep="\t", header=None,
                   names=["chrom", "best_start", "best_end", "length", "window", "orig_chrom", "orig_start", "orig_end", "orig_length", "window_boundaries"])

# 初始化输出结果
result_blocks = []

# 遍历每一行，筛选最佳窗口对应的区块
for _, row in data.iterrows():
    chrom, best_start, best_end, window = row["chrom"], row["best_start"], row["best_end"], row["window"]
    compare_file = os.path.join(base_dir, f"com_{window}_del_block.txt")

    if not os.path.exists(compare_file):
        print(f"File not found: {compare_file}")
        continue

    # 读取最佳窗口对应的文件
    compare_data = pd.read_csv(compare_file, sep="\t", header=None, names=["chrom", "start", "end"])

    # 筛选与当前行区间重叠的区块
    overlapping_blocks = compare_data[(compare_data["chrom"] == chrom) &
                                       (compare_data["end"] >= best_start) &
                                       (compare_data["start"] <= best_end)]

    # 将筛选的区块添加到结果中
    for _, block in overlapping_blocks.iterrows():
        result_blocks.append([chrom, block["start"], block["end"]])

# 将结果写入输出文件
if result_blocks:
    result_df = pd.DataFrame(result_blocks, columns=["chrom", "start", "end"])
    result_df.to_csv(output_file, sep="\t", index=False, header=False)
    print(f"Saved true del blocks to: {output_file}")
else:
    print("No overlapping blocks found.")
