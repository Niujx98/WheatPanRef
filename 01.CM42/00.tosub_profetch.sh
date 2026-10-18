#!/bin/bash

sbatch -e prefetch.e -o prefetch.o -q cpu_parallel -n 1 ./00.prefetch.sh
