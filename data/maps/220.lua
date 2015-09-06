local map = ...
local i = 0
local j = 0
local line = {}
local camera_x, camera_y, camera_width, camera_height = map:get_camera_position()
local surface = sol.surface.create(camera_width, camera_height)
local m = sol.movement.create("target")

local credits = { "Thank you for playing!" , "" , "CREDITS", "" ,
  "Solarus Engine: created by Christopho" , "" ,
  "Maps:", "ZeldaHistorian", "Renkineko (Lost Woods)"
}

function map:start_line(text_line)
  line[i] = sol.text_surface.create()
  line[i]:set_text(text_line)
print(line[i]:get_text())
  m:set_xy(camera_height, camera_width/2)
  m:set_target(0, camera_width/2) -- Move from the bottom to the top of the screen
  m:set_speed(16)

  function m:on_position_changed()
    local text_x, text_y = self:get_xy()
    local text_width, text_height = line[i]:get_size()
    line[i]:draw_region(0, 0, text_width, text_height, surface, text_x, text_y)
    if text_x < 50 then
      line[i]:fade_out() -- Fade out line and destroy movement when at top of screen
      sol.timer.start(self, 1000, function() self:stop() end)
    end
  end

  m:start(line[i])
end

function map:on_started(destination)
  map:get_game():set_hud_enabled(false)
  map:get_hero():set_position(-100, -100)
  map:get_hero():freeze()
  sol.timer.start(self, 4000, function()
    i = i + 1
    self:start_line(credits[i])
    return true
  end)
end

function map:on_draw(dst_surface)
  surface:draw(dst_surface)
end