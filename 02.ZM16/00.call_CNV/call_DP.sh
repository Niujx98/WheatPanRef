#!/bin/bash

SAMPLE=$2
chr=$1

for w in win_1Mb_step_200k win_500k_step_100k win_200k_step_40k win_100k_step_20k win_50k_step_10k win_40k_step_8k win_30k_step_6k win_20k_step_4k win_10k_step_2k ; do
    ~/bin/bedtools/bin/bedtools coverage -a /data1/share/elzd_2023_00095/niujx/01.new_pangenome/fasta/${SAMPLE}/bed/${chr}.1.${w}.bed -b  ../${chr}.1.dedup.bam -counts -sorted > ${chr}.1.${w}.DP
    ~/bin/bedtools/bin/bedtools coverage -a /data1/share/elzd_2023_00095/niujx/01.new_pangenome/fasta/${SAMPLE}/bed/${chr}.2.${w}.bed -b  ../${chr}.2.dedup.bam -counts -sorted > ${chr}.2.${w}.DP
done 
