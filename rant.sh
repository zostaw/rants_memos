#!/bin/bash

# Script will record a voice message and transcribe it to markdown file (it will add at the end if file already exists)
# usage: ./rant.sh [-a]
# send ^C when finished
# option: 
# -a (save audio file)

# do not change below
MAIN_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &>/dev/null && pwd)
cd $MAIN_DIR
FULL_DATE=$(date +"%Y.%m.%d_%H:%M")
TODAY=$(echo $FULL_DATE | sed 's/_.*//g')
AUDIO_TMP_16k="${MAIN_DIR}/${FULL_DATE}_16k.wav"

# below can be adjusted
whisper_dir="<your whisper path>"
output_dir=${MAIN_DIR}
audio_file="${output_dir}/${FULL_DATE}.wav"
output_file="${output_dir}/${TODAY}.md"

# open recorder
sox -d ${audio_file}
# preprocess
ffmpeg -i ${audio_file} -vn -ar 16000 -ac 1 ${AUDIO_TMP_16k}
# feed to whisper.cpp and save to markdown
cd $whisper_dir
touch ${output_file}
echo "# RANT ${FULL_DATE}" >> ${output_file}
echo >> ${output_file}
./main -m models/ggml-medium.en-q5_0.bin -f ${AUDIO_TMP_16k} | grep -e '-->' | sed 's/\[.*-->.*\]   //g' >> ${output_file}
echo >> ${output_file}

# cleanup
rm ${AUDIO_TMP_16k}
echo "transcript: ${output_file}"
if [ "$1" == "-a" ]; then
    echo "audio: ${output_file}"
    exit
fi
rm ${audio_file}

