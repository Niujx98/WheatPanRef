import os
import pandas as pd
import numpy as np

# 配置
base_dir = "./"  # 样本文件夹的根目录
window_combinations = [
    "win_100k_step_20k", "win_50k_step_10k", "win_40k_step_8k",
    "win_30k_step_6k", "win_20k_step_4k", "win_10k_step_2k"
]  # 窗口组合，从大到小


# 定义函数：计算最外围边界
def get_outermost_boundaries(blocks):
    """获取区块的最外围左右边界"""
    return blocks["start"].min(), blocks["end"].max()


# 定义函数：计算左右边界的距离
def calculate_boundary_distance(base_left, base_right, compare_blocks):
    """计算左右边界的距离和"""
    left_distance = abs(compare_blocks["start"] - base_left).min()
    right_distance = abs(compare_blocks["end"] - base_right).min()
    return left_distance + right_distance


if __name__ == "__main__":
    # 初始化输出结果
    distance_data = []

    # 读取 100k 窗口的 CNV 区块
    base_file = os.path.join(base_dir, "com_win_100k_step_20k_del_block.txt")
    if not os.path.exists(base_file):
        raise FileNotFoundError(f"Base file not found: {base_file}")

    base_data = pd.read_csv(base_file, sep="\t", header=None, names=["chrom", "start", "end"])

    # 遍历每个 100k 的区块
    for _, base_block in base_data.iterrows():
        current_left = base_block["start"]
        current_right = base_block["end"]
        block_distances = []  # 存储该区块每个窗口的边界距离和
        best_window = "win_100k_step_20k"  # 初始为 100k 窗口
        previous_distance = float("inf")  # 初始距离为无穷大

        # 当前基准区块
        current_block = base_block

        # 遍历窗口组合，从大到小
        for i in range(1, len(window_combinations)):
            current_window = window_combinations[i]
            compare_file = os.path.join(base_dir, f"com_{current_window}_del_block.txt")
            if not os.path.exists(compare_file):
                print(f"File not found: {compare_file}")
                block_distances.append(np.nan)
                continue

            # 读取当前窗口的 CNV 数据
            compare_data = pd.read_csv(compare_file, sep="\t", header=None, names=["chrom", "start", "end"])
            # 筛选与当前基准边界重叠的区块
            overlapping_blocks = compare_data[
                (compare_data["chrom"] == current_block["chrom"]) &
                (compare_data["end"] >= current_left) &
                (compare_data["start"] <= current_right)
            ]

            # 如果没有重叠区块，跳过
            if overlapping_blocks.empty:
                block_distances.append(np.nan)
                continue

            # 获取当前窗口重叠区块的最外围边界
            new_left, new_right = get_outermost_boundaries(overlapping_blocks)

            # 计算左右边界距离和
            total_distance = calculate_boundary_distance(current_left, current_right, overlapping_blocks)
            block_distances.append(total_distance)

            # 更新当前的左右边界
            current_left, current_right = new_left, new_right

            # 如果距离和趋于稳定（变化很小），记录最佳窗口
            if abs(previous_distance - total_distance) < 1e-3:
                best_window = current_window
            previous_distance = total_distance

        # 保存结果
        block_length = base_block["end"] - base_block["start"]
        distance_data.append([
            base_block["chrom"], base_block["start"], base_block["end"], block_length, best_window, *block_distances
        ])

    # 输出文件名
    output_file = os.path.join(base_dir, "com_boundary_distances.txt")

    # 定义列名
    columns = ["chrom", "start", "end", "length", "best_window"] + [
        f"{window}_distance" for window in window_combinations[1:]
    ]

    # 保存到文件
    pd.DataFrame(distance_data, columns=columns).to_csv(output_file, sep="\t", index=False)
    print(f"Saved: {output_file}")

