local entity = ...
local game = entity:get_game()
local map = entity:get_map()
local sprite
entity.can_burn = true


function entity:on_created()
  sprite = entity:get_sprite()
  if sprite:get_num_frames() > 1 then
    sprite:set_frame(math.random(1, sprite:get_num_frames() - 1))
  end
  entity:set_drawn_in_y_order()
  entity:set_traversable_by(true)
end


function entity:rustle(other_entity)
  --other_entity is the one that caused the rustling
  if entity.shaking then return end
  entity.shaking = true
  sol.audio.play_sound("grass_rustling_quiet")
  if sprite:has_animation"shaking" then
    sprite:set_animation("shaking", function()
      sprite:set_animation("shaking", "stopped")
    end)
  end
  sol.timer.start(entity, 200, function()
    if other_entity and entity:get_distance(other_entity) < 24 then
      return true
    else
      entity.shaking = false
    end
  end)
end


function entity:react_to_fire()
  if not entity:exists() then return end
  local x, y, z = entity:get_position()
  if not entity.is_burning then
    entity.is_burning = true
    local smolder = entity:create_sprite("elements/smolder", "smolder")
    local burn_timer = sol.timer.start(entity, 1000, function()
      entity:remove()
      --map:create_fire{x=x, y=y, layer=z}
      map:propagate_fire(x, y, z)
    end)

    function entity:put_out_fire()
      burn_timer:stop()
      entity.is_burning = false
      entity:remove_sprite(smolder)
      entity.put_out_fire = nil
    end
  end
end


function entity:react_to_wind()
  if entity.put_out_fire then entity:put_out_fire() end
end


function entity:react_to_lightning_bolt()
  sol.timer.start(entity, math.random(100,300), function()
    local x,y,z = entity:get_position()
    map:create_fire{x=x, y=y, layer=z}
  end)
end
