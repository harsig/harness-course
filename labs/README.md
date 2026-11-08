# How the labs work

Every lab has the same rhythm. Once you know it, you can spend your attention on the content instead of on the format.

| Step | What you do | Why it works |
| --- | --- | --- |
| **Warm-up** | Answer 3 short questions from earlier labs, from memory, *before* you look anything up. Then check the answers. | Recalling something strengthens memory much more than re-reading it. Doing it days later works better still. |
| **Predict** | Write down what you expect to happen, with a confidence from 1 (guess) to 5 (sure). | A wrong prediction you made yourself is the strongest signal to learn from. Confidence ratings show you where your intuition is off. |
| **Run** | Run the given commands. Compare with your prediction. | You see the real system before you see any explanation. |
| **Investigate** | Find the lines of code or config that caused what you saw. | You trace an effect back to its cause. |
| **The idea** | A short explanation of the mechanism, *after* you have seen it. | An explanation sticks when you have a question it answers. |
| **Modify / Make** | Change the system, then build something of your own. | Help is reduced step by step until you work on your own. |
| **Check** | Explain the mechanism in your own words, without notes. | If you can't explain it, you haven't got it yet. Better to find that out now than in the exam. |

## The context ledger

The one picture that explains almost everything in this course is **what the model receives in one call**. Draw it whenever a lab asks for a *ledger*:

```text
call #3 to the model
  system   : SOUL.md + AGENT.md                      (sent on every call)
  tools    : scripts-mcp__date, skills-mcp__date-output  (name + description + schema)
  messages :
    1 user       "What time is it in Tokyo?"
    2 assistant  tool_call skills-mcp__date-output {}
    3 tool       "# Date and Time Output ... add 5 minutes ..."
    4 assistant  tool_call scripts-mcp__date {"timezone":"Asia/Tokyo"}
    5 tool       "2026-11-09T06:10:48+09:00"
```

Everything the model "knows" in that call is in this box, and nothing else is. Most surprises in AI tools ("it forgot", "it ignored my rule", "it obeyed a web page") become obvious once you draw the ledger.

## Rules

- **Predict on paper first.** Predictions are only useful if you write them down *before* you run the command.
- **Keep a lab log.** For each lab, write down your predictions, the commands you ran (outputs shortened) and your answers. Use the template below.
- **One run proves little.** Models are not deterministic. When a lab asks "does X happen?", run it several times and report how often, e.g. "4 of 5".
- **Work on a branch or a copy.** Many labs change prompts or configs. `git stash` or `git restore .` takes you back.
- **AI assistants: after you predict, not before.** Do the warm-up, predictions and Check questions yourself: the point is the thinking, and an assistant can't do that for you. For everything else, use AI freely, and write down how you used it.

All paths assume the repositories sit next to each other in one folder (see the [README](../README.md#quick-start)), called `$WS`:

```sh
export WS=~/path/to/the/folder   # the folder that holds all repositories
```

## Lab log template

```markdown
# Lab N — <date>, model: <name + quantization>

## Warm-up
my answers → corrections

## Predictions
| # | I predict | confidence 1–5 | actual | why the difference |

## Notes
commands, shortened outputs, ledgers

## Check
answers in my own words
```

Look back at the *confidence* column after a few labs. Were your "5"s right more often than your "2"s? Getting a feel for your own confidence is a skill you will need when you judge AI output.
