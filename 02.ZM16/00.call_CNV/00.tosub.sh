#!/bin/bash
set -uxo pipefail

# 初始化变量以存储所有作业 ID
all_jobs=""

# Step 1: 提交 call_DP.sh 脚本
echo "Step 1: Submitting call_DP.sh scripts for each chromosome"

for chr in chr1A chr1B chr1D chr2A chr2B chr2D chr3A chr3B chr3D chr4A chr4B chr4D chr5A chr5B chr5D chr6A chr6B chr6D chr7A chr7B chr7D; do
    # 检测任务数量是否小于40
    sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh

    # 提交任务并收集作业 ID
    job_chr=$(sbatch -e ${chr}.DP.e -o ${chr}.DP.o -q cpu_parallel -n 1 --nodes=1 --ntasks-per-node=1 call_DP.sh ${chr} 02.ZM16 | awk '{print $4}')
    echo "call_DP.sh submitted for ${chr} with Job ID: $job_chr"

    # 将作业 ID 添加到列表中
    all_jobs="${all_jobs},${job_chr}"
done

# 移除 all_jobs 的第一个逗号
all_jobs=${all_jobs#,}

# Step 2: 提交 01.call_CNV.sh 脚本，依赖 Step 1 完成
echo "Step 2: Submitting 01.call_CNV.sh"

sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh
job_call_cnv=$(sbatch --dependency=afterok:${all_jobs} -e 01.call_CNV.e -o 01.call_CNV.o -q cpu_parallel -n 1 --nodes=1 --ntasks-per-node=1 01.call_CNV.sh 02.ZM16 | awk '{print $4}')
echo "01.call_CNV.sh submitted with Job ID: $job_call_cnv"

# Step 3: 提交 02.tosub_sel_block.sh 脚本，依赖 Step 2 完成
echo "Step 3: Submitting 02.tosub_sel_block.sh"

sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh
job_sel_block=$(sbatch --dependency=afterok:${job_call_cnv} -e 02.sel_block.e -o 02.sel_block.o -q cpu_parallel -n 1 --nodes=1 --ntasks-per-node=1 02.tosub_sel_block.sh | awk '{print $4}')
echo "02.tosub_sel_block.sh submitted with Job ID: $job_sel_block"

# Step 4: 提交 03.plot_block.sh 脚本，依赖 Step 3 完成
echo "Step 4: Submitting 03.plot_block.sh"

sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh
job_plot_block=$(sbatch --dependency=afterok:${job_sel_block} -e 03.plot_block.e -o 03.plot_block.o -q cpu_parallel -n 1 --nodes=1 --ntasks-per-node=1 03.plot_block.sh | awk '{print $4}')
echo "03.plot_block.sh submitted with Job ID: $job_plot_block"

echo "All steps submitted successfully!"

