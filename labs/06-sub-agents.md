# Lab 6: Sub-agent context

| | |
| --- | --- |
| **You will be able to** | trace one question through two agents, say exactly what each one knows, and judge when a sub-agent is a good design |
| **Time** | 60 min |

## Warm-up (from memory)

1. What is *progressive disclosure*, and what does it cost? (Lab 5)
2. With 10 runs per condition, is 7/10 vs. 4/10 a clear difference? (Lab 5)
3. What is saved in a session file, and what happens to it when a run fails? (Lab 2)

<details><summary>Answers</summary>

1. Only the descriptions are always in the context; the full text is loaded when needed. The cost: whether it gets loaded depends on the model's judgment.
2. No. That size of difference shows up often by chance alone.
3. The full message list, tool calls and results included. It is saved even when the run fails.

</details>

## 1. Predict

The main agent's `date_agent` tool starts the sub-agent. When the user asks a follow-up, "And in Berlin?":

> **Predict:** What exact text will the sub-agent receive? Will the skill's text ("add 5 minutes") end up in the main agent's session file?

## 2. Run: follow-up questions

```sh
cd $WS/plain-harness-config/main-agent
H=../../plain-harness/bin/plain-harness
$H --session lab6 "What time is it in Tokyo?"
$H --session lab6 "And in Berlin?"
$H --session lab6 "How many hours apart are they?"
jq -r '.messages[] | select(.tool_calls) | .tool_calls[].args' sessions/lab6.json
```

Can each question passed on be understood **on its own**, without the conversation? Search the session file for "5 minutes". Check your predictions.

## 3. Investigate

Read `main-agent/scripts/date-agent.sh` (about 30 lines). Then follow the run-time diagrams in [architecture.md](../docs/architecture.md#3-run-time-two-agents-four-servers-one-question) step by step, and count the model calls for one question.

## The idea

**A sub-agent is a separate agent run whose final text becomes one tool result.** Here it is not even a harness feature: `date-agent.sh` is a script, offered as a tool, that starts a second `plain-harness`. The sub-agent:

- starts with an **empty history**,
- has **different tools** (`date`, `date-output`) that the main agent never sees,
- has its own system prompt,
- returns **only its final text**. Its tool calls, the skill text and any dead ends stay out of the main agent's context.

| Benefit | Cost |
| --- | --- |
| the main context stays small and focused | more model calls (5 instead of about 3 for one question) |
| each agent has a short prompt and few tools, so it chooses better | the sub-agent can't ask back, so the main agent must write a question that stands on its own |
| a specialist can use another model or other settings | errors are harder to trace across two logs |

Rule 2 in the main agent's `AGENT.md`, "Write self-contained questions", exists because of the second cost.

> **Misconception:** "The sub-agent can see our conversation." It sees one string: the `question` argument.

## 4. Modify: remove the rule

In `main-agent/prompts/AGENT.md`, delete rule 2. Use a new session (`lab6b`) and repeat step 2 a few times.

> **Predict:** Which follow-up will go wrong, and how?

Compare the questions passed on. The effect may be small with a strong model and large with a weak one.

## 5. Modify: remove the delegation

Restore `AGENT.md`. In a copy of `main-agent/plain-harness.yml`, delete the whole `mcp_servers` block:

```sh
cp plain-harness.yml no-tools.yml   # then edit no-tools.yml
$H --config no-tools.yml "What time is it in Tokyo?"
```

> **Predict:** Will it admit that it can't know, or make up a time?

Which lines in `SOUL.md` and `AGENT.md` push it toward honesty? Delete `no-tools.yml` afterwards.

## 6. Count the cost

Ask the Tokyo question once through the main agent and once to the sub-agent directly. From the llama-server log (or your provider's usage page), count the model calls and, if available, the prompt tokens for each.

## Check

1. Draw **two ledgers**, one per agent, at the moment the sub-agent writes its final answer. Which tool results are in which ledger?
2. Name one task for which a sub-agent is a good design and one for which it is a bad design. Justify each with the table above.
3. `date-agent.sh` is about 30 lines of bash. List what a built-in sub-agent feature might add (parallel runs, shared files, limits, progress display) and what that would cost in complexity.
4. **Redraw your Lab 0 picture** from memory, then put both side by side. Write down three things you got wrong or left out back then. This is the most important answer in your log so far.

## In your daily work

When your coding agent says "launching a sub-agent to explore the codebase", this is what happens: a fresh context does the messy search, and only a summary comes back. Sub-agents are good at *search and summarize*, and weak at tasks that need the whole conversation. When you delegate, to an agent or a person, put everything needed into the request.
