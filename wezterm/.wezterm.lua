local wezterm = require "wezterm"
local config = wezterm.config_builder()

local is_windows = wezterm.target_triple:find("windows") ~= nil

if is_windows then
  config.default_prog = { "pwsh.exe", "-NoLogo" }
end

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 12

config.window_background_opacity = 0.95

config.window_padding = {
  left = 8,
  right = 8,
  top = 8,
  bottom = 8,
}

config.default_cursor_style = "BlinkingBar"
config.scrollback_lines = 50000
config.enable_scroll_bar = true

-- Custom purple color scheme (matches the oh-my-posh prompt palette)
config.colors = {
  foreground = "#E0D6F5",
  background = "#05030A",
  cursor_bg = "#C792EA",
  cursor_border = "#C792EA",
  cursor_fg = "#1A1025",
  selection_bg = "#4B2E83",
  selection_fg = "#E0D6F5",
  scrollbar_thumb = "#5C3D7A",
  split = "#4B2E83",

  ansi = {
    "#241733", -- black
    "#E0A6E8", -- red
    "#7FDBAA", -- green
    "#F5D76E", -- yellow
    "#7C7CE0", -- blue
    "#C792EA", -- magenta
    "#63D9E0", -- cyan
    "#E0D6F5", -- white
  },
  brights = {
    "#4B3B5C", -- bright black
    "#F5B8E8", -- bright red
    "#9CFFC7", -- bright green
    "#FFEB99", -- bright yellow
    "#A6A6FF", -- bright blue
    "#E0A6E8", -- bright magenta
    "#9CF0F5", -- bright cyan
    "#FFFFFF", -- bright white
  },
}

config.window_decorations = "TITLE | RESIZE"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 20

-- Tab bar colors (matches the purple color scheme above)
config.colors.tab_bar = {
  background = "#05030A",
  active_tab = {
    bg_color = "#4B2E83",
    fg_color = "#F5EBFF",
    intensity = "Bold",
  },
  inactive_tab = {
    bg_color = "#05030A",
    fg_color = "#8A6FA8",
  },
  inactive_tab_hover = {
    bg_color = "#2E1D47",
    fg_color = "#C792EA",
    italic = true,
  },
  new_tab = {
    bg_color = "#05030A",
    fg_color = "#8A6FA8",
  },
  new_tab_hover = {
    bg_color = "#2E1D47",
    fg_color = "#C792EA",
  },
}

-- Leader key (tmux-style prefix): Ctrl+A, then release and press the next key within 1s
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.initial_cols = 110
config.initial_rows = 30

-- Preserve long lines when copying (don't insert newlines at wrapping points)
config.canonicalize_pasted_newlines = "None"

config.mouse_bindings = {
  -- Ctrl+Click to open links
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  -- Restore default: click selects text
  {
    event = { Down = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = wezterm.action.SelectTextAtMouseCursor "Cell",
  },
  {
    event = { Drag = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = wezterm.action.ExtendSelectionToMouseCursor "Cell",
  },
  -- Double-click selects word
  {
    event = { Down = { streak = 2, button = "Left" } },
    mods = "NONE",
    action = wezterm.action.SelectTextAtMouseCursor "Word",
  },
  -- Triple-click selects line
  {
    event = { Down = { streak = 3, button = "Left" } },
    mods = "NONE",
    action = wezterm.action.SelectTextAtMouseCursor "Line",
  },
  -- Right-click paste
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = wezterm.action.PasteFrom "Clipboard",
  },
}

wezterm.on("update-right-status", function(window)
  local date = wezterm.strftime("%H:%M")
  window:set_right_status("  [" .. window:active_workspace() .. "]  " .. date .. "  ")
end)

-- Show "folder git:(branch)" in tab titles, like the shell prompt
local function git_branch(cwd_path)
  local dir = cwd_path
  for _ = 1, 8 do
    if dir == nil or dir == "" then
      return nil
    end
    local f = io.open(dir .. "/.git/HEAD", "r")
    if f then
      local content = f:read("*l")
      f:close()
      return content and content:match("ref: refs/heads/(.+)") or content
    end
    local parent = dir:match("^(.*)[\\/][^\\/]+$")
    if parent == dir then
      return nil
    end
    dir = parent
  end
  return nil
end

wezterm.on("format-tab-title", function(tab)
  local title = tab.tab_title
  if title and #title > 0 then
    return title
  end

  local cwd = tab.active_pane.current_working_dir
  local path = cwd and cwd.file_path
  if not path then
    local process = tab.active_pane.foreground_process_name
    local name = process and process:match("([^\\/]+)%.?e?x?e?$") or tab.active_pane.title
    return "  " .. name .. "  "
  end

  path = path:gsub("[\\/]$", "")
  local folder = path:match("([^\\/]+)$") or path

  local branch = git_branch(path)
  if branch then
    return "  " .. folder .. " git:(" .. branch .. ")  "
  end
  return "  " .. folder .. "  "
end)

config.keys = {
  { key = "F11", action = wezterm.action.ToggleFullScreen },

  { key = "s", mods = "ALT", action = wezterm.action.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" } },
  { key = "n", mods = "ALT", action = wezterm.action.PromptInputLine {
      description = "Enter workspace name",
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= "" then
          window:perform_action(wezterm.action.SwitchToWorkspace { name = line }, pane)
        end
      end),
    },
  },
  { key = "W", mods = "ALT|SHIFT", action = wezterm.action.PromptInputLine {
      description = "Rename workspace to:",
      action = wezterm.action_callback(function(window, _, line)
        if line and line ~= "" then
          wezterm.mux.rename_workspace(window:active_workspace(), line)
        end
      end),
    },
  },

  {
    key = "F2",
    action = wezterm.action.PromptInputLine {
      description = "Enter new tab title",
      action = wezterm.action_callback(function(window, _, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  { key = "UpArrow",    mods = "CTRL|SHIFT", action = wezterm.action.ScrollByPage(-0.5) },
  { key = "DownArrow",  mods = "CTRL|SHIFT", action = wezterm.action.ScrollByPage(0.5) },
  { key = "LeftArrow",  mods = "CTRL|SHIFT", action = wezterm.action.MoveTabRelative(-1) },
  { key = "RightArrow", mods = "CTRL|SHIFT", action = wezterm.action.MoveTabRelative(1) },

  { key = "1", mods = "ALT", action = wezterm.action.ActivateTab(0) },
  { key = "2", mods = "ALT", action = wezterm.action.ActivateTab(1) },
  { key = "3", mods = "ALT", action = wezterm.action.ActivateTab(2) },
  { key = "4", mods = "ALT", action = wezterm.action.ActivateTab(3) },
  { key = "5", mods = "ALT", action = wezterm.action.ActivateTab(4) },
  { key = "6", mods = "ALT", action = wezterm.action.ActivateTab(5) },
  { key = "7", mods = "ALT", action = wezterm.action.ActivateTab(6) },
  { key = "8", mods = "ALT", action = wezterm.action.ActivateTab(7) },
  { key = "9", mods = "ALT", action = wezterm.action.ActivateTab(-1) },

  -- Panes: direct shortcuts, no leader needed (like iTerm's Cmd+D / Cmd+Shift+D)
  { key = "d", mods = "ALT", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "D", mods = "ALT|SHIFT", action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },

  { key = "h", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection "Left" },
  { key = "j", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection "Down" },
  { key = "k", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection "Up" },
  { key = "l", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection "Right" },

  { key = "LeftArrow",  mods = "LEADER", action = wezterm.action.AdjustPaneSize { "Left", 5 } },
  { key = "RightArrow", mods = "LEADER", action = wezterm.action.AdjustPaneSize { "Right", 5 } },
  { key = "UpArrow",    mods = "LEADER", action = wezterm.action.AdjustPaneSize { "Up", 5 } },
  { key = "DownArrow",  mods = "LEADER", action = wezterm.action.AdjustPaneSize { "Down", 5 } },

  { key = "z", mods = "LEADER", action = wezterm.action.TogglePaneZoomState },
  { key = "x", mods = "LEADER", action = wezterm.action.CloseCurrentPane { confirm = true } },
  { key = "w", mods = "ALT", action = wezterm.action.CloseCurrentPane { confirm = true } },

  -- Copy mode and quick select (grab paths/urls/hashes without the mouse)
  { key = "[", mods = "LEADER", action = wezterm.action.ActivateCopyMode },
  { key = "Space", mods = "LEADER", action = wezterm.action.QuickSelect },
}

return config