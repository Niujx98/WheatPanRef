#!/usr/bin/env usr/sh
set -uxo pipefail

w=$1

ave=$(awk '$1 != 0 {print $1}' combine_${w}_DP | sort | uniq -c | sort -nr | head | awk -v range=0.2 -v mean=$(awk '$1 != 0 {sum+=$1; count++} END {if (count > 0) print sum/count; else print "NaN"}' combine_${w}_DP) '
{
    diff = ($2 > mean) ? ($2 - mean) : (mean - $2); 
    if (diff <= mean * range && (NR == 1 || $1 > max_count)) {
        max_count = $1;
        ave = $2;
    }
}
END {print ave}')

for CHR in chr1A chr1B chr1D chr2A chr2B chr2D chr3A chr3B chr3D chr4A chr4B chr4D chr5A chr5B chr5D chr6A chr6B chr6D chr7A chr7B chr7D ; do
  gawk -vOFS="\t" -vave=$ave '{print $1/ave}' ${CHR}.1.${w}.tmp > ${CHR}.${w}.norm
  gawk -vOFS="\t" -vave=$ave '{print $1/ave}' ${CHR}.2.${w}.tmp >> ${CHR}.${w}.norm
done

