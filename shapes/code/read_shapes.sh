#!/bin/bash
#SBATCH --cpus-per-task 4
R CMD BATCH --no-save read_shapes.R read_shapes.out
