#!/bin/bash

chr=$1
start=$2
end=$3

# 基因组路径
genome_dir="/data1/share/elzd_2023_00095/niujx/01.new_pangenome/fasta/00.CSgapless"
query_dir="./00.fa"
# 输出路径
delta_dir="./01.nucmer"
best_delta_dir="./02.filter"
coord_dir="./03.coords/01.toCS"

mkdir -p ./03.coords
mkdir -p ${delta_dir}
mkdir -p ${best_delta_dir}
mkdir -p ${coord_dir}


# 构建输入和输出文件路径
fa_file="${genome_dir}/${chr}.fa"
query_fa="${query_dir}/${chr}_${start}_${end}.fa"
delta_file="${delta_dir}/${chr}_${start}_${end}.delta"
best_delta_file="${best_delta_dir}/${chr}_${start}_${end}.best_delta"
coord_file="${coord_dir}/${chr}_${start}_${end}.coord.txt"

    # 比对到第一个染色体部分
    /data1/share/elzd_2023_00095/niujx/bin/mummer-4.0.0beta2/nucmer -c 100 -l 50 -t 4 --mum -p "${delta_dir}/${chr}_${start}_${end}" "${fa_file}" "${query_fa}"

    # 运行 delta-filter 进行过滤
    /data1/share/elzd_2023_00095/niujx/bin/mummer-4.0.0beta2/delta-filter -o 90 "${delta_file}" -1 > "${best_delta_file}"

    # 生成比对坐标文件
    /data1/share/elzd_2023_00095/niujx/bin/mummer-4.0.0beta2/.libs/lt-show-coords -T -q -H "${best_delta_file}" > "${coord_file}"
 
