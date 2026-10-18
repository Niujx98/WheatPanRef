#!/bin/bash

sample=$1

for i in 01 02 03 04 05 06 07 08
do
sbatch -e ${i}.bwa.e -o ${i}.bwa.o -q cpu_parallel -n 12 --mem=100G ./bwa.sh ${sample} ${i}
done
