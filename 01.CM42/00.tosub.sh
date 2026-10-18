#!/bin/bash

# Step 4: 运行 05.tosub_FilterBam.sh 脚本
echo "Step 4: Submitting 05.tosub_FilterBam.sh"
job_filterbam=$(sbatch -e FilterBam.e -o FilterBam.o -q cpu_parallel --mem=100G -n 12 ./FilterBam.sh | awk '{print $4}')
echo "05.tosub_FilterBam.sh submitted with Job ID: $job_filterbam"

# Step 5: 等待 05.tosub_FilterBam.sh 完成，运行 06.tosub_MASbam.sh 脚本
echo "Step 5: Waiting for 05.tosub_FilterBam.sh to complete..."
srun --dependency=afterok:${job_filterbam} true

echo "Step 5: Submitting 06.tosub_MASbam.sh"
while read i
do
    # 等待前一个作业完成后提交下一个
    sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh
    sbatch -e ${i}_MASBam.e -o ${i}_MASBam.o -q cpu_parallel --mem=100G -n 1 MergeAndSplitBam.sh 01.filter.bam ${i}
    echo "06.tosub_MASbam.sh submitted for chromosome ${i}"
done < /data1/share/elzd_2023_00095/niujx/00.quikly_add_genome/01.fangzhen/chr_list.txt

echo "All steps completed successfully!"
