local entity = ...
local map = entity:get_map()
local pushing = false
local block_on_switch = false
local lava_crust, ice_patch

-- Ice block: special block made of ice that can fill an
-- ice pit, turn lava solid, and freeze water.

function entity:on_created()
  self:set_size(16, 16)
  self:snap_to_grid()
  self:set_modified_ground("ice")
  self:set_traversable_by("hero", false)
  self:set_traversable_by("enemy", false)
  self:set_traversable_by("npc", false)
  self:set_traversable_by("custom_entity", true) -- To allow pushing block into pit.
  self:create_sprite("entities/ice_block")

  self:add_collision_test("facing", function(self, other)
    if other:get_type() == "hero" and not pushing then
      pushing = true
      local m = sol.movement.create("path")
      m:set_snap_to_grid(true)

      local sx, sy, sl = self:get_position()
      if other:get_direction() == 0 then
        if map:get_ground(sx+8,sy,sl) ~= "wall" and map:get_ground(sx+16,sy,sl) ~= "wall" then m:set_path({0,0}) end
      elseif other:get_direction() == 1 then
        if map:get_ground(sx,sy+8,sl) ~= "wall" and map:get_ground(sx,sy+16,sl) ~= "wall" then m:set_path({2,2}) end
      elseif other:get_direction() == 2 then
        if map:get_ground(sx-8,sy,sl) ~= "wall" and map:get_ground(sx-16,sy,sl) ~= "wall" then m:set_path({4,4}) end
      elseif other:get_direction() == 3 then
        if map:get_ground(sx,sy-8,sl) ~= "wall" and map:get_ground(sx,sy-16,sl) ~= "wall" then m:set_path({6,6}) end
      end
      m:start(self, function() pushing = false end)
    end
  end)

  self:add_collision_test("overlapping", function(self, other)
    if other:get_type() == "switch" and other:get_sprite():get_animation_set() == "entities/switch" then
      block_on_switch = true
      other:set_activated(true)
      if other:on_activated() ~= nil and not other.active then
        other:on_activated()
        other.active = true
      end
      sol.timer.start(map, 1000, function()
        if block_on_switch then
          return true
        else
          block_on_switch = false
          other:set_activated(false)
          if other:on_inactivated() ~= nil and other.active then
            other:on_inactivated()
            other.active = false
          end
        end
      end)
    elseif other:get_type() == "hole" then
      sol.audio.play_sound("hero_falls")
      self:remove()
    elseif other:get_type() == "fire" then
      sol.audio.play_sound("ice_melt")
      self:get_sprite():set_animation("destroy", function() self:remove() end)
    elseif other:get_type() == "explosion" then
      sol.audio.play_sound("ice_melt")
      self:get_sprite():set_animation("destroy", function() self:remove() end)
    else block_on_switch = false end
  end)

  local sx, sy, sl = self:get_position()
  self:on_position_changed(sx, sy, sl)
end

function entity:on_position_changed(x, y, layer)
  for e in map:get_entities("") do
    if e:get_type() == "dynamic_tile" then
      if self:overlaps(e) then -- If block overlaps dynamic tile
        if map:get_ground(e:get_position()) == "lava" then
          self:remove()
          if map:get_hero():get_direction() == 0 then -- Right
            lava_crust = map:create_custom_entity({ x=x+8, y=y-8, layer=layer, width=32, height=32, direction=0, sprite="entities/lava" })
          elseif map:get_hero():get_direction() == 1 then -- Up
            lava_crust = map:create_custom_entity({ x=x-8, y=y-16, layer=layer, width=32, height=32, direction=0, sprite="entities/lava" })
          elseif map:get_hero():get_direction() == 2 then -- Left
            lava_crust = map:create_custom_entity({ x=x-16, y=y-8, layer=layer, width=32, height=32, direction=0, sprite="entities/lava" })
          elseif map:get_hero():get_direction() == 3 then -- Down
            lava_crust = map:create_custom_entity({ x=x-8, y=y, layer=layer, width=32, height=32, direction=0, sprite="entities/lava" })
          end
          lava_crust:snap_to_grid()
          sol.audio.play_sound("freeze")
          lava_crust:set_modified_ground("traversable")
          lava_crust:set_traversable_by("hero", true)
          lava_crust:set_traversable_by("enemy", true)
          lava_crust:set_traversable_by("block", true)
          for e in map:get_entities("block") do
            e:bring_to_front()
          end
          sol.timer.start(map, 15000, function() lava_crust:remove() end)
        elseif map:get_ground(e:get_position()) == "deep_water" then
          self:remove()
          if map:get_hero():get_direction() == 0 then
            ice_patch = map:create_custom_entity({ x=x+8, y=y-8, layer=layer, width=32, height=32, direction=0, sprite="entities/ice" })
          elseif map:get_hero():get_direction() == 1 then
            ice_patch = map:create_custom_entity({ x=x-8, y=y-16, layer=layer, width=32, height=32, direction=0, sprite="entities/ice" })
          elseif map:get_hero():get_direction() == 2 then
            ice_patch = map:create_custom_entity({ x=x-16, y=y-8, layer=layer, width=32, height=32, direction=0, sprite="entities/ice" })
          elseif map:get_hero():get_direction() == 3 then
            ice_patch = map:create_custom_entity({ x=x-8, y=y, layer=layer, width=32, height=32, direction=0, sprite="entities/ice" })
          end
          ice_patch:snap_to_grid()
          sol.audio.play_sound("freeze")
          ice_patch:set_modified_ground("ice")
          ice_patch:set_traversable_by("hero", true)
          ice_patch:set_traversable_by("enemy", true)
          ice_patch:set_traversable_by("block", true)
          for e in map:get_entities("block") do
            e:bring_to_front()
          end
          sol.timer.start(map, 15000, function() ice_patch:remove() end)
        end
      end
    elseif e:get_type() == "wall" or e:get_type() == "hole" then
      e:stop_movement()
    end
  end
end