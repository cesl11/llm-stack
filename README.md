# LLM Stack

A self-hosted AI inference server enabling consumption of local AI models through OpenAI-compatible APIs, Claude Code, Codex, or any CLI harness.

## Overview

This project provides a complete stack for running local large language models (LLMs) with an OpenAI-compatible API interface. It leverages [LiteLLM](https://docs.litellm.ai/) as a unified proxy layer and [llama.cpp](https://github.com/ggerganov/llama.cpp) for efficient local model inference.

## Architecture

- **LiteLLM**: Acts as a unified API gateway, exposing an OpenAI-compatible REST API (`http://localhost:4000`). It proxies requests to the local model server while providing features like logging, authentication, and model management.
- **llama.cpp Server**: Runs the local Qwen3.5-9B model using the GGUF quantized format. It exposes a raw API at `http://localhost:8000`.
- **PostgreSQL**: Used by LiteLLM for storing model configurations, prompts, and spend logs.

## Quick Start

### Prerequisites

- [Docker](https://www.docker.com/) and Docker Compose
- ~6GB free RAM (for Qwen3.5-9B Q4 quantization)
- ~10GB free disk space

### Startup

1. Clone the repository and navigate to the project directory:

   ```bash
   cd llm-stack
   ```

2. Start the stack:

   ```bash
   docker compose up -d
   ```

3. Verify services are running:

   ```bash
   docker compose ps
   ```

   Expected output:
   ```
   NAME       IMAGE                    STATUS   PORTS
   llm-stack-litellm-1   ghcr.io/berriai/litellm:v1.81.14-stable   Up      0.0.0.0:4000->4000/tcp
   llm-stack-postgres-1  postgres:16                              Up      0.0.0.0:5432->5432/tcp
   ```

## Usage

### API Endpoints

The LiteLLM proxy exposes an OpenAI-compatible API:

| Endpoint | Description |
|----------|-------------|
| `POST /v1/chat/completions` | Chat completions (same as OpenAI) |
| `GET /v1/models` | List available models |
| `POST /v1/responses` | Anthropic-style responses API |

Base URL: `http://localhost:4000`

### Making Requests

Using curl:

```bash
curl http://localhost:4000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer soo-seecret" \
  -d '{
    "model": "claude-qwen3-5-local",
    "messages": [{"role": "user", "content": "Hello! How are you?"}]
  }'
```

Using OpenAI Python SDK:

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:4000",
    api_key="soo-seecret"
)

response = client.chat.completions.create(
    model="claude-qwen3-5-local",
    messages=[{"role": "user", "content": "Hello!"}]
)

print(response.choices[0].message.content)
```

Using Anthropic SDK (Responses API):

```python
import anthropic

client = anthropic.Anthropic(
    base_url="http://localhost:4000/v1",
    api_key="soo-seecret"
)

response = client.messages.create(
    model="claude-qwen3-5-local",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello!"}]
)

print(response.content[0].text)
```

## Configuration

### LiteLLM

Edit `config/litellm.yaml` to modify model settings, authentication, or proxy behavior.

Key settings:
- `model_list`: Defines available models and their endpoints
- `litellm_settings.master_key`: API authentication key
- `no_auth`: Disable authentication (for development)

### llama.cpp Server

Edit `config/llama.cpp.sh` to modify model parameters:

| Parameter | Description |
|-----------|-------------|
| `--ctx-size` | Context window size (default: 32768) |
| `--batch-size` | Prompt processing batch size |
| `--ubatch-size` | Prompt processing maximum-unrolled batch size |
| `--cache-type-k` | KV cache quantization type for keys |
| `--cache-type-v` | KV cache quantization type for values |

### Model

The default model is Qwen3.5-9B (Q4_K_M quantization). To use a different model:

1. Add the GGUF file to the `models/` directory
2. Update `config/llama.cpp.sh` with the new model path
3. Update the model alias in `config/litellm.yaml`

## Environment Variables

Create a `.env` file to override default settings:

```bash
# LiteLLM
LITELLM_MASTER_KEY=soo-seecret

# Database (optional override)
DATABASE_URL=postgres://litellm:litellm@postgres:5432/litellm
```

## Development

### Logs

View LiteLLM logs:

```bash
docker compose logs -f litellm
```

View llama.cpp logs (if running separately):

```bash
docker logs -f llm-llama
```

### Stopping the Stack

```bash
docker compose down
```

To also remove volumes:

```bash
docker compose down -v
```

## License

MIT