local map = ...
local game = map:get_game()

----------------------------------------------
-- Outside World C5 (Snowpeak/Caverns Entr) --
----------------------------------------------

local torch_overlay = nil
local anouki_talk = 0

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  random_walk(npc_anouki_3)

  if game:get_value("b1150") and game:get_value("i1910") < 6 then
    torch_1:get_sprite():set_animation("lit")
    sol.timer.start(1000, function()
      hero:freeze()
      torch_overlay = sol.surface.create("entities/dark.png")
      torch_overlay:fade_in(50)
      game:start_dialog("ordona.6.snowpeak", game:get_player_name(), function()
        torch_overlay:fade_out(50)
        sol.timer.start(2000, function() torch_overlay = nil end)
        hero:unfreeze()
        game:add_max_stamina(100)
        game:set_stamina(game:get_max_stamina())
        torch_1:get_sprite():set_animation("unlit")
        game:set_value("i1910", 6)
      end)
    end)
  end
end

function map:on_draw(dst_surface)
  -- Show torch overlay for Ordona dialog
  if game:get_time_of_day() ~= "night" and torch_overlay ~= nil then
    local screen_width, screen_height = dst_surface:get_size()
    local cx, cy = map:get_camera_position()
    local tx, ty = torch_1:get_center_position()
    local x = 320 - tx + cx
    local y = 240 - ty + cy
    torch_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
  end
end

function npc_anouki_3:on_interaction()
  game:set_dialog_style("default")
  if not game:get_value("b1117") then
    -- If at least Mausoleum not completed, suggest going there instead
    game:start_dialog("anouki_3.0.snowpeak", function()
      game:start_dialog("anouki_3.1.not_ready")
    end)
  else
    game:start_dialog("anouki_3."..anouki_talk..".snowpeak")
    if anouki_talk == 0 then anouki_talk = 1 else anouki_talk = 0 end
  end
end