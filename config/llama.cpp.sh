#!/bin/sh
set -e

MODEL_PATH="/models/Qwen3.5-9B.Q4_K_M.gguf"

/app/llama-server \
    -m ${MODEL_PATH} \
    --alias "qwen3-5-local" \
    --port 8000 \
    --host 0.0.0.0 \
    --jinja \
    --kv-unified \
    --cache-type-k q8_0 \
    --cache-type-v q8_0 \
    --batch-size 2048 \
    --ubatch-size 512 \
    --ctx-size 32768