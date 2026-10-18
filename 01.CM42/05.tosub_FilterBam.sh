#!/bin/bash

sbatch -e FilterBam.e -o FilterBam.o -q cpu_parallel --mem=100G -n 12 ./FilterBam.sh

