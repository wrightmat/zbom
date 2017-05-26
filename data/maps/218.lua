local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 8: Interloper Sanctum (Floor 1) --
---------------------------------------------

function map:on_started(destination)
  if not game:get_value("b1190") then boss_zirna:set_enabled(false) end
  if not game:get_value("b1191") then
    boss_belahim:set_enabled(false)
    dark_mirror:set_enabled(false)
    dark_mirror_out:set_enabled(false)
  else bed_zelda:remove() end
  if not game:get_value("b1180") then chest_compass:set_enabled(false) end
  if not game:get_value("b1185") then chest_key_1:set_enabled(false) end
  if not game:get_value("b1183") then
    miniboss_shadow_link:set_enabled(false)
    chest_item:set_enabled(false); chest_item_block:set_enabled(false)
    miniboss_warp:set_enabled(false)
  else miniboss_warp:set_enabled(true) end
  if not game:get_value("b1190") or not game:get_value("b1191") then
    boss_heart:set_enabled(false)
  end
  -- If the ending was interrupted but both bosses were defeated, finish the game.
  if game:get_value("b1190") and game:get_value("b1191") then
    game:set_dungeon_finished(8)
    game:set_value("b1699", true)
    game:set_value("i1807", 8)
  end
end

local function finish_game()
  game:set_dungeon_finished(8)
  game:set_value("b1699", true)  -- Main quest completed - Dark Tribe defeated.
  game:set_value("i1807", 8) -- Remove the "Book of Mudora" quest too.
  
  game:start_dialog("ordona.8.boss_dead", game:get_player_name(), function()
    local m = sol.movement.create("target")
    m:set_target(880, 1200)
    game:get_hero():freeze()
    game:get_hero():set_animation("walking")
    m:start(game:get_hero(), function()
      game:get_hero():set_animation("book_mudora")
      sol.timer.start(game:get_map(), 1000, function()
        dark_mirror:set_enabled()
        dark_mirror_out:set_enabled()
        dark_mirror:get_sprite():fade_in(100, function()
          game:start_dialog("ordona.8.mirror", game:get_player_name(), function()
            m:set_target(880, 1032)
            game:get_hero():set_direction(1) -- Walking upward.
            game:get_hero():set_animation("walking")
            m:start(map:get_hero())
            sol.timer.start(game:get_map(), 1800, function()
              game:get_hero():set_animation("stopped")
              if bed_zelda ~= nil then bed_zelda:remove() end
              game:start_dialog("ordona.8.zelda", function()
                game:get_hero():teleport("84", "from_sanctum")  -- Teleport hero outside of Sanctum and roll the credits.
                sol.timer.start(game, 500, function() game:on_credits_started() end)
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

for enemy in map:get_entities("wizzrobe_room6") do
  enemy.on_dead = function()
    if not map:has_entities("wizzrobe_room6") and not game:get_value("b1180") then
      chest_compass:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

for enemy in map:get_entities("wizzrobe_room7") do
  enemy.on_dead = function()
    if not map:has_entities("wizzrobe_room7") and not game:get_value("b1185") then
      chest_key_1:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

function sensor_miniboss:on_activated()
  if miniboss_shadow_link ~= nil then
    map:close_doors("boss_door")
    map:remove_entities("wallmaster") -- Don't want hero taken during boss fight.
    miniboss_shadow_link:set_enabled(true)
    sol.audio.play_music("boss")
  end
end
if miniboss_shadow_link ~= nil then
  function miniboss_shadow_link:on_dead()
    game:set_value("b1131", true)
    map:open_doors("boss_door") -- Door out of boss chamber.
    map:open_doors("room11_shutter") -- door down to basement
    sol.audio.play_sound("boss_killed")
    chest_item:set_enabled(true); chest_item_block:set_enabled(true)
    sol.audio.play_sound("chest_appears")
    sol.audio.play_music("temple_sanctum")
  end
end

function sensor_boss:on_activated()
  if boss_belahim ~= nil and game:get_value("b1190") then
    boss_belahim:set_enabled(true)
    sol.audio.play_music("boss")
    map:close_doors("boss_door")
    map:remove_entities("wallmaster") -- Don't want hero taken during boss fight.
    game:set_value("final_boss_active", true)
  end
  if boss_zirna ~= nil and game:get_value("dungeon_8_explored_1b_complete") then
    boss_zirna:set_enabled(true)
    sol.audio.play_music("boss")
    map:close_doors("boss_door")
    map:remove_entities("wallmaster") -- Don't want hero taken during boss fight.
    game:set_value("final_boss_active", true)
  end
end
if boss_zirna ~= nil then
  function boss_zirna:on_dead()
    sol.timer.start(self:get_map(), 5000, function()
      game:start_dialog("belahim.0.speech_1", function()
        boss_belahim:set_enabled(true)
      end)
    end)
  end
end
if boss_belahim ~= nil then
  function boss_belahim:on_dead()
    game:get_map():remove_entities("shadow")
    sol.audio.play_sound("boss_killed")
    boss_heart:set_enabled(true)
    sol.audio.play_music("temple_sanctum")
    sol.timer.start(self:get_map(), 2000, function()
      if game:get_value("b1192") and not game:get_value("b1699") then
        finish_game() -- If heart piece is obtained, then do the final dialog!
      end
      return true
    end)
  end
end