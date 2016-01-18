local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local hero_facing = false
local action_command = false

if game:get_value("i1631")==nil then game:set_value("i1631", 0) end

function entity:on_created()
  self:set_traversable_by("hero", false)
  self:set_drawn_in_y_order(true)
  if game:get_value("b1630") then
    entity:get_sprite():set_animation(entity:get_name())
  else
    -- Fetch Quest hasn't been initiated, so remove the entity.
    entity:remove()
  end
  if entity:get_name() == "plant_baba" and game:get_value("b1632") then entity:remove() end
    if entity:get_name() == "plant_corydalis" and game:get_value("b1633") then entity:remove() end
    if entity:get_name() == "plant_deku" and game:get_value("b1634") then entity:remove() end
    if entity:get_name() == "plant_exotic" and game:get_value("b1635") then entity:remove() end
    if entity:get_name() == "plant_flame" and game:get_value("b1636") then entity:remove() end
    if entity:get_name() == "plant_frost" and game:get_value("b1637") then entity:remove() end
    if entity:get_name() == "plant_gnarled" and game:get_value("b1638") then entity:remove() end
    if entity:get_name() == "plant_goponga" and game:get_value("b1639") then entity:remove() end
    if entity:get_name() == "plant_hibiscus" and game:get_value("b1640") then entity:remove() end
    if entity:get_name() == "plant_lavender" and game:get_value("b1641") then entity:remove() end
    if entity:get_name() == "plant_milkweed" and game:get_value("b1642") then entity:remove() end
    if entity:get_name() == "plant_mystical" and game:get_value("b1643") then entity:remove() end
    if entity:get_name() == "plant_pikit" and game:get_value("b1644") then entity:remove() end
    if entity:get_name() == "plant_sea" and game:get_value("b1645") then entity:remove() end
    if entity:get_name() == "plant_simple" and game:get_value("b1646") then entity:remove() end
    if entity:get_name() == "plant_town" and game:get_value("b1647") then entity:remove() end
end

entity:add_collision_test("facing", function(entity, other)
  if other:get_type() == "hero" then 
    hero_facing = true
    if hero_facing then
      game:set_custom_command_effect("action", "look")
      action_command = true
    else
      game:set_custom_command_effect("action", nil)
    end
  end
end)

function entity:on_interaction()
  -- If the plant is interacted with, then start
  -- the dialog and increment the quest counter.
  game:start_dialog("plants."..entity:get_name(), function()
    game:set_value("i1631", game:get_value("i1631")+1)
    if entity:get_name() == "plant_baba" then game:set_value("b1632", true) end
    if entity:get_name() == "plant_corydalis" then game:set_value("b1633", true) end
    if entity:get_name() == "plant_deku" then game:set_value("b1634", true) end
    if entity:get_name() == "plant_exotic" then game:set_value("b1635", true) end
    if entity:get_name() == "plant_flame" then game:set_value("b1636", true) end
    if entity:get_name() == "plant_frost" then game:set_value("b1637", true) end
    if entity:get_name() == "plant_gnarled" then game:set_value("b1638", true) end
    if entity:get_name() == "plant_goponga" then game:set_value("b1639", true) end
    if entity:get_name() == "plant_hibiscus" then game:set_value("b1640", true) end
    if entity:get_name() == "plant_lavender" then game:set_value("b1641", true) end
    if entity:get_name() == "plant_milkweed" then game:set_value("b1642", true) end
    if entity:get_name() == "plant_mystical" then game:set_value("b1643", true) end
    if entity:get_name() == "plant_pikit" then game:set_value("b1644", true) end
    if entity:get_name() == "plant_sea" then game:set_value("b1645", true) end
    if entity:get_name() == "plant_simple" then game:set_value("b1646", true) end
    if entity:get_name() == "plant_town" then game:set_value("b1647", true) end

    -- Lastly, remove the plant - it's taken.
    entity:remove()
  end)
end

function entity:on_update()
  if action_command and not hero_facing then
    game:set_custom_command_effect("action", nil)
    action_command = false
  end
  hero_facing = false
end