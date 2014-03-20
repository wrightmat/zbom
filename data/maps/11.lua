local map = ...
local game = map:get_game()

---------------------------------------------------------------------------------
-- Outside World F14 (Ordon Village) - Ranch, Fishing Pond and Obstacle Course --
---------------------------------------------------------------------------------

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

local function end_race_lost()
  sol.audio.play_sound("wrong")
  game:set_value("i1028", 4);
  torch_1:get_sprite():set_animation("unlit")
  torch_2:get_sprite():set_animation("unlit")
  torch_3:get_sprite():set_animation("unlit")
end

function map:on_started(destination)
  -- if the festival isn't over, make sure banners, booths and NPCs are outside
  if game:get_value("i1027") < 5 then
    banner_1:set_enabled(true)
    banner_2:set_enabled(true)
    banner_3:set_enabled(true)
    banner_4:set_enabled(true)
    banner_5:set_enabled(true)
    booth_1:set_enabled(true)
  else
    -- you've finished everything in Ordon - Ordona directs you to Faron
    if game:has_item("sword") and game:get_value("i1027") < 6 then
      torch_1:get_sprite():set_animation("lit")
      sol.timer.start(4000, function()
        hero:freeze()
        torch_overlay = sol.surface.create("entities/dark.png")
        game:set_value("i1027", 5)
        game:start_dialog("ordona.1.village", game:get_player_name(), function()
          torch_overlay:fade_out(50)
          hero:unfreeze()
          game:set_value("i1027", 6)
        end)
      end)
    end
    random_walk(npc_tern)
    torch_2:remove()
    torch_3:remove()
  end
  if game:get_value("i1027") < 3 then
    random_walk(npc_jarred)
    random_walk(npc_quint)
  elseif game:get_value("i1027") <= 3 or game:get_value("i1027") > 4 then
    npc_tristan:remove()
    npc_jarred:remove()
    npc_quint:remove()
  elseif game:get_value("i1027") == 4 then
    if not game:has_item("shield") then
      npc_tristan:remove()
    else
      random_walk(npc_tristan)
    end
    npc_jarred:remove()
    npc_quint:remove()
  end
  if game:get_value("i1028") == 2 then
    race_timer = sol.timer.start(40000, end_race_lost)
    race_timer:set_with_sound(true)
  elseif game:get_value("i1028") == 3 then
    race_timer = sol.timer.start(40000, end_race_lost)
    race_timer:set_with_sound(true)
    torch_1:get_sprite():set_animation("lit")
    torch_2:get_sprite():set_animation("lit")
    torch_3:get_sprite():set_animation("lit")
  end
end

function sensor_festival_dialog:on_activated()
  if game:get_value("i1027") < 3 and game:get_value("i1028") == 0 and hero:get_direction() == 1 then
    npc_tristan:get_sprite():set_animation("pose1")
    game:start_dialog("tristan.0.festival", game:get_player_name(), function()
      game:start_dialog("francis.1.festival", function()
        game:start_dialog("tristan.0.festival_response", game:get_player_name(), function()
          game:start_dialog("francis.1.festival_race", function(answer)
            if answer == 1 then
              if game:has_item("lamp") then
                game:start_dialog("tristan.0.festival_rules", function()
		  game:set_value("i1028", 1)
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
  end
end

function sensor_start_race:on_activated()
  if hero:get_direction() == 1 then
    if game:get_value("i1028") <= 1 or game:get_value("i1028") == 4 then
      game:set_value("i1028", 2)
      race_timer = sol.timer.start(40000, end_race_lost)
      race_timer:set_with_sound(true)
    end
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
    banner_race_3:set_enabled(true)
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
