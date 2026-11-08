# Lab 2: Read and break the loop

| | |
| --- | --- |
| **You will be able to** | explain the agent loop line by line, predict how it fails at each limit, and explain why long sessions get slow |
| **Time** | 60 min |

## Warm-up (from memory)

1. In Lab 1, why did the model receive your question a second time in turn 2?
2. Who runs a tool: the model or the harness?
3. Why must a tool result carry the `tool_call_id` of its call?

<details><summary>Answers</summary>

1. The model keeps no state. The client resends the whole conversation on every call.
2. The harness. The model only asks for the tool, with a name and arguments.
3. So the model can match each result to its request, which matters when one reply contains several tool calls.

</details>

## 1. Predict

When you ask the sub-agent "What time is it in Tokyo?", how many times is the model called? Write the number, and what each call returns.

## 2. Investigate: read the loop

Open `$WS/plain-harness/src/agent.go` (79 lines) and `types.go` (39 lines). Here is the core of `Agent.Run`, shortened slightly:

```go
history = append(history, Message{Role: roleUser, Text: prompt})
for i := 0; i < a.maxIterations; i++ {
    reply, err := a.chat(ctx, history, onText)
    if err != nil {
        return history, "", err
    }
    history = append(history, reply)
    if len(reply.ToolCalls) == 0 {
        return history, reply.Text, nil                  // no tool calls: this is the answer
    }
    for _, call := range reply.ToolCalls {
        history = append(history, a.callTool(ctx, call)) // run tool, append result
    }
}
return history, "", fmt.Errorf("stopped after max_iterations (%d) without a final answer", a.maxIterations)
```

Answer with line numbers from the real file:

1. Where is the user's message added to the history?
2. What makes the loop end with an answer? What makes it end with an error?
3. What happens when a tool fails? Does the run end?
4. When is a model request retried? Why is it *not* retried once text has been streamed?
5. `Run` returns `history` even when it returns an error. Find the caller in `main.go`. Why does that matter for sessions?

Now check your prediction from step 1.

## 3. Break it: the iteration cap

In `plain-harness-config/sub-agent/plain-harness.yml`, set `max_iterations: 1`.

> **Predict:** What will the sub-agent print? What exit code will it return?

```sh
cd $WS/plain-harness-config/sub-agent
../../plain-harness/bin/plain-harness "What time is it in Tokyo?"; echo "exit code: $?"
```

Now ask the **main** agent the same question. The sub-agent fails inside it. What does the user see? Find the rule in `main-agent/prompts/AGENT.md` that produced this behavior.

> **Predict:** What is the smallest `max_iterations` that works? Then try 2 and 3.

Restore the file: `git restore sub-agent/plain-harness.yml`.

## 4. Break it: a failing tool

> **Predict:** If the time zone doesn't exist, will the run fail?

```sh
../../plain-harness/bin/plain-harness "What time is it in the time zone Mars/Olympus_Mons?" 2>&1
```

Did the *tool* fail? Did the *run* fail? What did the model do with the error text from `date.sh` (`unknown time zone: …`)?

## The idea

**The agent loop.** *Ask the model. If it wants tools, run them, add the results to the history, and ask again. Stop when it answers without tools.* Every "decision" an agent makes is in a model reply. The harness only carries it out.

- **The model decides when it is done.** The loop ends when a reply has no tool calls.
- **There is a cap** (`max_iterations`, default 25). Without one, a confused model could loop forever, and every iteration costs time and money.
- **Every call resends the whole history.** Each new step makes all later calls longer.

**Failures are data.** The harness sorts failures by kind and handles each one differently:

| Failure | Handling | Why |
| --- | --- | --- |
| tool fails (bad args, exit code ≠ 0, timeout) | sent to the model as an error result (`callTool`) | the model can often fix it |
| network error, timeout, HTTP 429, 5xx | retried up to 3 times, honoring `Retry-After` (max 30 s) | the error is temporary, so retrying is safe |
| retry after text was already streamed | not retried | the user would see the text twice |
| no final answer after `max_iterations` | the run ends with an error | protects against endless loops |
| bad config | exit 1 at startup, before any model call | fail early, fail cheap |

The first row matters most: an error message the model can read is what lets an agent recover by itself.

> **Misconception:** "A failing tool crashes the agent." Usually it doesn't. The error becomes the next message, and the model gets another try.

## 5. Modify: log every iteration

Add one line to `Agent.Run` that logs the iteration number and the size of the history before each model call:

```text
plain-harness: iteration 2, 5 messages
```

Build (`./build.sh`). Run the main agent with **one session** for three questions in a row. Then run the tests (`cd src && go test ./...`), and restore your change or keep it on a branch.

## The idea, continued: sessions are the history on disk

With `--session demo`, the harness saves the history to `sessions/demo.json` and loads it on the next run. The file *is* the `Message` list that will be sent again. `session.go` is worth reading:

- **exclusive lock** (`flock` on `demo.json.lock`): two runs can't write the same session at once
- **atomic save** (write a temp file, then rename it): a crash can't leave half a file
- **saved even on error**: a failed run can be continued
- **no compaction** (out of scope in `spec.md`): the session grows until it no longer fits the model's context window, and then the run fails

**What production harnesses add.** Commercial agents deal with this growth in three ways. **Compaction** summarizes or drops old turns when the context fills up. **Prompt caching** lets the provider reuse the unchanged start of the request, so resending it costs less and goes faster. But it is still sent, and it still takes up the context window. **Parallel tool calls** run several tools from one reply at the same time. `plain-harness` leaves all three out, so you can see the plain mechanism.

## Check

1. Make a table of messages per model call over your three questions. What grows, and how fast?
2. Estimate how the *total* amount of text sent grows with the number of turns in a session: linear, quadratic, or something else? Explain why.
3. Draw the ledger for the last model call of your third question. Which parts would a compaction step change?
4. In your own words: why does the harness return a tool error to the model instead of stopping?

## In your daily work

An agent that "goes in circles" is in this loop, with tool results that don't move it forward. Stopping it, adding the missing information and starting again is often faster than waiting. "Context window full", "conversation compacted" and "start a new chat for better results" are all about the session growing. A long session isn't free memory: the model reads it again on every call, and pays less attention to old details. Start a fresh session for each new task. And write good error messages in your own projects: an agent fixes a clear compiler error in one step, but has to guess at a bare stack trace.
