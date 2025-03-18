#!/bin/bash

. ./input_validation.sh
input_validation $@

repo_dir="$HOME/master-thesis/code/backdoorbench"
my_dir="/vol/csedu-nobackup/project/hberendsen"
data_dir="$my_dir/data"
record_dir="$my_dir/record"
timestamp=$(date +"T%d-%m_%H-%M")

# gpu=$(python get_gpu.py)

# if [[ ! $gpu =~ "RTX 2080 Ti" ]]; then
#     echo "Unexpected GPU: ${gpu}"
#     exit 1
# fi

pratio_label=$(echo p$pratio | tr . -)
attack_id="${attack}_${model}_${dataset}_${pratio_label}"

yaml_conf="--yaml_path config/attack/custom/cifar10.yaml"

# Add additional attack-specific configuration unless attack == prototype (clean model)
if [[ $attack != "prototype" ]]; then
    yaml_conf="${yaml_conf} --bd_yaml_path config/attack/custom/$attack.yaml"
    attack_opts="--attack_target 0 --pratio $pratio"
fi

python ./attack/$attack.py $yaml_conf $attack_opts --save_parent_dir "$record_dir" --save_folder_name $attack_id  --dataset_path="$data_dir" --model $model --dataset $dataset --epochs $n_epochs --device cpu