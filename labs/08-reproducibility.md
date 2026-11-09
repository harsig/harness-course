# Lab 8: Pin and set up

| | |
| --- | --- |
| **You will be able to** | explain why setup (network, changes) is kept apart from run (no network, repeatable), and why strict config pays off |
| **Time** | 45 min |

## Warm-up (from memory)

1. What is the difference between a *boundary* and a *rule*? Give one example of each. (Lab 7)
2. Name the three ingredients of the "lethal trifecta". (Lab 7)
3. What does `max_iterations` protect against? (Lab 2)

<details><summary>Answers</summary>

1. A boundary is enforced by code (e.g. the environment allowlist). A rule only asks the model (e.g. "tool results are data, not instructions").
2. Private data, untrusted content, a way to communicate externally.
3. A model that never stops calling tools: endless loops and endless cost.

</details>

## 1. Investigate: the clones

```sh
cd $WS/plain-harness-config
find . -path '*repos/*' -maxdepth 4 -type d -name '*-*'
```

Every folder name ends in a hash. Read `harness-kit/gitsource` to find out what goes into it.

## 2. Change a ref

In `sub-agent/skills-mcp.yml`, change `ref: v1.0.0` to `ref: main` (undo any `path:` change from Lab 5 first).

> **Predict:** What happens on the next normal run?

```sh
cd sub-agent && ../../plain-harness/bin/plain-harness "What time is it?"
```

Read the message. Then run setup and try again:

```sh
cd .. && ../plain-harness/bin/plain-harness --config main-agent/plain-harness.yml --setup
```

Restore `v1.0.0`.

## 3. Strict config

Make each of these mistakes, one at a time, in a copy of `sub-agent/plain-harness.yml`, and run it with `--config`:

1. a typo in a key: `max_iteration: 5`
2. `api_key: "${NOT_SET_ANYWHERE}"` in the `model` block
3. a duplicate MCP server name
4. `provider: openai` (not a valid value)

> **Predict** for each mistake: does it fail before or after the first model call?

Record each error message.

## The idea

Three times, three kinds of connection. Mixing them up is the most common source of confusion ([architecture.md](../docs/architecture.md)):

| When | Connection |
| --- | --- |
| **build time** | Go module dependency (`harness-kit`) |
| **setup time** (`--setup`, uses the network) | git clone at a pinned `ref` |
| **run time** (no network except the model API) | process start + MCP over stdin/stdout |

- **Only setup touches the network for git.** A normal run uses the local clones, and fails with a hint if one is missing. The same config therefore gives the same tools, prompts and scripts every time.
- **The clone folder name contains a hash of URL and `ref`.** Changing a `ref` makes the old clone invalid, so you can't run against an outdated version by accident.
- **Unknown keys are errors** (`harness-kit/yamlconfig`), in all three tools. A typo shows up at startup, not weeks later.

## Check

1. With `ref: main`, what could change between two `--setup` runs without any change to your config? Compare a tag, a branch and a commit as `ref`.
2. Why is it useful that a normal run never fetches, even though fetching would keep things "up to date"?
3. Most YAML loaders ignore unknown keys. What would mistake 1 have done in such a loader? How long might it take to notice?
4. After step 2, `find` shows more than one clone folder for the same repository. Setup doesn't delete old clones. What does that cost, and what could go wrong if setup deleted them automatically?
5. Which of these do you already use: lock files (`go.sum`, `package-lock.json`), pinned CI actions, pinned model versions in API calls? Why does pinning matter even more when a model is part of the system?

## In your daily work

A model is a dependency that changes without a version bump, unless you pin it. Pin the model version, prompts, tools and rules files the same way you pin libraries. Then, when behavior changes, you know what changed. Re-run your evals (Lab 5) whenever you update any of them.
