# Lab 0: Build, run, and draw your first guess

| | |
| --- | --- |
| **You will be able to** | build and run a complete agent, and say where its answer, its logs and its memory are |
| **Time** | 45 min (plus model setup) |

## Before you start: draw your current model (10 min, no notes, no AI)

On paper, draw how you think an AI coding assistant answers **"What time is it in Tokyo?"** Use boxes for the parts and arrows for the messages. Where does the time come from? Who decides what to do next?

There is no wrong drawing. Keep it. You will draw it again in Lab 6 and compare the two. The difference between them shows what you learned.

## 1. A model server

The configs expect an OpenAI-compatible API at `http://localhost:8080/v1`. Pick one:

**Local (free and private, recommended).** Install [llama.cpp](https://github.com/ggml-org/llama.cpp) and start a model that supports tool calling:

```sh
llama-server -m <model>.gguf --jinja --port 8080
```

`--jinja` turns on the model's chat template, which tool calling needs. Larger models use tools more reliably. With models under about 8B parameters, expect failures: they are interesting to watch, but frustrating as a first experience.

**Local with Docker (Linux with a GPU).** [llama.cpp-compose](https://github.com/harsig/llama.cpp-compose) starts `llama-server` with the model the configs ask for (`Qwen3.8-27B-S`) and a pinned llama.cpp build, so your results are comparable with everyone else's. It needs about 16 GB of VRAM. It doesn't work on macOS, because Docker there can't use the Apple Silicon GPU; use the command above instead.

```sh
git clone https://github.com/harsig/llama.cpp-compose
cd llama.cpp-compose
docker compose --profile amd up -d      # or: --profile nvidia
curl http://localhost:8080/v1/models    # the first start downloads the model, which takes a while
```

**Hosted API.** Change the `model:` block in **both** `plain-harness-config/main-agent/plain-harness.yml` and `sub-agent/plain-harness.yml`, for example:

```yaml
model:
  provider: anthropic_compatible
  endpoint: https://api.anthropic.com     # no /v1 for anthropic_compatible
  name: "claude-haiku-5-5"
  api_key: "${ANTHROPIC_API_KEY}"
  timeout_seconds: 600
```

`${ANTHROPIC_API_KEY}` is read from your environment, so the key is never written into the file. If the variable isn't set, the harness refuses to start.

## 2. Build and set up

```sh
cd $WS
(cd plain-harness && ./build.sh)
(cd skills-mcp && ./build.sh)
cd plain-harness-config
../plain-harness/bin/plain-harness --config main-agent/plain-harness.yml --setup
find . -path '*/repos/*' -maxdepth 4 -type d     # what did setup create?
```

## 3. Run one agent

Start with the smaller of the two agents, the **sub-agent**. It is a complete agent on its own.

> **Predict** (write it in your log, with confidence 1–5): Will the answer match the real time in Tokyo?

```sh
cd $WS/plain-harness-config/sub-agent
../../plain-harness/bin/plain-harness "What time is it in Tokyo?"
TZ=Asia/Tokyo date
```

The answer is **5 minutes ahead**. Don't look up why yet. Explaining this exactly is what the next six labs build up to.

## 4. Where to look

| What | Where |
| --- | --- |
| the answer | stdout |
| what the harness did (`tool call: …`, retries, errors) | stderr, lines start with `plain-harness: ` |
| the full conversation, including tool calls and results | `sessions/<name>.json` (only with `--session`) |
| what the model server received | the llama-server log, or your provider's console |

Separate the two output streams:

```sh
../../plain-harness/bin/plain-harness "What day is it?" 2>harness.log
cat harness.log
```

## 5. A preview: two agents

The **main agent** is the one a user talks to. It hands date questions to the sub-agent. Run it with a session, so it keeps the conversation:

```sh
cd $WS/plain-harness-config/main-agent
../../plain-harness/bin/plain-harness --session lab0 "What time is it in Tokyo?"
../../plain-harness/bin/plain-harness --session lab0 --stream "And in New York?"
```

You don't need to understand this yet. Just note one thing: the second question says "And in New York?", which only makes sense with the first question in mind.

## Check

1. Which lines in `harness.log` show that a tool was called? What were the tools called?
2. Open `main-agent/sessions/lab0.json`. What exact question did the main agent pass on the second time? Did it say "New York" or `America/New_York`? Did it mention "time"?
3. Run the main agent twice **without** `--session`. What does the second run know about the first?
4. Look at your drawing from the start. Mark one thing on it that you are now unsure about.
