#!/bin/bash

#prefetch SRR5893651 -X 100G

#fasterq-dump ./SRR5893651/SRR5893651.sra -O ./SRR5893651 --split-files --threads 4

gzip ./SRR5893651/SRR5893651_1.fq
gzip ./SRR5893651/SRR5893651_2.fq
