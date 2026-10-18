#!/usr/bin/env usr/sh
set -uxo pipefail

w=$1

awk '{if($1!=0) print}' combine_${w}_DP > com_${w}_DP
ave=`./count_CNV.py --normalize on -i com_${w}_DP`

for CHR in chr1A chr1B chr1D chr2A chr2B chr2D chr3A chr3B chr3D chr4A chr4B chr4D chr5A chr5B chr5D chr6A chr6B chr6D chr7A chr7B chr7D ; do
  gawk -vOFS="\t" -vave=$ave '{print $1/ave}' ${CHR}.1.${w}.tmp > ${CHR}.${w}.norm
  gawk -vOFS="\t" -vave=$ave '{print $1/ave}' ${CHR}.2.${w}.tmp >> ${CHR}.${w}.norm
done
