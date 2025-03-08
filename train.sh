#!/bin/bash

attack=$1

repo_dir="$HOME/master-thesis/code/backdoorbench"
my_dir="/vol/csedu-nobackup/project/hberendsen"
data_dir="$my_dir/data"
record_dir="$my_dir/record"
timestamp=$(date +"%d-%m_%H:%M")


if [[ ! $attack=~"^badnet|blended|wanet|bpp$" ]]; then
    echo "Attack $attack is not supported"
    exit 1
fi

# Merge common dataset configuration and attack-specific configuration
attack_id="${attack}_${timestamp}"
yaml_conf="config/attack/tmp/$attack_id.yaml"
touch $yaml_conf
cat config/attack/custom/cifar10.yaml config/attack/custom/$attack.yaml >> $yaml_conf

python ./attack/$attack.py $flags --yaml_path $repo_dir/$yaml_conf --save_parent_dir "$record_dir" --save_folder_name $attack_id  --dataset_path="$data_dir" --epochs 0 --device cpu
