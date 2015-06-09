local map = ...
local game = map:get_game()

------------------------------------
-- Dungeon 2: Sacred Grove Temple --
------------------------------------

local torches_puzzle_nb_enabled = 0
local torches_puzzle_correct = false
local arrow_puzzle_nb_correct = 0
local arrow_puzzle_correct = false

function map:on_started(destination)
  if destination == from_outside then
    -- Since the world starts outside in this dungeon, dying
    -- defaultly starts the hero back at the last map change
    -- (often a house in Ordon) - we override that behavior.
    game:set_starting_location("203", "from_outside")
  end
  -- hidden chests
  if not game:get_value("b1066") then chest_jade:set_enabled(false) end
  if not game:get_value("b1055") then chest_map:set_enabled(false) end
  -- open up miniboss shutter doors that will close later during battle
  map:set_doors_open("door_miniboss")
  if game:get_value("b1067") then map:set_doors_open("room15_shutter") end
  if not game:get_value("b1057") then miniboss_mothulita:set_enabled(false) end
  -- if hero has bow, then close the arrow switch-activated doors
  if game:get_value("b2003") then
    --map:set_doors_open("room6_shutter_2", false)
  else
    map:set_doors_open("room6_shutter")
  end
end

function map:on_obtained_treasure(treasure_item, treasure_variant, treasure_savegame_variable)
  if treasure_name == book_mudora and treasure_variant == 1 then
    game:set_dungeon_finished(2) --first dungeon is actually the sewers
  end
end

function sensor_open_room1:on_activated()
  -- open only if big key in inventory (helps prevent running around)
  if game:get_value("b1053") then map:open_doors("room1_shutter") end
end
function sensor_close_room1:on_activated()
  if map:get_entity("hero"):get_direction() == 2 then map:close_doors("room1_shutter") end
end
function sensor_open_room9:on_activated()
  map:open_doors("room9_shutter")
end
function sensor_close_room9:on_activated()
  map:close_doors("room9_shutter")
end
function sensor_open_room6:on_activated()
  map:open_doors("room6_shutter")
  sensor_close_room6:set_enabled(true)
end
function sensor_close_room6:on_activated()
  map:close_doors("room6_shutter")
end

function sensor_miniboss_start:on_activated()
  if not game:get_value("b1057") then
    miniboss_mothulita:set_enabled(true)
    map:close_doors("door_miniboss")
    sol.audio.play_music("miniboss")
  end
end

function sensor_out_torches_room:on_activated()
  torches_puzzle_nb_enabled = 0
  torches_puzzle_correct = false
  torch_room6_1:get_sprite():set_animation("unlit")
  torch_room6_2:get_sprite():set_animation("unlit")
  torch_room6_3:get_sprite():set_animation("unlit")
  torch_room6_4:get_sprite():set_animation("unlit")
  torch_room6_5:get_sprite():set_animation("unlit")
end

function room1_arrow:on_activated()
  map:open_doors("room1_shutter")
end

function room6_arrow_1:on_activated()
  room6_arrow_1:set_locked(true)
  if room6_arrow_2:is_activated() then
    map:open_doors("room6_shutter")
    sensor_close_room6:set_enabled(false)
  end
end
function room6_arrow_2:on_activated()
  room6_arrow_2:set_locked(true)
  if room6_arrow_1:is_activated() then
    map:open_doors("room6_shutter")
    sensor_close_room6:set_enabled(false)
  end
end

local function reset_arrow_puzzle()
  sol.audio.play_sound("wrong")
  room15_arrow_1:set_locked(false)
  room15_arrow_2:set_locked(false)
  room15_arrow_3:set_locked(false)
  room15_arrow_4:set_locked(false)
  room15_arrow_1:set_activated(false)
  room15_arrow_2:set_activated(false)
  room15_arrow_3:set_activated(false)
  room15_arrow_4:set_activated(false)
  arrow_puzzle_correct = false
  arrow_puzzle_nb_correct = 0
end

function room15_arrow_1:on_activated()
  if arrow_puzzle_nb_correct == 0 then
    room15_arrow_1:set_locked(true)
    arrow_puzzle_nb_correct = 1
  else
    reset_arrow_puzzle()
  end
end
function room15_arrow_2:on_activated()
  if arrow_puzzle_nb_correct == 1 then
    room15_arrow_2:set_locked(true)
    arrow_puzzle_nb_correct = 2
  else
    reset_arrow_puzzle()
  end
end
function room15_arrow_3:on_activated()
  if arrow_puzzle_nb_correct == 2 then
    room15_arrow_3:set_locked(true)
    arrow_puzzle_nb_correct = 3
  else
    reset_arrow_puzzle()
  end
end
function room15_arrow_4:on_activated()
  if arrow_puzzle_nb_correct == 3 then
    room15_arrow_4:set_locked(true)
    -- puzzle solved!
    sol.audio.play_sound("secret")
    arrow_puzzle_correct = true
    arrow_puzzle_nb_correct = 0
    map:open_doors("room15_shutter")
    game:set_value("b1067", true)
  else
    reset_arrow_puzzle()
  end
end

for enemy in map:get_entities("room2") do
  enemy.on_dead = function()
    if not map:has_entities("room2_rope") and not game:get_value("b1066") then
      chest_jade:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

for enemy in map:get_entities("room10") do
  enemy.on_dead = function()
    if not map:has_entities("room10_tentacle") and not game:get_value("b1055") then
      chest_map:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

if miniboss_mothulita ~= nil then
  function miniboss_mothulita:on_dead()
    sol.audio.play_sound("boss_killed")
    map:open_doors("door_miniboss")
    game:set_value("b1057", true)
    sol.audio.play_music("temple_grove")
  end
end

local function torch_puzzle_wrong()
  sol.audio.play_sound("wrong")
  torches_puzzle_nb_enabled = 0
  torches_puzzle_correct = false
  map:create_enemy{
    name = "room6_chuchu",
    layer = 0,
    x = 1384,
    y = 786,
    direction = 3,
    breed = "chuchu_green",
    treasure_name = "magic_flask" }
  map:create_enemy{
    name = "room6_chuchu",
    layer = 0,
    x = 1520,
    y = 728,
    direction = 3,
    breed = "chuchu_green" }
  torch_room6_1:get_sprite():set_animation("unlit")
  torch_room6_2:get_sprite():set_animation("unlit")
  torch_room6_3:get_sprite():set_animation("unlit")
  torch_room6_4:get_sprite():set_animation("unlit")
  torch_room6_5:get_sprite():set_animation("unlit")
end

function torch_room6_1:on_interaction_item(lamp)
  if not torches_puzzle_correct then
    if torches_puzzle_nb_enabled == 0 then
      torch_room6_1:get_sprite():set_animation("lit")
      torches_puzzle_nb_enabled = torches_puzzle_nb_enabled + 1
    else
      torch_puzzle_wrong()
    end
  end
end
function torch_room6_2:on_interaction_item(lamp)
  if not torches_puzzle_correct then
    if torches_puzzle_nb_enabled == 1 then
      torch_room6_2:get_sprite():set_animation("lit")
      torches_puzzle_nb_enabled = torches_puzzle_nb_enabled + 1
    else
      torch_puzzle_wrong()
    end
  end
end
function torch_room6_3:on_interaction_item(lamp)
  if not torches_puzzle_correct then
    if torches_puzzle_nb_enabled == 2 then
      torch_room6_3:get_sprite():set_animation("lit")
      torches_puzzle_nb_enabled = torches_puzzle_nb_enabled + 1
    else
      torch_puzzle_wrong()
    end
  end
end
function torch_room6_4:on_interaction_item(lamp)
  if not torches_puzzle_correct then
    if torches_puzzle_nb_enabled == 3 then
      torch_room6_4:get_sprite():set_animation("lit")
      torches_puzzle_nb_enabled = torches_puzzle_nb_enabled + 1
    else
      torch_puzzle_wrong()
    end
  end
end
function torch_room6_5:on_interaction_item(lamp)
  if not torches_puzzle_correct then
    if torches_puzzle_nb_enabled == 4 then
      torch_room6_5:get_sprite():set_animation("lit")
      sol.audio.play_sound("secret")
      torches_puzzle_correct = true
      torches_puzzle_nb_enabled = 0
      map:open_doors("room6_shutter_2")
    else
      torch_puzzle_wrong()
    end
  end
end

function torch_moth:on_interaction()
  game():start_dialog("torch.grove_temple_moths")
end
function torch_moth:on_interaction_item(lamp)
  torch_moth:get_sprite():set_animation("lit")
  sol.timer.start(10000, function()
    torch_moth:get_sprite():set_animation("unlit")
  end)
end
