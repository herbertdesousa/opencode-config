---
description: Run a pragmatic senior-level PR review. Optionally pass a PR number.
agent: pr-review
subtask: true
---

Review this pull request following your review guidelines.

Start by fetching the PR description and metadata from GitHub:

- If a PR number was provided, run `gh pr view $ARGUMENTS` and `gh pr checks $ARGUMENTS`
- Otherwise run `gh pr view` to infer from the current branch

Then gather git context:

- `git log main...HEAD --oneline` (adjust base branch if needed)
- `git diff main...HEAD` for the full diff

Use the PR description as the primary source of intent. Cross-reference it with the actual diff.

If you find blockers, suggestions, or questions that map to changed lines, create separate inline GitHub review comments for each one by invoking `~/.config/opencode/scripts/pr-comment.sh`.

- Anchor every comment to the exact affected diff line(s)
- Include the relevant file path and changed line number(s) in the comment text when useful
- Call the script with: `<PR_NUMBER> <FILE_PATH> <LINE_NUMBER> <COMMENT_BODY> <REPO_WITH_OWNER>`
- Derive `PR_NUMBER` from the argument or `gh pr view --json number`
- Derive `REPO_WITH_OWNER` from `gh repo view --json nameWithOwner`
- Use the script to submit comments instead of `gh` review submission commands
