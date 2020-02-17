#!/usr/bin/env bash

echo_time() {
    date +"[%Y-%m-%d %H:%M:%S] $(printf "%s " "$@" | sed 's/%/%%/g')"
}

DOCUMENTS=${1}
cd ${DOCUMENTS}
mkdir input &> /dev/null
mkdir input_old &> /dev/null
mkdir output &> /dev/null

if mv ~/Library/Application\ Support/dk.logging.ContextLogger/* ./input >> "${DOCUMENTS}/debuglog.txt"; then
    echo_time "Moved captured files to input folder" >> "${DOCUMENTS}/sequencelog.txt"
    source ~/.bash_profile >> "${DOCUMENTS}/debuglog.txt"
    eval "$(conda shell.bash hook)" >> "${DOCUMENTS}/debuglog.txt"
    conda activate logger >> "${DOCUMENTS}/debuglog.txt"
    python "${1}/dot.py" >> "${DOCUMENTS}/sequencelog.txt"
    python "${1}/generateImageDiffs.py" >> "${DOCUMENTS}/sequencelog.txt"
    if mv ./input/* ./input_old &> /dev/null; then
        echo_time "Moved processed input files out of the way" >> "${DOCUMENTS}/sequencelog.txt"
    else
        echo_time "Failed to move files from input out of the way (nothing to move? Was the environment setup?)" >> "${DOCUMENTS}/sequencelog.txt"
    fi
    mkdir "${DOCUMENTS}/OutputImageFolder" &> /dev/null
    mv -n output/*.jpg "${DOCUMENTS}/OutputImageFolder"
else
    echo_time "Failed to move captured files to input (nothing to move? Was something captured?)" >> ${DOCUMENTS}/sequencelog.txt
fi
