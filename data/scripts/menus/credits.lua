local game = ...
local credits_menu = {}  -- The credits menu.
local text_width, text_height = 0

function game:on_credits_started()
  sol.menu.start(game:get_map(), credits_menu)
end

function credits_menu:on_started()
  sol.audio.play_music("credits", false)
  local map = game:get_map()
  local hero = game:get_hero()
  self.heading = sol.text_surface.create{
    font = "lttp",
    font_size = "20",
    horizontal_alignment = "center",
    vertical_alignment = "top"
  }
  self.line = sol.text_surface.create{
    font = "lttp",
    font_size = "14",
    horizontal_alignment = "center",
    vertical_alignment = "top"
  }

  map:get_game().hud:set_enabled(false)
  map:get_hero():set_position(-100, -100)
  map:get_hero():freeze()

  function show_group(index)
    local i = 0
    self.group = sol.surface.create(320,240)
    local text_group = sol.language.get_string("credits."..index)
    for text_lines in string.gmatch(text_group, "[^$]+") do
      i = i + 1
      if i == 1 then
        self.heading:set_text(text_lines)
        self.heading:draw(self.group, 150, 0)
        text_width, text_height = self.heading:get_size()
      else
        self.line:set_text(text_lines)
        self.line:draw(self.group, 150, 0+(i*15))
        tw, th = self.line:get_size()
        if tw > text_width then text_width = tw end
        if th > text_height then text_height = th end
      end
    end

    self.group:fade_in(50, function()
      sol.timer.start(map, 15000, function()
        self.group:fade_out(50, function()
          return true
        end)
      end)
    end)
  end

  function end_credits()
    -- Credits over. Now what?
    game:start_dialog("_credits", function(answer)
      if answer == 1 then
        -- Save and continue.
        game:save()
        game:start()
      else
        -- Quit (don't save).
        sol.main.reset()
      end
    end)
  end

  sol.timer.start(map, 100, function()
    show_group(1)
    sol.timer.start(map, 10000, function()
      show_group(2)
      sol.timer.start(map, 10000, function()
        show_group(3)
        sol.timer.start(map, 10000, function()
          show_group(4)
          sol.timer.start(map, 10000, function()
            show_group(5)
            sol.timer.start(map, 10000, function()
              show_group(6)
              sol.timer.start(map, 10000, function()
                show_group(7)
                sol.timer.start(map, 10000, function()
                  show_group(8)
                  sol.timer.start(map, 6000, function() end_credits() end)
                end)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

function credits_menu:on_finished()
  sol.timer.stop_all(self)
end

function credits_menu:on_draw(dst_surface)
  local camera_x, camera_y, camera_width, camera_height = game:get_map():get_camera_position()
  local credits_background = sol.surface.create("menus/credits_background")
  credits_background:draw(dst_surface)

  if self.group ~= nil then
    self.group:draw(dst_surface, (camera_width/2)-150, (camera_height/2)-80)
  end
end