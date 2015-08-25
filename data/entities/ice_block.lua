local entity = ...
local map = entity:get_map()
local pushing = false
local block_on_switch = false

-- Ice block: special block made of ice that can fill an
-- ice pit, turn lava solid, and freeze water.

function entity:on_created()
  self:set_size(16, 16)
  self:snap_to_grid()
  self:set_modified_ground("ice")
  self:set_traversable_by("hero", false)
  self:set_traversable_by("dynamic_tile", true)
  self:set_traversable_by("custom_entity", true) --to allow pushing block into pit
  self:set_can_traverse("dynamic_tile", true)
  self:create_sprite("entities/ice_block")

  self:add_collision_test("facing", function(self, other)
    if other:get_type() == "hero" and not pushing then
      pushing = true
      local m = sol.movement.create("path")
      m:set_ignore_obstacles(false)
      m:set_snap_to_grid(true)

      if other:get_direction() == 0 then m:set_path({0,0})
      elseif other:get_direction() == 1 then m:set_path({2,2})
      elseif other:get_direction() == 2 then m:set_path({4,4})
      elseif other:get_direction() == 3 then m:set_path({6,6}) end
      m:start(self, function()
	pushing = false
      end)
    end
  end)

  self:add_collision_test("overlapping", function(self, other)
    local lava_crust, ice_patch
    if other:get_type() == "dynamic_tile" then
      local tsx, tsy = other:get_size()
      local tpx, tpy, tpl = other:get_position()
      local sx, sy, sl = self:get_position()
      self:clear_collision_tests()
      self:remove()
      if map:get_ground(sx,sy,sl) == "lava" then
        if (sx > tpx-32) and (sx < tpx+tsx+32) and (sy > tpy-32) and (sy < tpy+tsy+32) then
          lava_crust = map:create_custom_entity({ x = sx, y = sy, layer = sl, width = 32, height = 32, direction = 0 })
          lava_crust:snap_to_grid()
          sol.audio.play_sound("freeze")
          lava_crust:create_sprite("entities/lava")
          lava_crust:set_modified_ground("traversable")
          lava_crust:set_traversable_by("hero", true)
          lava_crust:set_traversable_by("enemy", true)
	  sol.timer.start(map, 15000, function()
	    lava_crust:remove()
	  end)
        end
      elseif map:get_ground(sx,sy,sl) == "deep_water" then
        if (sx > tpx-16) and (sx < tpx+tsx+16) and (sy > tpy-16) and (sy < tpy+tsy+16) then
          ice_patch = map:create_custom_entity({ x = sx, y = sy, layer = sl, width = 32, height = 32, direction = 0 })
          sol.audio.play_sound("freeze")
          ice_patch:create_sprite("entities/ice")
          ice_patch:set_modified_ground("ice")
          ice_patch:set_traversable_by("hero", true)
          ice_patch:set_traversable_by("enemy", true)
	  sol.timer.start(map, 15000, function()
	    ice_patch:remove()
	  end)
        end
      end
    elseif other:get_type() == "switch" then
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
      self:remove()
    elseif other:get_type() == "explosion" then
      sol.audio.play_sound("ice_melt")
      self:remove()
    else
      block_on_switch = false
    end
  end)
end

function entity:on_removed()
  self:get_sprite():set_animation("destroy")
end