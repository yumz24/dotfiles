local wezterm = require 'wezterm'
local config = {}

-- startup zsh of MSYS2
-- config.default_prog = { 'C:/msys64/usr/bin/zsh.exe', '-l' }

-- env settings
-- config.set_environment_variables = {
--   MSYSTEM = 'MINGW64',
--   MSYS2_PATH_TYPE = 'inherit',
--   HOME = wezterm.home_dir,
-- }

if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- WSL Ubuntuをデフォルトドメインとして設定
config.default_domain = 'WSL:Ubuntu'

config.leader = { key = 'k', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- Copy
  { key = 'c', mods = 'ALT', action = wezterm.action.CopyTo 'Clipboard' },
  -- Paste
  { key = 'v', mods = 'ALT', action = wezterm.action.PasteFrom 'Clipboard' },
  -- 前のプロンプトへ
  { key = 'UpArrow', mods = 'SHIFT|CTRL', action = wezterm.action.ScrollToPrompt(-1) },
  -- 次のプロンプトへ  
  { key = 'DownArrow', mods = 'SHIFT|CTRL', action = wezterm.action.ScrollToPrompt(1) },
  {
      key = 'c',
      mods = 'LEADER',
      action = wezterm.action.SpawnCommandInNewTab { domain = { DomainName = 'local' }, args = { 'C:/msys64/usr/bin/zsh.exe', '-l' } },
  },
   -- Leader + " で水平分割
  {
    key = '"',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Leader + % で垂直分割
  {
    key = '%',
    mods = 'LEADER|SHIFT',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'x',
    mods = 'LEADER',
    action = wezterm.action.CloseCurrentPane { confirm = false },
  },

  -- Leader + h/j/k/l でペイン移動
  { key = 'h', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Left', },
  { key = 'j', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Down', },
  { key = 'k', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Up', },
  { key = 'l', mods = 'LEADER', action = wezterm.action.ActivatePaneDirection 'Right', },

  { key = '1', mods = 'LEADER', action = wezterm.action.ActivateTab(0), },
  { key = '2', mods = 'LEADER', action = wezterm.action.ActivateTab(1), },
  { key = '3', mods = 'LEADER', action = wezterm.action.ActivateTab(2), },
  { key = '4', mods = 'LEADER', action = wezterm.action.ActivateTab(3), },
  { key = '5', mods = 'LEADER', action = wezterm.action.ActivateTab(4), },
  { key = '6', mods = 'LEADER', action = wezterm.action.ActivateTab(5), },
  { key = '7', mods = 'LEADER', action = wezterm.action.ActivateTab(6), },
  { key = '8', mods = 'LEADER', action = wezterm.action.ActivateTab(7), },
  { key = '9', mods = 'LEADER', action = wezterm.action.ActivateTab(8), },
}

return config
