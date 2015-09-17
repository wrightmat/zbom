local map = ...
local game = map:get_game()

local arrow_puzzle_nb_correct = 0
local arrow_puzzle_correct = false
local room9_1, room9_2, room9_3 = false

----------------------------------------------
-- Dungeon 8: Interloper Sanctum (Basement) --
----------------------------------------------

local function update_rooms()
  -- No need to update on every game cycle, so we call this every second or so to speed things up.
  if game:get_value("dungeon_8_explored_1b_1") then room_overlay_1:get_sprite():set_direction(3) else room_overlay_1:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_2") then
    room_overlay_2:get_sprite():set_direction(3)
    room2_gate_e1:set_enabled(false)
    room2_gate_e2:set_enabled(false)
    room1_gate_w1:set_enabled(false)
    room1_gate_w2:set_enabled(false)
  else
    room_overlay_2:get_sprite():set_direction(1)
  end
  if game:get_value("dungeon_8_explored_1b_3") then room_overlay_3:get_sprite():set_direction(3) else room_overlay_3:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_4") then room_overlay_4:get_sprite():set_direction(3) else room_overlay_4:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_5") then room_overlay_5:get_sprite():set_direction(3) else room_overlay_5:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_6") then room_overlay_6:get_sprite():set_direction(3) else room_overlay_6:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_7") then room_overlay_7:get_sprite():set_direction(3) else room_overlay_7:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_8") then room_overlay_8:get_sprite():set_direction(3) else room_overlay_8:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_9") then
    room_overlay_9:get_sprite():set_direction(3)
    room9_gate_e1:set_enabled(false)
    room9_gate_e2:set_enabled(false)
    room8_gate_w1:set_enabled(false)
    room8_gate_w2:set_enabled(false)
  else
    room_overlay_9:get_sprite():set_direction(1)
  end
  if game:get_value("dungeon_8_explored_1b_10") then room_overlay_10:get_sprite():set_direction(3) else room_overlay_10:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_11") then room_overlay_11:get_sprite():set_direction(3) else room_overlay_11:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_12") then room_overlay_12:get_sprite():set_direction(3) else room_overlay_12:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_13") then room_overlay_13:get_sprite():set_direction(3) else room_overlay_13:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_14") then room_overlay_14:get_sprite():set_direction(3) else room_overlay_14:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_15") then room_overlay_15:get_sprite():set_direction(3) else room_overlay_15:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_16") then room_overlay_16:get_sprite():set_direction(3) else room_overlay_16:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_17") then room_overlay_17:get_sprite():set_direction(3) else room_overlay_17:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_18") then room_overlay_18:get_sprite():set_direction(3) else room_overlay_18:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_19") then room_overlay_19:get_sprite():set_direction(3) else room_overlay_19:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_20") then room_overlay_20:get_sprite():set_direction(3) else room_overlay_20:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_21") then room_overlay_21:get_sprite():set_direction(3) else room_overlay_21:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_22") then room_overlay_22:get_sprite():set_direction(3) else room_overlay_22:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_23") then room_overlay_23:get_sprite():set_direction(3) else room_overlay_23:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_24") then room_overlay_24:get_sprite():set_direction(3) else room_overlay_24:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_explored_1b_25") then room_overlay_25:get_sprite():set_direction(3) else room_overlay_25:get_sprite():set_direction(1) end

  if math.random(20) == 1 then  -- 1 in 20 chance of "switching off" a room each cycle.
    room = math.random(25)
    if game:get_value("dungeon_8_explored_1b_"..room) then
      game:set_value("dungeon_8_explored_1b_"..room, false)
      sol.audio.play_sound("poe_soul")
    end
  end

  map:create_enemy({ x = 1160, y = 925, layer = 0, direction = 0, breed = "boulder" })
  map:create_enemy({ x = 1304, y = 925, layer = 0, direction = 0, breed = "boulder" })
end

function map:on_started(destination)
  -- The only way to get out of the game is to die.
  game:set_starting_location("218", "from_outside")

  if destination == from_above then
    sol.timer.start(self, 1000, function()
      map:move_camera(992, 1453, 250, function()
        sol.audio.play_sound("poe_soul")
        game:start_dialog("shadow_link.sanctum_basement", game:get_player_name(), function()
          shadow_link:get_sprite():fade_out(50, function()
            enter_stairs_1:set_enabled(false)
            enter_stairs_2:set_enabled(false)
            enter_stairs_3:set_enabled(false)
          end)
        end)
      end, 500, 10000)
    end)
  end
  game:set_value("dungeon_8_explored_1b_25", true)
  local update_timer = sol.timer.start(self, 1000, function()
    update_rooms()
    return true
  end)
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
print("game won!")
  sol.audio.play_sound("secret")
  map:move_camera(896, 144, 250, function()
    exit_stairs_1:set_enabled(true)
    exit_stairs_2:set_enabled(true)
    exit_stairs_3:set_enabled(true)
  end, 500, 2000)
end

for enemy in map:get_entities("room_1_") do
  enemy.on_dead = function()
    if not map:has_entities("room_1_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_1", true)
    end
  end
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
    sol.audio.play_sound("lamp")
    game:set_value("dungeon_8_explored_1b_2", true)
  else
    reset_arrow_puzzle()
  end
end

-- Room 3 in map:on_update()

for enemy in map:get_entities("room_4_") do
  enemy.on_dead = function()
    if not map:has_entities("room_4_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_4", true)
    end
  end
end

function room5_switch:on_activated()
  game:set_value("dungeon_8_explored_1b_5", true)
end

for enemy in map:get_entities("room_6_") do
  enemy.on_dead = function()
    if not map:has_entities("room_6_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_6", true)
    end
  end
end

for enemy in map:get_entities("room_7_") do
  enemy.on_dead = function()
    if not map:has_entities("room_7_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_7", true)
    end
  end
end

for enemy in map:get_entities("room_8_") do
  enemy.on_dead = function()
    if not map:has_entities("room_8_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_8", true)
    end
  end
end

function room9_switch_1:on_activated()
  room9_pit_2:set_enabled(false)
  room9_pit_4:set_enabled(false)
  room9_1 = true
  if room9_1 and room9_2 and room9_3 then game:set_value("dungeon_8_explored_1b_9", true) end
end
function room9_switch_2:on_activated()
  room9_pit_1:set_enabled(false)
  room9_2 = true
  if room9_1 and room9_2 and room9_3 then game:set_value("dungeon_8_explored_1b_9", true) end
end
function room9_switch_3:on_activated()
  room9_pit_3:set_enabled(false)
  room9_3 = true
  if room9_1 and room9_2 and room9_3 then game:set_value("dungeon_8_explored_1b_9", true) end
end

function room10_arrow_1:on_activated()
  room10_arrow_1:set_locked(true)
  if room10_arrow_2:is_activated() then
    sol.audio.play_sound("lamp")
    game:set_value("dungeon_8_explored_1b_10", true)
  end
end
function room10_arrow_2:on_activated()
  room10_arrow_2:set_locked(true)
  if room10_arrow_1:is_activated() then
    sol.audio.play_sound("lamp")
    game:set_value("dungeon_8_explored_1b_10", true)
  end
end

for entity in map:get_entities("room_11_") do
  entity.on_removed = function()
print(entity:get_name())
    if not map:has_entities("room_11_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_11", true)
    end
  end
end

for enemy in map:get_entities("room_12_") do
  enemy.on_dead = function()
    if not map:has_entities("room_12_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_12", true)
    end
  end
end

for enemy in map:get_entities("room_13_") do
  enemy.on_dead = function()
    if not map:has_entities("room_13_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_13", true)
    end
  end
end

for enemy in map:get_entities("room_14_") do
  enemy.on_dead = function()
    if not map:has_entities("room_14_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_14", true)
    end
  end
end

for enemy in map:get_entities("room_17_") do
  enemy.on_dead = function()
    if not map:has_entities("room_17_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_17", true)
    end
  end
end

for enemy in map:get_entities("room_20_") do
  enemy.on_dead = function()
    if not map:has_entities("room_20_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_20", true)
    end
  end
end

function room21_crystal:on_activated()
print("room 21 activated")
  sol.audio.play_sound("lamp")
  game:set_value("dungeon_8_explored_1b_21", true)
end

function room22_switch:on_activated()
  sol.audio.play_sound("lamp")
  game:set_value("dungeon_8_explored_1b_22", true)
end

for enemy in map:get_entities("room_23_") do
  enemy.on_dead = function()
    if not map:has_entities("room_23_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_23", true)
    end
  end
end

for enemy in map:get_entities("room_24_") do
  enemy.on_dead = function()
    if not map:has_entities("room_24_") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_explored_1b_24", true)
    end
  end
end

function map:on_update()
  if torch_room3_1:get_sprite():get_animation() == "lit" and
     torch_room3_2:get_sprite():get_animation() == "lit" and
     torch_room3_3:get_sprite():get_animation() == "lit" and
     torch_room3_4:get_sprite():get_animation() == "lit" and
     torch_room3_5:get_sprite():get_animation() == "lit" and
     not game:get_value("dungeon_8_explored_1b_3") then
    sol.audio.play_sound("lamp")
    game:set_value("dungeon_8_explored_1b_3", true)
  end

  -- Win Conditions (12 total).
  if game:get_value("dungeon_8_explored_1b_3") and game:get_value("dungeon_8_explored_1b_4") and game:get_value("dungeon_8_explored_1b_9") and game:get_value("dungeon_8_explored_1b_10") and game:get_value("dungeon_8_explored_1b_11") then self:game_won() end  -- 1st Column
  if game:get_value("dungeon_8_explored_1b_2") and game:get_value("dungeon_8_explored_1b_5") and game:get_value("dungeon_8_explored_1b_8") and game:get_value("dungeon_8_explored_1b_12") and game:get_value("dungeon_8_explored_1b_13") then self:game_won() end  -- 2nd Column
  if game:get_value("dungeon_8_explored_1b_1") and game:get_value("dungeon_8_explored_1b_6") and game:get_value("dungeon_8_explored_1b_7") and game:get_value("dungeon_8_explored_1b_14") and game:get_value("dungeon_8_explored_1b_25") then self:game_won() end  -- 3rd Column
  if game:get_value("dungeon_8_explored_1b_15") and game:get_value("dungeon_8_explored_1b_16") and game:get_value("dungeon_8_explored_1b_20") and game:get_value("dungeon_8_explored_1b_21") and game:get_value("dungeon_8_explored_1b_24") then self:game_won() end  -- 4th Column
  if game:get_value("dungeon_8_explored_1b_23") and game:get_value("dungeon_8_explored_1b_22") and game:get_value("dungeon_8_explored_1b_19") and game:get_value("dungeon_8_explored_1b_18") and game:get_value("dungeon_8_explored_1b_17") then self:game_won() end  -- 5th Column
  if game:get_value("dungeon_8_explored_1b_11") and game:get_value("dungeon_8_explored_1b_12") and game:get_value("dungeon_8_explored_1b_16") and game:get_value("dungeon_8_explored_1b_17") and game:get_value("dungeon_8_explored_1b_25") then self:game_won() end  -- 1st Row
  if game:get_value("dungeon_8_explored_1b_10") and game:get_value("dungeon_8_explored_1b_13") and game:get_value("dungeon_8_explored_1b_14") and game:get_value("dungeon_8_explored_1b_15") and game:get_value("dungeon_8_explored_1b_18") then self:game_won() end  -- 2nd Row
  if game:get_value("dungeon_8_explored_1b_7") and game:get_value("dungeon_8_explored_1b_8") and game:get_value("dungeon_8_explored_1b_9") and game:get_value("dungeon_8_explored_1b_19") and game:get_value("dungeon_8_explored_1b_20") then self:game_won() end  -- 3rd Row
  if game:get_value("dungeon_8_explored_1b_4") and game:get_value("dungeon_8_explored_1b_5") and game:get_value("dungeon_8_explored_1b_6") and game:get_value("dungeon_8_explored_1b_21") and game:get_value("dungeon_8_explored_1b_22") then self:game_won() end  -- 4th Row
  if game:get_value("dungeon_8_explored_1b_1") and game:get_value("dungeon_8_explored_1b_2") and game:get_value("dungeon_8_explored_1b_3") and game:get_value("dungeon_8_explored_1b_23") and game:get_value("dungeon_8_explored_1b_24") then self:game_won() end  -- 5th Row
  if game:get_value("dungeon_8_explored_1b_11") and game:get_value("dungeon_8_explored_1b_13") and game:get_value("dungeon_8_explored_1b_7") and game:get_value("dungeon_8_explored_1b_21") and game:get_value("dungeon_8_explored_1b_23") then self:game_won() end  -- 1st Diagonal
  if game:get_value("dungeon_8_explored_1b_17") and game:get_value("dungeon_8_explored_1b_15") and game:get_value("dungeon_8_explored_1b_7") and game:get_value("dungeon_8_explored_1b_5") and game:get_value("dungeon_8_explored_1b_3") then self:game_won() end  -- 2nd Diagonal
end