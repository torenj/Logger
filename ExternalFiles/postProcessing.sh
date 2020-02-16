#!/usr/bin/env bash
mkdir input &> /dev/null
mkdir input_old &> /dev/null
mkdir output &> /dev/null

if mv ~/Library/Application\ Support/dk.logging.ContextLogger/* ./input &> /dev/null; then
    echo "Moved captured files to input folder"
    source ~/.bash_profile
    eval "$(conda shell.bash hook)"
    conda activate logger
    python ${1}dot.py
    python ${1}generateImageDiffs.py
    if mv ./input/* ./input_old &> /dev/null; then
        echo "Moved processed input files out of the way"
    else
        echo "Failed to move files from input out of the way (nothing to move? Was the environment setup?)"
    fi
    mkdir "${1}OutputImageFolder" &> /dev/null
    mv -n output/*.jpg "${1}OutputImageFolder"
else
    echo "Failed to move captured files to input (nothing to move? Was something captured?)"
fi
