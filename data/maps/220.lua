local map = ...
local game = map:get_game()
--local lines = {}

-- experimenting with creating scrolling credits

--function map:on_started()
--  local start = sol.text_surface.create({
--    horizontal_alignment = "center",
--    font = "bom",
--    font_size = 14,
--    text = "CREDITS"
--  })
--  lines[#lines+1] = start
--
--  sol.timer.start(1000, add_line)
--end