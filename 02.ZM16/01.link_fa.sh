#!/bin/bash

output_dir="./00.link_fa"

# 创建输出目录
mkdir -p "$output_dir"

sam=$1
base_name=$2

    # 定义输入文件
    input1="../${sam}/01.col/simi_CS.txt"
    input2="../${sam}/01.col/simi_CS_100k.txt"
    fasta_file="../fasta/${sam}/${base_name}.fa"

    # 函数：解析输入文件并抽取符合条件的序列
    extract_sequences() {
        local input_file=$1
        while read -r line; do
            # 跳过空行
            if [[ -z "$line" ]]; then
                continue
            fi
            
            # 提取列信息
            region=$(echo "$line" | awk '{print $1}')
            value=$(echo "$line" | awk '{print $2}')
            
            # 判断第二列是否 <= 30
            if (( $(echo "$value <= 30" | bc -l) )); then
                # 提取染色体和区间
                chr=$(echo "$region" | cut -d'_' -f1)
                start=$(echo "$region" | cut -d'_' -f2)
                end=$(echo "$region" | cut -d'_' -f3)

                # 将 start 加 1
                start=$((start + 1))
                
                # 使用samtools抽取序列
                output_file="$output_dir/${base_name}_${region}.fa"
                samtools faidx "$fasta_file" "${chr}:${start}-${end}" > "$output_file"
                
                # 修改FASTA头信息，包含样本名和区间信息
                {
                    echo ">${base_name}_${region}"
                    tail -n +2 "$output_file"
                } > "${output_file}.tmp" && mv "${output_file}.tmp" "$output_file"

            fi
        done < "$input_file"
    }

    # 处理两个输入文件
    extract_sequences "$input1"
    extract_sequences "$input2"
