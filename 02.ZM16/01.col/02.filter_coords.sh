#!/bin/bash
set -uxo pipefail

#SBATCH --partition=cpu_parallel  # 指定分区
#SBATCH --ntasks=1                # 任务数
#SBATCH --output=~/tmp.o      # Standard output
#SBATCH --error=~/tmp.e       # Standard error

base_dir="./"
coord_dir="${base_dir}/03.coords/01.toCS"

# 遍历样本文件夹
interval_file="../00.call_CNV/com_true_del_block.txt"

while IFS=$'\t' read -r chr start end; do
    # 计算区块长度
    block_length=$((end - start))

    # 根据区块长度动态调整 TOP5_INT 的值
    if [ $block_length -le 5000000 ]; then
        TOP5_INT=3
    else
        TOP5_INT=$((3 + (block_length - 5000000) / 1000000))
    fi

    # 遍历每个查询区块的 *.coord.txt 文件
    coord_file="${coord_dir}/${chr}_${start}_${end}.coord.txt"
    output_file="${base_dir}/04.filtered_coords/${chr}_${start}_${end}.filtered_coords.txt"
    >"$output_file" # 清空输出文件

    BED=/data1/share/elzd_2023_00095/niujx/01.new_pangenome/fasta/02.ZM16/bed/${chr}.win_3Mb_step_1M.bed
    awk -v chr="$chr" '{print chr "\t" $0}' $coord_file > ${chr}_${start}_${end}.tmp
    ~/anaconda3/envs/njxpy/bin/bedtools intersect -a "$BED" -b "${chr}_${start}_${end}.tmp" -wa -wb > "out_${chr}_${start}_${end}.tmp"
    awk '{print $1"\t"$2"\t"$3}' ${chr}_${start}_${end}.tmp | sort -k2,2n -k3,3n > sorted_${chr}_${start}_${end}.tmp
    ~/anaconda3/envs/njxpy/bin/bedtools merge -i sorted_${chr}_${start}_${end}.tmp > merged_${chr}_${start}_${end}.tmp
    ~/anaconda3/envs/njxpy/bin/bedtools intersect -a "$BED" -b merged_${chr}_${start}_${end}.tmp -wo \
    | awk '{OFS="\t"; overlap[$1":"$2"-"$3]+=$NF} END {for (key in overlap) {split(key, fields, /[:-]/); print fields[1], fields[2], fields[3], overlap[key]}}' \
    | sort -k4,4nr > "out2_${chr}_${start}_${end}.tmp"

    cat "out2_${chr}_${start}_${end}.tmp" | head -n $TOP5_INT | awk '{print $1"\t"$2"\t"$3}' > out3_${chr}_${start}_${end}.tmp
    awk 'NR==FNR{a[$1,$2,$3];next} ($1,$2,$3) in a' out3_${chr}_${start}_${end}.tmp out_${chr}_${start}_${end}.tmp | cut -f5-13 > "$output_file"
    rm ${chr}_${start}_${end}.tmp out*_${chr}_${start}_${end}.tmp merged_${chr}_${start}_${end}.tmp sorted_${chr}_${start}_${end}.tmp
done <"$interval_file"
