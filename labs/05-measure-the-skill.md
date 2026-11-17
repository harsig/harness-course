# Lab 5: Measure the skill

| | |
| --- | --- |
| **You will be able to** | explain how skills are loaded on demand, and measure whether an agent follows an instruction instead of trusting an impression; write a skill of your own and test it |
| **Time** | 120 min |

## Warm-up (from memory)

1. What three things does a model see of a tool? (Lab 4)
2. In your Lab 4 experiment, which description variant worked best, and was the difference larger than the noise?
3. Draw the ledger of the sub-agent's *first* model call for "What time is it in Tokyo?". (Labs 1–2)

<details><summary>Answers</summary>

1. Name, description, JSON schema.
2. Your own result. If you can't say whether it was larger than the noise, that is exactly what this lab practices.
3. system: SOUL.md + AGENT.md · tools: `scripts-mcp__date`, `skills-mcp__date-output` (names, descriptions, schemas) · messages: 1 user "What time is it in Tokyo?". Nothing else: no skill text yet.

</details>

## 1. Investigate: what the model sees of a skill

Read `$WS/skills/date-output/SKILL.md` and `$WS/plain-harness-config/sub-agent/prompts/AGENT.md`. Then answer:

- What part of `SKILL.md` is in the sub-agent's context on *every* call?
- What part arrives only after the model calls `date-output`?
- Which line in `AGENT.md` tells the model to call it?

## The idea

**The system prompt is configuration.** It is the text sent before the conversation on every call. Here it is built by joining files (`system_prompt_files`, `loadSystemPrompt` in `main.go`). The example splits it into `SOUL.md` (identity, values, voice) and `AGENT.md` (role, tools, working rules, output format). Notice that the sub-agent's `AGENT.md` is written for its *position in the system*: "your reply is returned verbatim to the calling agent".

A **skill** is a markdown file with instructions for one kind of task. What matters is *when* it gets loaded. `skills-mcp` offers each skill as a tool with no arguments. The model sees only the skill's name and description. Calling the tool returns the full `SKILL.md`.

```text
always in context:   "date-output: Use whenever you state a date, a time... Always add 5 minutes"
loaded when needed:  the full rules, examples and edge cases (midnight rollover, ranges, durations...)
```

This is **progressive disclosure**: every skill costs context for its description, but only a skill that is used costs context for its full text. You can't put 50 skills into the system prompt, but you can put 50 one-line descriptions there.

The price: **loading depends on the model's judgment.** If the description doesn't match the situation, or the model doesn't bother, the skill is never read. That's why `date-output` makes the agent do something visibly wrong: it adds 5 minutes. It is a **canary**: from any answer, you can tell whether the rule was applied. Whether the skill was *loaded* is a second question, and the harness log answers it (step 2).

> **Misconception:** "A skill that is loaded is followed." Loading and following are separate steps, and both can fail. Your table in step 4 shows how often.

**State of the art.** Claude Code and other agents now load skills natively from the same kind of `SKILL.md` file: the name and description from the frontmatter are always in the context, and the body is read on demand. `skills-mcp` builds this mechanism over MCP, so you can see it work in any MCP client.

## 2. The measuring tool

`labs/tools/measure-skill.sh` asks for the current UTC time N times and records two things per run.

Was the answer shifted?

- 3–6 minutes ahead: **shifted** (the +5 rule was applied)
- the real time: **plain** (the rule was not applied)
- anything else: **other**

Was the skill loaded? The script looks for `tool call: skills-mcp__date-output` in the harness log and marks the run **loaded** or **not loaded**.

These are two separate questions. The skill's *description* is always in the context, and it already says "Always add 5 minutes". So a model can shift the time **without** loading the skill, and it can load the skill and still not shift. The summary line counts all four combinations.

```sh
cd $WS/plain-harness-config/sub-agent
M=$WS/harness-course/labs/tools/measure-skill.sh
H=$WS/plain-harness/bin/plain-harness
$M $H plain-harness.yml 10
```

To edit the skill, point `sub-agent/skills-mcp.yml` at your local copy instead of the pinned git version:

```yaml
sources:
  - path: ../../skills/date-output
```

Run the baseline again. Nothing should change, since it is the same file.

## 3. The experiment

Run each condition 10 times (better: 20). Restore everything between conditions.

| # | Change | Question |
| --- | --- | --- |
| C1 | none | baseline |
| C2 | remove every mention of the skill from `AGENT.md`: rule 1 ("Load the output rules first") and the `date-output` line under *Tools*. This is one change: the prompt no longer names the skill | is the skill's description alone enough to get it loaded? |
| C3 | as C2, and shorten the skill's `description:` to `Output formatting.` | how much does the description matter? |
| C4 | as C2, and start the description with `ALWAYS call this before stating any time.` | can a description force loading? |
| C5 | baseline, but delete "Faithful to your rules" from `SOUL.md` | does the soul affect whether rules are followed? |

> **Predict before you run anything:** write down the expected *shifted* count and the expected *loaded* count out of 10 for each condition.

For each condition, also look at one full run to see *why*: run the harness once by hand and read its stderr lines.

## 4. Analyze

Make a table: condition × (shifted, plain, other) × (loaded, not loaded). How large must a difference be before you trust it? A rough rule: with 10 runs per condition, 7 out of 10 vs. 4 out of 10 is *not* a clear difference. With 20 runs each, 15 vs. 7 is. To get more data, pool your results with the whole group.

You also compare four conditions with the baseline. The more comparisons you make, the more likely it is that one of them looks clear by chance alone. Decide *before* you run which comparison matters most to you, and treat the others as hints that need a second test.

This is a tiny **eval**: a fixed task, a measurable signal, repeated runs, conditions compared. Teams that build agents work this way, with hundreds of tasks instead of one.

## 5. Make: your own skill, with your own canary

Write a skill for your agent from Lab 4 (`~/my-agent`).

1. Create `~/my-agent/skills/<name>/SKILL.md` with `name` and `description` in the frontmatter. The body holds real rules for one kind of task of your agent (for example, how to present a list of commits), plus **one canary**: a harmless rule whose effect you can find in the answer with `grep`.
2. Keep the canary out of the description. Then *loaded* and *followed* stay two separate measurements.
3. Add a `skills-mcp.yml` with your skill folder as a `path` source, and a second server in `plain-harness.yml` that runs `skills-mcp` with it. `sub-agent/plain-harness.yml` shows the pattern.
4. Decide whether your `AGENT.md` should name the skill, and write down why.
5. Measure 10 runs of one fitting question: how often was the skill loaded (`tool call:` line in stderr), and how often does the canary show in the answer?

## Check

1. Which condition had the largest effect? Was it the one you predicted?
2. Explain the C2 result with the ledger: what did the model see, and what didn't it see? (In C2, look at the *shifted, not loaded* count: the description alone already says "Always add 5 minutes". If C1 and C2 look the same, which words in the description did the work? C3 tests exactly that.)
3. Did you see runs that were *loaded* but not *shifted*, or *shifted* but not *loaded*? What does each tell you about "loaded" vs. "followed"?
4. Why is a deliberately wrong behavior (+5 minutes) a better test signal than a realistic rule like "always use ISO 8601"?
5. What would you need to change to publish these results? (Think of sample size, model version, temperature, prompt wording.)
6. For your own skill: show the description, your two counts, and one change that would raise the lower of the two.

## In your daily work

`CLAUDE.md`, `AGENTS.md`, `.cursorrules` and skills are pieces of the system prompt that your tool adds for you. Treat them like code: keep them short and specific, put them under version control, and **test** whether a change actually changes behavior. If "the AI ignores my instructions", first check whether the instructions were ever in its context. Then design a canary for your own rules file, and decide when you would remove it.
