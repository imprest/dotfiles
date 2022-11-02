local wezterm = require 'wezterm'
local act = wezterm.action

local mykeys = {}
for i = 1, 8 do
  -- CTRL+ALT + number to activate that tab
  table.insert(mykeys, {
    key = tostring(i),
    mods = 'ALT',
    action = act.ActivateTab(i - 1),
  })
end

return {
  keys = mykeys,
  font = wezterm.font('JetBrainsMono', { weight = 'Bold', italic = false }),
  font_size = 9.0,
  force_reverse_video_cursor = true,
  harfbuzz_features = { "zero" },
  color_scheme = 'OneDark (base16)',
  use_fancy_tab_bar = false,
  hide_tab_bar_if_only_one_tab = true,
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  }
}
