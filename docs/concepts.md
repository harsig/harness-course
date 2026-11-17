# The mental model on one page

Use this page to **review**, not to learn for the first time: each idea is explained in its lab, after you have seen it happen. A good way to review is to cover the right column and explain each idea out loud before you read it.

## Twelve ideas

| # | Idea | In one sentence | Lab |
| --- | --- | --- | --- |
| 1 | The model is a stateless function | `reply = model(system, messages, tools)`: nothing is kept between calls, and the client resends everything. | 1 |
| 2 | A harness is everything around the model | Prompts, tools, the loop, history, errors and limits; same model + different harness = different behavior. | 1 |
| 3 | The agent loop | Ask, run the requested tools, append the results, ask again; stop when a reply has no tool calls. | 2 |
| 4 | Failures are data | A tool error becomes a message the model can react to; only temporary network errors are retried. | 2 |
| 5 | Sessions are the history on disk | The saved list of messages that is resent on every call; it only grows. | 2 |
| 6 | MCP is a plug standard | JSON-RPC between a harness and a tool server; it never talks to the model. | 3 |
| 7 | A tool is a name, a description and a schema | The model sees only that text, never the code; the description is a prompt. | 4 |
| 8 | The system prompt is configuration | Files sent before the conversation on every call; treat them like code. | 5 |
| 9 | Skills load knowledge on demand | The description is always in the context, the body only when loaded; whether it is loaded is the model's choice. | 5 |
| 10 | Sub-agents isolate context | A fresh run with its own prompt and tools; only its final text comes back. | 6 |
| 11 | Boundaries vs. rules | Code enforces boundaries; a prompt rule only lowers the odds; tool output is untrusted. | 7 |
| 12 | Pin everything, spec first | The same versions give the same system; the quality of AI-written code follows the quality of the spec. | 8, 9 |

## The one picture: the context ledger

```text
system   : SOUL.md + AGENT.md                              ← idea 8
tools    : name + description + schema of each tool         ← ideas 7, 9
messages : user → assistant(tool_call) → tool(result) → …   ← ideas 3, 5
```

The model knows exactly what is in this box, and nothing else.

## Common misconceptions

| Belief | What is actually true | Shown in |
| --- | --- | --- |
| "The model remembers our conversation." | The client resends it on every call. | Lab 1 |
| "The model ran the command." | It asked for it; the harness ran it. | Lab 1 |
| "A failing tool crashes the agent." | The error becomes the next message. | Lab 2 |
| "Prompt caching makes long sessions free." | It makes resending cheaper, but the context still fills up. | Lab 2 |
| "MCP connects the model to tools." | MCP connects the *harness* to tools. | Lab 3 |
| "It picked the wrong tool because it's dumb." | It picked the best match for the text it could see. | Lab 4 |
| "A skill that is loaded is followed." | Loaded and followed are separate steps, and both can fail. | Lab 5 |
| "The sub-agent knows the context." | It sees one string. | Lab 6 |
| "A good system prompt stops prompt injection." | It lowers the odds; only enforced limits are boundaries. | Lab 7 |
| "I didn't change anything, so nothing changed." | A branch ref, an unpinned model or a `latest` image can change under you. | Lab 8 |
| "The tests pass, so the AI's code is right." | Tests the AI wrote check what the AI understood, not what the spec says. | Lab 9 |

## You observe → mechanism

| You observe in an AI tool | Mechanism | Idea |
| --- | --- | --- |
| it "remembers" or "forgets" | history resent by the client | 1, 5 |
| same model, different tool, different quality | the harness | 2 |
| it loops, or gets slow on long tasks | the agent loop, a growing history | 3, 5 |
| it fixes its own mistakes | errors returned as data | 4 |
| you can plug in new capabilities | MCP | 6 |
| it picks the wrong tool | tool name, description, schema | 7 |
| project rules files change its behavior | the system prompt | 8 |
| it follows a guideline only sometimes | skills, progressive disclosure | 9 |
| "launching sub-agent…" | context isolation | 10 |
| it did something you didn't intend | boundaries, prompt injection | 11 |
| it behaves differently than last month | something unpinned changed | 12 |
| its code doesn't match what you wanted | the spec | 12 |
