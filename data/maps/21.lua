local map = ...
local game = map:get_game()

-------------------------------------------------------------------------------------------------
-- Outside World C15 (Grove-Temple Entr) - Grove Temple Entrance, Beach entrance (Gerudo ship) --
-------------------------------------------------------------------------------------------------

if game:get_value("i1917")==nil then game:set_value("i1917", 0) end
local monkey_sprite = npc_monkey:get_sprite()
local monkey_jumps = 0

function monkey_jump(dir)
  local m = sol.movement.create("jump")
  sol.audio.play_sound("monkey")
  m:set_direction8(dir)
  m:set_distance(48)
  m:set_ignore_obstacles(true)
  m:set_speed(48)
  m:start(npc_monkey)
  monkey_sprite:set_animation("jumping")
  monkey_jumps = monkey_jumps + 1
end

function map:on_started(destination)
  if game:get_value("b1061") and game:get_value("i1068") < 9 and destination == from_temple then
    -- Temple is complete- have monkey steal book page and jump away
    npc_monkey:set_position(648, 752, 2)
    sol.audio.play_sound("monkey")
    sol.timer.start(1000, function()
      sol.audio.play_sound("monkey")
      game:start_dialog("monkey1.1.grove", function()
        game:get_item("book_mudora"):set_variant(0) --take away book page
        sol.timer.start(300, function()
          sol.audio.play_sound("monkey")
          monkey_sprite:set_animation("jumping")
          local m = sol.movement.create("jump")
          m:set_direction8(2)
          m:set_distance(48)
          m:set_speed(48)
          m:set_ignore_obstacles(true)
          m:start(npc_monkey, function()
            sol.audio.play_sound("monkey")
            monkey_sprite:set_animation("jumping")
            local m2 = sol.movement.create("jump")
            m2:set_direction8(2)
            m2:set_distance(48)
            m2:set_speed(48)
            m2:set_ignore_obstacles(true)
            m2:start(npc_monkey, function()
              sol.audio.play_sound("monkey")
              monkey_sprite:set_animation("jumping")
              local m3 = sol.movement.create("jump")
              m3:set_direction8(2)
              m3:set_distance(48)
              m3:set_speed(48)
              m3:set_ignore_obstacles(true)
              m3:start(npc_monkey, function()
                sol.audio.play_sound("monkey")
                monkey_sprite:set_animation("jumping")
                local m4 = sol.movement.create("jump")
                m4:set_direction8(2)
                m4:set_distance(48)
                m4:set_speed(48)
                m4:set_ignore_obstacles(true)
                m4:start(npc_monkey, function()
	      end)
	    end)
          end)
        end)
      end)
      hero:unfreeze()
      game:set_value("i1068", 2)
      sol.timer.start(2000, function() npc_monkey:remove() end)
    end)
  end
  if game:get_item("airship_part"):get_variant() == 3 then
    -- If player has all three airship parts, proceed with Gerudo storyline
    game:set_value("i1068", 4)
  end
  if game:get_value("i1068") == 2 then
    npc_monkey:remove()
  elseif game:get_value("i1068") > 2 and game:get_value("i1068") < 6 then
    npc_monkey:remove()
    npc_gerudo_leader:set_position(416, 69)
  elseif game:get_value("i1068") == 6 then
    gerudo_ship:get_sprite():set_animation("ship")
    map:set_entities_enabled("ship_block", true)
    npc_monkey:remove()
  elseif game:get_value("i1068") > 6 then
    npc_monkey:remove()
    gerudo_ship:remove()
    map:set_entities_enabled("ship_block", false)
  end
  if game:get_value("i1068") >= 7 then
    npc_gerudo_leader:remove()
    npc_gerudo_pirate_1:remove()
    npc_gerudo_pirate_2:remove()
  end
end

function npc_gerudo_pirate_1:on_interaction()
  if game:get_value("i1068") < 5 then
    game:start_dialog("gerudo.0.beach")
  elseif game:get_value("i1068") >= 6 then
    game:start_dialog("gerudo.2.beach")
  else
    game:start_dialog("gerudo.1.beach")
  end
end

function npc_gerudo_pirate_2:on_interaction()
  if game:get_value("i1068") < 5 then
    game:start_dialog("gerudo.0.beach")
  elseif game:get_value("i1068") >= 6 then
    game:start_dialog("gerudo.2.beach")
  else
    game:start_dialog("gerudo.1.beach")
  end
end

function npc_gerudo_leader:on_interaction()
  if game:get_value("i1917") >= 1 then
    if game:get_value("i1068") == 1 then
      game:start_dialog("hesla.1.beach")
    elseif game:get_value("i1068") == 2 then
      game:start_dialog("hesla.2.beach", function()
        hero:start_treasure("world_map")
        game:set_value("i1068", 3)
        -- Move Hesla out of the way so we can get to the beach
        local m = sol.movement.create("target")
        npc_gerudo_leader:get_sprite():set_animation("walking")
        m:set_speed(24)
        m:set_target(416, 69)
        m:start(npc_gerudo_leader, function()
          npc_gerudo_leader:get_sprite():set_direction(0)
          npc_gerudo_leader:get_sprite():set_animation("stopped")
        end)
      end)
    elseif game:get_value("i1068") == 3 then
      game:start_dialog("hesla.3.beach")
    elseif game:get_value("i1068") == 4 then
      game:start_dialog("hesla.4.beach")
      game:get_item("airship_part"):set_variant(0) --take airship parts from inventory
      game:set_value("i1068", 5)
    elseif game:get_value("i1068") == 5 then
      game:start_dialog("hesla.5.beach")
      -- After 5 real-time minutes the ship will be repaired
      sol.timer.start(game, 30000, function()
        game:set_value("i1068", 6)
      end)
    elseif game:get_value("i1068") == 6 then
      game:start_dialog("hesla.6.beach")
      game:set_value("i1068", 7)
    else
      game:start_dialog("hesla.0.beach")
    end
  else
    game:start_dialog("hesla.0.beach", function()
      game:set_value("i1917", 1)
    end)
  end
end

function npc_monkey:on_interaction()
  sol.audio.play_sound("monkey")
  game:start_dialog("monkey1.0.grove", function()
    sol.audio.play_sound("monkey")
    sol.timer.start(300, function()
      hero:freeze()
      monkey_jump(2)
      hero:unfreeze()
    end)
  end)
end

function sensor_water_bottle:on_activated()
  if game:has_bottle() then
    local first_empty_bottle = game:get_first_empty_bottle()
    if first_empty_bottle ~= nil then
      game:start_dialog("found_water", function(answer)
	if answer == 1 then
	  hero:start_treasure(first_empty_bottle:get_name(), 2, nil)
	end
      end)
    else
      game:start_dialog("found_water.no_empty_bottle")
    end
  else
    game:start_dialog("found_water.no_bottle")
  end
end
