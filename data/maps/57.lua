local map = ...
local game = map:get_game()

--------------------------------------
-- Outside World G5 (Zora's Domain) --
--------------------------------------

function map:on_started(destination)
  if not game:get_value("b2029") then quest_trading_scale:remove() end
  if not game:get_value("b1721") then chest_heart_piece_2:set_enabled(false) end
  -- Save default solid ground to prevent perma-death if hero hits mines
  -- before landing on solid ground somewhere on this map.
  if destination == to_H5_water or destination == to_F5_2 then
    game:get_hero():save_solid_ground(712,168,0)
  elseif destination == to_F5 then
    game:get_hero():save_solid_ground(8,320,0)
  elseif destination == to_H5_2
    game:get_hero():save_solid_ground(1112,208,0)
  else
    game:get_hero():save_solid_ground(472,1000,0)
  end
end

for enemy in map:get_entities("pincer") do
  enemy.on_dead = function()
    if not map:has_entities("pincer") and not game:get_value("b1721") then
      chest_heart_piece_2:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

npc_mijas:register_event("on_interaction", function()
  sol.audio.play_sound("zora")
  if game:get_item("tunic"):get_variant() < 3 then
    game:start_dialog("zora.0.tunic")
  else
    local rand = math.random(4)
    if rand == last_rand then rand = math.random(4) end
    game:start_dialog("zora.0.domain_"..rand)
    local last_rand = rand
  end
end)

npc_zorir:register_event("on_interaction", function()
  sol.audio.play_sound("zora")
  if game:get_item("tunic"):get_variant() < 3 then
    game:start_dialog("zora.0.tunic")
  else
    local rand = math.random(4)
    if rand == last_rand then rand = math.random(4) end
    game:start_dialog("zora.0.domain_"..rand)
    local last_rand = rand
  end
end)

npc_peja:register_event("on_interaction", function()
  sol.audio.play_sound("zora")
  local rand = math.random(4)
  if rand == last_rand then rand = math.random(4) end
  game:start_dialog("zora.0.domain_"..rand)
  local last_rand = rand
end)

npc_arin:register_event("on_interaction", function()
  sol.audio.play_sound("zora")
  if game:get_value("b2029") then
    game:start_dialog("zora.0.trading", function(answer)
      if answer == 1 then
        -- Give him the vase, get the zora scale
        game:start_dialog("zora.0.trading_yes", function()
          hero:start_treasure("trading", 10)
          game:set_value("b2030", true)
          game:set_value("b2029", false)
          quest_trading_scale:remove()
        end)
      else
        -- Don't give him the vase
        game:start_dialog("zora.0.trading_no")
      end
    end)
  else
    game:start_dialog("zora.0.domain")
  end
end)

function reset_ground_1:on_activated()
  game:get_hero():reset_solid_ground()
end
function reset_ground_2:on_activated()
  game:get_hero():reset_solid_ground()
end
function reset_ground_3:on_activated()
  game:get_hero():reset_solid_ground()
end
function reset_ground_4:on_activated()
  game:get_hero():reset_solid_ground()
end