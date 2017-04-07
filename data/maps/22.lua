local map = ...
local game = map:get_game()

---------------------------------------------------------------------------------------------
-- Outside World C14 (Faron Woods/Beach) - Grove Temple Boss (Gohma), Bananas & Tokay Chef --
---------------------------------------------------------------------------------------------

if game:get_value("i1068") == nil then game:set_value("i1068", 0) end

function map:on_started(destination)
  if not game:get_value("b2027") then quest_trading_bananas:remove() end
  if not game:get_value("b1058") then
    to_book_chamber:set_enabled(false)
    boss_heart:set_enabled(false)
    if destination ~= from_temple_boss then
      -- if not coming from the boss door then deactivate the boss
      if boss_gohma ~= nil then boss_gohma:set_enabled(false) end
    else
      if boss_gohma ~= nil then
        sol.audio.play_music("boss")
        boss_gohma:set_enabled(true)
      end
    end
  end
  if game:get_value("i1068") < 6 then
    npc_tokay_Chef:remove()
    to_C15:remove()
  elseif game:get_value("i1068") == 6 then
    to_C15:remove()
  elseif game:get_value("i1068") > 6 then
    gerudo_ship:remove()
    map:set_entities_enabled("ship_block", false)
  end

  if destination == from_house_chef then
    sol.audio.play_music("beach")
  end

  if game:get_time_of_day() == "night" and npc_tokay_Chef ~= nil then
    npc_tokay_Chef:remove()
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
    for entity in game:get_map():get_entities("windows_") do
      entity:set_enabled(true)
    end
  end
end

function npc_tokay_Chef:on_interaction()
  if game:get_value("b2027") then
    game:start_dialog("chef.0.trading", function(answer)
      if answer == 1 then
        -- Give him the Dog Food, get the Bananas.
        game:start_dialog("chef.0.trading_yes", function()
          hero:start_treasure("trading", 8)
          game:set_value("b2028", true)
          game:set_value("b2027", false)
          quest_trading_bananas:remove()
        end)
      else
        -- Don't give him the Dog Food.
        game:start_dialog("chef.0.trading_no")
      end
    end)
  else
    game:start_dialog("chef.0.beach")
  end
end

if boss_gohma ~= nil then
 function boss_gohma:on_dead()
  sol.audio.play_sound("boss_killed")
  boss_heart:set_enabled(true)
  sol.timer.start(200, function()
    sol.audio.play_music("faron_woods")
    to_book_chamber:set_enabled(true)
    to_temple_boss:set_enabled(false)
    to_temple_jade:set_enabled(false)
    sol.audio.play_sound("secret")
  end)
  game:set_value("b1058", true)
 end
end