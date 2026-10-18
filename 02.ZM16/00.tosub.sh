#!/bin/bash

# Step 1: 运行 03.fastp.sh 脚本
echo "Step 1: Submitting 03.fastp.sh"

# 检测任务数量是否小于40
sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh

# 提交任务
job_fastp=$(sbatch -e fastp.e -o fastp.o -q cpu_parallel -n 16 --mem=100G ./03.fastp.sh fangzhen | awk '{print $4}')
echo "03.fastp.sh submitted with Job ID: $job_fastp"

# Step 2: 等待 Step 1 完成，运行 04.tosub_bwa.sh 脚本
echo "Step 2: Submitting 04.tosub_bwa.sh"

for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16
do
    # 检测任务数量是否小于40
    sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh

    # 提交任务
    job_bwa=$(sbatch --dependency=afterok:${job_fastp} -e ${i}.bwa.e -o ${i}.bwa.o -q cpu_parallel -n 16 --mem=100G ./bwa.sh ZM16 ${i} | awk '{print $4}')
    echo "bwa.sh for part ${i} submitted with Job ID: $job_bwa"
done

# Step 3: 等待所有 bwa.sh 作业完成
echo "Step 3: Submitting 05.tosub_FilterBam.sh"

# 检测任务数量是否小于40
sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh

# 提交任务
job_filterbam=$(sbatch --dependency=singleton -e FilterBam.e -o FilterBam.o -q cpu_parallel --mem=100G -n 16 ./FilterBam.sh | awk '{print $4}')
echo "05.tosub_FilterBam.sh submitted with Job ID: $job_filterbam"

# Step 4: 等待 05.tosub_FilterBam.sh 完成，运行 06.tosub_MASbam.sh 脚本
echo "Step 4: Submitting 06.tosub_MASbam.sh"

while read i
do
    # 检测任务数量是否小于40
    sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh

    # 提交任务
    job_masbam=$(sbatch --dependency=afterok:${job_filterbam} -e ${i}_MASBam.e -o ${i}_MASBam.o -q cpu_parallel --mem=100G -n 1 MergeAndSplitBam.sh 01.filter.bam ${i} | awk '{print $4}')
    echo "06.tosub_MASbam.sh submitted for chromosome ${i} with Job ID: $job_masbam"
done < /data1/share/elzd_2023_00095/niujx/00.quikly_add_genome/01.fangzhen/chr_list.txt

echo "All steps completed successfully!"


