#!/bin/bash
#SBATCH -A cseduproject 
#SBATCH -p csedu-prio,csedu 
#SBATCH -q csedu-small 
#SBATCH -c 4 
#SBATCH --mem 4G 
#SBATCH --gres=gpu:rtx_2080_ti:1 
#SBATCH -t 2:00:00
#SBATCH --output=jobs/%j.out
#SBATCH --error=jobs/%j.err

. ./input_validation.sh
input_validation $@

./train.sh $attack $n_epochs
