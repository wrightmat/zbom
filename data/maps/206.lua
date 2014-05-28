local map = ...
local game = map:get_game()

---------------------------------------
-- Dungeon 5: Lakebed Lair (Floor 1) --
---------------------------------------

function map:on_started(destination)
  chest_big_key:set_enabled(false)
end

function map:on_obtained_treasure(treasure_item, treasure_variant, treasure_savegame_variable)
  if treasure_name == book_mudora and treasure_variant == 4 then
    game:set_dungeon_finished(5)
  end
end

if miniboss_aquadraco ~= nil then
 function miniboss_aquadraco:on_dead()
  map:open_doors("door_miniboss")
  sol.audio.play_sound("boss_killed")
  sol.timer.start(1000, function()
  sol.audio.play_music("temple_lake")
  end)
 end
end

for enemy in map:get_entities("aquadracini") do
  enemy.on_dead = function()
    if not map:has_entities("aquadracini") and not game:get_value("b1129") then
      chest_big_key:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

for enemy in map:get_entities("tektite") do
  enemy.on_dead = function()
    if not map:has_entities("tektite") then
      grate:set_enabled(false)
      sol.audio.play_sound("secret")
    end
  end
end
