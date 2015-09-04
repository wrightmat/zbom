local map = ...
local t
local i = 1
local camera_x, camera_y, camera_width, camera_height = map:get_camera_position()

local credits = {
  { line = "Thank you for playing!" },
  { line = "" },
  { line = "CREDITS" },
  { line = "" },
  { line = "Solarus Engine: created by Christopho" },
  { line = "" },
  { line = "Maps:" },
  { line = "ZeldaHistorian" },
  { line = "Renkineko (Lost Woods)" },
}

function map:on_started(destination)
  map:get_game():set_hud_enabled(false)
  map:get_hero():set_position(-100, -100)
  map:get_hero():freeze()

  self:add_credit()
  sol.timer.start(self, 4000, function()
    i = i + 1
    self:add_credit()
    return true
  end)
end

function map:add_credit()
  t[i] = sol.text_surface.create()
  t[i]:set_text(credits[i].line)
print(t[i]:get_text())
  local m = sol.movement.create("path")
  m:set_xy(camera_height, camera_width/2)
  m:set_path({2,2})
  m:set_loop(true)
  m:set_speed(32)
  m:start(t[i])
end

function map:on_draw(dst_surface)
  --dst_surface:fill_color({0,0,0})
  for i = 1, #credits do
    local text_x, text_y = t[i]:get_xy()
    --if text_x < 100 then t[i]:fade_out() end
    t[i]:draw(text_x, text_y, dst_surface)
  end
end