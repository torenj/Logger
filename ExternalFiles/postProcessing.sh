#!/usr/bin/env bash
cd ${1}
mkdir input &> /dev/null
mkdir input_old &> /dev/null
mkdir output &> /dev/null

if mv -v ~/Library/Application\ Support/dk.logging.ContextLogger/* ./input; then
    echo "Moved captured files to input folder" >> ${1}sequencelog.txt
    source ~/.bash_profile >> ${1}sequencelog.txt
    eval "$(conda shell.bash hook)" >> ${1}sequencelog.txt
    conda activate logger >> ${1}sequencelog.txt
    python ${1}dot.py >> ${1}sequencelog.txt
    python ${1}generateImageDiffs.py >> ${1}sequencelog.txt
    if mv ./input/* ./input_old &> /dev/null; then
        echo "Moved processed input files out of the way" >> ${1}sequencelog.txt
    else
        echo "Failed to move files from input out of the way (nothing to move? Was the environment setup?)" >> ${1}sequencelog.txt
    fi
    mkdir "${1}OutputImageFolder" &> /dev/null
    mv -n output/*.jpg "${1}OutputImageFolder"
else
    echo "Failed to move captured files to input (nothing to move? Was something captured?)" >> ${1}sequencelog.txt
fi
