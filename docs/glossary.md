# Glossary

| Term | Meaning | In this project |
| --- | --- | --- |
| **Agent** | A model used in a loop that can take actions (tool calls) and decides on its own when the task is done. | one `plain-harness` run with a config |
| **Agent loop** | Ask the model, run the tools it requests, append the results, repeat until it answers without tools. | `Agent.Run` in `plain-harness/src/agent.go` |
| **Canary** | A deliberately unusual, easy-to-spot behavior that shows whether an instruction was read and followed. | the +5 minutes of the `date-output` skill |
| **Context (window)** | All text sent to the model in one call, and the maximum amount the model can take. | system prompt + session history + tool definitions |
| **Context compaction** | Shortening an old history (dropping or summarizing) so it fits the context window. | out of scope in `plain-harness`; Lab 2, Lab 9 level C |
| **Context ledger** | The course's drawing of what the model receives in one call: system prompt, tool definitions, messages. | introduced in Lab 1, drawn in Labs 1, 2, 5, 6, 7, 9 and 10 |
| **Conventional Commits** | Commit message format (`feat:`, `fix:`, `docs:`) from which tooling derives version numbers. | `semantic-release` in each repository's workflow |
| **Eval** | A repeatable measurement of agent behavior: fixed tasks, a measurable signal, many runs, conditions compared. | `labs/tools/measure-skill.sh`, Lab 5 |
| **Harness** | The program around a model: prompts, tools, loop, history, errors, limits. | `plain-harness` |
| **Iteration** | One pass through the agent loop: one model call, plus the tools that reply asked for. | counted against `max_iterations` |
| **JSON Schema** | A JSON format for describing the structure of data, used for tool arguments. | built by `scripts-mcp` from the script header |
| **JSON-RPC** | A simple protocol of request objects with `id`, `method`, `params` and matching responses. | the format MCP uses on stdin/stdout |
| **Lethal trifecta** | One agent with private data, untrusted content and a way to communicate externally: the setting in which prompt injection does real damage. | Lab 7 |
| **MCP server** | A program that offers tools (and possibly other things) over MCP. | `scripts-mcp`, `skills-mcp` |
| **MCP** (Model Context Protocol) | An open protocol for clients (harnesses) to discover and call tools in servers. | `scripts-mcp`, `skills-mcp`; client in `plain-harness/src/mcp.go` |
| **Model call** | One request to the model API and its reply. The context ledger shows what one model call contains. | `Provider.Chat` in `plain-harness/src/types.go` |
| **Progressive disclosure** | Show only short descriptions up front and load the full content on demand. | skills: description always, `SKILL.md` on call |
| **Prompt caching** | The provider reuses the unchanged start of a request, so resending a long history costs less and is faster. It still fills the context window. | `cache_control` in `plain-harness/src/anthropic.go`; OpenAI-compatible servers cache on their own; Lab 2 |
| **Prompt injection** | Text in model input (often from a tool result) that tries to override the actual instructions. | Lab 7 |
| **Provider** | A model API family with its own wire format. | `openai_compatible`, `anthropic_compatible` |
| **Ref** | A git tag, branch or commit that pins which version of a source is used. | `ref: v1.0.0` in the configs |
| **Run** | One start of `plain-harness`, from the command line to the exit code. In this harness, one run handles one turn. | `plain-harness "<message>"` |
| **Session** | The saved history of a conversation, resent on the next run. | `--session <name>` → `sessions/<name>.json` |
| **Skill** | A markdown file with instructions for one kind of task, loaded when needed. | `skills/date-output/SKILL.md` |
| **Spec-driven development** | Writing a precise specification first, then implementing (by hand or with AI) and checking against it. | each tool's `spec.md`; Lab 9 |
| **stdio transport** | Running an MCP server as a child process and talking over its stdin and stdout. | all servers in the example config |
| **Streamable HTTP** | The MCP transport for remote servers, usually with OAuth for authentication. | `mcp_servers[].http` in `plain-harness` |
| **Sub-agent** | An agent started by another agent for a subtask, with its own fresh context. Only its final answer goes back. | `sub-agent/`, started by `date-agent.sh` |
| **System prompt** | Instructions sent before the conversation on every model call. | `SOUL.md` + `AGENT.md` |
| **Turn** | One user message and everything the agent does until its final answer: one or more iterations. | one call of `Agent.Run` |
| **Tool** | A capability offered to the model, described by name, description and argument schema. | each script in `scripts`, each skill in `skills` |
| **Tool call** | A structured request in a model reply to run a tool with given arguments. | `ToolCall` in `plain-harness/src/types.go` |
