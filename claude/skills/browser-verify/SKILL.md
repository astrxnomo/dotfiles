---
name: browser-verify
description: Test a feature in a real browser with the Chrome DevTools MCP — navigate, interact, screenshot, and check console/network errors.
---

# Browser verify

Verify the feature in a real browser using the **Chrome DevTools MCP**
(`mcp__chrome-devtools__*`). It drives its own dedicated Chrome profile, so it
never touches the personal one; the first time a site needs a login, sign in
there once and it persists.

In Claude Code these tools may be deferred — load the ones you need in a single
`ToolSearch` call, e.g.:

```
select:mcp__chrome-devtools__new_page,mcp__chrome-devtools__navigate_page,mcp__chrome-devtools__take_snapshot,mcp__chrome-devtools__take_screenshot,mcp__chrome-devtools__click,mcp__chrome-devtools__fill,mcp__chrome-devtools__list_console_messages
```

## Steps

1. **Serve the app** on `http://localhost:<port>` (start the dev server if it
   isn't running).
2. **Open a page** with `new_page` (or `list_pages` / `select_page` to reuse
   one), then `navigate_page` to the URL under test.
3. **Read the page** with `take_snapshot` — it returns the accessibility tree
   with `uid`s, which is what `click`, `fill`, `fill_form`, and `hover` take as
   their target. Use `take_screenshot` when the visual result is the point.
4. **Drive the flow** the user would: click, fill, `wait_for` the expected text,
   `navigate_page_history` to go back.
5. **Check for errors** with `list_console_messages` and, when the feature hits
   an API, `list_network_requests` / `get_network_request` for failed calls.
6. **Report** what you saw with evidence — a screenshot and the actual console
   or network output, not just "it works".

## Notes

- Interactions need a fresh `take_snapshot` after the DOM changes; a stale `uid`
  fails.
- Prefer `http://localhost` over `file://` — modules, fetch, and cookies behave
  differently on `file://`.
- Don't trigger `alert`/`confirm` dialogs blindly; if one appears, resolve it
  with `handle_dialog`.
- If the same action fails 2–3 times, stop and tell the user what you saw
  instead of looping.
