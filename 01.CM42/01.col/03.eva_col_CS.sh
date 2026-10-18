#!/bin/bash
set -uxo pipefail

#SBATCH --partition=cpu_parallel  # 指定分区
#SBATCH --ntasks=1                # 任务数
#SBATCH --output=~/tmp.o      # Standard output
#SBATCH --error=~/tmp.e       # Standard error

# 定义输入输出目录
input_dir="04.filtered_coords"
output_file="simi_CS.txt"

# 清空输出文件（如果已存在）
> "$output_file"

# 遍历所有 .filtered_coords.txt 文件
for file in "$input_dir"/*.filtered_coords.txt; do
    # 提取文件前缀（去掉路径和扩展名）
    prefix=$(basename "$file" .filtered_coords.txt)

    # 提取区块长度
    start=$(echo "$prefix" | awk -F'_' '{print $2}')
    end=$(echo "$prefix" | awk -F'_' '{print $3}')
    block_length=$((end - start))

    # 生成 tmp.bed
    awk '{ if ($4 < $3) { print $8 "\t" $4 "\t" $3 } else { print $8 "\t" $3 "\t" $4 } }' "$file" | \
        sort -k2,2n -k3,3n > tmp.bed

    # 检查 tmp.bed 是否为空
    if [[ ! -s tmp.bed ]]; then
        echo -e "$prefix\t0" >> "$output_file"
        continue
    fi

    # 合并区间生成 tmp_merged.bed
    ~/anaconda3/envs/njxpy/bin/bedtools merge -i tmp.bed > tmp_merged.bed

    # 计算 a：合并区间的总长度
    a=$(awk '{sum += $3 - $2} END {print sum}' tmp_merged.bed)

    # 计算 b：第七列的均值
    b=$(awk '{sum += $7; count++} END {if (count > 0) print sum / count; else print "0"}' "$file")

    # 计算相似性比例
    if [[ $block_length -gt 0 ]]; then
        similarity=$(echo "scale=2; ($a * $b ) / $block_length" | bc)
    else
        similarity="0"
    fi

    # 输出结果到 simi_CS.txt
    echo -e "$prefix\t$similarity" >> "$output_file"

    # 清理临时文件
    rm -f tmp.bed tmp_merged.bed

done

echo "All files processed. Results saved to $output_file."
