local map = ...
local game = map:get_game()
local magic_counter = 0
local draw_counter = 0
local vars = {}

local arrow_puzzle_nb_correct = 0
local arrow_puzzle_correct = false
local room9_1, room9_2, room9_3 = false
local room17_1, room17_2, room17_3 = false

local shadow = sol.surface.create(1792, 1472)
local lights = sol.surface.create(1792, 1472)
shadow:set_blend_mode("multiply")
lights:set_blend_mode("add")
local effects = {
  torch = sol.sprite.create("entities/torch_light"),
  torch_tile = sol.sprite.create("entities/torch_light_tile"),
  torch_hero = sol.sprite.create("entities/torch_light_hero"),
  torch_room = sol.sprite.create("entities/torch_light_room")
}
effects.torch:set_blend_mode("blend")
effects.torch_tile:set_blend_mode("blend")
effects.torch_hero:set_blend_mode("blend")
effects.torch_room:set_blend_mode("blend")

----------------------------------------------
-- Dungeon 8: Interloper Sanctum (Basement) --
----------------------------------------------

function map:on_started(destination)
  -- The only way to get out of this area of the game is to die.
  game:set_starting_location("218", "from_outside")

  if destination == from_above and not game:get_value("dungeon_8_explored_1b_complete") then
    local sp = sol.sprite.create("entities/torch_light")
    sp:set_blend_mode("blend")
    sp:draw(lights, 960, 1421)
    sol.timer.start(self, 2000, function()
      map:get_camera():start_tracking(shadow_link)
      sol.audio.play_sound("poe_soul")
      game:start_dialog("shadow_link.sanctum_basement", game:get_player_name(), function()
        if not game:get_value("b1181") then
          game:get_hero():start_treasure("map", 1, "b1181") -- Give map so explored and non-explored rooms show correctly.
        end
        shadow_link:get_sprite():fade_out(50, function()
          map:get_camera():start_tracking(map:get_hero())
          enter_stairs_1:set_enabled(false)
          enter_stairs_2:set_enabled(false)
          enter_stairs_3:set_enabled(false)
        end)
      end)
    end)
  end
  boulder_timer = sol.timer.start(map, 600, function()
    map:create_enemy({ x = 1160, y = 941, layer = 0, direction = 0, breed = "boulder" })
    map:create_enemy({ x = 1304, y = 941, layer = 0, direction = 0, breed = "boulder" })
    return true
  end)
  game:set_value("dungeon_8_explored_1b_25", true)
  if game:get_value("dungeon_8_explored_1b_complete") then
    shadow_link:remove()
    exit_stairs_1:set_enabled(true)
    exit_stairs_2:set_enabled(true)
    exit_stairs_3:set_enabled(true)
  end
  switch_complete_1:set_enabled(false)
  switch_complete_4:set_enabled(false)
  switch_complete_6:set_enabled(false)
  switch_complete_7:set_enabled(false)
  switch_complete_8:set_enabled(false)
  switch_complete_12:set_enabled(false)
  switch_complete_13:set_enabled(false)
  switch_complete_14:set_enabled(false)
  switch_complete_15:set_enabled(false)
  switch_complete_16:set_enabled(false)
  switch_complete_18:set_enabled(false)
  switch_complete_20:set_enabled(false)
  switch_complete_23:set_enabled(false)
  switch_complete_24:set_enabled(false)
end

local function reset_arrow_puzzle()
  sol.audio.play_sound("wrong")
  room2_arrow_1:set_locked(false)
  room2_arrow_2:set_locked(false)
  room2_arrow_3:set_locked(false)
  room2_arrow_1:set_activated(false)
  room2_arrow_2:set_activated(false)
  room2_arrow_3:set_activated(false)
  arrow_puzzle_correct = false
  arrow_puzzle_nb_correct = 0
end

local function game_won()
  if not game:get_value("dungeon_8_explored_1b_complete") then
    game:set_value("dungeon_8_explored_1b_complete", true)
    sol.audio.play_sound("secret")
    map:move_camera(896, 144, 250, function()
      exit_stairs_1:set_enabled(true)
      exit_stairs_2:set_enabled(true)
      exit_stairs_3:set_enabled(true)
    end, 500, 2000)
  end
end

local function room_complete(room, complete)
  local switch = "switch_complete_"..room
  if complete then
    sol.audio.play_sound("lamp")
    game:set_value("dungeon_8_explored_1b_"..room, true)
  elseif map:get_entity(switch) ~= nil then
    if map:get_entity(switch):exists() then
      map:get_entity(switch):set_enabled(true)
      map:get_entity(switch):set_activated(false)
    end
    if room == 2 then
      room2_arrow_1:set_activated(false)
      room2_arrow_2:set_activated(false)
      room2_arrow_3:set_activated(false)
    end
    if room == 9 then
      room9_switch_1:set_activated(false)
      room9_switch_2:set_activated(false)
      room9_switch_3:set_activated(false)
      block:set_position(296,685)
    end
    if room == 10 then
      room10_arrow_1:set_activated(false)
      room10_arrow_2:set_activated(false)
    end
    if room == 17 then
      room17_switch_1:set_activated(false)
      room17_switch_2:set_activated(false)
      room17_switch_3:set_activated(false)
    end
  end

  -- Win Conditions (12 total).
  if game:get_value("dungeon_8_explored_1b_3") and game:get_value("dungeon_8_explored_1b_4") and game:get_value("dungeon_8_explored_1b_9") and game:get_value("dungeon_8_explored_1b_10") and game:get_value("dungeon_8_explored_1b_11") then game_won() end  -- 1st Column
  if game:get_value("dungeon_8_explored_1b_2") and game:get_value("dungeon_8_explored_1b_5") and game:get_value("dungeon_8_explored_1b_8") and game:get_value("dungeon_8_explored_1b_12") and game:get_value("dungeon_8_explored_1b_13") then game_won() end  -- 2nd Column
  if game:get_value("dungeon_8_explored_1b_1") and game:get_value("dungeon_8_explored_1b_6") and game:get_value("dungeon_8_explored_1b_7") and game:get_value("dungeon_8_explored_1b_14") and game:get_value("dungeon_8_explored_1b_25") then game_won() end  -- 3rd Column
  if game:get_value("dungeon_8_explored_1b_15") and game:get_value("dungeon_8_explored_1b_16") and game:get_value("dungeon_8_explored_1b_20") and game:get_value("dungeon_8_explored_1b_21") and game:get_value("dungeon_8_explored_1b_24") then game_won() end  -- 4th Column
  if game:get_value("dungeon_8_explored_1b_23") and game:get_value("dungeon_8_explored_1b_22") and game:get_value("dungeon_8_explored_1b_19") and game:get_value("dungeon_8_explored_1b_18") and game:get_value("dungeon_8_explored_1b_17") then game_won() end  -- 5th Column
  if game:get_value("dungeon_8_explored_1b_11") and game:get_value("dungeon_8_explored_1b_12") and game:get_value("dungeon_8_explored_1b_16") and game:get_value("dungeon_8_explored_1b_17") and game:get_value("dungeon_8_explored_1b_25") then game_won() end  -- 1st Row
  if game:get_value("dungeon_8_explored_1b_10") and game:get_value("dungeon_8_explored_1b_13") and game:get_value("dungeon_8_explored_1b_14") and game:get_value("dungeon_8_explored_1b_15") and game:get_value("dungeon_8_explored_1b_18") then game_won() end  -- 2nd Row
  if game:get_value("dungeon_8_explored_1b_7") and game:get_value("dungeon_8_explored_1b_8") and game:get_value("dungeon_8_explored_1b_9") and game:get_value("dungeon_8_explored_1b_19") and game:get_value("dungeon_8_explored_1b_20") then game_won() end  -- 3rd Row
  if game:get_value("dungeon_8_explored_1b_4") and game:get_value("dungeon_8_explored_1b_5") and game:get_value("dungeon_8_explored_1b_6") and game:get_value("dungeon_8_explored_1b_21") and game:get_value("dungeon_8_explored_1b_22") then game_won() end  -- 4th Row
  if game:get_value("dungeon_8_explored_1b_1") and game:get_value("dungeon_8_explored_1b_2") and game:get_value("dungeon_8_explored_1b_3") and game:get_value("dungeon_8_explored_1b_23") and game:get_value("dungeon_8_explored_1b_24") then game_won() end  -- 5th Row
  if game:get_value("dungeon_8_explored_1b_11") and game:get_value("dungeon_8_explored_1b_13") and game:get_value("dungeon_8_explored_1b_7") and game:get_value("dungeon_8_explored_1b_21") and game:get_value("dungeon_8_explored_1b_23") then game_won() end  -- 1st Diagonal
  if game:get_value("dungeon_8_explored_1b_17") and game:get_value("dungeon_8_explored_1b_15") and game:get_value("dungeon_8_explored_1b_7") and game:get_value("dungeon_8_explored_1b_5") and game:get_value("dungeon_8_explored_1b_3") then game_won() end  -- 2nd Diagonal
end

for enemy in map:get_entities("room_1_") do
  enemy.on_dead = function()
    if not map:has_entities("room_1_") then room_complete(1, true) end
  end
end
function switch_complete_1:on_activated()
  room_complete(1, true)
end

function room2_arrow_1:on_activated()
  if arrow_puzzle_nb_correct == 0 then
    room2_arrow_1:set_locked(true)
    arrow_puzzle_nb_correct = 1
  else
    reset_arrow_puzzle()
  end
end
function room2_arrow_2:on_activated()
  if arrow_puzzle_nb_correct == 1 then
    room2_arrow_2:set_locked(true)
    arrow_puzzle_nb_correct = 2
  else
    reset_arrow_puzzle()
  end
end
function room2_arrow_3:on_activated()
  if arrow_puzzle_nb_correct == 2 then
    room2_arrow_3:set_locked(true)
    arrow_puzzle_correct = true
    arrow_puzzle_nb_correct = 0
    room_complete(2, true)
  else
    reset_arrow_puzzle()
  end
end

-- Room 3 in map:on_update()

for enemy in map:get_entities("room_4_") do
  enemy.on_dead = function()
    if not map:has_entities("room_4_") then room_complete(4, true) end
  end
end
function switch_complete_4:on_activated()
  room_complete(4, true)
end

function switch_complete_5:on_activated()
  room_complete(5, true)
end

for enemy in map:get_entities("room_6_") do
  enemy.on_dead = function()
    if not map:has_entities("room_6_") then room_complete(6, true) end
  end
end
function switch_complete_6:on_activated()
  room_complete(6, true)
end

for enemy in map:get_entities("room_7_") do
  enemy.on_dead = function()
    if not map:has_entities("room_7_") then room_complete(7, true) end
  end
end
function switch_complete_7:on_activated()
  room_complete(7, true)
end

for enemy in map:get_entities("room_8_") do
  enemy.on_dead = function()
    if not map:has_entities("room_8_") then room_complete(8, true) end
  end
end
function switch_complete_8:on_activated()
  room_complete(8, true)
end

function room9_switch_1:on_activated()
  room9_pit_2:set_enabled(false)
  room9_pit_4:set_enabled(false); room9_1 = true
  if room9_1 and room9_2 and room9_3 then room_complete(9, true) end
end
function room9_switch_2:on_activated()
  room9_pit_1:set_enabled(false); room9_2 = true
  if room9_1 and room9_2 and room9_3 then room_complete(9, true) end
end
function room9_switch_3:on_activated()
  room9_pit_3:set_enabled(false); room9_3 = true
  if room9_1 and room9_2 and room9_3 then room_complete(9, true) end
end

function room10_arrow_1:on_activated()
  room10_arrow_1:set_locked(true)
  if room10_arrow_2:is_activated() then
    room_complete(10, true)
  end
end
function room10_arrow_2:on_activated()
  room10_arrow_2:set_locked(true)
  if room10_arrow_1:is_activated() then
    room_complete(10, true)
  end
end

-- Room 11 in map:on_update()

for enemy in map:get_entities("room_12_") do
  enemy.on_dead = function()
    if not map:has_entities("room_12_") then room_complete(12, true) end
  end
end
function switch_complete_12:on_activated()
  room_complete(12, true)
end

for enemy in map:get_entities("room_13_") do
  enemy.on_dead = function()
    if not map:has_entities("room_13_") then room_complete(13, true) end
  end
end
function switch_complete_13:on_activated()
  room_complete(13, true)
end

for enemy in map:get_entities("room_14_") do
  enemy.on_dead = function()
    if not map:has_entities("room_14_") then room_complete(14, true) end
  end
end
function switch_complete_14:on_activated()
  room_complete(14, true)
end

for enemy in map:get_entities("room_15_") do
  enemy.on_dead = function()
    if not map:has_entities("room_15_") then room_complete(15, true) end
  end
end
function switch_complete_15:on_activated()
  room_complete(15, true)
end

for enemy in map:get_entities("room_16_") do
  enemy.on_dead = function()
    if not map:has_entities("room_16_") then room_complete(16, true) end
  end
end
function switch_complete_16:on_activated()
  room_complete(16, true)
end

function room17_switch_1:on_activated()
  room17_1 = true
  if room17_1 and room17_2 and room17_3 then room_complete(17, true) end
end
function room17_switch_2:on_activated()
  room17_2 = true
  if room17_1 and room17_2 and room17_3 then room_complete(17, true) end
end
function room17_switch_3:on_activated()
  room17_3 = true
  if room17_1 and room17_2 and room17_3 then room_complete(17, true) end
end

for enemy in map:get_entities("room_18_") do
  enemy.on_dead = function()
    if not map:has_entities("room_18_") then room_complete(18, true) end
  end
end
function switch_complete_18:on_activated()
  room_complete(18, true)
end

function room19_switch_1:on_activated()
  room19_switch_2:set_activated(false)
  local positions_1 = { {x = 1440, y = 720}, {x = 1552, y = 680}, {x = 1552, y = 760} }
  local positions_2 = { {x = 1520, y = 720}, {x = 1552, y = 640}, {x = 1552, y = 800} }
  local c = map:get_entities_count("room19_pit")
  for i = 1, c do
    local ex, ey, el = map:get_entity("room19_pit_"..c):get_position()
    if (ex == positions_2[c].x) and (ey == positions_2[c].y) then
      map:get_entity("room19_pit_"..i):set_position(positions_1[i].x, positions_1[i].y)
    else
      map:get_entity("room19_pit_"..i):set_position(positions_2[i].x, positions_2[i].y)
    end
  end
end
function room19_switch_2:on_activated()
  if not game:get_value("dungeon_8_explored_1b_19") then
    room_complete(19, true)
    room19_block:set_enabled(false)
  end
  room19_switch_1:set_activated(false)
  local positions_1 = { {x = 1440, y = 720}, {x = 1552, y = 680}, {x = 1552, y = 760} }
  local positions_2 = { {x = 1520, y = 720}, {x = 1552, y = 640}, {x = 1552, y = 800} }
  local c = map:get_entities_count("room19_pit")
  for i = 1, c do
    local ex, ey, el = map:get_entity("room19_pit_"..c):get_position()
    if (ex == positions_2[c].x) and (ey == positions_2[c].y) then
      map:get_entity("room19_pit_"..i):set_position(positions_1[i].x, positions_1[i].y)
    else
      map:get_entity("room19_pit_"..i):set_position(positions_2[i].x, positions_2[i].y)
    end
  end
end

for enemy in map:get_entities("room_20_") do
  enemy.on_dead = function()
    if not map:has_entities("room_20_") then room_complete(20, true) end
  end
end
function switch_complete_20:on_activated()
  room_complete(20, true)
end

function switch_complete_21:on_activated()
  room_complete(21, true)
end

function switch_complete_22:on_activated()
  room_complete(22, true)
end

for enemy in map:get_entities("room_23_") do
  enemy.on_dead = function()
    if not map:has_entities("room_23_") then room_complete(23, true) end
  end
end
function switch_complete_23:on_activated()
  room_complete(23, true)
end

for enemy in map:get_entities("room_24_") do
  enemy.on_dead = function()
    if not map:has_entities("room_24_") then room_complete(24, true) end
  end
end
function switch_complete_24:on_activated()
  room_complete(24, true)
end

function sensor_save_ground_1:on_activated()
  game:get_hero():reset_solid_ground()
end
function sensor_save_ground_2:on_activated()
  game:get_hero():reset_solid_ground()
end
function sensor_save_ground_3:on_activated()
  game:get_hero():reset_solid_ground()
end
function sensor_save_ground_4:on_activated()
  game:get_hero():reset_solid_ground()
end

function map:on_update()
  if torch_room3_1:get_sprite():get_animation() == "lit" and
     torch_room3_2:get_sprite():get_animation() == "lit" and
     torch_room3_3:get_sprite():get_animation() == "lit" and
     torch_room3_4:get_sprite():get_animation() == "lit" and
     torch_room3_5:get_sprite():get_animation() == "lit" and
     not game:get_value("dungeon_8_explored_1b_3") then
    room_complete(3, true)
  end
  if room21_crystal:is_in_same_region(map:get_hero()) then
    boulder_timer:set_suspended(false)
  else
    boulder_timer:set_suspended(true)
  end

  if not map:has_entities("statue_room_11_") and not game:get_value("dungeon_8_explored_1b_11") then
    room_complete(11, true)
  end

  if math.random(500) == 1 and not game:is_suspended() and not game:get_value("dungeon_8_explored_1b_complete") then
    -- 1 in 500 chance of "switching off" a room each cycle (as long as the game isn't over).
    room = math.random(24)
    if game:get_value("dungeon_8_explored_1b_"..room) then
      game:set_value("dungeon_8_explored_1b_"..room, false)
      sol.audio.play_sound("poe_soul")
      room_complete(room, false)
    end
  end
end

function map:on_draw(dst_surface)
  local x,y = map:get_camera():get_position()
  local w,h = map:get_camera():get_size()
  
  shadow:fill_color({032,064,128,128})
  lights:clear()
  
  if game:get_value("dungeon_8_explored_1b_1") and game:get_hero():get_distance(896,1269) <= 500 then
    effects.torch_room:draw(lights, 736, 1149)
  end
  if game:get_value("dungeon_8_explored_1b_2") and game:get_hero():get_distance(560,1269) <= 500 then
    effects.torch_room:draw(lights, 400, 1149)
    room2_gate_e1:set_enabled(false)
    room2_gate_e2:set_enabled(false)
    room1_gate_w1:set_enabled(false)
    room1_gate_w2:set_enabled(false)
  end
  if game:get_value("dungeon_8_explored_1b_3") and game:get_hero():get_distance(224,1269) <= 500 then
    effects.torch_room:draw(lights, 64, 1149)
  end
  if game:get_value("dungeon_8_explored_1b_4") and game:get_hero():get_distance(224,997) <= 500 then
    effects.torch_room:draw(lights, 64, 877)
  end
  if game:get_value("dungeon_8_explored_1b_5") and game:get_hero():get_distance(560,997) <= 500 then
    effects.torch_room:draw(lights, 400, 877)
  end
  if game:get_value("dungeon_8_explored_1b_6") and game:get_hero():get_distance(896,997) <= 500 then
    effects.torch_room:draw(lights, 736, 877)
    room6_gate_s1:set_enabled(false)
    room6_gate_s2:set_enabled(false)
    room1_gate_n1:set_enabled(false)
    room1_gate_n2:set_enabled(false)
  end
  if game:get_value("dungeon_8_explored_1b_7") and game:get_hero():get_distance(896,725) <= 500 then
    effects.torch_room:draw(lights, 736, 605)
  end
  if game:get_value("dungeon_8_explored_1b_8") and game:get_hero():get_distance(560,725) <= 500 then
    effects.torch_room:draw(lights, 400, 605)
  end
  if game:get_value("dungeon_8_explored_1b_9") and game:get_hero():get_distance(224,725) <= 500 then
    effects.torch_room:draw(lights, 64, 605)
    room9_gate_e1:set_enabled(false)
    room9_gate_e2:set_enabled(false)
    room8_gate_w1:set_enabled(false)
    room8_gate_w2:set_enabled(false)
  end
  if game:get_value("dungeon_8_explored_1b_10") and game:get_hero():get_distance(224,453) <= 500 then
    effects.torch_room:draw(lights, 64, 333)
  end
  if game:get_value("dungeon_8_explored_1b_11") and game:get_hero():get_distance(224,181) <= 500 then
    effects.torch_room:draw(lights, 64, 61)
  end
  if game:get_value("dungeon_8_explored_1b_12") and game:get_hero():get_distance(560,181) <= 500 then
    effects.torch_room:draw(lights, 400, 61)
  end
  if game:get_value("dungeon_8_explored_1b_13") and game:get_hero():get_distance(560,453) <= 500 then
    effects.torch_room:draw(lights, 400, 333)
  end
  if game:get_value("dungeon_8_explored_1b_14") and game:get_hero():get_distance(896,453) <= 500 then
    effects.torch_room:draw(lights, 736, 333)
  end
  if game:get_value("dungeon_8_explored_1b_15") and game:get_hero():get_distance(1232,453) <= 500 then
    effects.torch_room:draw(lights, 1072, 333)
  end
  if game:get_value("dungeon_8_explored_1b_16") and game:get_hero():get_distance(1232,181) <= 500 then
    effects.torch_room:draw(lights, 1072, 61)
  end
  if game:get_value("dungeon_8_explored_1b_17") and game:get_hero():get_distance(1568,181) <= 500 then
    effects.torch_room:draw(lights, 1408, 61)
  end
  if game:get_value("dungeon_8_explored_1b_18") and game:get_hero():get_distance(1568,453) <= 500 then
    effects.torch_room:draw(lights, 1408, 333)
  end
  if game:get_value("dungeon_8_explored_1b_19") and game:get_hero():get_distance(1568,725) <= 500 then
    effects.torch_room:draw(lights, 1408, 605)
  end
  if game:get_value("dungeon_8_explored_1b_20") and game:get_hero():get_distance(1232,725) <= 500 then
    effects.torch_room:draw(lights, 1072, 605)
  end
  if game:get_value("dungeon_8_explored_1b_21") and game:get_hero():get_distance(1232,997) <= 500 then
    effects.torch_room:draw(lights, 1072, 877)
  end
  if game:get_value("dungeon_8_explored_1b_22") and game:get_hero():get_distance(1568,997) <= 500 then
    effects.torch_room:draw(lights, 1408, 877)
  end
  if game:get_value("dungeon_8_explored_1b_23") and game:get_hero():get_distance(1568,1269) <= 500 then
    effects.torch_room:draw(lights, 1408, 1149)
  end
  if game:get_value("dungeon_8_explored_1b_24") and game:get_hero():get_distance(1232,1269) <= 500 then
    effects.torch_room:draw(lights, 1072, 1149)
    room1_gate_e1:set_enabled(false)
    room1_gate_e2:set_enabled(false)
    room24_gate_w1:set_enabled(false)
    room24_gate_w2:set_enabled(false)
  end
  if game:get_value("dungeon_8_explored_1b_25") and game:get_hero():get_distance(896,191) <= 500 then
    effects.torch_room:draw(lights, 736, 61)
  end
  for e in map:get_entities("torch_") do
    if e:get_sprite():get_animation() == "lit" and e:get_distance(game:get_hero()) <= 300 then
      local xx,yy = e:get_position()
      effects.torch:draw(lights, xx-32, yy-40)
    end
  end
  for e in map:get_entities("eye_") do
    if e:get_distance(game:get_hero()) <= 300 then
      local xx,yy = e:get_position()
      effects.torch:draw(lights, xx-16, yy-16)
    end
  end
  for e in map:get_entities("statue_") do
    if e:get_distance(game:get_hero()) <= 300 then
      local xx,yy = e:get_position()
      effects.torch:draw(lights, xx-32, yy-40)
    end
  end
  for e in map:get_entities("lava_") do
    if e:get_distance(game:get_hero()) <= 300 then
      local xx,yy = e:get_position()
      effects.torch_tile:draw(lights, xx-8, yy-8)
    end
  end
  
  lights:draw_region(x,y,w,h,shadow,x,y)
  shadow:draw_region(x,y,w,h,dst_surface)
end