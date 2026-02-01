#!/usr/bin/env bash
#
# Claude Code hook to restrict git operations.
# Blocks: git push, switching branches
# Allows: all other git operations, creating new branches
#

# Read stdin
input=$(cat)

# Extract command from JSON - handles the structure {"tool_input": {"command": "..."}}
# Use grep to find the command field and extract its value
command=$(echo "$input" | grep -o '"command"[[:space:]]*:[[:space:]]*"[^"]*"' | sed 's/"command"[[:space:]]*:[[:space:]]*"//' | sed 's/"$//')

# Block git push
if echo "$command" | grep -qE '\bgit[[:space:]]+push\b'; then
    echo '{"decision": "block", "reason": "git push is not allowed"}'
    exit 0
fi

# Block switching branches (but allow checkout -b/-B for new branches)
if echo "$command" | grep -qE '\bgit[[:space:]]+(checkout|switch)\b'; then
    if ! echo "$command" | grep -qE '\-[bB]\b'; then
        echo '{"decision": "block", "reason": "Switching branches is not allowed"}'
        exit 0
    fi
fi

echo '{"decision": "approve"}'
