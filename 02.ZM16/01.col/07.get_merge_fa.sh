#!/bin/bash
set -uxo pipefail

#SBATCH --partition=cpu_parallel  # 指定分区
#SBATCH --ntasks=1                # 任务数
#SBATCH --output=~/tmp.o      # Standard output
#SBATCH --error=~/tmp.e       # Standard error

# 定义输入和输出文件
simi_file="simi_CS.txt"
fa_dir="00.fa"
output_fasta="genome_1.fa"

# 复制初始 genome_1.fa
cp /data1/share/elzd_2023_00095/niujx/01.new_pangenome/fasta/00.CSgapless/wheat.CS.Gapless.fa "$output_fasta"

# 读取 simi_CS.txt 文件
while read -r line; do
    # 提取第一列和第二列
    region=$(echo "$line" | awk '{print $1}')
    similarity=$(echo "$line" | awk '{print $2}')

    # 检查第二列是否大于等于30
    if (( $(echo "$similarity <= 30" | bc -l) )); then
        # 将对应的 .fa 文件内容追加到 genome_1.fa
        cat "$fa_dir/$region.fa" >> "$output_fasta"
    fi
done < "$simi_file"

# 为输出的 genome_1.fa 创建索引
samtools faidx "$output_fasta"

echo "Processing complete. The indexed genome is in $output_fasta."

