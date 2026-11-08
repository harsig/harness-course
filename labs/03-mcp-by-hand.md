# Lab 3: Speak MCP by hand

| | |
| --- | --- |
| **You will be able to** | run a complete MCP session from the shell, and explain what MCP does and doesn't do |
| **Time** | 45 min |

## Warm-up (from memory)

1. What makes the agent loop stop with an answer?
2. A tool fails with "unknown time zone". What does the harness do with that error?
3. Why does a long session get slower with every turn? (Lab 2)

<details><summary>Answers</summary>

1. A model reply that contains no tool calls.
2. It sends the error text to the model as a tool result marked as an error, and the loop continues.
3. Every call resends the whole history, so each call carries more text than the one before.

</details>

## 1. Build and configure scripts-mcp

```sh
cd $WS/scripts-mcp && ./build.sh
mkdir -p ~/mcp-lab && cd ~/mcp-lab
cat > scripts.yml <<EOF
sources:
  - path: $WS/scripts/date.sh
EOF
```

## 2. A session by hand

Each line below is one JSON-RPC message: an initialization, a tool listing, and two tool calls. The second call asks for a format that doesn't exist.

> **Predict:** Which messages will get an answer? What will the answer to the invalid call (id 4) look like?

```sh
{ printf '%s\n' \
  '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"by-hand","version":"0"}}}' \
  '{"jsonrpc":"2.0","method":"notifications/initialized"}' \
  '{"jsonrpc":"2.0","id":2,"method":"tools/list"}' \
  '{"jsonrpc":"2.0","id":3,"method":"tools/call","params":{"name":"date","arguments":{"timezone":"Asia/Tokyo"}}}' \
  '{"jsonrpc":"2.0","id":4,"method":"tools/call","params":{"name":"date","arguments":{"format":"week"}}}'
  sleep 1; } | $WS/scripts-mcp/bin/scripts-mcp scripts.yml
```

Expected output, shortened:

```text
scripts-mcp: serving 1 scripts                                   ← stderr
{"jsonrpc":"2.0","id":1,"result":{"protocolVersion":"…","serverInfo":{"name":"scripts-mcp",...}}}
{"jsonrpc":"2.0","id":2,"result":{"tools":[{"name":"date","inputSchema":{...}}]}}
{"jsonrpc":"2.0","id":4,"result":{"content":[{"type":"text","text":"invalid arguments: argument \"format\" must be one of: iso, rfc, date, time, unix"}],"isError":true}}
{"jsonrpc":"2.0","id":3,"result":{"content":[{"type":"text","text":"2026-11-09T06:10:48+09:00\n"}]}}
```

The server answers `initialize` with the protocol version it will use. Client and server agree on a version before anything else happens.

## 3. Investigate

1. Compare the `inputSchema` in the `tools/list` answer with the header of `date.sh`. Which header line became which part of the schema?
2. The answer to id 4 may arrive **before** id 3. Why is that allowed? What is the `id` for?
3. The invalid call came back as a `result` with `isError: true`, not as a JSON-RPC `error`. Who is that message written for: the client program or the model?

## The idea

**MCP (Model Context Protocol)** is how a harness finds and calls tools that live in another process. It is JSON-RPC 2.0. Over the stdio transport, that means one JSON object per line on the server's stdin and stdout. For tools, you have just seen almost the whole protocol: `initialize`, `tools/list`, `tools/call`.

Why a protocol and not a plugin API? Because it separates **who runs the loop** from **who provides capabilities**. `scripts-mcp` works unchanged in `plain-harness`, Claude Code, Cursor and any other MCP client.

What MCP does **not** do: it never talks to the model. The harness translates MCP's tool format into the model API's format (`openai.go`, `anthropic.go`). That makes four formats in play: MCP, OpenAI, Anthropic, and the harness's own neutral `Message` type between them.

**Beyond this lab.** MCP can also run over HTTP (*Streamable HTTP*, with OAuth for authentication). That is how remote servers, such as a company's issue tracker, are connected. Besides tools, servers can offer *resources* and *prompts*. `plain-harness` supports HTTP servers but uses tools only.

> **Misconception:** "MCP is how the model talks to tools." The model never sees MCP. It sees tool definitions in its own API format, which the harness builds.

## 4. Modify

1. Remove the `sleep 1`. **Predict** first. What changes, and why?
2. Add `echo debug` near the top of a copy of `date.sh` and serve the copy. **Predict:** does this break the protocol? (Where does a *script's* stdout go, compared with the *server's* stdout?)
3. Do the same for skills-mcp:

   ```sh
   cd $WS/skills-mcp && ./build.sh && cd ~/mcp-lab
   cat > skills.yml <<EOF
   sources:
     - path: $WS/skills/date-output
   EOF
   ```

   Send `initialize`, `notifications/initialized`, `tools/list` and a `tools/call` for `date-output` with `"arguments":{}`. What does the call return? What do the `annotations` in the listing say, and what could a client do with `readOnlyHint`?

## 5. Make

Register `scripts-mcp` in an MCP client you already use (each server's README shows how to do it for Claude Code and for JSON configs). Ask it for the time in Tokyo. What did you have to change so the same binary works in a different harness?

## Check

1. Draw the processes and pipes for step 2: who writes to which stream, and who reads it?
2. Explain why an MCP server over stdio must never print debug output to stdout.

## In your daily work

Adding an MCP server to your AI tool gives the model new abilities, *and* new risks: everything the server returns becomes model input (Lab 7). When you write your own server, log to stderr only. A stray `print` to stdout breaks the connection, and this is a common bug in home-made servers.
