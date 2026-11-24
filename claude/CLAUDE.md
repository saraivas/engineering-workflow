# Working rules for every project

General rules for every project in the workspace, current and future. Claude
Code loads them through a one-line `CLAUDE.md` in the workspace folder that
imports this file, so the published rules and the ones in use are the same
file.

## Where each instruction lives

| File | What goes in it | In git? |
|---|---|---|
| This file | Purpose of the series, working rules, agents and skills. Applies to every project. | Yes, in this repository |
| `<repo>/CLAUDE.md` | Only what belongs to that project: commands, conventions that differ from defaults, pitfalls, domain rules (for example multi-tenancy). It must stand on its own, because people who clone the repo, CI and cloud sessions do not see this file. | Yes |
| `<repo>/.claude/rules/*.md` | A rule for one topic or one part of the code (`paths:` in the frontmatter). Use it when the repo's `CLAUDE.md` grows. | Yes |
| `<repo>/CLAUDE.local.md` | Personal preference in that repo. Listed in `.gitignore`. | No |
| `~/.claude/CLAUDE.md` | Preferences for everything on the machine, including projects outside the workspace. | No |

Maintenance rules:

- Do not write what the code already says: folder structure, dependencies,
  architecture overviews, project status. That ages and starts to lie.
- Keep each `CLAUDE.md` under 200 lines. Concrete, checkable instructions
  ("run `pytest`") instead of vague ones ("test your changes").
- A multi-step procedure becomes a skill, not a paragraph here.
- What must always happen (for example, never merging) goes into Claude Code
  permissions or hooks. For Claude, `CLAUDE.md` is context, not a lock.
- If two files contradict each other, Claude may follow either. Fix the
  contradiction instead of relying on the order.

## Purpose

A public study series in backend, data and AI. Each project targets specific
gaps (auth from the inside, SQL, multi-tenancy, testing, CI/CD, semantic
search), not "one more CRUD". The repositories are a portfolio: they show,
with verifiable evidence, how decisions were made and tested.
`saraivas.github.io` is the site that presents the projects.

## The main rule: truth first

READMEs, ADRs, diagrams, the portfolio page and the CV describe **only** what
is implemented and verified.

- No number, test result, performance gain or deployment that was not
  measured or checked. Count the tests in the repository before quoting a
  number.
- Planned work goes under "Known limitations" or an ADR's "Future
  improvements", never in the description of what exists.
- If the docs and the code disagree, say so. Fix one of them and explain
  which one and why.
- Public text does not mention employers, clients or internal projects, and
  holds no secrets.

## How we work

1. **Plan before code.** Present what you will do and why, and wait for
   approval. When there is a choice, show the options with pros and cons;
   Felipe decides.
2. **Small PRs.** One subject per PR, a reason for every change.
3. **Branch and PR.** Never push to `main`. Felipe reviews and merges every
   PR; Claude never merges (also blocked in Claude Code permissions).
4. **A test that can fail.** Every new behaviour comes with a test. Break the
   code on purpose and confirm the test catches it.
5. **CI only counts when it finishes.** Do not say it passed before the
   conclusion is `success`
   (`gh api repos/<owner>/<repo>/commits/<branch>/check-runs`).
6. **ADRs** are numbered, only for real decisions, and never rewritten: when
   one turns out wrong or outdated, add an `Update` note under its Status and
   write a new ADR.
7. **Diagrams.** A change to a flow updates the README diagram in the same
   PR; Mermaid syntax is checked before committing.
8. **Commits in English**, `feat:`, `fix:`, `docs:`, `test:`, `ci:`,
   explaining why.
9. **Two review layers before a PR.** `code-review` on the diff for bugs;
   then `ponytail-review` to cut what does not need to exist (duplicated
   code, abstractions with a single use, flexibility nobody uses). Apply the
   cuts, run the tests again and say in the PR what was cut. A hook
   (`hooks/ponytail-before-commit.ps1`) reminds Claude of this before every
   `git commit` it runs in the workspace.
10. **Study pause.** Before coding a PR that touches a concept asked in
    backend interviews (transactions, isolation, authorization in SQL,
    indexes, concurrency, caching, queues, consistency across systems), tell
    Felipe before the plan: the concept, why it matters here, what to read,
    and 2 or 3 questions to check his understanding. Ordinary routes and CRUD
    need no pause.
11. **Study notes are Felipe's.** His answers to the study-pause questions
    are kept in his own words; Claude corrects and points out mistakes but
    never writes the note for him.
12. **A "Decisions" section in every PR**, split into: *Decided by Felipe*
    (the options on the table, the choice and why, faithful to what he
    said); *Proposed by Claude, approved*; *From review* (what was accepted
    and what was declined, with the reason). Never attribute to Felipe a
    decision he did not make.
13. **When a PR is done**, say what changed, how it was verified (including
    the test broken on purpose) and what can be explained in an interview.
14. **Conversation in Portuguese.** Code, commits and repository docs in
    English; the portfolio is bilingual.
15. **Session start:** check open PRs (`gh pr list`) and the recent
    `git log` before assuming the state of anything.

## Agents and skills

Use these; ask before using others.

| Agent | When |
|---|---|
| `Explore` | Search many files when only the conclusion matters. |
| `Plan` | Draft the plan for a larger change before presenting it. |
| `claude-code-guide` | Questions about Claude Code itself, the API or the Agent SDK. |
| `@claude` in a PR comment | Review on GitHub against the repo's `CLAUDE.md` (GitHub Action, see `github/claude.yml`). Felipe decides what to accept. |

| Skill | When |
|---|---|
| `code-review` | Review the diff before opening the PR. |
| `security-review` | PRs that touch auth, sessions, permissions or data across tenants. |
| `simplify` / `ponytail-review` | Cut complexity from the diff; `ponytail-audit` for a whole repo. |
| `run` | Start the app and see the change working, beyond the tests. |
| `init` | First `CLAUDE.md` of a new repository (then trim it by the rules above). |
| `claude-api` | Projects with an LLM (RAG, agents, evals). |
| `frontend-design` / `impeccable` / `unslop` | Portfolio pages. |
| `dataviz` | Charts (latency, recall, metrics) in a README or the portfolio. |
| `pdf` / `docx` | CV in PDF or Word. |
