from pathlib import Path
import subprocess
import os
import re
import json


def m4a_to_wav(m4a_file, out_dir):
    # transposes: m4a memos file into wav 16kHz
    # saves them in out_dir
    # returns: wav_file

    wav_filename = "memo.wav"
    wav_file = out_dir / wav_filename
    CMD = [
        "ffmpeg",
        "-y",
        "-i",
        m4a_file,
        "-vn",
        "-ar",
        "16000",
        "-ac",
        "1",
        wav_file,
    ]
    with open(wav_file, "w") as out_file:
        out = subprocess.run(CMD, capture_output=True, text=True)
        out_file.write(out.stdout)

    return wav_file


def whisper_process(m4a_file, output_dir, WHISPER_DIR):
    # transposes wav_filename from tmp_dir
    # saves into a transposed_filename in output_dir
    # returns: transposed_filename [.txt]

    os.chdir(WHISPER_DIR)
    TMP_DIR = WHISPER_DIR / "tmp"

    if not TMP_DIR.exists():
        os.makedirs(TMP_DIR)

    # preprocess - whisper requires wav 16kHz
    wav_file = m4a_to_wav(m4a_file, TMP_DIR)

    # define paths
    output_filename = wav_file.with_suffix(".md").name
    output_file = OUTPUT_DIR / output_filename

    with open(output_file, "a") as file:
        # make section with metadata
        file.write(f"# MEMO {m4a_file.stem}\n")
        out = subprocess.run(
            ["./main", "-m", "models/ggml-medium.en-q5_0.bin", "-f", wav_file],
            capture_output=True,
            text=True,
        )
        output = re.sub(r"\[.*-->.*\]   ", "", out.stdout)
        file.write(output)

    return m4a_file.name


def get_source_list(source_dir):
    if not source_dir.exists():
        raise Exception(
            "Source dir cannot be accessed. Check if it exists and if you have right privileges."
        )
    source_list = []
    source_dir_contents = Path(source_dir)
    for entry in sorted(source_dir_contents.iterdir()):
        if entry.match("*.m4a"):
            source_list.append(entry.name)
    return source_list


def load_processed_list(processed_file):
    if not processed_file.exists():
        return []
    with open(processed_file, "r") as file:
        processed_list = json.load(file)
    return processed_list


def save_processed_list(processed_list, processed_list_file):
    with open(processed_list_file, "w") as file:
        json.dump(processed_list, file)


if __name__ == "__main__":
    # source dir - dir containing m4a files to transcribe
    # output_dit - transcriptions destination
    WHISPER_DIR = Path("<whisper.cpp path>")
    SOURCE_DIR = Path(
        "/Users/<your login name>/Library/Application Support/com.apple.voicememos/Recordings"
    )
    OUTPUT_DIR = Path("<your output dir>")

    source_list = get_source_list(SOURCE_DIR)
    processed_list_file = SOURCE_DIR / "processed.txt"
    processed_list = load_processed_list(processed_list_file)

    for m4a_file in source_list:
        if locals()["processed_list"] and m4a_file in processed_list:
            continue
        processed_filename = whisper_process(
            SOURCE_DIR / m4a_file, OUTPUT_DIR, WHISPER_DIR
        )
        processed_list.append(str(processed_filename))

    save_processed_list(processed_list, processed_list_file)
