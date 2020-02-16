#!/usr/bin/env bash

mkdir input &> /dev/null
mkdir input_old &> /dev/null
mkdir output &> /dev/null

if mv ~/Library/Application\ Support/dk.logging.ContextLogger/* ./input &> /dev/null; then
    echo "Moved captured files to input folder"
    eval "$(conda shell.bash hook)"
    conda activate logger
    python dot.py
    python generateImageDiffs.py
    if mv ./input/* ./input_old &> /dev/null; then
        echo "Moved processed input files out of the way"
    else
        echo "Failed to move files from input out of the way (nothing to move? Was the environment setup?)"
    fi
else
    echo "Failed to move captured files to input (nothing to move? Was something captured?)"
fi
