# Evals And Iterations

## Goal

Do not trust a skill because it looks good on paper.

Run realistic tasks with the skill, compare against a baseline, review outputs, and iterate.

## Start small

Begin with 2-3 realistic prompts.

Each eval should include:

- `prompt`
- `expected_output`
- `files` if needed
- optional `assertions` after the first run

Use realistic user phrasing:

- include file paths
- include business context
- vary formality
- include at least one edge case

## Workspace shape

Use a sibling workspace directory, organized by iteration.

```text
my-skill/
└── evals/
    └── evals.json
my-skill-workspace/
└── iteration-1/
    ├── eval-a/
    │   ├── with_skill/
    │   │   ├── outputs/
    │   │   ├── timing.json
    │   │   └── grading.json
    │   └── without_skill/
    │       ├── outputs/
    │       ├── timing.json
    │       └── grading.json
    └── benchmark.json
```

If improving an existing skill, the baseline can be a snapshot of the previous version instead of `without_skill`.

## Run both sides together

For each prompt, run:

- with skill
- baseline without skill, or old version

Launch both in the same overall pass so timing and context are comparable.

## Add assertions after the first pass

Do not overdesign assertions before seeing outputs.

Strong assertions are:

- objective
- easy to grade
- phrased so a human can understand them at a glance

Good examples:

- output includes a valid JSON file
- report contains a recommendations section
- generated chart has labeled axes
- exactly 3 records were created

Weak examples:

- output is good
- answer feels polished
- wording exactly matches a fixed phrase

Subjective qualities are still important. Use human review for those.

## Capture timing and token cost

For each run, save:

```json
{
  "total_tokens": 84852,
  "duration_ms": 23332,
  "total_duration_seconds": 23.3
}
```

This lets you compare what the skill costs against what it improves.

## Grade with evidence

Each assertion should be marked pass or fail with concrete evidence.

Example shape:

```json
{
  "assertion_results": [
    {
      "text": "The output includes a bar chart image file",
      "passed": true,
      "evidence": "Found chart.png in outputs directory"
    }
  ]
}
```

Use scripts for mechanical checks when possible.

## Aggregate results

Track at least:

- pass rate
- time
- tokens

Compare:

- with skill
- baseline
- delta

Do not look only at averages. Also inspect per-eval outcomes.

## Analyze patterns

Watch for:

- assertions that always pass in both modes
- assertions that always fail in both modes
- evals that are flaky across runs
- high time or token outliers
- repeated wasted work in transcripts

If the same helper logic gets recreated across evals, bundle it into `scripts/`.

## Human review still matters

Review actual outputs, not just grades.

Useful human feedback is specific:

- missing axis labels
- wrong ordering
- did the technically correct thing but missed the user's intent

Empty feedback means the output looked fine.

## Iteration loop

1. review assertions, human feedback, and transcripts
2. revise the skill
3. rerun all evals in `iteration-N+1`
4. compare against baseline again
5. repeat until results stabilize or stop improving

## Improvement heuristics

- generalize from the feedback; do not overfit to one prompt
- cut instructions that waste time
- explain why important steps exist
- move deterministic repeated work into scripts
- tighten defaults if the model is hesitating or branching too much

## Exit standard

A mature skill should beat the baseline on the tasks that matter, with an acceptable time and token cost, and should survive review beyond a single handpicked example.