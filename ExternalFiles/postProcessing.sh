#!/usr/bin/env bash

echo_time() {
    date +"[%Y-%m-%d %H:%M:%S] $(printf "%s " "$@" | sed 's/%/%%/g')"
}

DOCUMENTS=${1}
APP_SUPPORT_FOLDER=~/Library/Application\ Support/dk.logging.ContextLogger/
cd ${DOCUMENTS}

mkdir input &> /dev/null
mkdir input_old &> /dev/null
mkdir output &> /dev/null

if [ "$(ls -A "$APP_SUPPORT_FOLDER")" ]; then
    for file in "$APP_SUPPORT_FOLDER"*; do mv -- "$file" ./input ; done
    echo_time "Moved captured files to input folder" >> "${DOCUMENTS}/sequencelog.txt"
    source ~/.zshrc >> "${DOCUMENTS}/debuglog.txt"
    eval "$(conda shell.bash hook)" >> "${DOCUMENTS}/debuglog.txt"
    conda activate logger >> "${DOCUMENTS}/debuglog.txt"
    python "${DOCUMENTS}/dot.py" >> "${DOCUMENTS}/sequencelog.txt"
    python "${DOCUMENTS}/generateImageDiffs.py" >> "${DOCUMENTS}/sequencelog.txt"
    
    if [ "$(ls -A ./input)" ]; then
        for file in ./input/*; do mv -- "$file" ./input_old ; done
        echo_time "Moved processed input files out of the way" >> "${DOCUMENTS}/sequencelog.txt"
    else
        echo_time "Failed to move files from input out of the way (nothing to move? Was the environment setup?)" >> "${DOCUMENTS}/sequencelog.txt"
    fi
    mkdir "${DOCUMENTS}/OutputImageFolder" &> /dev/null
    for file in ./output/*; do mv -- "$file" "${DOCUMENTS}/OutputImageFolder" ; done
else
    echo_time "Failed to move captured files to input (nothing to move? Was something captured?)" >> "${DOCUMENTS}/sequencelog.txt"
fi
