#!/bin/bash

function input_validation() {
    usage_str="""
Usage: ${0} <ATTACK> <NUMBER OF EPOCHS>"""

    if [[ $# -ne 2 ]]; then
        echo $usage_str
        exit 1
    fi

    attack=$1
    n_epochs=$2
}
