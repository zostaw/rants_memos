#!/bin/bash

# Script will record a voice message and transcribe it to markdown file (it will add at the end if file already exists)
# usage: ./rant.sh [-a]
# send ^C when finished
# option: 
# -a (save audio file)

# do not change below - main dir is dreams main path
MAIN_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)
cd $MAIN_DIR
FULL_DATE=$(date +"%Y-%m-%d_%H:%M")
TODAY=$(echo $FULL_DATE | sed 's/_.*//g')
TMP_DIR=${MAIN_DIR}/tmp
AUDIO_TMP_16k="${TMP_DIR}/${FULL_DATE}_16k.wav"
source ${MAIN_DIR}/params.sh

if [ ! -x "${WHISPER_MAIN}" ]; then
    echo "WHISPER_MAIN=\"$WHISPER_MAIN\" is not executable. \
        Check if set correctly in params.sh. Installation details are in README.md"
fi

if [ ! -f "${WHISPER_MODEL}" ]; then
    echo "WHISPER_MODEL=\"$WHISPER_MODEL\" cannot be found. \
        Check if set correctly in params.sh. Installation details are in README.md"
fi

if [ ! -d "${TMP_DIR}" ]; then
    mkdir -p ${TMP_DIR} || echo "Could not find or create TMP_DIR=\"$TMP_DIR\" \
        Check if write permissions are set to MAIN_DIR=\"$MAIN_DIR\" \
        MAIN_DIR ussualy should be parent dir for the script. Is it?"
fi

if [ ! -d "${RANTS_OUTPUT_DIR}" ]; then
    mkdir -p ${RANTS_OUTPUT_DIR} || echo "Could not find or create RANTS_OUTPUT_DIR=\"$RANTS_OUTPUT_DIR\" \
        Check if it's correctly set in params.sh \
        Check if write permissions are set to its parent dir."
fi
 
# below can be adjusted
audio_file="${RANTS_OUTPUT_DIR}/${FULL_DATE}.wav"
output_file="${RANTS_OUTPUT_DIR}/${TODAY}.md"

# open recorder
sox -d ${audio_file}
# preprocess
ffmpeg -i ${audio_file} -vn -ar 16000 -ac 1 ${AUDIO_TMP_16k}
# feed to whisper.cpp and save to .md
touch ${output_file}
echo "# RANT ${FULL_DATE}" >> ${output_file}
echo >> ${output_file}
${WHISPER_MAIN} -m ${WHISPER_MODEL} -f ${AUDIO_TMP_16k} | grep -e '-->' | sed 's/\[.*-->.*\]   //g' >> ${output_file}
echo >> ${output_file}

# cleanup
rm ${AUDIO_TMP_16k}
echo "transcript: ${output_file}"
if [ "$1" == "-a" ]; then
    echo "audio: ${output_file}"
    exit
fi
rm ${audio_file}

