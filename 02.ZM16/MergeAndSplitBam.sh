#!/bin/bash

HEADER_BAM=$1
chr=$2
    (samtools view -H ${HEADER_BAM}; while read BAM; do samtools view ${BAM} ${chr}; done < /data1/share/elzd_2023_00095/niujx/00.quikly_add_genome/01.fangzhen/FILTERED_BAMS.txt) | samtools view -Sb - > ${chr}.bam
    samtools sort  -o ${chr}.sort.bam ${chr}.bam; rm ${chr}.bam
    samtools rmdup -S ${chr}.sort.bam ${chr}.dedup.bam
    samtools index ${chr}.dedup.bam
    samtools flagstat ${chr}.dedup.bam > ${chr}.flagstat

