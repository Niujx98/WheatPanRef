#!/bin/bash
sample_name=$1
i=$2
ref_fasta=/data1/share/elzd_2023_00095/niujx/01.new_pangenome/fasta/02.ZM16/ZM16_part.fa

  bwa mem -t 16 \
      -R '@RG\tID:'${sample_name}'\tLB:'${sample_name}'\tPL:ILLUMINA\tSM:'${sample_name} \
      ${ref_fasta} \
      ${i}.R1.clean.fq.gz ${i}.R2.clean.fq.gz | tee \
      >(samtools view -Sbh -f 4 - > ${i}.unmapped.bam) |\
      samtools view -Sbh - > ${i}.bam
