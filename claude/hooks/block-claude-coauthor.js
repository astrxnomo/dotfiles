// PreToolUse hook (matcher: Bash) — enforces the "no Co-Authored-By: Claude"
// rule from CLAUDE.md deterministically, instead of relying on the model
// remembering it every time.
let input = "";
process.stdin.on("data", (chunk) => (input += chunk));
process.stdin.on("end", () => {
  let data;
  try {
    data = JSON.parse(input);
  } catch {
    process.exit(0);
  }

  const command = data?.tool_input?.command || "";
  if (/co-authored-by[^\n]*claude/i.test(command)) {
    console.log(
      JSON.stringify({
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "deny",
          permissionDecisionReason:
            "No agregar 'Co-Authored-By: Claude' en los commits (ver CLAUDE.md).",
        },
      }),
    );
  }
  process.exit(0);
});
