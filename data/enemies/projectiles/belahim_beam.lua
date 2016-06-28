local enemy = ...

-- A magic beam thrown by another enemy (Belahim).

function enemy:on_created(properties)
  self:set_life(1); self:set_damage(8)
  self:create_sprite("enemies/belahim_beam")
  self:set_size(16, 16); self:set_origin(8, 8)
  self:set_invincible()
  self:set_minimum_shield_needed(3)
  self:set_can_hurt_hero_running(true)
  self:set_obstacle_behavior("flying")
  sol.audio.play_sound("poe_soul")
end

function enemy:on_obstacle_reached()
  self:remove()
end

function enemy:on_restarted()
  local dir4 = self:get_sprite():get_direction()
  local m = sol.movement.create("straight")
  if dir4 == 0 then angle = 0 end
  if dir4 == 1 then angle = math.pi / 2 end
  if dir4 == 2 then angle = math.pi end
  if dir4 == 3 then angle = 3 * math.pi / 2 end
  m:set_smooth(false)
  m:set_speed(76)
  m:set_angle(angle)
  m:start(self)
end

function enemy:on_attacking_hero(hero)
  -- Purple tunic makes hero nearly immune to dark magic.
  if self:get_game():get_value("tunic_equipped") ~= 4 then
    hero:start_hurt(8)
  else
    hero:start_hurt(2)
  end
end