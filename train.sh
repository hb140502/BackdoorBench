#!/bin/bash

attack=$1

repo_dir="$HOME/master-thesis/code/backdoorbench"
my_dir="/vol/csedu-nobackup/project/hberendsen"
data_dir="$my_dir/data"
record_dir="$my_dir/record"
timestamp=$(date +"%d-%m_%H:%M")

if [[ ! $attack =~ "^badnet|blended|wanet|bpp|prototype$" ]]; then
    echo "Attack $attack is not supported"
    exit 1
fi

gpu=$(python get_gpu.py)

if [[ ! $gpu =~ "RTX 2080 Ti" ]]; then
    echo "Unexpected GPU: ${gpu}"
    exit 1
fi

attack_id="${attack}_${timestamp}"

yaml_conf="--yaml_path config/attack/custom/cifar10.yaml"

# Add additional attack-specific configuration unless attack == prototype (clean model)
if [[ $attack != "prototype" ]]; then
    yaml_conf="${yaml_conf} --bd_yaml_path config/attack/custom/$attack.yaml"
fi

# TODO: make pratio, dataset and model variable
python ./attack/$attack.py $yaml_conf --save_parent_dir "$record_dir" --save_folder_name $attack_id  --dataset_path="$data_dir" --attack_target 0 --model resnet18 --dataset cifar10 --pratio 0.05 --epochs 100 --device cuda:0
