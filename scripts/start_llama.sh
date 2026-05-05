#!/bin/bash
llama-server \
  -m ~/llm-stack/models/Qwen3.5-9B.Q4_K_M.gguf \
  --alias "qwen3-5-local" \
  --port 8000 \
  --host 0.0.0.0 \
  --n-gpu-layers 99 \
  --ctx-size 32768 \
  --batch-size 2048 \
  --jinja