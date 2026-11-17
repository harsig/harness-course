# For instructors

Learning outcomes, how the course is designed and why, formats, assessment, and practical notes.

## Rationale

Students now write much of their code with AI assistants, and most of them use those tools as black boxes. They pick up habits ("just ask again", "start a new chat") without knowing why these work. That leaves them unable to debug the tools, to judge how far to trust them, or to build such systems themselves.

This course opens the box. The model is a given component with an HTTP API. Everything else (loop, tools, protocol, prompts, context, safety, reproducibility) is ordinary software engineering that students can read, test and change. The harness is about 1,500 lines of Go plus tests, and each tool server is smaller, so a student can read all of it.

## Learning outcomes and alignment

Each outcome is practiced in specific labs and assessed by specific evidence. If a lab activity doesn't serve an outcome, it shouldn't be in the course, and if an outcome isn't assessed, it isn't really an outcome.

| # | After the course, students can… | Practiced in | Assessed by |
| --- | --- | --- | --- |
| LO1 | **explain** how a stateless model becomes an agent through a harness loop, and trace one request through all components | 0, 1, 2, 6 | ledger drawings; Lab 6 redraw; live walk-through |
| LO2 | **implement** a tool with name, description and schema, and **serve** it over MCP to any compatible client | 3, 4 | Lab 4 tool and agent |
| LO3 | **design** system prompts and skills, and explain the trade-offs of progressive disclosure | 5 | Lab 5 Check answers |
| LO4 | **evaluate** agent behavior empirically, with repeated runs, conditions and a measurable signal, instead of single impressions | 4, 5, 6, 7 | Lab 5 experiment report |
| LO5 | **analyze** a multi-agent design for context flow, cost and failure modes | 6 | Lab 6 ledgers and Check answers |
| LO6 | **assess** the security boundaries of an agent system, and tell enforced limits apart from prompt rules | 7 | Lab 7 boundary table |
| LO7 | **apply** reproducibility practices (pinned versions, setup/run separation, strict config) to systems that include a model | 8 | Lab 8 log |
| LO8 | **develop** a feature with an AI assistant through a spec-first workflow, and take responsibility for the result | 9 | Lab 9 deliverables, live walk-through |

## How the course teaches, and why

The design follows a small set of principles with strong evidence from cognitive psychology and education research, and with some support from neuroscience. A word of honesty first: neuroscience rarely yields classroom instructions directly. What it mostly does is explain *why* principles found in behavioral studies work. And beware of neuromyths, "learning styles" in particular, which have no empirical support (Pashler et al., 2008).

| Principle | How the course uses it | Evidence |
| --- | --- | --- |
| **Retrieval practice** | every lab starts with a warm-up from memory, with answers to check right after; Check questions ask for explanations without notes | Roediger & Karpicke, 2006; Dunlosky et al., 2013 |
| **Spacing and interleaving** | warm-ups mix questions from the previous lab with questions from several labs back; the ledger comes back again and again | Cepeda et al., 2006; Rohrer & Taylor, 2007. Sleep consolidates memory between sessions (Diekelmann & Born, 2010), so spread labs over days, not one afternoon |
| **Prediction before observation** | a written prediction with a confidence rating before every experiment | surprise, a prediction error, drives learning (Brod, Hasselhorn & Bunge, 2018); in the brain, dopamine signals prediction errors (Schultz, Dayan & Montague, 1997); curiosity improves memory, through the hippocampus (Gruber, Gelman & Ranganath, 2014) |
| **Experience before explanation** | "The idea" comes after Run and Investigate, not before | Schwartz & Bransford, 1998 ("A time for telling"); productive failure (Kapur, 2016) |
| **PRIMM for programming** | Predict → Run → Investigate → Modify → Make is the lab rhythm | Sentance, Waite & Kallia, 2019 |
| **A notional machine** | the *context ledger*: one simple, accurate model of what the model sees, drawn in Labs 1, 2, 5, 6, 9 | du Boulay, 1986; Sorva, 2013 |
| **Worked examples, then fading** | Lab 1 does everything by hand with exact JSON; Lab 4 goes from an annotated example, to a template with gaps, to a tool of the students' own design | Sweller, van Merriënboer & Paas, 2019; Renkl & Atkinson, 2003 |
| **Managing cognitive load** | the same lab template every time; Lab 0 runs one agent before showing two; the explanation sits next to the code instead of in a separate document | Sweller et al., 2019 (split attention); expertise reversal: reduce guidance as skill grows (Kalyuga et al., 2003) |
| **Conceptual change** | students draw their current model in Lab 0 and redraw it in Lab 6; misconceptions are named in each lab and tested against the system | Chi, 2008; self-explanation (Chi et al., 1994) |
| **Metacognition** | confidence ratings next to predictions; students look back at how well their confidence matched their results | Dunlosky et al., 2013 |
| **Constructive alignment** | outcomes, activities and assessment line up in the table above | Biggs, 1996 |
| **Generation before AI help** | warm-ups, predictions, Check answers and the Lab 9 spec are done without AI; AI is encouraged everywhere else | open AI access without such guardrails improved practice scores but harmed exam performance in a large field experiment (Bastani et al., 2025) |

## Formats

**7-week module** (one 90-minute session plus about 3 hours of self-study per week). One lab per sitting, spread over the week, uses spacing better than a single long block.

| Week | Session | Self-study |
| --- | --- | --- |
| 1 | Lab 0 together, incl. the drawing; start Lab 1 | finish Lab 1 |
| 2 | Discuss Lab 1 ledgers; Lab 2 | Lab 3 |
| 3 | Warm-up as a class quiz; Lab 4 started in class | finish Lab 4 |
| 4 | Experiment design; Lab 5, with results pooled across the group | Lab 5 report |
| 5 | Lab 6, incl. the redraw; discuss the drawings | Lab 7 |
| 6 | Discuss Lab 7 counts; Lab 8 | start Lab 9 |
| 7 | Lab 9 walk-throughs, reflection | final report |

**Block week** (5 days): one day each for Labs 0–2, 3–4, 5–6, 7–8, and 9 with presentations. Start each day with a 10-minute mixed quiz on the days before.

**Single workshop** (3 hours): Lab 0 prepared in advance, Lab 1, then Lab 5 with conditions C1 and C3 only (with strong models, C1 and C2 often look the same). These show the two key ideas: the loop is simple, and instructions are followed only with some probability.

## Assessment

A portfolio works well: the lab logs plus Lab 9.

| Component | Weight | Evidence |
| --- | --- | --- |
| Lab logs 0–8 | 40 % | predictions, ledgers, Check answers, with commands and outputs |
| Lab 5 experiment report | 20 % | method, table, interpretation, limitations |
| Lab 9 feature | 30 % | spec diff, code, tests, review notes |
| Reflection | 10 % | 1–2 pages: the Lab 0/Lab 6 drawings compared, and how the course changed the way they use AI tools |

**Grade predictions for being made, not for being right.** A wrong prediction that is honestly explained is worth as much as a correct one. Otherwise students will fill in the prediction after the run.

Rubric for Lab 9:

| | Insufficient | Sufficient | Good | Excellent |
| --- | --- | --- | --- | --- |
| Spec | missing or vague | behavior described | + errors and limits | + justified scope, out-of-scope list updated |
| Tests | none, or only the happy path | main rules covered | + error cases | + a test that caught a real bug in AI output |
| Review | "looks fine" | checklist done | deviations from the spec found and fixed | + can explain every line live |
| Reflection | describes steps | names AI mistakes | explains them with course mechanisms | + concrete changes to their own workflow |

**On AI use:** the answers depend on *each student's own* runs and measurements, which an assistant can't produce for them. A short live code walk-through in Lab 9 (5 minutes per student) tests understanding better than any rule against AI.

## Practical notes

- **Hardware.** A local model with reliable tool calling needs a recent GPU or an Apple Silicon machine with enough memory. Alternatives: a shared lab server running `llama-server`, or a hosted API with a course budget. Small local models (under about 8B parameters) work for Labs 1 and 3, but make Labs 4–6 noisy.
- **Reference model server.** [llama.cpp-compose](https://github.com/harsig/llama.cpp-compose) runs `llama-server` in Docker (AMD or NVIDIA, Linux) with the model the configs expect. Use it for a shared lab server or for students' own machines: everyone gets the same model, quantization and server settings. The llama.cpp image is not pinned (the compose file pulls the latest build on every start), so before results are pooled for Lab 5, pin the image to one tag or digest for the whole course, or have students record the build.
- **Shared model server.** With one shared server, runs queue up. Spread Lab 5 out, or use fewer repetitions per student and pool the results.
- **Prepare Lab 0 in advance.** Building, `--setup` and the model connection are where time is lost. A pre-built VM or container image saves the first session.
- **Nondeterminism is part of the content.** Students will get different results from each other. Collect the whole group's Lab 5 results and analyze them together: that gives a sample size no single student has.
- **Repository versions.** Students clone the `main` branch of each repository. For a course run, note the commit of each one (or have everyone check out the same tags), so file and line references in the labs match what students see.
- **Model versions.** Have students write the exact model and quantization into every log. Results from one model don't carry over to another, and seeing that is itself a learning outcome.

## Discussion questions

1. "The model decides, the harness executes." Find a place in this codebase where the harness makes a decision itself. Should it?
2. The sub-agent is a bash script; commercial tools have built-in sub-agents. What is gained, and what is lost?
3. Skills are loaded at the model's discretion. When is that the right design, and when should instructions always be in the system prompt?
4. Is a tool description documentation or a prompt? Who is its reader?
5. Which mechanisms in this course will still matter when models get much better? Which problems might go away?
6. If a model can write this harness from its spec, what is left for the engineer? (Look at your Lab 9 log before you answer.)

## Extensions

- **Comparison study:** run `scripts-mcp` and `skills-mcp` in Claude Code or another MCP client and in `plain-harness`, and compare the behavior. What does the other harness add to the prompt?
- **Second provider:** run Lab 5 with an `openai_compatible` and an `anthropic_compatible` model, and compare the wire formats in `openai.go` and `anthropic.go`.
- **Eval suite:** turn `labs/tools/measure-skill.sh` into a small test suite for agent behavior, with several tasks and a pass rate per condition.
- **Permission step:** add a human approval prompt before selected tool calls, and measure what it costs in time and in interruptions.
- **HTTP transport:** connect an MCP server over Streamable HTTP (`mcp_servers[].http`) and discuss what changes for authentication and trust.

## References

- Bastani, H., et al. (2025). Generative AI without guardrails can harm learning: Evidence from high school mathematics. *PNAS*, 122(26).
- Biggs, J. (1996). Enhancing teaching through constructive alignment. *Higher Education*, 32.
- Brod, G., Hasselhorn, M., & Bunge, S. A. (2018). When generating a prediction boosts learning: The element of surprise. *Learning and Instruction*, 55.
- Cepeda, N. J., et al. (2006). Distributed practice in verbal recall tasks. *Psychological Bulletin*, 132.
- Chi, M. T. H. (2008). Three types of conceptual change. In *International Handbook of Research on Conceptual Change*.
- Chi, M. T. H., et al. (1994). Eliciting self-explanations improves understanding. *Cognitive Science*, 18.
- Diekelmann, S., & Born, J. (2010). The memory function of sleep. *Nature Reviews Neuroscience*, 11.
- du Boulay, B. (1986). Some difficulties of learning to program. *Journal of Educational Computing Research*, 2.
- Dunlosky, J., et al. (2013). Improving students' learning with effective learning techniques. *Psychological Science in the Public Interest*, 14.
- Gruber, M. J., Gelman, B. D., & Ranganath, C. (2014). States of curiosity modulate hippocampus-dependent learning via the dopaminergic circuit. *Neuron*, 84.
- Kalyuga, S., Ayres, P., Chandler, P., & Sweller, J. (2003). The expertise reversal effect. *Educational Psychologist*, 38.
- Kapur, M. (2016). Examining productive failure, productive success, unproductive failure, and unproductive success in learning. *Educational Psychologist*, 51.
- Pashler, H., McDaniel, M., Rohrer, D., & Bjork, R. (2008). Learning styles: Concepts and evidence. *Psychological Science in the Public Interest*, 9.
- Renkl, A., & Atkinson, R. K. (2003). Structuring the transition from example study to problem solving in cognitive skill acquisition. *Educational Psychologist*, 38.
- Roediger, H. L., & Karpicke, J. D. (2006). Test-enhanced learning. *Psychological Science*, 17.
- Rohrer, D., & Taylor, K. (2007). The shuffling of mathematics problems improves learning. *Instructional Science*, 35.
- Schultz, W., Dayan, P., & Montague, P. R. (1997). A neural substrate of prediction and reward. *Science*, 275.
- Schwartz, D. L., & Bransford, J. D. (1998). A time for telling. *Cognition and Instruction*, 16.
- Sentance, S., Waite, J., & Kallia, M. (2019). Teaching computer programming with PRIMM: A sociocultural perspective. *Computer Science Education*, 29.
- Sorva, J. (2013). Notional machines and introductory programming education. *ACM Transactions on Computing Education*, 13.
- Sweller, J., van Merriënboer, J. J. G., & Paas, F. (2019). Cognitive architecture and instructional design: 20 years later. *Educational Psychology Review*, 31.
