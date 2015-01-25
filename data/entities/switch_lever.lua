local entity = ...
local map = entity:get_map()
local state = "inactivated"
local pushing = nil

-- Lever switch: custom lever switch which is
-- physically pushed by the hero

function entity:on_created()
  local sprite = self:get_sprite()
  self:set_size(16, 16)
  if state == "inactivated" then self:set_origin(5,16) else self:set_origin(-16, 5) end
  self:set_traversable_by(false)
  self:add_collision_test("touching", function(self, other)
    if other:get_type() == "hero" and map:get_entity("hero"):get_state() == "pushing" then
      -- if hero continues pushing for 5 seconds, activate switch
      if pushing == nil then
       pushing = sol.timer.start(5000, function()
	self:get_sprite():set_animation("changing")
	sol.audio.play_sound("switch")
	if state == "inactivated" then state = "activated" elseif state == "activated" then state = "inactivated" end
  	sol.timer.start(500,function() self:get_sprite():set_animation(state) end)
       end)
       pushing = nil
      end
    else
      if pushing ~= nil then pushing:stop() end
    end
  end)
end
