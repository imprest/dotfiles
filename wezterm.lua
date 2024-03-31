local wezterm = require("wezterm")
local act = wezterm.action
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

local mykeys = {}
for i = 1, 8 do
	-- CTRL+ALT + number to activate that tab
	table.insert(mykeys, {
		key = tostring(i),
		mods = "CTRL|ALT",
		action = act({ ActivateTab = i - 1 }),
	})
end

table.insert(mykeys, { key = "c", mods = "ALT", action = act.ActivateCopyMode })
table.insert(mykeys, { key = "q", mods = "ALT", action = act.QuickSelect })
-- table.insert(mykeys, { key = "s", mods = "ALT", action = act.Search { CaseSensitiveString = '' } })
table.insert(mykeys, { key = "f", mods = "ALT", action = "ToggleFullScreen" })
table.insert(mykeys, { key = "F11", mods = "", action = "ToggleFullScreen" })
table.insert(mykeys, { key = "n", mods = "ALT", action = act({ SpawnTab = "CurrentPaneDomain" }) })
table.insert(mykeys, { key = "v", mods = "ALT", action = act({ SplitVertical = { domain = "CurrentPaneDomain" } }) })
table.insert(mykeys, { key = "s", mods = "ALT", action = act({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) })
table.insert(mykeys, { key = "x", mods = "ALT", action = act({ CloseCurrentPane = { confirm = false } }) })
table.insert(mykeys, { key = "h", mods = "ALT", action = act({ ActivatePaneDirection = "Left" }) })
table.insert(mykeys, { key = "j", mods = "ALT", action = act({ ActivatePaneDirection = "Down" }) })
table.insert(mykeys, { key = "k", mods = "ALT", action = act({ ActivatePaneDirection = "Up" }) })
table.insert(mykeys, { key = "l", mods = "ALT", action = act({ ActivatePaneDirection = "Right" }) })
table.insert(mykeys, { key = "h", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Left", 1 }) })
table.insert(mykeys, { key = "j", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Down", 1 }) })
table.insert(mykeys, { key = "k", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Up", 1 }) })
table.insert(mykeys, { key = "l", mods = "CTRL|ALT", action = act.AdjustPaneSize({ "Right", 1 }) })

-- config.line_height = 1.1
config.font = wezterm.font({
	family = "Fira Code",
	weight = "Medium",
	stretch = "Expanded",
	harfbuzz_features = {
		"calt=1",
		"clig=1",
		"liga=1",
	},
})
config.bold_brightens_ansi_colors = "BrightOnly"
config.freetype_load_target = "Light"
config.font_size = 10.49
config.anti_alias_custom_block_glyphs = false
config.warn_about_missing_glyphs = false
config.default_cursor_style = "SteadyBar"
config.animation_fps = 1
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.force_reverse_video_cursor = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"
config.initial_cols = 130
config.initial_rows = 38
config.window_background_opacity = 0.95
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.audible_bell = "Disabled"
config.scrollback_lines = 10000
config.color_scheme = "Tokyo Night Moon"
config.exit_behavior = "Close"
config.front_end = "WebGpu"
config.keys = mykeys

return config
