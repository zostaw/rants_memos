# memos and rants transcription

This project uses whisper.cpp to provide transcription tool for:
- "Voice Memos" (apple products).
- Real-time voice message transcribed into notes.

# TODO

- Write documentation
- incorporate whisper as a submodule...
- change private paths
- remove dependencies -> make it computer independent

# Usage

# prerequisites

Download whisper.cpp, weights, setup a model.

## rants.sh

1. edit script - modify:
- whisper_dir 
- output_dir
- change model path "models/ggml-medium.en-q5_0.bin" to whatever is configured

2. execute following to start voice message, kill with ^C after finishing

```
./rants.sh
```

## memos.py

1. setup python venv (at least 3.10.5)

2. edit memos.py - modify:
- WHISPER_DIR 
- change model path "models/ggml-medium.en-q5_0.bin" to whatever is configured
- SOURCE_DIR 
- OUTPUT_DIR

3. execute
```
python ./memos.py
```
     

