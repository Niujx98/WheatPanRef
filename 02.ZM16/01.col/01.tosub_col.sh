#!/bin/bash

# 输入区块文件路径
#interval_file="../00.call_CNV/com_true_del_block.txt"
interval_file="../00.call_CNV/com_true_100k_del_block.txt"

# 读取区块文件并循环处理
while IFS=$'\t' read -r chr start end; do

sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh

sbatch -e ${chr}_${start}_${end}.e -o ${chr}_${start}_${end}.o -q cpu_parallel --mem=100G -n 1 01.col_CS.sh ${chr} ${start} ${end}

done < "$interval_file"
