local wezterm = require 'wezterm'
local config = wezterm.config_builder and wezterm.config_builder() or {}

-- カラースキーム
config.color_scheme = 'Kanagawa (Gogh)'

-- タブバー設定
config.tab_bar_at_bottom = true
config.tab_max_width = 32

-- タブやウィンドウ装飾の UI 用フォント設定
config.window_frame = {
  font = wezterm.font_with_fallback({
    "JetBrains Mono",
    "Noto Sans",
  }),
  font_size = 18.0,
}
config.font_size = 18.0

--- ここから透過設定とキーバインドの追加 ---

-- 初期状態（不透明）
config.window_background_opacity = 1.0

config.keys = {
  -- Cmd + [ で背景を透過 (不透明度 0.7)
  {
    key = '[',
    mods = 'CMD',
    action = wezterm.action_callback(function(window, pane)
      window:set_config_overrides({
        window_background_opacity = 0.7,
        -- 透過時に文字を見やすくするため、Mac標準のブラーをかける場合は以下を有効に
        -- macos_window_background_blur = 20, 
      })
    end),
  },
  -- Cmd + ] で背景を元に戻す (不透明度 1.0)
  {
    key = ']',
    mods = 'CMD',
    action = wezterm.action_callback(function(window, pane)
      window:set_config_overrides({
        window_background_opacity = 1.0,
      })
    end),
  },
}

return config
