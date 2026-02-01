#!/usr/bin/env python3
"""
Claude Code hook to restrict git operations.
Blocks: git push, switching branches
Allows: all other git operations, creating new branches
"""
import json
import sys
import re

input_data = json.load(sys.stdin)
command = input_data.get("tool_input", {}).get("command", "")

# Block git push
if re.search(r'\bgit\s+push\b', command):
    print(json.dumps({"decision": "block", "reason": "git push is not allowed"}))
    sys.exit(0)

# Block switching branches (but allow checkout -b/-B for new branches)
if re.search(r'\bgit\s+(checkout|switch)\b', command):
    if not re.search(r'-[bB]\b', command):
        print(json.dumps({"decision": "block", "reason": "Switching branches is not allowed"}))
        sys.exit(0)

print(json.dumps({"decision": "approve"}))
