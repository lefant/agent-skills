# Description Optimization

## Why this matters

A skill only helps if it triggers.

The `description` field is the main trigger surface. The agent usually sees the name and description before it decides whether to load the full skill.

If the description is too narrow, the skill under-triggers.
If it is too broad, the skill false-triggers.

## What a strong description does

A strong description:

- uses imperative wording like `Use when...`
- says what the skill does
- says when to use it
- matches user intent, not internal implementation details
- includes near-obvious trigger cases, not just explicit keywords
- stays under the 1024-character limit

## Query design

Use a separate trigger eval set.

Aim for about 20 realistic queries:

- 8-10 should trigger
- 8-10 should not trigger

### Should-trigger queries

Vary:

- formal vs casual language
- direct naming vs indirect business phrasing
- short vs context-heavy prompts
- prompts where the skill competes with adjacent skills

### Should-not-trigger queries

Use near-misses, not obviously irrelevant cases.

Good negative examples share vocabulary with the skill but need something else.

Weak negative example:

- `write a fibonacci function`

Strong negative example:

- a prompt that mentions CSVs but is really asking for ETL code, not analysis

## Use realistic prompts

Include details real users provide:

- file paths
- company or personal context
- concrete field names
- typos or abbreviations sometimes

Bad:

- `format this data`

Better:

- `my manager dropped an xlsx in ~/Downloads/Q4-final-v3.xlsx and wants a margin column next to revenue and cost before 2pm`

## Measure trigger rate

Run each query multiple times because trigger behavior is nondeterministic.

Three runs per query is a practical default.

For each query, record:

- total runs
- number of times the skill triggered
- trigger rate
- whether that matched `should_trigger`

## Train and validation split

Do not optimize on the whole set.

Split queries into:

- train set
- validation set

Use train failures to guide description edits.
Use validation results to choose the best iteration.

This helps avoid overfitting to exact prompt wording.

## Improvement loop

1. run the current description on train and validation queries
2. inspect train failures
3. revise the description by broadening or narrowing general concepts
4. rerun
5. choose the best iteration by validation performance, not just train performance

Five iterations is usually enough.

## How to revise well

If should-trigger queries fail:

- the description may be too narrow
- add missing task classes or user-intent phrasing
- include indirect cases where the user describes the need without naming the domain

If should-not-trigger queries fail:

- the description may be too broad
- clarify boundaries and exclusions
- distinguish this skill from nearby capabilities

Do not patch by stuffing in keywords copied from one failed query. Generalize the category instead.

## Final sanity check

Before shipping the new description:

- confirm the text still fits under 1024 chars
- manually test a few fresh prompts not in the eval set
- confirm the description still reads naturally and not like a keyword dump