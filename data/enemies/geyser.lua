local enemy = ...

-- Geyser: More of an entity, but made as an enemy so it can easily damage the hero.

function enemy:on_created()
  self:set_damage(2)
  self:create_sprite("enemies/geyser")
  self:set_size(32, 64); self:set_origin(16, 61)
  self:set_invincible()
  sol.timer.start(math.random(10)*1000, geyser_start)
  self:get_sprite():set_animation("immobilized")
end

function geyser_start()
  sol.audio.play_sound("wind")
  if enemy:get_sprite() ~= nil then
    enemy:get_sprite():set_animation("walking")
    sol.timer.start(1300, geyser_stop)
  end
end

function geyser_stop()
  enemy:get_sprite():set_animation("immobilized")
  sol.timer.start(math.random(10)*1000, geyser_start)
end