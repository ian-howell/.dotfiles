---
description: Identify one small improvement opportunity (<200 lines) in the codebase
subtask: true
agent: plan
---

Survey the codebase in the current working directory. Read the directory structure, key config files, entry points, and a representative sample of source files to understand the tech stack and patterns in use.

Identify **one specific, concrete improvement** that is estimated to require fewer than 200 line changes. Evaluate candidates using this priority order:

1. **Correctness** — bugs, unsafe assumptions, missing null/error checks, incorrect logic
2. **Tests** — missing or inadequate test coverage for non-trivial logic
3. **Efficiency** — unnecessary allocations, redundant work, poor algorithmic choices in hot paths
4. **Maintainability** — duplicated logic, unclear naming, inconsistent patterns
5. **Style** — cosmetic issues (only if nothing higher-priority is found)

The improvement must be tied to concrete code you have actually read. Do not suggest speculative or architectural changes. Discard any candidate you cannot point to in the code. Exclude anything estimated to exceed 200 lines.

Additional constraints (if any): $ARGUMENTS

Return a structured recommendation with these sections:

**What**: the specific change and where it is (file, function, or line range)
**Why**: the concrete benefit, noting which priority tier it falls under
**Estimated size**: rough line count confirming it is under 200
