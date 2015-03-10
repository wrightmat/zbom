local entity = ...
local game = entity:get_game()

function entity:on_created()
  self:set_drawn_in_y_order(true)
  self:set_traversable_by("hero", false)
  --if...then
  --self:remove()
end

function entity:on_interaction()
  if game:get_value("i1024") <= 80 then
    game:start_dialog("pim.0.stamina")
  else
    if game:get_value("i1925") <= 2 then
      game:start_dialog("pim."..game:get_value("i1925")..".house")
      game:set_value("i1925", game:get_value("i1925")+1)
    elseif game:get_value("i1925") >=4 then
      game:start_dialog("pim.2.house")
    else
      game:start_dialog("pim.3.house", function()
	game:set_value("i1925", 4)
	hero:start_treasure("apple")
      end)
    end
  end
end
