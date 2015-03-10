local entity = ...
local game = entity:get_game()

-- Pim is an NPC which appears on several maps and will sell
-- our hero a pumpkin if he doesn't have one already.

function entity:on_created()
  self:set_drawn_in_y_order(true)
  self:set_traversable_by("hero", false)
  if game:get_value("i1845") > 1 and game:get_map():get_id() ~= "1" then
    self:remove()
  end
end

function entity:on_interaction()
  if game:get_value("i1024") <= 80 then
    game:start_dialog("pim.0.stamina")
  else
    if game:get_value("i1925") <= 2 then
      game:start_dialog("pim."..game:get_value("i1925")..".house")
      game:set_value("i1925", game:get_value("i1925")+1)
    elseif game:get_value("i1925") >=4 then
      if game:get_map():get_id() == "1" then
	-- In his house, don't sell pumpkins
        game:start_dialog("pim.2.house")
      else
	game:start_dialog("pim.2.pumpkin", function(answer)
	  if answer == 1 then
	    hero:start_treasure("pumpkin")
	  end
	end)
    else
      game:start_dialog("pim.3.house", function()
	game:set_value("i1925", 4)
	hero:start_treasure("apple")
      end)
    end
  end
end
