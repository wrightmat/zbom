local map = ...
local game = map:get_game()

local boss_visible = false

------------------------------------------------------------------
-- Island Palace Boss Run - Defeat all bosses for a heart piece --
------------------------------------------------------------------

if game:get_value("i1613") == nil then game:set_value("i1613", 1) end

function map:on_started(destination)
game:set_value("i1613", 1)
  map:set_tileset("13")
  warp:set_enabled(false)
end

function sensor_boss:on_activated()
  sol.audio.play_music("boss")
  if game:get_value("i1613") == 1 then
    map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "poe_big", treasure_name = "fairy" })
  elseif game:get_value("i1613") == 2 then
    map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "gohma", treasure_name = "arrow", treasure_variant = 3 })
  elseif game:get_value("i1613") == 3 then
    local boss = map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "manhandla", treasure_name = "apple" })
    boss:set_enabled()
  elseif game:get_value("i1613") == 4 then
    map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "vire", treasure_name = "bomb", treasure_variant = 3 })
    map:create_enemy({ name = "boss_2", x = 416, y = 192, layer = 0, direction = 3, breed = "vire_sorceror", treasure_name = "bomb", treasure_variant = 3 })
  elseif game:get_value("i1613") == 5 then
    map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "plasmarine_blue", treasure_name = "magic_flask" })
    map:create_enemy({ name = "boss_2", x = 416, y = 192, layer = 0, direction = 3, breed = "plasmarine_red", treasure_name = "magic_flask" })
  elseif game:get_value("i1613") == 6 then
    map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "stalfos_knight", treasure_name = "fairy" })
  elseif game:get_value("i1613") == 7 then
    map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "helmaroc_rex", treasure_name = "arrow", treasure_variant = 3 })
  elseif game:get_value("i1613") == 8 then
    map:create_enemy({ name = "boss", x = 416, y = 168, layer = 0, direction = 3, breed = "shadow_link", treasure_name = "arrow", treasure_variant = 3 })
    map:create_enemy({ name = "boss_2", x = 416, y = 192, layer = 0, direction = 3, breed = "zirna", treasure_name = "arrow", treasure_variant = 3 })
  end
  boss_visible = true
end

function map:on_update()
  if not map:has_entities("boss") then
    if game:get_value("i1613") < 8 and not warp:is_enabled() and boss_visible then
print("warp enabled")
      warp:set_enabled(true)
      sol.audio.play_music("underground")
    elseif game:get_value("i1613") == 8 and boss_visible then
print("door enabled")
      map:open_doors("door")
      game:set_value("i1613", 9)
      sol.audio.play_music("underground")
    end
  end
end

function sensor_tileset:on_activated()
  if game:get_value("i1613") == 1 then
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
  end
end

function sensor_room:on_activated()
  map:set_tileset("13")
end

function warp:on_activated()
  game:set_value("i1613", game:get_value("i1613")+1)
end