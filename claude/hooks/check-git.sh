#!/usr/bin/env bash
#
# Claude Code hook to restrict git operations.
# Blocks: switching branches (but allows creating new branches with -b/-B)
# Note: git push is blocked via deny list in settings.json
#

# Read stdin
input=$(cat)

# Extract command from JSON - handles the structure {"tool_input": {"command": "..."}}
command=$(echo "$input" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

# Block switching branches (but allow checkout -b/-B for new branches)
if echo "$command" | grep -qE '\bgit[[:space:]]+(checkout|switch)\b'; then
    if ! echo "$command" | grep -qE '\-[bB]\b'; then
        echo '{"decision": "block", "reason": "Switching branches is not allowed"}'
        exit 0
    fi
fi

echo '{"decision": "approve"}'
