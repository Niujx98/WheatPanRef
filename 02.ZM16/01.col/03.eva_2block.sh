#!/bin/bash
set -uxo pipefail

# 定义输入输出目录
input_dir="./03.coords/02.2block"
output_file="simi_2block.txt"

# 清空输出文件（如果已存在）
> "$output_file"

# 临时文件用于存储中间结果
temp_result="tmp_result.txt"
> "$temp_result"

# 遍历所有 .coords.txt 文件
for file in "$input_dir"/*.coord.txt; do
    # 提取文件前缀和目标样本
    full_name=$(basename "$file" .coord.txt)
    prefix=$(echo "$full_name" | awk -F'_vs_' '{print $1}')
    target_sam=$(echo "$full_name" | awk -F'_vs_' '{print $2}')

    # 提取区块长度
    start=$(echo "$prefix" | awk -F'_' '{print $2}')
    end=$(echo "$prefix" | awk -F'_' '{print $3}')
    block_length=$((end - start))

    # 生成 tmp.bed
    awk '{ if ($4 < $3) { print $8 "\t" $4 "\t" $3 } else { print $8 "\t" $3 "\t" $4 } }' "$file" | \
        sort -k2,2n -k3,3n > tmp.bed

    # 检查 tmp.bed 是否为空
    if [[ ! -s tmp.bed ]]; then
        echo -e "$prefix\t$target_sam\t0" >> "$temp_result"
        continue
    fi

    # 合并区间生成 tmp_merged.bed
    ~/bin/bedtools/bin/bedtools merge -i tmp.bed > tmp_merged.bed

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

    # 保存结果到临时文件
    echo -e "$prefix\t$target_sam\t$similarity" >> "$temp_result"

    # 清理临时文件
    rm -f tmp.bed tmp_merged.bed
done

# 处理临时结果，取每个 prefix 对应的最高 similarity
awk -F'\t' '
{
    if (!($1 in max_similarity) || $3 > max_similarity[$1]) {
        max_similarity[$1] = $3
        best_target[$1] = $2
    }
}
END {
    for (prefix in max_similarity) {
        print prefix "\t" best_target[prefix] "\t" max_similarity[prefix]
    }
}' "$temp_result" > "$output_file"

# 删除临时文件
rm -f "$temp_result"
