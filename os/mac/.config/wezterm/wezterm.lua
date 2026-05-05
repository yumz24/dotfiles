local wezterm = require 'wezterm'
local config = {} 

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.automatically_reload_config = true
config.color_scheme = 'Kanagawa (Gogh)'
config.default_cursor_style = "BlinkingBlock"
config.enable_scroll_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.window_frame = {
  font = wezterm.font_with_fallback({
    "JetBrains Mono",
    "Noto Sans",
  }),
  font_size = 18.0,
}
config.font_size = 18.0
config.hide_mouse_cursor_when_typing = true
config.animation_fps = 1

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

config.term = "wezterm"
config.front_end = "Software"

return config
