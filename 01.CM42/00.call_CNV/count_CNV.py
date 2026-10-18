#!/usr/bin/env python3
# -*- coding:utf-8 -*-
from __future__ import division  # very important !!!!
from collections import defaultdict
import os
import gzip
import sys
import re
import math
from scipy import stats

def Count(infile, combine_data, count, compensent_deletion, normalize, split, chrom, pop_num, compensent_duplication):
    # open the infile
    try:
        if infile:
            if infile.endswith(".gz"):
                IN = gzip.open(infile, 'rb')
            else:
                IN = open(infile, 'r')
            #
        else:
            IN = sys.stdin
        #
    except IOError:
        print("\n[Error]:\n\t File cannot be open: %s" % infile)
        exit(-1)
#
    if normalize == 'on':
        lis=[]
        for line in IN:
            item = line.strip("\n").split("\t")
            if item[0] != '0':
                lis.append(item[0])
        mode_num=float(stats.mode(lis)[0][0])
        print("%.2f" % mode_num)

    if infile:
        IN.close()
from optparse import OptionParser

# ===========================================
def main():
    usage = "Usage: %prog [-i <input>] [-b 1000] [-o <output>]\n" \
            "Author : Yang, zhengzhao; yangzhengzhao@cau.edu.cn; 2018-06-07\n" \
            "Description: Identify genotype bins orientation from parents.\n" \
            "Input format:\n" \
            "   chr pos geno_p1 geno_p2 geno_son\n" \
            "Output format:\n" \
            "   chr start end total eqp1 eqp2 orient\n" \
            "   chr1A   10001 20000 20  18  2   1\n"
    #
    parser = OptionParser(usage)
    parser.add_option("-i", dest="infile",
                  help="Input file, use STDIN if omit; "
                       "gzip file end with \".gz\".", metavar="FILE")
    parser.add_option("-o", dest="outfile",
                  help="Output file, use STDOUT if omit; "
                       "gzip file end with \".gz\".", metavar="FILE")
    parser.add_option("--combine_data", dest="combine_data",
                  help="Input file, use STDIN if omit; "
                       "gzip file end with \".gz\".", metavar="FILE")
    parser.add_option("--count", dest="count",
                  help="column id for offSpring [default: %default]", metavar="STRING",
                      default = 'off')
    parser.add_option("--split", dest="split",
                  help="column id for offSpring [default: %default]", metavar="STRING",
                      default = 'off')
    parser.add_option("--compensent_deletion", dest="compensent_deletion",
                  help="column id for offSpring [default: %default]", metavar="STRING",
                      default = 'off')
    parser.add_option("--chrom", dest="chrom",
                  help="column id for offSpring [default: %default]", metavar="STRING",
                      default = '1A')
    parser.add_option("--pop_num", dest="pop_num",
                  help="column id for offSpring [default: %default]", metavar="STRING",
                      default = '81')
    parser.add_option("--normalize", dest="normalize",
                  help="column id for offSpring [default: %default]", metavar="STRING",
                      default = 'off')
    parser.add_option("--compensent_duplication", dest="compensent_duplication",
                  help="column id for offSpring [default: %default]", metavar="STRING",
                      default = 'off')
    #
    (options, args) = parser.parse_args()
    #
    if (options.outfile is not None) :  #??????
        if options.outfile.endswith('.gz') :
            sys.stdout = gzip.open(options.outfile, 'wb')
        else:
            sys.stdout = open(options.outfile, 'w')
        #
    #
    Count(infile=options.infile, combine_data=options.combine_data, count=options.count, chrom=options.chrom,
          normalize=options.normalize, compensent_deletion=options.compensent_deletion, split=options.split,
          pop_num=options.pop_num, compensent_duplication=options.compensent_duplication)
    #
#

# ===========================================
if __name__ == "__main__":
    main()
#

