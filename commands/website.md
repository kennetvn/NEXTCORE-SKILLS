Read the full workflow file at `.agent/workflows/website.md` and follow it strictly for the task: $ARGUMENTS

Key steps:
1. Detect project (example-homestay.com vs api.example.com) from context
2. Classify task size (XS/S/M/L) to determine if PRE-FLIGHT is required
3. Auto-detect flow: start/dev → §1, bug/fix → §3, deploy → §4, backup/db → §5, default → §2
4. Execute the appropriate section from the workflow
