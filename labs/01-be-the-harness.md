# Lab 1: Be the harness

| | |
| --- | --- |
| **You will be able to** | run one agent turn by hand, and explain why a model "remembers" only what it is sent |
| **Time** | 60 min |
| **You need** | `curl`, `jq`, the model server from Lab 0; work in a scratch folder |

## Warm-up (from memory)

1. Where does the harness write its own log lines: stdout or stderr?
2. Where is a conversation stored when you use `--session demo`?
3. Without `--session`, what does a second run know about the first?

<details><summary>Answers</summary>

1. stderr, prefixed `plain-harness: `. stdout carries only the answer.
2. `sessions/demo.json`, in the folder set by `session_dir`.
3. Nothing at all.

</details>

## 1. Call one: offer a tool

Create `call1.json`. Set `"model"` to the name your server lists under `curl -s http://localhost:8080/v1/models`. It holds a system prompt, the user's message and one tool definition, the same one that `scripts-mcp` builds from the header of `date.sh`:

```json
{
  "model": "Qwen3.8-27B-S",
  "messages": [
    {"role": "system", "content": "You have no clock. Use tools for anything about the current time."},
    {"role": "user", "content": "What time is it in Tokyo?"}
  ],
  "tools": [{
    "type": "function",
    "function": {
      "name": "date",
      "description": "Show the current date and time, optionally in another time zone or format.",
      "parameters": {
        "type": "object", "additionalProperties": false,
        "properties": {
          "timezone": {"type": "string", "description": "IANA time zone, e.g. Europe/Berlin or UTC"},
          "format": {"type": "string", "enum": ["iso", "rfc", "date", "time", "unix"], "default": "iso"}
        }
      }
    }
  }]
}
```

> **Predict:** Will the reply contain the time? If not, what will it contain?

```sh
curl -s http://localhost:8080/v1/chat/completions -H 'Content-Type: application/json' \
  -d @call1.json | jq '.choices[0].message'
```

(Hosted OpenAI-compatible API: use your provider's URL and add `-H "Authorization: Bearer $YOUR_API_KEY"`. The Anthropic API uses a different request format; see the note in Lab 0.)

You get an assistant message with **no answer** and a `tool_calls` entry, something like `{"name": "date", "arguments": "{\"timezone\":\"Asia/Tokyo\"}"}`. Look closely: `arguments` is a *string* that contains JSON. The model wrote it as text, so nothing guarantees that it is valid.

## 2. Run the tool yourself

You are the harness now. The model can't run anything, so you do it. Run the script the way `scripts-mcp` would, with the arguments as environment variables:

```sh
PARAM_TIMEZONE=Asia/Tokyo PARAM_FORMAT=iso $WS/scripts/date.sh
```

## 3. Call two: send the result back

Copy `call1.json` to `call2.json` and add two messages at the end of `messages`: first the assistant message **exactly as you received it**, then the tool result:

```json
    {"role": "assistant", "content": null, "tool_calls": [ <the tool_calls array from step 1> ]},
    {"role": "tool", "tool_call_id": "<the id from that tool call>", "content": "<output of date.sh>"}
```

The `tool_call_id` ties the result to its request. One reply can contain several tool calls, and the model must be able to tell which result belongs to which call.

Send `call2.json`. Now the model answers in text. The reply has no tool calls, so a harness would stop here.

**Draw the ledger** (see [How the labs work](README.md#the-context-ledger)) for the second call: system, tools, and the four messages.

## The idea

**The model is a stateless function.** A model API takes text and returns text, roughly:

```text
reply = model(system_prompt, messages[], tool_definitions[])
```

Nothing is kept between calls. In the second call the model "remembered" your question only because **you sent it again**. The model has no clock, no files and can't run commands. All it can do is produce text, and part of that text may be a structured request to call a tool.

**A harness is everything around the model.** The harness is the program that turns this function into an agent. It builds the system prompt, tells the model which tools exist, runs the tools the model asks for, keeps the history, handles errors and limits, and decides what the tools may do. You just did all of that by hand. In `plain-harness`, the whole interface to a model is one method (`src/types.go`):

```go
type Provider interface {
    Chat(ctx context.Context, system string, msgs []Message, tools []ToolDef, onText func(string)) (Message, error)
}
```

Together, your two calls were one **turn**: one user message, handled until the final answer. (The [glossary](../docs/glossary.md) keeps *model call*, *iteration*, *turn* and *run* apart.)

> **Misconception:** "The model ran the `date` command." It didn't. It asked for it. *You* ran it, and in a real agent the harness does.

## 4. Investigate

Open `$WS/plain-harness/src/openai.go` and find the functions `messages` and `tools`. They build the JSON you just wrote by hand. Then open `anthropic.go`: it does the same job for a different wire format.

## 5. Modify

For each change, **predict first**, then send it:

1. Remove the `tools` array from `call1.json`. What does the model answer, and is the answer right?
2. In `call2.json`, replace the tool result with a wrong time (`2020-01-01T03:00:00+09:00`). What does the model say?
3. Send `call2.json` with a wrong `tool_call_id`. What happens? (llama-server accepts it silently; the OpenAI and Anthropic APIs reject it.) Imagine a reply with two tool calls: why would a strict API insist that the ids match, and what could go wrong with a server that doesn't check?

## Check

1. Where did the facts in the final answer come from? Name each source.
2. List every step you did by hand that `Agent.Run` in `agent.go` would do for you.
3. Explain to someone who has never seen an API why a chatbot seems to remember your earlier messages. Use at most three sentences.

## In your daily work

"The AI forgot what I said" means the information is no longer in what gets sent: it was cut, summarized, or never included. "The AI knows my project" means that some program read your files and put them into the prompt. Ask *which* program did that, and what it chose to include. Two tools that use the *same model* can behave very differently because their harnesses differ. When you compare AI coding tools, you are mostly comparing harnesses.
