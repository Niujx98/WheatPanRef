#!/bin/bash
set -uxo pipefail

#SBATCH --partition=cpu_parallel  # 指定分区
#SBATCH --ntasks=1                # 任务数
#SBATCH --output=~/tmp.o      # Standard output
#SBATCH --error=~/tmp.e       # Standard error

# Paths to necessary files and directories
sample_list="./simi_CS_100k.txt"
sample_list_WORK="./04.filtered_100k_coords"

# Output file paths
lt30_sample_list="lt30_sample_list.txt"
gt30_sample_list="gt30_sample_list.txt"

# Directories for filtered work
gt30_sample_listwork="05.filter_100k"
lt30_sample_listwork="06.retain_100k"

# Create separate lists based on column 2 value
awk '$2<=30 {print $1}' "$sample_list" > "$lt30_sample_list"
awk '$2>30 {print $1}' "$sample_list" > "$gt30_sample_list"

# Create directories if not exist
mkdir -p "$lt30_sample_listwork"
mkdir -p "$gt30_sample_listwork"

# Copy files for lt30 samples
while read -r line; do
    cp "${sample_list_WORK}/${line}.filtered_coords.txt" "${lt30_sample_listwork}/"
done < "$lt30_sample_list"

# Copy files for gt30 samples
while read -r line; do
    cp "${sample_list_WORK}/${line}.filtered_coords.txt" "${gt30_sample_listwork}/"
done < "$gt30_sample_list"

rm "$lt30_sample_list" "$gt30_sample_list"
