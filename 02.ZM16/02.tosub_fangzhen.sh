#!/bin/bash

sbatch -e fangzhen.e -o fangzhen.o -q cpu_parallel --mem=100G -n 2 ./02.fangzhen.sh
