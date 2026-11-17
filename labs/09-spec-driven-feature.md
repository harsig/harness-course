# Lab 9: Extend the harness with an AI assistant

| | |
| --- | --- |
| **You will be able to** | build a real feature with an AI coding assistant, spec first, and defend every line of the result |
| **Time** | 2–4 h |

You may (and should) use an AI coding assistant for this lab. You are graded on the spec, the tests, your review and your reflection, not on typing the code yourself.

## Warm-up (from memory)

1. Describe the agent loop, step by step. (Lab 2)
2. Why does a sub-agent need self-contained questions? (Lab 6)
3. Why must a run never fetch from git? (Lab 8)

<details><summary>Answers</summary>

1. Ask the model → if it wants tools, run them → append the results → ask again → stop when the reply has no tool calls (or the cap is reached).
2. It starts with an empty history, so it sees only the question string.
3. So the same config always runs the same, reviewed versions.

</details>

## The idea: spec first, AI second

Each tool repository has a `spec.md`: features, config schema, error behavior, code layout, and an explicit **out of scope** list. These specs read like instructions to an implementer, and they work just as well as instructions to an AI.

The quality of AI-generated code follows the quality of the spec. "Add sessions" gets you something. "One JSON file per session, atomic saves, an exclusive lock, saved even when the run fails" gets you what you need. The *out of scope* list matters as much as the features: it stops you, and the AI, from quietly adding hot reload or glob patterns "while we're at it".

You are still responsible for the result. You must be able to read, test and explain every line you commit.

> **Misconception:** "The tests pass, so the AI's code is right." Tests that the AI wrote check what the AI understood, not what your spec says.

## Choose a feature

| Level | Feature | The hard part |
| --- | --- | --- |
| A | **Timing log:** log how long each model call and each tool call takes, to stderr. | where to measure; leaving stdout unchanged; testing log output |
| B | **Tool filter:** an optional `tools:` list per MCP server (`allow: [date]`), so only some of a server's tools are offered to the model. | config validation (an unknown tool name in `allow` is a startup error); filtering by the name before or after adding the `<server>__` prefix |
| C | **History limit:** an optional `max_history_messages`. Before each model call, drop the oldest messages so the history fits. | an assistant message with tool calls must never be split from its tool results; the first message must stay a user message. The OpenAI and Anthropic APIs reject a broken history, but llama-server accepts it silently, so with a local model only your tests will catch the bug |

Level C touches a design decision the spec explicitly leaves out ("context compaction"). Part of the task is arguing in the spec why your limited version is acceptable.

## Procedure

1. **Branch.** `git switch -c feat/<name>` in `plain-harness`. Read `spec.md` in full.
2. **Spec first, by yourself, without AI.** Edit `spec.md`: the feature bullet, the config schema, error behavior, and what stays out of scope. Commit: `docs: specify <feature>`.
3. **Predict.** Write down two places where you expect the AI to get it wrong.
4. **Implement with the AI.** Give it the spec diff and the relevant files. Ask for code plus table-driven tests in the existing style. Save your prompts in your lab log.
5. **Review** every changed line:
   - Does the code do what the spec says, *and nothing more*?
   - Is there a test for each rule in the spec, including the error cases?
   - Does it follow the spec's code layout section (files, "no interfaces beyond `Provider`")?
   - Can you explain each line to someone else, without notes?
   - Run `go vet ./... && go test ./...`, then the example config from Lab 0.
6. **Break your own feature.** Write one test case that you expect the AI's code to fail. Did it fail?
7. **Commit** with a Conventional Commit message (`feat: …`). Read `.releaserc.json` and `.github/workflows/release.yml`: what version number would this commit produce on `main`?

## Deliverables

- the branch, or a patch (`git format-patch main`)
- your lab log: prompts, what the AI got wrong, what you changed by hand, and the answers below

## Check

1. Where did the AI deviate from the spec? Was the spec unclear there, or did the AI ignore it? Compare with your predictions from step 3.
2. Did the AI add anything that wasn't asked for? Did you keep it? Why?
3. How long did the spec take compared with the implementation? What would you write differently next time?
4. (Level C) Show a history where a naive "drop the oldest N messages" breaks the API contract, and the test that prevents it.
5. Name one behavior of the AI assistant you used in this lab that you can now explain with a mechanism from this course. Draw the ledger if it helps.
