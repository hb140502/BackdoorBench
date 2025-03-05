#!/bin/bash

repo_dir="$HOME/BackdoorBench"
my_dir="/vol/csedu-nobackup/project/hberendsen"
data_dir="$my_dir/data"
record_dir="$my_dir/record"
timestamp=$(date +"%d-%m_%H:%M")

python ./attack/badnet.py --yaml_path "$repo_dir/config/attack/prototype/cifar10.yaml" --patch_mask_path "$repo_dir/resource/badnet/trigger_image.png"  --save_parent_dir "$record_dir" --save_folder_name "badnet_$timestamp" --dataset_path="$data_dir" --epochs 1
