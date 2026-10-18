#!/bin/bash
set -uxo pipefail

mkdir -p ./fq

../GenerateReads_WG_PE -i ../01.CM42/01.col/genome_1.fa -n 500000000 -l 150 -o ./fq/fangzhen

python ../fasta2fastq.py ./fq/fangzhen_1.fa ./fq/fangzhen_1.fq 150
python ../fasta2fastq.py ./fq/fangzhen_2.fa ./fq/fangzhen_2.fq 150

sed -i 's/_.*//g' ./fq/fangzhen_1.fq 
sed -i 's/_.*//g' ./fq/fangzhen_2.fq 

sed -i 's/_-_/_+_/g' ./fq/fangzhen_1.fq
sed -i 's/_-_/_+_/g' ./fq/fangzhen_2.fq

gzip ./fq/fangzhen_1.fq 
gzip ./fq/fangzhen_2.fq

