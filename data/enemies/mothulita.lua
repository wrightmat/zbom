local enemy = ...
local nb_moths_created = 0
local going_hero = false

-- Mothulita: Miniboss of Sacred Grove, enemy who generates a swarm of moths and attacks.

function enemy:on_created()
  self:set_life(6); self:set_damage(2)
  self:create_sprite("enemies/mothulita")
  self:set_size(32, 32); self:set_origin(16, 29)
  self:set_hurt_style("boss")
  self:set_obstacle_behavior("flying")
  self:get_sprite():set_animation("immobilized")
end

function add_moth()
  -- first wave: should be easy enough to kill just with sword: 1 moth every second for 15 moths
  if nb_moths_created <= 15 then
    enemy:create_enemy({
      name = "moth_",
      breed = "moth"
    })
    nb_moths_created = nb_moths_created + 1
    sol.timer.start(1000, add_moth)
  -- second wave: will have to use torch to group moths: 2 moths every second for 10 moths
  elseif nb_moths_created > 15 and nb_moths_created < 25 then
    enemy:create_enemy{
      name = "moth_",
      breed = "moth"
    }
    enemy:create_enemy{
      name = "moth_",
      breed = "moth"
    }
    nb_moths_created = nb_moths_created + 2
    sol.timer.start(500, add_moth)
  elseif nb_moths_created >=25 then
    -- all moths have been spawned: activate mothulita!
    enemy:set_attack_consequence("sword", 1)
    enemy:restart()
  end
end

function enemy:on_enabled()
  -- Mothulita is enabled (via sensor when entering room)
  -- To set himself up and start generating moths.
  -- After moths are dead he will be restarted (via moth
  -- enemy script), which makes him start moving and vulnerable.
  sol.timer.start(1000, add_moth)
  self:set_attack_consequence("sword", 0)
  self:get_sprite():set_animation("immobilized")
end

function enemy:on_restarted()
  -- All moth enemies are dead, so Mothulita
  -- should start moving around!
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer and self:get_distance(hero) < 100

  if near_hero and not going_hero then
    self:get_sprite():set_animation("walking")
    self:set_attack_consequence("sword", 1)
    local m = sol.movement.create("target")
    m:set_speed(32)
    m:set_target(hero)
    m:set_ignore_obstacles(true)
    m:start(self)
    going_hero = true
  elseif not near_hero and going_hero then
    self:get_sprite():set_animation("walking")
    self:set_attack_consequence("sword", 1)
    local m = sol.movement.create("random")
    m:start(self)
    going_hero = false
  end

  sol.timer.start(self, 500, function() enemy:restart() end)
end