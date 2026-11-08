# Lab 4: Write a tool and your own agent

| | |
| --- | --- |
| **You will be able to** | write a tool that a model uses correctly, build an agent from the parts, and measure how much a description changes its behavior |
| **Time** | 90 min |

## Warm-up (from memory)

1. Name the three MCP methods that a tool session uses.
2. Why must an MCP server over stdio log to stderr?
3. In Lab 1, what did the model get when you offered it the `date` tool? List the parts.

<details><summary>Answers</summary>

1. `initialize`, `tools/list`, `tools/call`.
2. Because stdout carries the protocol. Any other output there corrupts it.
3. A name, a description and a JSON schema for the arguments. Not the code.

</details>

## 1. Worked example: how a script becomes a tool

Read this header from `scripts/date.sh`, and next to it the schema that `scripts-mcp` builds from it. Each comment says what a line becomes:

```bash
# ---
# name: date                                   → tool name the model sees
# description: Show the current date and time, optionally in another time zone or format.
#                                              → the ONLY text the model reads to decide whether to use it
# parameters:
#   timezone:
#     type: string                             → "type": "string"
#     description: IANA time zone, e.g. Europe/Berlin or UTC (default is the local time zone)
#   format:
#     type: string
#     description: Output format
#     enum: [iso, rfc, date, time, unix]       → the model can't pick other values; the server rejects them
#     default: iso
# ---
```

```json
{"type": "object", "additionalProperties": false,
 "properties": {
   "format":   {"type": "string", "enum": ["iso","rfc","date","time","unix"], "default": "iso", "description": "Output format"},
   "timezone": {"type": "string", "description": "IANA time zone, e.g. Europe/Berlin or UTC (default is the local time zone)"}}}
```

The arguments arrive as `PARAM_TIMEZONE` and `PARAM_FORMAT` environment variables. Whatever the script prints to stdout is the tool result.

## 2. Your agent

Create a folder outside the other repositories:

```text
~/my-agent/
  plain-harness.yml
  scripts-mcp.yml
  prompts/AGENT.md
  scripts/
```

`plain-harness.yml` (copy the model block from your Lab 0 setup):

```yaml
max_iterations: 15

model:
  provider: openai_compatible
  endpoint: http://localhost:8080/v1
  name: "model-name"

system_prompt_files:
  - ./prompts/AGENT.md

mcp_servers:
  - name: "tools"
    stdio:
      command: /absolute/path/to/scripts-mcp/bin/scripts-mcp
      args: ["./scripts-mcp.yml"]
```

`scripts-mcp.yml`:

```yaml
sources:
  - path: ./scripts
    files: [repo_log.sh]
```

Write a short `prompts/AGENT.md` yourself, with three parts: role, tools, output format.

## 3. Complete the tool

Here is `scripts/repo_log.sh` with gaps. Fill them in: the parameter list, and the check for a missing repository. Use the `git_log` example in the `scripts-mcp` README as a reference.

```bash
#!/usr/bin/env bash
# ---
# name: repo_log
# description: Shows commits.
# parameters:
#   repo:
#     type: ___
#     required: ___
#   count:
#     type: ___
#     default: ___
#   author:
#     type: ___
# ---
set -euo pipefail

if ___ ; then                       # not a git repository?
  echo "___" >&2                    # a message the MODEL will read
  exit 2
fi

args=(-n "${PARAM_COUNT:-5}" --format='%h %an %ad %s' --date=short)
[[ -n "${PARAM_AUTHOR:-}" ]] && args+=(--author="$PARAM_AUTHOR")
git -C "$PARAM_REPO" log "${args[@]}"
```

`chmod +x` it, then test it **without a model**, the way `scripts-mcp` would run it:

```sh
PARAM_REPO=$WS/plain-harness PARAM_COUNT=3 ./scripts/repo_log.sh
PARAM_REPO=/tmp ./scripts/repo_log.sh; echo "exit $?"
```

Then with the agent:

```sh
cd ~/my-agent
/path/to/plain-harness/bin/plain-harness "What were the last three changes in $WS/plain-harness?"
```

## 4. Experiment: the description

Write five questions that should use the tool and three that shouldn't (e.g. "What is git?"). Run each question with each description below. Every harness run starts a fresh `scripts-mcp`, so a changed description takes effect on the next run.

| Variant | `description:` |
| --- | --- |
| A | *(empty)* |
| B | `Shows commits.` |
| C | `Show the most recent commits of a local git repository, newest first. Use it to answer questions about what changed in a repository, by whom and when. repo must be an absolute path.` |

> **Predict** for each variant: in how many of the 8 questions will the tool be used correctly?

For each run, record: was the tool called? Were the arguments right? Was the answer right? Run the whole set at least twice.

## 5. Experiment: schema constraints

Add a `format` parameter, first as a free `string` with the description "oneline, short or full", then as `enum: [oneline, short, full]`. Ask for "a detailed log".

> **Predict:** Which version produces invalid calls? What will the model do with the error?

## The idea

**To the model, a tool is three things: a name, a description and a schema.** It never sees the code. That has consequences:

- **The description is a prompt.** The model picks tools by reading their descriptions. Compare the plain `date` description with `date_agent` in `plain-harness-config/main-agent/scripts/date-agent.sh`, which says "ALWAYS use this tool whenever…". That description is written to change behavior, not just to document.
- **The schema is a contract, but the model can break it.** Models send wrong types, unknown fields or broken JSON. `scripts-mcp` checks every call *before* it starts the script and returns a readable error. Constraints like `enum` turn a vague instruction into a check that always runs.
- **The result is text, too.** Whatever the tool prints goes into the model's context. It is cut at `max_output_bytes`, because a tool that prints a megabyte would fill the context window.
- **Names are namespaced** as `<server>__<tool>` (e.g. `tools__repo_log`), so two servers can both offer a tool called `search`.

> **Misconception:** "The model picked the wrong tool because it's dumb." Usually it picked the best match for what it could read: a name, a description and a schema.

## Check

1. Show your results table from step 4. Which differences are larger than the differences between repeated runs of the same variant?
2. Why are arguments passed as `PARAM_*` environment variables and not as command-line arguments? Give a `repo` value that would be dangerous if the script built a shell command line from it.
3. Write three rules for tool descriptions, based on **your measurements**. Then compare them with a published tool-design guide (for example Anthropic's "Writing effective tools for agents"). Which rule did you find that the guide doesn't mention, or the other way round?

## In your daily work

When an agent picks the wrong tool or calls it badly, look at the description and the schema first. When you write tools, MCP servers or rules files for your own projects, write for a reader who sees nothing but that text. And make error messages say what to do next: "repo must be an absolute path" helps a model much more than "invalid input".
