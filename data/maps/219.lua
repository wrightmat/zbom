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
  if game:get_value("dungeon_8_room1_lit") then room_overlay_1:get_sprite():set_direction(3) else room_overlay_1:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room2_lit") then
    room_overlay_2:get_sprite():set_direction(3)
    room2_gate_e1:set_enabled(false)
    room2_gate_e2:set_enabled(false)
    room1_gate_w1:set_enabled(false)
    room1_gate_w2:set_enabled(false)
  else
    room_overlay_2:get_sprite():set_direction(1)
  end
  if game:get_value("dungeon_8_room3_lit") then room_overlay_3:get_sprite():set_direction(3) else room_overlay_3:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room4_lit") then room_overlay_4:get_sprite():set_direction(3) else room_overlay_4:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room5_lit") then room_overlay_5:get_sprite():set_direction(3) else room_overlay_5:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room6_lit") then room_overlay_6:get_sprite():set_direction(3) else room_overlay_6:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room7_lit") then room_overlay_7:get_sprite():set_direction(3) else room_overlay_7:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room8_lit") then room_overlay_8:get_sprite():set_direction(3) else room_overlay_8:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room9_lit") then
    room_overlay_9:get_sprite():set_direction(3)
    room9_gate_e1:set_enabled(false)
    room9_gate_e2:set_enabled(false)
    room12_gate_w1:set_enabled(false)
    room12_gate_w2:set_enabled(false)
  else
    room_overlay_9:get_sprite():set_direction(1)
  end
  if game:get_value("dungeon_8_room10_lit") then room_overlay_10:get_sprite():set_direction(3) else room_overlay_10:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room11_lit") then room_overlay_11:get_sprite():set_direction(3) else room_overlay_11:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room12_lit") then room_overlay_12:get_sprite():set_direction(3) else room_overlay_12:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room13_lit") then room_overlay_13:get_sprite():set_direction(3) else room_overlay_13:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room14_lit") then room_overlay_14:get_sprite():set_direction(3) else room_overlay_14:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room15_lit") then room_overlay_15:get_sprite():set_direction(3) else room_overlay_15:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room16_lit") then room_overlay_16:get_sprite():set_direction(3) else room_overlay_16:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room17_lit") then room_overlay_17:get_sprite():set_direction(3) else room_overlay_17:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room18_lit") then room_overlay_18:get_sprite():set_direction(3) else room_overlay_18:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room19_lit") then room_overlay_19:get_sprite():set_direction(3) else room_overlay_19:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room20_lit") then room_overlay_20:get_sprite():set_direction(3) else room_overlay_20:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room21_lit") then room_overlay_21:get_sprite():set_direction(3) else room_overlay_21:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room22_lit") then room_overlay_22:get_sprite():set_direction(3) else room_overlay_22:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room23_lit") then room_overlay_23:get_sprite():set_direction(3) else room_overlay_23:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room24_lit") then room_overlay_24:get_sprite():set_direction(3) else room_overlay_24:get_sprite():set_direction(1) end
  if game:get_value("dungeon_8_room25_lit") then room_overlay_25:get_sprite():set_direction(3) else room_overlay_25:get_sprite():set_direction(1) end
end

function map:on_started(destination)
  if destination == from_above then
    sol.timer.start(self, 1000, function()
      map:move_camera(992, 1453, 250, function()
        game:start_dialog("shadow_link.sanctum_basement", game:get_player_name(), function()
          shadow_link:get_sprite():fade_out()
        end)
      end, 500, 10000)
    end)
  end
  game:set_value("dungeon_8_room25_lit", true)
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
    stairs_1:set_enabled(true)
    stairs_2:set_enabled(true)
    stairs_3:set_enabled(true)
  end, 500, 2000)
end

for enemy in map:get_entities("room_1") do
  enemy.on_dead = function()
print("room 1 enemy dead")
    if not map:has_entities("room_1") then
print("all room 1 dead")
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_room1_lit", true)
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
    -- puzzle solved!
    arrow_puzzle_correct = true
    arrow_puzzle_nb_correct = 0
    sol.audio.play_sound("lamp")
    game:set_value("dungeon_8_room2_lit", true)
  else
    reset_arrow_puzzle()
  end
end

for enemy in map:get_entities("room_4") do
  enemy.on_dead = function()
    if not map:has_entities("room_4") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_room4_lit", true)
    end
  end
end

function room9_switch_1:on_activated()
  room9_pit_2:set_enabled(false)
  room9_pit_4:set_enabled(false)
  room9_1 = true
  if room9_1 and room9_2 and room9_3 then game:set_value("dungeon_8_room9_lit", true) end
end
function room9_switch_2:on_activated()
  room9_pit_1:set_enabled(false)
  room9_2 = true
  if room9_1 and room9_2 and room9_3 then game:set_value("dungeon_8_room9_lit", true) end
end
function room9_switch_3:on_activated()
  room9_pit_3:set_enabled(false)
  room9_3 = true
  if room9_1 and room9_2 and room9_3 then game:set_value("dungeon_8_room9_lit", true) end
end

for enemy in map:get_entities("room_12") do
  enemy.on_dead = function()
    if not map:has_entities("room_12") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_room12_lit", true)
    end
  end
end

for enemy in map:get_entities("room_14") do
  enemy.on_dead = function()
    if not map:has_entities("room_14") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_room14_lit", true)
    end
  end
end

for enemy in map:get_entities("room_20") do
  enemy.on_dead = function()
    if not map:has_entities("room_20") then
      sol.audio.play_sound("lamp")
      game:set_value("dungeon_8_room20_lit", true)
    end
  end
end

function map:on_update()
  if torch_room3_1:get_sprite():get_animation() == "lit" and
     torch_room3_2:get_sprite():get_animation() == "lit" and
     torch_room3_3:get_sprite():get_animation() == "lit" and
     torch_room3_4:get_sprite():get_animation() == "lit" and
     torch_room3_5:get_sprite():get_animation() == "lit" and
     not game:get_value("dungeon_8_room3_lit") then
    sol.audio.play_sound("lamp")
    game:set_value("dungeon_8_room3_lit", true)
  end

  -- Win Conditions (12 total).
  if game:get_value("dungeon_8_room3_lit") and game:get_value("dungeon_8_room4_lit") and game:get_value("dungeon_8_room9_lit") and game:get_value("dungeon_8_room10_lit") and game:get_value("dungeon_8_room11_lit") then self:game_won() end  -- 1st Column
  if game:get_value("dungeon_8_room2_lit") and game:get_value("dungeon_8_room5_lit") and game:get_value("dungeon_8_room8_lit") and game:get_value("dungeon_8_room12_lit") and game:get_value("dungeon_8_room13_lit") then self:game_won() end  -- 2nd Column
  if game:get_value("dungeon_8_room1_lit") and game:get_value("dungeon_8_room6_lit") and game:get_value("dungeon_8_room7_lit") and game:get_value("dungeon_8_room14_lit") and game:get_value("dungeon_8_room25_lit") then self:game_won() end  -- 3rd Column
  if game:get_value("dungeon_8_room15_lit") and game:get_value("dungeon_8_room16_lit") and game:get_value("dungeon_8_room20_lit") and game:get_value("dungeon_8_room21_lit") and game:get_value("dungeon_8_room24_lit") then self:game_won() end  -- 4th Column
  if game:get_value("dungeon_8_room23_lit") and game:get_value("dungeon_8_room22_lit") and game:get_value("dungeon_8_room19_lit") and game:get_value("dungeon_8_room18_lit") and game:get_value("dungeon_8_room17_lit") then self:game_won() end  -- 5th Column
  if game:get_value("dungeon_8_room11_lit") and game:get_value("dungeon_8_room12_lit") and game:get_value("dungeon_8_room16_lit") and game:get_value("dungeon_8_room17_lit") and game:get_value("dungeon_8_room25_lit") then self:game_won() end  -- 1st Row
  if game:get_value("dungeon_8_room10_lit") and game:get_value("dungeon_8_room13_lit") and game:get_value("dungeon_8_room14_lit") and game:get_value("dungeon_8_room15_lit") and game:get_value("dungeon_8_room18_lit") then self:game_won() end  -- 2nd Row
  if game:get_value("dungeon_8_room7_lit") and game:get_value("dungeon_8_room8_lit") and game:get_value("dungeon_8_room9_lit") and game:get_value("dungeon_8_room19_lit") and game:get_value("dungeon_8_room20_lit") then self:game_won() end  -- 3rd Row
  if game:get_value("dungeon_8_room4_lit") and game:get_value("dungeon_8_room5_lit") and game:get_value("dungeon_8_room6_lit") and game:get_value("dungeon_8_room21_lit") and game:get_value("dungeon_8_room22_lit") then self:game_won() end  -- 4th Row
  if game:get_value("dungeon_8_room1_lit") and game:get_value("dungeon_8_room2_lit") and game:get_value("dungeon_8_room3_lit") and game:get_value("dungeon_8_room23_lit") and game:get_value("dungeon_8_room24_lit") then self:game_won() end  -- 5th Row
  if game:get_value("dungeon_8_room11_lit") and game:get_value("dungeon_8_room13_lit") and game:get_value("dungeon_8_room7_lit") and game:get_value("dungeon_8_room21_lit") and game:get_value("dungeon_8_room23_lit") then self:game_won() end  -- 1st Diagonal
  if game:get_value("dungeon_8_room17_lit") and game:get_value("dungeon_8_room15_lit") and game:get_value("dungeon_8_room7_lit") and game:get_value("dungeon_8_room5_lit") and game:get_value("dungeon_8_room3_lit") then self:game_won() end  -- 2nd Diagonal
end