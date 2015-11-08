local map = ...
local game = map:get_game()

--------------------------------------
-- Outside World G5 (Zora's Domain) --
--------------------------------------

function map:on_started()
  if not game:get_value("b2029") then quest_trading_scale:remove() end
  if not game:get_value("b1721") then chest_heart_piece_2:set_enabled(false) end
end

for enemy in map:get_entities("pincer") do
  enemy.on_dead = function()
    if not map:has_entities("pincer") and not game:get_value("b1721") then
      chest_heart_piece_2:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

function npc_zora_1:on_interaction()
  game:set_dialog_style("default")
  sol.audio.play_sound("zora")
  if game:get_item("tunic"):get_variant() < 3 then
    game:start_dialog("zora.0.tunic")
  else
    game:start_dialog("zora.0.domain")
  end
end

function npc_zora_2:on_interaction()
  game:set_dialog_style("default")
  sol.audio.play_sound("zora")
  if game:get_item("tunic"):get_variant() < 3 then
    game:start_dialog("zora.0.tunic")
  else
    game:start_dialog("zora.0.domain")
  end
end

function npc_zora_3:on_interaction()
  game:set_dialog_style("default")
  sol.audio.play_sound("zora")
  game:start_dialog("zora.0.domain")
end

function npc_zora_trading:on_interaction()
  game:set_dialog_style("default")
  sol.audio.play_sound("zora")
  if game:get_value("b2029") then
    game:start_dialog("zora.0.trading", function(answer)
      if answer == 1 then
        -- give him the vase, get the zora scale
        game:start_dialog("zora.0.trading_yes", function()
          hero:start_treasure("trading", 10)
          game:set_value("b2030", true)
          game:set_value("b2029", false)
          quest_trading_scale:remove()
        end)
      else
        -- don't give him the vase
        game:start_dialog("zora.0.trading_no")
      end
    end)
  else
    game:start_dialog("zora.0.domain")
  end
end