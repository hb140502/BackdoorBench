#!/bin/bash

. ./input_validation.sh
input_validation $@

repo_dir="$HOME/master-thesis/code/backdoorbench"
my_dir="/vol/csedu-nobackup/project/hberendsen"
data_dir="$my_dir/data"
record_dir="$my_dir/record"
timestamp=$(date +"T%d-%m_%H-%M")

# pyenv activate bb
source /vol/csedu-nobackup/project/hberendsen/.pyenv/versions/bb/bin/activate

gpu=$(python get_gpu.py)

if [[ ! $gpu =~ "RTX 2080 Ti" ]]; then
    echo "Unexpected GPU: ${gpu}"
    exit 1
fi

pratio_label=$(echo p$pratio | tr . -)
attack_id="${attack}_${model}_${dataset}_${pratio_label}"

function get_clean_config() {
    if [[ $dataset == "imagenette" ]]; then
        echo "config/attack/custom/imagenette.yaml"
    else
        echo "config/attack/custom/cifar10.yaml"
    fi
}

function get_badnet_trigger() {
    if [[ $dataset == "imagenette" ]]; then
        echo "./resource/badnet/badnet_patch_80.png"
    else
        echo "./resource/badnet/badnet_patch_32.png"
    fi
}

function get_badnet_mask() {
    if [[ $dataset == "imagenette" ]]; then
        echo "./resource/badnet/white_square_80.png"
    else
        echo "./resource/badnet/white_square_32.png"
    fi
}

function get_blend_trigger() {
    path_to_trigger="./resource/blended"

    if [[ $dataset == "imagenette" ]]; then
        echo "$path_to_trigger/hellokitty_80.png"
    else
        echo "$path_to_trigger/hellokitty_32.png"
    fi
}

# Clean training configuration
yaml_conf="--yaml_path $(get_clean_config)"

# Add additional attack-specific configuration unless attack == prototype (clean model)
if [[ $attack != "prototype" ]]; then
    yaml_conf="${yaml_conf} --bd_yaml_path config/attack/custom/$attack.yaml"
    attack_opts="--attack_target 0 --pratio $pratio"

    if [[ $attack == "badnet" ]]; then
        attack_opts="$attack_opts --patch_path $(get_badnet_trigger) --mask_path $(get_badnet_mask)"
    elif [[ $attack == "blended" ]]; then
        attack_opts="$attack_opts --attack_trigger_img_path $(get_blend_trigger)"
    elif [[ $attack == "bpp" ]]; then
        attack_opts="$attack_opts --neg_ratio $pratio"
    fi
fi

python ./attack/$attack.py $yaml_conf $attack_opts --save_parent_dir "$record_dir" --save_folder_name $attack_id  --dataset_path="$data_dir" --model $model --dataset $dataset --epochs $n_epochs --device cuda:0

# Handle BackdoorBench failure
if [[ $? -ne 0 ]]; then
    mv "$record_dir/$attack_id" "$record_dir/FAIL_${attack_id}_${timestamp}"
    echo "!!! BACKDOORBENCH FAILURE !!!"
    exit 1
fi

echo "!!! FINISHED TRAINING !!!"
cd $record_dir

# Remove additional bpp datasets before creating tar
if [ $attack == "bpp" ]; then
    cp $attack_id "../bpp_backups/${attack_id}_${timestamp}" # Make backup just in case
    
    cd $attack_id
    rm -rf "clean_train_dataset" "clean_test_dataset" "bd_train_dataset_Save" "bd_test_all_dataset" 
    cd ..
fi
    
tar -cf "${attack_id}_${timestamp}.tar" $attack_id
