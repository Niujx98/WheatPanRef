#!/bin/bash

mkdir -p ./plot

Rscript 05.plot_col_filter.R

Rscript 06.plot_col_retain.R
