local map = ...
local game = map:get_game()

local boss_visible = false

------------------------------------------------------------------
-- Island Palace Boss Run - Defeat all bosses for a heart piece --
------------------------------------------------------------------

if game:get_value("i1613") == nil then game:set_value("i1613", 1) end

function map:on_started(destination)
print(game:get_value("i1613"))
  map:set_tileset("13")
  warp:set_enabled(false)
  flying_heart:get_sprite():set_animation("heart")
  flying_heart_2:get_sprite():set_animation("heart")
  if game:get_value("b1190") then map:set_doors_open("door_shutter") end
end

function flying_heart:on_obtained()
  self:get_game():add_life(4); self:get_game():add_stamina(8)
end
function flying_heart_2:on_obtained()
  self:get_game():add_life(4); self:get_game():add_stamina(8)
end

function sensor_boss:on_activated()
  if game:get_value("i1613") <= 8 then
    if warp:is_enabled() == false then
      warp:set_enabled(false)
      sol.audio.play_music("boss")
      boss_visible = true
    end
  else
    map:open_doors("door")
  end
  if game:get_value("i1613") == 1 and boss == nil and warp:is_enabled() == false then
    local boss = map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "poe_big", treasure_name = "fairy" })
  elseif game:get_value("i1613") == 2 and boss == nil and warp:is_enabled() == false then
    local boss = map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "gohma", treasure_name = "arrow", treasure_variant = 3 })
  elseif game:get_value("i1613") == 3 and boss == nil and warp:is_enabled() == false then
    local boss = map:create_enemy({ name = "boss_manhandla", x = 416, y = 168, layer = 0, direction = 3, breed = "manhandla", treasure_name = "apple" })
    boss:set_enabled(false); boss:set_enabled(true) -- Disable and re-enable, which prompts creation of the heads.
  elseif game:get_value("i1613") == 4 and boss == nil and boss_2 == nil and warp:is_enabled() == false then
    local boss = map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "vire", treasure_name = "bomb", treasure_variant = 3 })
    local boss_2 = map:create_enemy({ name = "boss_2", x = 416, y = 192, layer = 0, direction = 3, breed = "vire_sorceror", treasure_name = "bomb", treasure_variant = 3 })
  elseif game:get_value("i1613") == 5 and boss == nil and boss_2 == nil and warp:is_enabled() == false then
    local boss = map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "plasmarine_blue", treasure_name = "magic_flask" })
    local boss_2 = map:create_enemy({ name = "boss_2", x = 416, y = 192, layer = 0, direction = 3, breed = "plasmarine_red", treasure_name = "magic_flask" })
  elseif game:get_value("i1613") == 6 and boss == nil and warp:is_enabled() == false then
    local boss = map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "stalfos_knight", treasure_name = "fairy" })
  elseif game:get_value("i1613") == 7 and boss == nil and warp:is_enabled() == false then
    local boss = map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "helmaroc_rex", treasure_name = "arrow", treasure_variant = 3 })
  elseif game:get_value("i1613") == 8 and boss == nil and boss_2 == nil and warp:is_enabled() == false then
    local boss = map:create_enemy({ name = "boss", x = 376, y = 144, layer = 0, direction = 3, breed = "shadow_link", treasure_name = "arrow", treasure_variant = 3 })
    local boss_2 = map:create_enemy({ name = "boss_2", x = 480, y = 192, layer = 0, direction = 3, breed = "zirna", treasure_name = "arrow", treasure_variant = 3 })
  end
end

function map:on_update()
  if not map:has_entities("boss") then
    if game:get_value("i1613") < 8 and not warp:is_enabled() and boss_visible then
      warp:set_enabled(true)
      sol.audio.play_music("underground")
    elseif game:get_value("i1613") == 8 and not warp:is_enabled() and boss_visible then
      map:open_doors("door")
      game:set_value("i1613", 9)
      sol.audio.play_music("underground")
    end
  end
end

function sensor_tileset:on_activated()
  --[[if game:get_value("i1613") == 1 then
    map:set_tileset("4")
  elseif game:get_value("i1613") == 2 then
    map:set_tileset("5")
  elseif game:get_value("i1613") == 3 then
    map:set_tileset("6")
  elseif game:get_value("i1613") == 4 then
    map:set_tileset("7")
  elseif game:get_value("i1613") == 5 then
    map:set_tileset("8")
  elseif game:get_value("i1613") == 6 then
    map:set_tileset("9")
  elseif game:get_value("i1613") == 7 then
    map:set_tileset("10")
  elseif game:get_value("i1613") == 8 then
    map:set_tileset("11")
  end--]]
end

function sensor_room:on_activated()
  map:set_tileset("13")
end

function warp:on_activated()
  game:set_value("i1613", game:get_value("i1613")+1)
  map:set_tileset("13")
  warp:set_enabled(false)
end