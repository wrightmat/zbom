local map = ...
local game = map:get_game()

------------------------------------------------------------
-- Outside World F15 (Ordon Village) - Houses and Shops   --
------------------------------------------------------------

if game:get_value("i1027")==nil then game:set_value("i1027", 0) end --Festival progress
if game:get_value("i1028")==nil then game:set_value("i1028", 0) end --Race progress
if game:get_value("i1902")==nil then game:set_value("i1902", 0) end --Rudy
if game:get_value("i1903")==nil then game:set_value("i1903", 0) end --Julita
if game:get_value("i1904")==nil then game:set_value("i1904", 0) end --Ulo
if game:get_value("i1905")==nil then game:set_value("i1905", 0) end --Bilo
if game:get_value("i1907")==nil then game:set_value("i1907", 0) end --Quint
if game:get_value("i1908")==nil then game:set_value("i1908", 0) end --Francis
if game:get_value("i1909")==nil then game:set_value("i1909", 0) end --Jarred

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

local function follow_hero(npc)
 sol.timer.start(npc, 500, function()
  local hero_x, hero_y, hero_layer = hero:get_position()
  local npc_x, npc_y, npc_layer = npc:get_position()
  local distance_hero = math.abs((hero_x+hero_y)-(npc_x+npc_y))
  local m = sol.movement.create("target")
  if distance_hero > 1000 then -- hero's too far away, catch up!
    m:set_speed(64)
  elseif distance_hero < 100 then -- getting closer, slow them down
    m:set_speed(32)
  elseif distance_hero < 50 then -- too close. back off so we don't trap the hero
    m:set_speed(1)
  else
    m:set_speed(48)
  end
  m:start(npc)
  npc:get_sprite():set_animation("walking")
 end)
end

function map:on_started(destination)
  -- If the festival isn't over, make sure banner, booths and NPCs are outside
  if game:get_value("i1027") < 5 then
    banner_1:set_enabled(true)
    banner_2:set_enabled(true)
    banner_3:set_enabled(true)
    banner_4:set_enabled(true)
    banner_5:set_enabled(true)
    banner_6:set_enabled(true)
    banner_7:set_enabled(true)
    banner_8:set_enabled(true)
    booth_1:set_enabled(true)
    booth_2:set_enabled(true)
    blacksmith_table:set_enabled(true)
    blacksmith_furnace:set_enabled(true)
    npc_julita_sensor:remove(true)
    npc_rudy_sensor:remove(true)
    random_walk(npc_ulo)
    --random_walk(npc_bilo) -- TODO: add back once he has all of his directions/animations
  else  -- If festival is over, then don't have NPCs walking around outside
    npc_rudy:remove()
    npc_julita:remove()
    npc_julita_sensor:remove(true)
    npc_rudy_sensor:remove(true)
    npc_ulo:remove()
    npc_bilo:remove()
  end
  if game:get_value("i1027") < 2 then  -- Whether or not kids should be walking around
    follow_hero(npc_jarred)
    follow_hero(npc_quint)
    follow_hero(npc_francis)
  else
    random_walk(npc_jarred)
    random_walk(npc_quint)
    random_walk(npc_francis)
  end  -- Show the quest bubble for the "find Crista for Julita" quest only at the appropriate time
  if game:get_value("i1027") ~= 4 and quest_julita:exists() then
    quest_julita:remove()
  end

  -- Entrances of houses.
  local entrance_names = {
    "pim", "ulo", "julita"
  }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")

    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1
	  and tile:is_enabled() then
	tile:set_enabled(false)
	sol.audio.play_sound("door_open")
      end
    end
  end
end

function sensor_festival_dialog:on_activated()
  -- if Link walks out of his house and the festival's going on
  -- then start the initial dialog (if it hasn't been done already)
  if game:get_value("i1027") == 0 then
    hero:freeze()
    game:set_value("i1027", 1)
    festival_timer = sol.timer.start(2000, function()
      local m = sol.movement.create("jump")
      sol.audio.play_sound("jump")
      m:set_direction8(6)
      m:set_distance(8)
      m:set_speed(32)
      m:start(npc_jarred)
      sol.timer.start(400, function()
        game:start_dialog("jarred.0.festival", game:get_player_name(), function()
          local m = sol.movement.create("jump")
	  sol.audio.play_sound("jump")
          m:set_direction8(6)
          m:set_distance(8)
          m:start(npc_francis)
	  sol.timer.start(400, function()
            game:start_dialog("francis.0.festival_2", function()
              game:set_value("i1027", 2)
              hero:unfreeze()
              follow_hero(npc_jarred)
              follow_hero(npc_quint)
              follow_hero(npc_francis)
              game:set_value("i1907", game:get_value("i1907")+1)
              game:set_value("i1908", game:get_value("i1908")+1)
              game:set_value("i1909", game:get_value("i1909")+1)
            end)--dialog
	  end)--jump timer
        end)--dialog
      end)--jump timer
    end)--sensor timer
  end--if
end

function npc_rudy:on_interaction()
  if game:get_value("i1902") > 0 then
    if game:get_value("i1027") >= 3 and not game:has_item("shield") then
      game:start_dialog("rudy.0.festival_reward", function()
        game:set_value("i1902", game:get_value("i1902")+1)
        hero:start_treasure("shield", 1, "b1820", function()
          game:start_dialog("rudy.0.festival_reward_2")
        end)
      end)
    else
      game:start_dialog("rudy.1.festival")
    end
  else
    game:start_dialog("rudy.0.festival")
    if game:get_value("i1902") == 0 then game:set_value("i1902", 1) end
  end
end
function npc_rudy_sensor:on_interaction()
  npc_rudy:on_interaction()
end

function npc_quint:on_interaction()
  if game:get_value("i1907") >= 1 then
    if game:get_value("i1028") > 1 then game:start_dialog("quint.1.ordon") end
  end
end

function npc_francis:on_interaction()
  if game:get_value("i1908") >= 1 then
    --if game:get_value("i1028") > 1 then game:start_dialog("francis.1.ordon") end
  end
end

function npc_jarred:on_interaction()
  if game:get_value("i1909") >= 1 then
    if game:get_value("i1028") > 1 then game:start_dialog("jarred.1.ordon") end
  end
end

function npc_bilo:on_interaction()
  if game:get_value("i1905") >= 1 and game:get_value("i1027") >= 4 then
    game:start_dialog("bilo.1")
  else
    game:start_dialog("bilo.0")
  end
end

function npc_ulo:on_interaction()
  if game:get_value("i1904") >= 1 then
    if game:has_item("lamp") then
      game:start_dialog("ulo.1.festival")
    else
      game:start_dialog("ulo.1.festival_lamp")
    end
  else
    game:set_value("i1904", game:get_value("i1904")+1)
    game:start_dialog("ulo.0.festival", game:get_player_name())
  end
end

function npc_julita:on_interaction()
  if game:get_value("i1903") >= 1 and game:get_value("i1027") >= 4 then
    if quest_julita ~= nil then quest_julita:remove() end
    game:start_dialog("julita.1", game:get_player_name())
  elseif game:get_value("i1027") < 5 then
    game:start_dialog("julita.0.festival", function(answer)
      if answer == 1 then
        if game:get_magic() then
          game:add_magic(20)
          game:start_dialog("julita.0.festival_yes")
        else
          game:start_dialog("julita.0.festival_magic")
        end
      else
        game:start_dialog("julita.0.festival_no")
      end
      game:set_value("i1903", game:get_value("i1903")+1)
    end)
  else
    game:start_dialog("julita.0")
  end
end
function npc_julita_sensor:on_interaction()
  npc_julita:on_interaction()
end
