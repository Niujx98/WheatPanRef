#!/bin/bash
set -uxo pipefail

#SBATCH --partition=cpu_parallel  # 指定分区
#SBATCH --ntasks=1                # 任务数
#SBATCH --output=~/tmp.o      # Standard output
#SBATCH --error=~/tmp.e       # Standard error

python sel_win_100k.py

python sel_true_100k_block.py

#python sel_win_dis_100k.py
