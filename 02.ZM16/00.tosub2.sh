#!/bin/bash

# Step 3: 等待所有 bwa.sh 完成，运行 FilterBam.sh
echo "Step 3: Submitting 05.tosub_FilterBam.sh"

# 检测任务数量是否小于40
sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh

# 提交任务，依赖所有 bwa.sh 作业完成，限制为单节点运行
job_filterbam=$(sbatch -e FilterBam.e -o FilterBam.o -q cpu_parallel --mem=100G -n 16 --nodes=1 --ntasks-per-node=16 ./FilterBam.sh | awk '{print $4}')
echo "05.tosub_FilterBam.sh submitted with Job ID: $job_filterbam"

# Step 4: 等待 05.tosub_FilterBam.sh 完成，运行 MergeAndSplitBam.sh 脚本
echo "Step 4: Submitting 06.tosub_MASbam.sh"

while read i; do
    # 检测任务数量是否小于40
    sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh

    # 提交任务，限制为单节点运行
    job_masbam=$(sbatch --dependency=afterok:${job_filterbam} -e ${i}_MASBam.e -o ${i}_MASBam.o -q cpu_parallel --mem=100G -n 1 --nodes=1 --ntasks-per-node=1 MergeAndSplitBam.sh 01.filter.bam ${i} | awk '{print $4}')
    echo "06.tosub_MASbam.sh submitted for chromosome ${i} with Job ID: $job_masbam"
done < /data1/share/elzd_2023_00095/niujx/00.quikly_add_genome/01.fangzhen/chr_list.txt

echo "All steps completed successfully!"
