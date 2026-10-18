#!/bin/bash
set -uxo pipefail

#SBATCH --partition=cpu_parallel  # 指定分区
#SBATCH --ntasks=1                # 任务数
#SBATCH --output=~/tmp.o      # Standard output
#SBATCH --error=~/tmp.e       # Standard error

for sample in 01.CM42; do 

    # 去掉前缀 "01."，仅保留 "CM42"
    base_name=${sample#01.}

    # 输入文件路径
    simi_file="../../${sample}/01.col/simi_CS.txt"
    fa_dir="/data1/share/elzd_2023_00095/niujx/01.new_pangenome/${sample}/01.col/00.fa"
    link_dir="./00.link_fa"

    # 创建目标文件夹，如果不存在
    mkdir -p "$link_dir"

    # 遍历 simi_CS.txt 文件，处理第二列值 <= 30 的情况
    while read -r line; do
        # 提取第一列和第二列
        first_col=$(echo "$line" | awk '{print $1}')
        second_col=$(echo "$line" | awk '{print $2}')

        # 检查第二列值是否小于等于 30
        if (( $(echo "$second_col <= 30" | bc -l) )); then
            # 构造源文件和目标链接
            source_file="${fa_dir}/${first_col}.fa"
            target_link="${link_dir}/${base_name}:${first_col}.fa"

            # 如果源文件存在，创建符号链接
            if [[ -f "$source_file" ]]; then
                ln -s "$source_file" "$target_link"
                echo "Linked: $source_file -> $target_link"
            else
                echo "Source file not found: $source_file"
            fi
        fi
    done < "$simi_file"

done

