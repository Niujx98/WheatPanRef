#!/bin/bash
set -uxo pipefail

#SBATCH --partition=cpu_parallel  # 指定分区
#SBATCH --ntasks=1                # 任务数
#SBATCH --output=~/tmp.o      # Standard output
#SBATCH --error=~/tmp.e       # Standard error  

SAMPLE=$1

for chr in chr1A chr1B chr1D chr2A chr2B chr2D chr3A chr3B chr3D chr4A chr4B chr4D chr5A chr5B chr5D chr6A chr6B chr6D chr7A chr7B chr7D;do
    for w in win_1Mb_step_200k win_500k_step_100k win_200k_step_40k win_100k_step_20k win_50k_step_10k win_40k_step_8k win_30k_step_6k win_20k_step_4k win_10k_step_2k ; do
        awk '{print $4*1000/($3-$2)}' ${chr}.1.${w}.DP > ${chr}.1.${w}.tmp
        awk '{print $4*1000/($3-$2)}' ${chr}.2.${w}.DP > ${chr}.2.${w}.tmp
    done
done

for w in win_1Mb_step_200k win_500k_step_100k win_200k_step_40k win_100k_step_20k win_50k_step_10k win_40k_step_8k win_30k_step_6k win_20k_step_4k win_10k_step_2k ; do
     cat chr*.${w}.tmp > combine_${w}_DP
     sh ./script_un1k.sh ${w}
     rm com_${w}_del_block.txt
     for chr in chr1A chr1B chr1D chr2A chr2B chr2D chr3A chr3B chr3D chr4A chr4B chr4D chr5A chr5B chr5D chr6A chr6B chr6D chr7A chr7B chr7D;do
         awk '{if ($1<=0.5) print "deletion";else print "white"}' ${chr}.${w}.norm > ${chr}.z
         paste /data1/share/elzd_2023_00095/niujx/01.new_pangenome/fasta/${SAMPLE}/bed/${chr}.${w}.bed ${chr}.z | sed 's/ /\t/g'> ${chr}.${w}.CNV
         grep 'deletion' ${chr}.${w}.CNV > ${chr}.z1
         awk '{print $1"\t"$2"\t"$3}' ${chr}.z1 |sort -n -k 2 > ${chr}.z3
         ~/bin/bedtools/bin/bedtools merge -i ${chr}.z3 -d 500 > ${chr}.${w}.com_del
         rm ${chr}.z*
         awk '{print $1"\t"$2"\t"$3}' ${chr}.${w}.com_del >> com_${w}_del_block.txt
         rm ${chr}.${w}.com_del
     done
done

rm *.tmp *.CNV
