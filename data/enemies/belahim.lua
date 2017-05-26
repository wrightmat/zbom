local enemy = ...
local game = enemy:get_game()
local initial_life = 40
local second_life = 20
local state -- States: "stopped", "going_shadow", "shadow", "from_shadow", "shooting", "going_hero", "hidden", "hiding", "unhiding"
local shadow = nil
local nb_sons = 0
belahim_second_stage = false

-- Belahim (Dark Tribe leader, final boss of game)
-- Behavior: Invincible as normal form, must avoid both boss and beams he throws
--       Vulnerable to only light arrows as shadow form, which he shrinks to periodically
--       Once hit with light arrows 10 times, he shows his true form and is vulnerable to sword
--       (Light sword does three times as much damage, must hit him 12 times with Forged Sword)

function enemy:on_created()
  self:set_life(initial_life); self:set_damage(16)
  sprite = enemy:create_sprite("enemies/" .. enemy:get_breed())
  self:set_size(64, 64); self:set_origin(32, 56)
  self:set_invincible()
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(true)
  self:set_hurt_style("boss")
  sprite:set_animation("stopped")
  state = "stopped"
end

function enemy:on_restarted()
  if game:get_map():get_id() == "218" and self:is_enabled() then -- Don't want Belahim to act during the intro.
    self:set_visible(true)
    local action = math.random(6)
    if action == last_action then local action = math.random(6) end
    last_action = action
    if action == 1 and state ~= "shadow" and not belahim_second_stage then self:go_shadow()
    elseif action == 2 then self:go_beam()
    else self:go_hero() end
  end
end

function enemy:on_obstacle_reached(movement)
  self:restart()
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  self:get_sprite():set_direction(direction4)
end

function enemy:go_shadow()
  state = "going_shadow"
  self:stop_movement()
  self:get_sprite():set_animation("shrink")
  sol.timer.start(self:get_map(), 500, function()
    self:set_visible(false)
    nb_sons = self:get_map():get_entities_count("shadow")
    if nb_sons <= 3 then
      shadow = self:create_enemy({ name="shadow", x=8, y=8, breed="belahim_shadow", treasure_name="arrow", treasure_variant=2 })
    end
    state = "shadow"
  end)
end

function enemy:go_beam()
  state = "shooting"
  self:get_sprite():set_animation("stopped")
  sol.timer.start(self:get_map(), 7000, function() self:restart() end)

  function throw_beam()
    self:create_enemy({ x = 0, y = 8, breed = "projectiles/belahim_beam", name = "belahim_beam" })
  end

  throw_beam()
  if self:get_life() <= initial_life / 2 then
    sol.timer.start(self, 200, function() throw_beam() end)
    sol.timer.start(self, 400, function() throw_beam() end)
  end
end

function enemy:go_hero()
  state = "going_hero"
  local m = sol.movement.create("target")
  m:set_target(self:get_map():get_hero())
  m:set_ignore_obstacles(true)
  if belahim_second_stage then
    m:set_speed(56)
    self:get_sprite():set_animation("large")
  else
    m:set_speed(40)
    self:get_sprite():set_animation("walking")
  end
  m:start(self)
  sol.timer.start(self:get_map(), math.random(10)*500, function() enemy:restart() end)
end

function enemy:on_hurt(attack)
  local life = self:get_life()
  if life <= 0 and not belahim_second_stage then
    self:get_map():remove_entities("belahim_beam")
    self:set_life(second_life)
    belahim_second_stage = true
    self:set_damage(20)
  end
end

if belahim_second_stage then -- Only vulnerable to sword in second stage.
  if game:get_ability("sword") == 3 then -- Light sword does more damage.
    function enemy:on_hurt_by_sword(hero, enemy_sprite)
      self:hurt(3)
    end
  end
end

function enemy:on_update()
  if belahim_second_stage then
    self:set_attack_consequence("sword", 1)
  end
end