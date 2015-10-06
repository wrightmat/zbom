local enemy = ...
local vulnerable = false
local last_action = 0
local dark_magic_sprite = sol.sprite.create("entities/dark_appears")
local positions = {
  {x = 800, y = 997},
  {x = 960, y = 1000},
  {x = 880, y = 1080},
  {x = 880, y = 1237},
  {x = 824, y = 1296},
  {x = 960, y = 1296}
}

-- Zirna (Dark Tribe enchantress)
-- Behavior: Uses dark magic to move herself and Link around the room.
--    Creates random enemies to send against Link using dark magic.
--    Only vulnerable to light arrows when she's using dark magic - otherwise sword is minimally effective.

function enemy:on_created()
  self:set_life(64); self:set_damage(6)
  local sprite = self:create_sprite("enemies/zirna")
  self:set_size(24, 40); self:set_origin(12, 37)
  self:set_invincible()
  self:set_attack_arrow("custom")
  self:set_attack_consequence("sword", 1)
  self:set_pushed_back_when_hurt(false)
  sprite:set_animation("stopped")
end

function enemy:create_son()
  vulnerable = true
  local rand = math.random(5)
  if rand == 1 then
    sol.timer.start(self, 2000, function()
      self:create_enemy({ breed = "redead", treasure_name = "random" })
    end)
  elseif rand == 2 then
    sol.timer.start(self, 2000, function()
      self:create_enemy({ breed = "hinox", treasure_name = "random" })
    end)
  elseif rand == 3 then
    sol.timer.start(self, 2000, function()
      self:create_enemy({ breed = "keese_dark", treasure_name = "random" })
    end)
  elseif rand == 4 then
    sol.timer.start(self, 2000, function()
      self:create_enemy({ breed = "poe", treasure_name = "random" })
    end)
  end
  sol.timer.start(self, 3000, function() self:restart() end)
end

function enemy:teleport(object)
  vulnerable = true
  local position = (positions[math.random(#positions)])
  if object == "self" then
    self:get_sprite():fade_out()
    self:set_position(position.x, position.y)
    self:get_sprite():fade_in()
  elseif object == "hero" then
    local hero = self:get_map():get_hero()
    local x,y,l = hero:get_position()
    dark_appears = self:get_map():create_npc({name="dark_appears", x=x, y=y, layer=2, direction=0, subtype=0, sprite="entities/dark_appears"})
    hero:freeze()
    sol.timer.start(self:get_map(), 1000, function()
      hero:set_position(position.x, position.y)
      hero:unfreeze()
      self:get_map():remove_entities("dark_appears")
    end)
  end
  self:restart()
end

function enemy:go_hero()
  vulnerable = false
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_target(self:get_map():get_hero())
  m:set_speed(32)
  m:start(self)
  sol.timer.start(enemy, math.random(10)*500, function() enemy:restart() end)
end

function enemy:on_restarted()
  if self:get_game():get_map():get_id() == "218" then -- Don't want Zirna to act during the cutscene.
    local rand = math.random(5)
    if last_action == rand then -- Try to get a different action than last time.
      sol.timer.start(self:get_map(), 1100, function() local rand = math.random(5) end)
    end
    last_action = rand
    if rand == 1 then self:create_son()
    elseif rand == 2 then self:teleport("self")
    elseif rand == 3 then self:teleport("hero")
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

function enemy:on_update()
  if vulnerable then self:get_sprite():set_animation("casting") end
end

function enemy:on_post_draw()
  if vulnerable then
    local x, y, layer = self:get_position()
    self:get_map():draw_sprite(dark_magic_sprite, x, y)
  end
end

function enemy:on_custom_attack_received(attack, sprite)
  if attack == "arrow" and self:get_game():has_item("bow_light") then
    if vulnerable then
      self:hurt(8)
      vulnerable = false
    end
  end
end