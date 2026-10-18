#!/bin/bash

sam=$1

# Paths to necessary files and directories
sample_list="./simi_CS.txt"
sample_list_WORK="/data1/share/elzd_2023_00095/niujx/01.new_pangenome/${sam}/01.col/04.filtered_coords"

# Output file paths
lt30_sample_list="lt30_sample_list.txt"
gt30_sample_list="gt30_sample_list.txt"

# Directories for filtered work
gt30_sample_listwork="05.filter"
lt30_sample_listwork="06.retain"

# Create separate lists based on column 2 value
awk '$3<=30 {print $1}' "$sample_list" > "$lt30_sample_list"
awk '$3>30 {print $1}' "$sample_list" > "$gt30_sample_list"

# Create directories if not exist
mkdir -p "$lt30_sample_listwork"
mkdir -p "$gt30_sample_listwork"

# Copy files for lt30 samples
while read -r line; do
    ln -s "${sample_list_WORK}/${line}.filtered_coords.txt" "${lt30_sample_listwork}/"
done < "$lt30_sample_list"

# Copy files for gt30 samples
while read -r line; do
    ln -s "${sample_list_WORK}/${line}.filtered_coords.txt" "${gt30_sample_listwork}/"
done < "$gt30_sample_list"

rm "$lt30_sample_list" "$gt30_sample_list"
