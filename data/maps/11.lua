local map = ...
local game = map:get_game()

---------------------------------------------------------------------------
-- Outside World F14 (Ordon Village) - Ranch, Fishing Pond and Maze Race --
---------------------------------------------------------------------------

if game:get_value("i1906")==nil then game:set_value("i1906", 0) end --Tern

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

local function follow_hero(npc)
  local hero_x, hero_y, hero_layer = hero:get_position()
  local npc_x, npc_y, npc_layer = npc:get_position()
  local distance_hero = math.abs((hero_x+hero_y)-(npc_x+npc_y))
  local m = sol.movement.create("target")
  if distance_hero > 1000 then
    m:set_speed(64)
  elseif distance_hero < 20 then
    m:set_speed(32)
  else
    m:set_speed(48)
  end
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

local function are_all_torches_on()
  return torch_1 ~= nil
    and torch_1:get_sprite():get_animation() == "lit"
    and torch_2:get_sprite():get_animation() == "lit"
    and torch_3:get_sprite():get_animation() == "lit"
end

function end_race_lost()
  sol.audio.play_sound("wrong")
  game:set_value("i1028", 4);
  torch_1:get_sprite():set_animation("unlit")
  torch_2:get_sprite():set_animation("unlit")
  torch_3:get_sprite():set_animation("unlit")
end

function map:on_started(destination)
  random_walk(goat_1)
  random_walk(goat_2)
  random_walk(goat_3)
  random_walk(goat_4)
  random_walk(goat_5)
  -- if the festival isn't over, make sure banners, booths and NPCs are outside
  if game:get_value("i1027") < 5 then
    banner_1:set_enabled(true)
    banner_2:set_enabled(true)
    banner_3:set_enabled(true)
    banner_4:set_enabled(true)
    banner_5:set_enabled(true)
    booth_1:set_enabled(true)
  else
    random_walk(npc_tern)
    torch_2:remove()
    torch_3:remove()
  end
  if game:get_value("i1027") < 3 then
    if game:get_value("i1028") < 1 then
      local m = sol.movement.create("straight")
      m:set_ignore_obstacles(true)
      m:set_angle(math.pi / 2)
      m:set_speed(48)
      m:start(npc_francis)
      local m2 = sol.movement.create("straight")
      m2:set_ignore_obstacles(true)
      m2:set_angle(math.pi / 2)
      m2:set_speed(48)
      m2:start(npc_jarred)
      sol.timer.start(2000, function()
        m:stop()
        m2:stop()
      end)
    else
      npc_jarred:set_position(720, 992)
      npc_francis:set_position(656, 992)
      random_walk(npc_jarred)
      random_walk(npc_francis)
    end
  elseif game:get_value("i1027") <= 3 or game:get_value("i1027") > 4 then
    npc_tristan:remove()
    npc_jarred:remove()
    npc_francis:remove()
  elseif game:get_value("i1027") == 4 then
    if not game:has_item("shield") then
      npc_tristan:remove()
    else
      random_walk(npc_tristan)
    end
    npc_jarred:remove()
    npc_francis:remove()
  end
  if game:get_value("i1028") == 3 then
    torch_1:get_sprite():set_animation("lit")
    torch_2:get_sprite():set_animation("lit")
    torch_3:get_sprite():set_animation("lit")
  end
end

function sensor_festival_dialog:on_activated()
  if game:get_value("i1027") < 3 and game:get_value("i1028") == 0 and hero:get_direction() == 1 then
    npc_tristan:get_sprite():set_animation("pose1")
    game:start_dialog("tristan.0.festival", game:get_player_name(), function()
      local m = sol.movement.create("jump")
      sol.audio.play_sound("jump")
      m:set_direction8(2) --face up
      m:set_distance(8)
      m:start(npc_francis)
      sol.timer.start(400, function()
        game:start_dialog("francis.1.festival", function()
          npc_tristan:get_sprite():set_animation("pose2")
          game:start_dialog("tristan.0.festival_response", game:get_player_name(), function()
            game:start_dialog("francis.1.festival_race", function(answer)
              if answer == 1 then
                if game:has_item("lamp") then
                  game:start_dialog("tristan.0.festival_rules", function()
		    game:set_value("i1028", 1)
		    random_walk(npc_jarred)
		    random_walk(npc_francis)
                  end)
                else
                  game:start_dialog("tristan.0.festival_lamp")
                end
              else
                game:start_dialog("tristan.0.festival_no")
              end
            end)
          end)
        end)
      end)
    end)
  end
end

function sensor_start_race:on_activated()
  if hero:get_direction() == 1 then
    if game:get_value("i1028") <= 1 or game:get_value("i1028") == 4 then
      game:set_value("i1028", 2)
      race_timer = sol.timer.start(game, 140000, end_race_lost)
      race_timer:set_with_sound(true)
    end
  end
end

function sensor_ordona_speak:on_activated()
  -- you've finished everything in Ordon - Ordona directs you to Faron
  if game:has_item("sword") and game:get_value("i1027") < 6 then
    sol.timer.start(1500,function()
      torch_1:get_sprite():set_animation("lit")
    end)
    sol.timer.start(2500, function()
      hero:freeze()
      torch_overlay = sol.surface.create("entities/dark.png")
      torch_overlay:fade_in(50)
      game:set_value("i1027", 5)
      hero:set_direction(0)
      game:start_dialog("ordona.1.village", game:get_player_name(), function()
        torch_overlay:fade_out(50)
        hero:unfreeze()
        game:set_value("i1027", 6)
        sol.timer.start(10000, function()
          torch_1:get_sprite():set_animation("lit")
        end)
      end)
    end)
  end
end

function npc_tern:on_interaction()
  if game:get_value("i1027") <= 5 then
    game:start_dialog("tern.0.festival")
  else
    game:start_dialog("tern.1.ranch")
  end
end

function npc_tristan:on_interaction()
  if game:get_value("i1028") <= 1 then
    game:start_dialog("tristan.0.festival_question", function(answer)
      if answer == 1 then
        if game:has_item("lamp") then
          game:start_dialog("tristan.0.festival_rules")
        else
          game:start_dialog("tristan.0.festival_lamp")
        end
      else
        game:start_dialog("tristan.0.festival_no")
      end
    end)
  elseif game:get_value("i1028") > 1 and game:get_value("i1028") <= 3 then
    game:start_dialog("tristan.0.festival_underway")
  elseif game:get_value("i1028") == 4 then
    game:start_dialog("tristan.0.festival_lost")
  elseif game:get_value("i1028") == 5 then
    if game:has_item("shield") then
      game:start_dialog("tristan.0.festival_shield")
    else
      game:start_dialog("tristan.0.festival_won", game:get_player_name())
    end
  end
end

function map:on_update()
  if game:get_value("i1028") == 2 and are_all_torches_on() then
    sol.audio.play_sound("chest_appears")
    game:set_value("i1028", 3)
  end
  if game:get_value("i1028") == 2 or game:get_value("i1028") == 3 then
    banner_race_1:set_enabled(true)
    banner_race_2:set_enabled(true)
  end
  -- Show remaining timer time on screen
  if race_timer ~= nil then
    function map:on_draw(dst_surface)
      local timer_icon = sol.surface.create("hud/timer.png")
      local timer_time = race_timer:get_remaining_time()
      local timer_text = sol.text_surface.create{
        font = "white_digits",
        horizontal_alignment = "left",
        vertical_alignment = "top",
      }
      timer_icon:draw(dst_surface, 25, 55)
      timer_text:set_text(timer_time)
      timer_text:draw(dst_surface, 45, 60)
    end
  end
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_id() == "11" and torch_overlay then
      local torch = map:get_entity("torch_1")
      local screen_width, screen_height = dst_surface:get_size()
      local cx, cy = map:get_camera_position()
      local tx, ty = torch:get_center_position()
      local x = 320 - tx + cx
      local y = 240 - ty + cy
      torch_overlay:draw_region(x, y, screen_width, screen_height, dst_surface)
    end
  end
end

function torch_1:on_interaction()
  map:get_game():start_dialog("torch.need_lamp")
end
function torch_1:on_interaction_item(lamp)
  torch_1:get_sprite():set_animation("lit")
end

function torch_2:on_interaction()
  map:get_game():start_dialog("torch.need_lamp")
end
function torch_2:on_interaction_item(lamp)
  torch_2:get_sprite():set_animation("lit")
end

function torch_3:on_interaction()
  map:get_game():start_dialog("torch.need_lamp")
end
function torch_3:on_interaction_item(lamp)
  torch_3:get_sprite():set_animation("lit")
end

function ocarina_wind_to_D7:on_interaction()
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1502") then
    game:start_dialog("warp.new_point", function()
      game:set_value("b1502", true)
    end)
  else
    -- if other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1503") then
      game:start_dialog("warp.to_D7", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(51, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end
