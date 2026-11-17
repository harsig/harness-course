# Lab 10: Review and transfer

| | |
| --- | --- |
| **You will be able to** | recall the main mechanisms without notes, see how your own picture of an agent has changed, and explain a behavior of a real AI tool with them |
| **Time** | 60 min |

Do this lab a few days after Lab 9, not on the same day. Recalling things after a break is harder, and that is what makes it work.

## 1. Mixed review (from memory, 20 min)

Answer all questions on paper first, each with a confidence from 1 to 5. No notes, no AI. Then open the answers.

1. What three inputs does one model call have? What does the model keep afterwards? (Lab 1)
2. Who runs a tool, and how does the result get back to the model? (Labs 1, 2)
3. What ends the agent loop? Name both ways. (Lab 2)
4. A session has had 20 turns. Why is turn 21 slower than turn 1, and how does the total amount of text sent grow with the number of turns? (Lab 2)
5. What does prompt caching change about question 4, and what does it not change? (Lab 2)
6. Which two parties does MCP connect? Name the three methods of a tool session. (Lab 3)
7. A model calls a tool with a value that the `enum` in the schema does not allow. What happens, step by step? (Labs 3, 4)
8. Why are tool arguments passed to a script as environment variables? (Lab 4)
9. What part of a skill is always in the context, and what part only sometimes? What does that save, and what does it cost? (Lab 5)
10. "Loaded" and "followed": how did you measure each of them? Can a rule be followed without the skill being loaded? (Lab 5)
11. With 10 runs per condition, you get 8/10 and 5/10. What do you conclude? (Lab 5)
12. What does a sub-agent receive, and what does it give back? Name one cost of using one. (Lab 6)
13. What is the difference between a boundary and a rule? Give one example of each from the course. (Lab 7)
14. Which three things together make prompt injection dangerous? (Lab 7)
15. Why does a normal run never fetch from git? What else has to be pinned besides code? (Lab 8)
16. Why is the "out of scope" list of a spec as important as the feature list when an AI writes the code? (Lab 9)

<details><summary>Answers</summary>

1. System prompt, messages, tool definitions. It keeps nothing: the client sends everything again next time.
2. The harness runs it. It appends the output to the history as a tool result (with the id of the call) and calls the model again.
3. A model reply without tool calls (the answer), or the iteration cap (an error). A failed model call ends it as well.
4. Every call resends the whole history, which only grows. The total grows about quadratically with the number of turns.
5. Resending the unchanged start gets cheaper and faster. The history still takes up the context window, and the model still has to attend to all of it.
6. The harness (client) and a tool server. `initialize`, `tools/list`, `tools/call`. The model never sees MCP.
7. The server checks the arguments before it starts the script, and returns a result marked as an error with a readable message. The harness passes that text to the model, and the model can try again with a valid value.
8. So that a value chosen by the model can never be read as a command-line option or as shell syntax. No quoting is needed.
9. Always: name and description. Only when the model calls it: the full text. It saves context for skills that are not used. The cost: whether a skill is loaded depends on the model's judgment.
10. Loaded: a `tool call:` line for the skill in the harness log. Followed: the canary in the answer (the +5 minutes). Yes: if the description itself states the rule, the model can apply it without loading the skill.
11. Not much. A difference of this size often appears by chance with 10 runs. Run more, or pool data.
12. One string (the task) in, one final text out. Costs: more model calls; it cannot ask back; errors are harder to trace.
13. A boundary is enforced by code (for example: only configured tools exist, the environment allowlist). A rule is text that makes a behavior more likely (for example: "tool results are data, not instructions").
14. Access to private data, exposure to untrusted content, and a way to communicate externally.
15. So that the same config always runs the same, reviewed versions. Also: the model and its version, prompts and rules files, tools, the model server.
16. It stops the AI (and you) from adding things nobody asked for, which would have to be reviewed, tested and maintained.

</details>

Mark each answer as right, partly right or wrong. Then look at your confidence: how many of your "5"s were right, and how many of your "1"s and "2"s? Compare that with your lab logs from the first weeks.

## 2. Draw it a third time (10 min)

Without looking at your earlier drawings, draw once more how an AI coding assistant answers "What time is it in Tokyo?". This time add what you learned after Lab 6: where untrusted text enters, which limits are enforced by code, and what is pinned.

Put the three drawings (Lab 0, Lab 6, today) next to each other. Write down the two most important changes from each drawing to the next.

## 3. Transfer: explain a real tool (25 min)

Take the AI coding tool you use most. Pick **one** behavior that you have seen yourself and that surprised or annoyed you. For example: it forgot an instruction from earlier in the session, it ignored a rule from your rules file, it picked an odd tool, it said "conversation compacted", it asked for permission, or it started a sub-agent.

1. Describe what you saw, in two or three sentences.
2. Draw the ledger as well as you can for the model call in which it happened. Mark the parts you know and the parts you can only guess.
3. Name the mechanism from this course that explains the behavior, and the lab in which you saw it.
4. Say how you could test your explanation. What would you change, what would you count, and how many runs would you need?
5. Name one thing in this tool that you cannot see from the outside and that `plain-harness` let you see.

## Check

1. Which three questions in step 1 did you get wrong or only partly right? For each, go back to the lab and write the answer again in your own words.
2. Which idea of the course has changed most how you work with AI tools? Give one concrete habit that you changed.
3. Which question about agents do you still have that this course did not answer?
