#!/bin/bash

while read i
do
sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh
sbatch -e ${i}_MASBam.e -o ${i}_MASBam.o -q cpu_parallel --mem=100G -n 1 MergeAndSplitBam.sh  01.filter.bam  ${i}
#done < /data1/share/elzd_2023_00095/niujx/00.quikly_add_genome/01.fangzhen/chr_list.txt
done < /data1/share/elzd_2023_00095/niujx/00.quikly_add_genome/01.fangzhen/chr_list.txt
