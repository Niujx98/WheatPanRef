#!/bin/bash
set -uxo pipefail

for chr in chr1A chr1B chr1D chr2A chr2B chr2D chr3A chr3B chr3D chr4A chr4B chr4D chr5A chr5B chr5D chr6A chr6B chr6D chr7A chr7B chr7D;do
   sh /data1/share/elzd_2023_00095/niujx/wait_niu.sh
   sbatch -e ${chr}.DP.e -o ${chr}.DP.o -q cpu_parallel -n 1 call_DP.sh ${chr} 01.CM42
done

