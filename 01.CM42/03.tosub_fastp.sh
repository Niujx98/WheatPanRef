#!/bin/bash

sample=$1

sbatch -e fastp.e -o fastp.o -q cpu_parallel -n 12 --mem=100G ./03.fastp.sh ${sample}
