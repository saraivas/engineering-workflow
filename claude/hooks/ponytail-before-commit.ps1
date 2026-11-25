# Claude Code PreToolUse hook. Before Claude runs `git commit` in a repo inside
# the workspace, it reminds Claude to run the over-engineering review on the
# staged diff (rule 9 of claude/CLAUDE.md). Outside the workspace it does nothing.
# It is a reminder, not a lock: it adds context and lets the commit run.
#
# The workspace is the folder that holds this repository
# (<workspace>/engineering-workflow/claude/hooks/this-file).
$workspace = (Resolve-Path "$PSScriptRoot\..\..\..").Path
$event = [Console]::In.ReadToEnd() | ConvertFrom-Json
if (-not ($event.cwd -like "$workspace*")) { exit 0 }

$msg = 'Before this commit (rule 9 of claude/CLAUDE.md): invoke the ponytail-review skill on the staged diff (git diff --cached); a hand-written review does not count. Apply the cuts, run the tests again and note in the PR what was cut. If the skill already ran on this same diff, go ahead.'
@{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; additionalContext = $msg } } | ConvertTo-Json -Compress
