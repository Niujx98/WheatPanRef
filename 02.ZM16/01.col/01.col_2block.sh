#!/bin/bash
set -euxo pipefail

# 输入参数
query_sam="ZM16"
interval_file="../00.call_CNV/com_true_del_block.txt"  # 输入区块文件路径
seq_file="./seq_${query_sam}.txt"                     # 基因组序列信息文件
query_dir="./00.fa"                                   # 查询区块路径
delta_dir="./01.nucmer"                               # 输出路径
best_delta_dir="./02.filter"
coord_dir="./03.coords/02.2block"

# 创建必要的输出目录
mkdir -p "${delta_dir}" "${best_delta_dir}" "${coord_dir}"

# 生成序列文件
ls ./00.link_fa/ | awk -F/ '{print $NF}' > "$seq_file"


# 读取区块文件并循环处理
while IFS=$'\t' read -r chr start end; do
    # 构建查询区块路径
    query_fa="${query_dir}/${chr}_${start}_${end}.fa"

    # 遍历 seq 文件中的目标序列，匹配当前染色体的所有区块
    grep ":${chr}_" "$seq_file" | while read -r target_fa; do
        # 提取样本名、染色体和区间信息
        sample=$(echo "$target_fa" | cut -d':' -f1)  # 提取冒号前的样本名
        target_chr=$(echo "$target_fa" | cut -d':' -f2 | cut -d'_' -f1)  # 提取染色体名称
        target_interval=$(echo "$target_fa" | cut -d':' -f2 | cut -d'_' -f2- | sed 's/.fa//')  # 提取区间信息并去掉 .fa

        # 构建目标文件路径
        target_fa_path="./00.link_fa/${target_fa}"

        # 输出文件路径
        delta_file="${delta_dir}/${chr}_${start}_${end}_vs_${sample}_${target_chr}_${target_interval}.delta"
        best_delta_file="${best_delta_dir}/${chr}_${start}_${end}_vs_${sample}_${target_chr}_${target_interval}.best_delta"
        coord_file="${coord_dir}/${chr}_${start}_${end}_vs_${sample}_${target_chr}_${target_interval}.coord.txt"

        # 运行 nucmer 进行比对
        /data1/share/elzd_2023_00095/niujx/bin/mummer-4.0.0beta2/nucmer -c 100 -l 50 -t 4 --mum -p "${delta_file%.delta}" "$target_fa_path" "$query_fa"

        # 运行 delta-filter 进行过滤
        /data1/share/elzd_2023_00095/niujx/bin/mummer-4.0.0beta2/delta-filter -o 90 -1 "${delta_file}" > "${best_delta_file}"

        # 生成比对坐标文件
        /data1/share/elzd_2023_00095/niujx/bin/mummer-4.0.0beta2/.libs/lt-show-coords -T -q -H "${best_delta_file}" > "${coord_file}"

        # 删除临时文件
        rm -f "${delta_file}" "${best_delta_file}"
    done
done < "$interval_file"
