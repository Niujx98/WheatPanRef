#!/bin/bash

bam_filter_file=/data1/share/elzd_2023_00095/niujx/00.quikly_add_genome/01.fangzhen/filter_list.txt
ID_list_file=/data1/share/elzd_2023_00095/niujx/00.quikly_add_genome/01.fangzhen/ID_list.txt
for identifier in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16;do
BAM=${identifier}.bam      
      samtools sort -@ 16 -o ${identifier}.sort.bam ${BAM}
      bamtools filter \
        -in ${identifier}.sort.bam  \
        -out ${identifier}.filter.bam \
        -forceCompression -script ${bam_filter_file};
      samtools index ${identifier}.filter.bam;

      rm ${identifier}.sort.bam;
    done

    gawk '{print $1".filter.bam"}' ${ID_list_file} > bam_list.txt
    gawk '{print $1".filter.bam.bai"}' ${ID_list_file} > bam_index_list.txt
