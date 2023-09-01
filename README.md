# memos and rants transcription

This project uses whisper.cpp to provide transcription tool for:
- "Voice Memos" (Apple app).
- Microphone voice capture real-time and transcribed into notes.

# About

## rants.sh

*rants.sh* listens to microphone input until it is stopped with ^C. 
Once it's finished, it transcribes the note into text file stored in *RANTS_OUTPUT_DIR/<today date>.md*
If recorded multiple memos, they are all appended to file, but separate md sections are created, for example:

```RANTS_OUTPUT_DIR/2023-09-01.md

# RANT 2023-09-01_14:45

Okay, so this is a test.

# RANT 2023-09-01_20:35

Okay, so this is a test for the new implementation of the RANTS.
I edited the script to load parameters for directories and for whisper model from a separate
file that is now shared between RANTS and memos.
And I incorporated whisper installation within my dreams and memories and reflections repository
because ultimately I want to move the memos and RANTS as a separate module, sub-module.
```

## memos.py

*memos.py* transcribes all *.m4a files placed in MEMOS_INPUT_DIR. 
I use it for my Apple Voice Memos transcription as they synchronize automaticaly with my computer,
but there's no reason to try to use it on another directory.
The program can be executed multiple times on the same directory, it will ommit already processed.
To ensure that, it creates a json file *processed.txt* (sorry about the unpure extension :p).
All memos are saved in file under MEMOS_OUTPUT_DIR in single file *memo.md* and separated with markdown sections.
The sections contain original path, ie.:

```MEMOS_OUTPUT_DIR/memo.md
# /Users/zostaw/Library/Application Support/com.apple.voicememos/Recordings/20230204 175104-266B2F99.m4a
I had the most fascinating thought while walking in the evening.
Everything is covered with snow and I walk.
I look at the sky.
It's so beautiful.
It's divided in two.
On the left it's clouded and chaotic.
[...]

# /Users/zostaw/Library/Application Support/com.apple.voicememos/Recordings/20230201 144034-96D59721.m4a
There you are, here I am. See you later, alligator.
[...]
```

# Prerequisites


## Download submodule whisper.cpp:

```bash
git submodule init
git submodule update
```

## Install python virtualenv (at least 3.10.5)

Use your favorite approach to install python venv, for example:
```bash
python -m venv venv
source venv/bin/activate
```

## Download weights, setup a model

Follow the instructions from original repo - https://github.com/ggerganov/whisper.cpp
Or below, for the time being (2023-09-01), this is setup fo Macbook M1:

```bash
cd scripts/whisper.cpp

# Install "base" model
./models/download-ggml-model.sh medium.en

# Quantize a model with Q5_0 method
make quantize
./quantize models/ggml-medium.en.bin models/ggml-medium.en-q5_0.bin q5_0

# (Optional) Prepare for Core ML processing (Apple M1 procesor)
## install python dependencies for ANE
pip install ane_transformers
pip install openai-whisper
pip install coremltools
## install Xcode tools
xcode-select --install
## generate CoreML model
./models/generate-coreml-model.sh medium.en

# Build
## using Makefile
make clean
WHISPER_COREML=1 make -j
```

After whisper.cpp is installed, copy *params.sh.example* to *params.sh* and setup paths, i.e.:
```bash
# whisper installation dir and model path
WHISPER_MAIN="/example/path/rants_and_memos/whisper.cpp/main"
WHISPER_MODEL="/example/path/rants_and_memos/whisper.cpp/models/ggml-medium.en-q5_0.bin"
# define below paths, make sure they exists
RANTS_OUTPUT_DIR="/example/path/rants_and_memos/rants/"
MEMOS_OUTPUT_DIR="/example/path/rants_and_memos/rants/"
TMP_DIR="/example/path/rants_and_memos/tmp/"
# Apple ussualy stores in this path
MEMOS_INPUT_DIR="/Users/your_login/Library/Containers/com.apple.VoiceMemos/Data/Library/Application Support/Recordings"
```

# Usage

See #Prerequisites first.

## rants.sh

Execute following to start voice message, stop with *^C* after finishing:

```
./rants.sh
^C
```

## memos.py

Execute following to process memos defined in MEMOS_INPUT_DIR:

```
python ./memos.py
```

