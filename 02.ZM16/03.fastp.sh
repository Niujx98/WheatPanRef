#!/bin/bash

sample_name=$1

   fastp \
      --in1 ./fq/${sample_name}_1.fq.gz \
      --in2 ./fq/${sample_name}_2.fq.gz \
      --out1 R1.clean.fq.gz \
      --out2 R2.clean.fq.gz \
      --split 16 \
      --split_prefix_digits 2 \
      --length_required 36 \
      -5 \
      --cut_front_window_size 1 \
      --cut_front_mean_quality 3 \
      -3 \
      --cut_tail_window_size 1 \
      --cut_tail_mean_quality 3 \
      --cut_window_size 4 \
      --cut_mean_quality 15 \
      --thread 16

