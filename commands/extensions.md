Read the full workflow file at `.agent/workflows/extensions.md` and follow it strictly for the task: $ARGUMENTS

Key steps:
1. Detect extension type from context:
   - Has `manifest.json` (Chrome MV3) → §1 Chrome Extension Flow
   - Has `package.json` + `engines.vscode` → §2 IDE Extension Flow
   - Keywords: "facebook/group/post/approve/blacklist" → §1
   - Keywords: "vscode/ide/antigravity/vsix" → §2
   - Keywords: "bug/lỗi/fix" → §3 Debug Mode
2. Run Pre-flight: read chrome-extension + facebook-dom + aka-design-system skills
3. Execute the appropriate section
