#!/bin/bash

# 输入区块文件路径
#interval_file="../00.call_CNV/com_true_del_block.txt"
interval_file="a.tmp"
# 基因组目录路径
genome_dir="/data1/share/elzd_2023_00095/niujx/01.new_pangenome/fasta/01.CM42"
# 输出目录路径
output_dir="./00.fa"

# 读取区块文件
while IFS=$'\t' read -r chr start end; do
    # 构建染色体FA文件路径
    fa_file="${genome_dir}/CM42.fa"
    # 构建输出文件路径（文件名保持原始 start 值）
    output_file="${output_dir}/${chr}_${start}_${end}.fa"

    # 如果 start 是 0，则将其转换为 1，仅用于 samtools faidx 参数
    faidx_start=$start
    if [[ "$start" -eq 0 ]]; then
        faidx_start=1
    fi

    # 提取区间序列
    samtools faidx "$fa_file" "${chr}:${faidx_start}-${end}" > "$output_file"

done < "$interval_file"
