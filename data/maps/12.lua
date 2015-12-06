local map = ...
local game = map:get_game()

----------------------------------------------------------------
-- Outside World G14 (Ordon Village) - Maze Race and Overlook --
----------------------------------------------------------------

if game:get_value("i1910")==nil then game:set_value("i1910", 0) end --Ordona
local torch_overlay = nil

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

local function are_all_torches_on()
 return torch_1 ~= nil
    and torch_1:get_sprite():get_animation() == "lit"
    and torch_2:get_sprite():get_animation() == "lit"
    and torch_3:get_sprite():get_animation() == "lit"
    and torch_4:get_sprite():get_animation() == "lit"
    and torch_5:get_sprite():get_animation() == "lit"
    and game:get_value("i1028") == 3
end

local function end_race_won()
  sol.timer.stop_all(map)
  game.race_timer:stop()
  game.race_timer = nil
  sol.audio.play_sound("secret")
  game:set_value("i1027", 3)
  game:set_value("i1028", 5)
  npc_tristan:get_sprite():set_direction(0)
  game:start_dialog("tristan.0.festival_won", game:get_player_name(), function()
    if game:get_value("i1027") < 4 then
      sol.timer.start(1000, function()
        hero:freeze()
        torch_overlay = sol.surface.create("entities/dark.png")
        torch_overlay:fade_in(50)
        hero:set_direction(0)
        game:start_dialog("ordona.0.festival", game:get_player_name(), function()
          torch_overlay:fade_out(50)
          sol.timer.start(2000, function()
            torch_overlay = nil
            torch_5:get_sprite():set_animation("unlit")
          end)
          hero:unfreeze()
          game:set_value("i1027", 4)
          game:set_value("i1910", game:get_value("i1910")+1)
          banner_4:set_enabled(false) -- Make it easier to exit the map.
          banner_5:set_enabled(false)
        end)
      end)
    end
  end)
end

function map:on_started(destination)
  if game:get_value("i1027") > 1 and game:get_value("i1027") < 4 then
    banner_1:set_enabled(true)
    banner_2:set_enabled(true)
    banner_3:set_enabled(true)
    banner_4:set_enabled(true)
    banner_5:set_enabled(true)
    banner_6:set_enabled(true)
    banner_7:set_enabled(true)
    banner_8:set_enabled(true)
    banner_9:set_enabled(true)
  elseif game:get_value("i1027") == 4 then
    npc_tristan:remove()
  elseif game:get_value("i1027") >= 5 then
    random_walk(npc_tristan)
    torch_1:remove(); wall_1:remove()
    torch_2:remove(); wall_2:remove()
    torch_3:remove(); wall_3:remove()
    torch_4:remove(); wall_4:remove()
    torch_5:remove(); wall_5:remove()
  end
end

function map:on_draw(dst_surface)
  -- Show torch overlay for Ordona dialog
  if game:get_time_of_day() ~= "night" and torch_overlay ~= nil then
    local screen_width, screen_height = dst_surface:get_size()
    local cx, cy = map:get_camera_position()
    local tx, ty = torch_5:get_center_position()
    local x = 320 - tx + cx
    local y = 240 - ty + cy
    torch_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
  end

  -- Show remaining timer time on screen
  if game.race_timer ~= nil then
    local timer_icon = sol.surface.create("hud/timer.png")
    local timer_time = math.floor(game.race_timer:get_remaining_time() / 1000)
    local timer_text = sol.text_surface.create{
      font = "white_digits",
      horizontal_alignment = "left",
      vertical_alignment = "top",
    }
    timer_icon:draw(dst_surface, 5, 55)
    timer_text:set_text(timer_time)
    timer_text:draw(dst_surface, 22, 58)
  end
end

function npc_tristan:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("i1068") >= 9 then
    game:start_dialog("tristan.3.castle_town")
  elseif game:get_value("i1068") >= 3 then
    game:start_dialog("tristan.2.desert")
  elseif game:get_value("i1027") >= 5 then
    game:start_dialog("tristan.1.faron")
  elseif game:get_value("i1028") == 5 then
    if game:has_item("shield") then
      game:start_dialog("tristan.0.festival_shield", game:get_player_name())
    else
      game:start_dialog("tristan.0.festival_won", game:get_player_name())
    end
  elseif game:get_value("i1028") > 0 and game:get_value("i1028") < 4 then
    game:start_dialog("tristan.0.festival_underway")
  elseif game:get_value("i1028") == 4 then
    game:start_dialog("tristan.0.festival_lost")
  elseif game:get_value("i1028") == 0 then
    game:start_dialog("tristan.0.festival_rules")
  end
end

function map:on_update()
  if are_all_torches_on() then end_race_won() end
end

function torch_1:on_interaction_item(lamp)
  torch_1:get_sprite():set_animation("lit")
end
function torch_2:on_interaction_item(lamp)
  torch_2:get_sprite():set_animation("lit")
end
function torch_3:on_interaction_item(lamp)
  torch_3:get_sprite():set_animation("lit")
end
function torch_4:on_interaction_item(lamp)
  torch_4:get_sprite():set_animation("lit")
end
function torch_5:on_interaction_item(lamp)
  torch_5:get_sprite():set_animation("lit")
end