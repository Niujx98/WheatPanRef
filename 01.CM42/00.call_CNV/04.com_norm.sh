#!/bin/bash
set -uxo pipefail

#SBATCH --partition=cpu_parallel  # 指定分区
#SBATCH --ntasks=1                # 任务数
#SBATCH --output=~/tmp.o      # Standard output
#SBATCH --error=~/tmp.e       # Standard error  

rm com.*.norm
for chr in chr1A chr1B chr1D chr2A chr2B chr2D chr3A chr3B chr3D chr4A chr4B chr4D chr5A chr5B chr5D chr6A chr6B chr6D chr7A chr7B chr7D;do    
	for w in win_1Mb_step_200k win_500k_step_100k win_200k_step_40k win_100k_step_20k win_50k_step_10k win_40k_step_8k win_30k_step_6k win_20k_step_4k win_10k_step_2k ; do
        cat ${chr}.${w}.norm >> com.${w}.norm
    done
done

Rscript hist_norm.R
