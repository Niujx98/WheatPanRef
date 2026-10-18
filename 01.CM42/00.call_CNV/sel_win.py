import os
import pandas as pd
import numpy as np

# 配置
base_dir = "./"  # 样本文件夹的根目录
window_combinations = ["win_1Mb_step_200k", "win_500k_step_100k", "win_200k_step_40k",
                       "win_100k_step_20k", "win_50k_step_10k", "win_40k_step_8k",
                       "win_30k_step_6k", "win_20k_step_4k", "win_10k_step_2k"]

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

# 主逻辑
if __name__ == "__main__":
    final_blocks = []
    base_file = os.path.join(base_dir, "com_win_1Mb_step_200k_del_block.txt")
    if not os.path.exists(base_file):
        print(f"File not found: {base_file}")
        exit(0)

    base_data = pd.read_csv(base_file, sep="\t", header=None, names=["chrom", "start", "end"])

    for _, base_block in base_data.iterrows():
        # 基准窗口初始参数
        current_left = base_block["start"]
        current_right = base_block["end"]
        best_window = "win_1Mb_step_200k"
        best_left, best_right = current_left, current_right

        # 初始化
        distance_sums = []
        window_boundaries = {"win_1Mb_step_200k": (current_left, current_right)}

        for i in range(1, len(window_combinations)):
            current_window = window_combinations[i]
            compare_file = os.path.join(base_dir, f"com_{current_window}_del_block.txt")
            if not os.path.exists(compare_file):
                print(f"File not found: {compare_file}")
                continue

            compare_data = pd.read_csv(compare_file, sep="\t", header=None, names=["chrom", "start", "end"])
            overlapping_blocks = compare_data[
                (compare_data["chrom"] == base_block["chrom"]) &
                (compare_data["end"] >= current_left) &
                (compare_data["start"] <= current_right)
            ]

            if overlapping_blocks.empty:
                continue

            # 获取当前窗口重叠区块的最外围边界
            new_left, new_right = get_outermost_boundaries(overlapping_blocks)
            total_distance = calculate_boundary_distance(current_left, current_right, overlapping_blocks)

            # 更新边界和存储距离
            distance_sums.append(total_distance)
            window_boundaries[current_window] = (new_left, new_right)

            # 更新边界为当前窗口的最外围边界
            current_left, current_right = new_left, new_right

        # 检查是否有有效的距离和
        if not distance_sums:
            print(f"No valid overlaps for block: {base_block['start']}-{base_block['end']}")
            continue

        # 计算最小距离和及偏值
        min_distance_sum = min(distance_sums)
        distance_biases = [total_distance - min_distance_sum for total_distance in distance_sums]

        # 遍历找到最佳窗口
        for i in range(1, len(window_combinations)):
            if i-1 >= len(distance_biases):  # 安全索引
                break
            distance_bias = distance_biases[i-1]
            if distance_bias < 50000:
                best_window = window_combinations[i-1]  # 上一个窗口
                best_left, best_right = window_boundaries[best_window]
                break

        # 存储所有窗口边界字符串
        window_boundaries_positions_str = ";".join([f"{window}:{window_boundaries.get(window, ('NA', 'NA'))[0]}-{window_boundaries.get(window, ('NA', 'NA'))[1]}"
                                                   for window in window_combinations])

        # 保存结果
        block_length = best_right - best_left
        original_block_length = base_block["end"] - base_block["start"]
        final_blocks.append([base_block["chrom"], best_left, best_right, block_length, best_window,
                             base_block["chrom"], base_block["start"], base_block["end"], original_block_length,
                             window_boundaries_positions_str])

    # 检查最终结果
    if not final_blocks:
        print("No blocks to save.")
        exit(0)

    # 保存输出
    output_file = os.path.join(base_dir, "com_overlap_block.txt")
    sorted_blocks = pd.DataFrame(final_blocks, columns=["chrom", "best_start", "best_end", "length", "window",
                                                        "orig_chrom", "orig_start", "orig_end", "orig_length", "window_boundaries"])
    sorted_blocks = sorted_blocks.sort_values(by=["chrom", "best_start", "best_end"])
    sorted_blocks.to_csv(output_file, sep="\t", index=False, header=False)
    print(f"Saved: {output_file}")

