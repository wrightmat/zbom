local enemy = ...
local casting = false
local dark_magic_sprite = sol.sprite.create("entities/dark_appears")

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

function enemy:on_custom_attack_received(attack, sprite)
print(sprite)
  if sprite == "arrow_light" and casting then
    self:hurt(8)
    casting = false
  end
end

function enemy:on_restarted()
  if self:get_game():get_map():get_id() == "218" then -- Don't want Zirna to act during the cutscene.
    casting = true
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
    self:go_hero()
  end
end

function enemy:on_obstacle_reached(movement)
  casting = false
  enemy:restart()
end

function enemy:go_hero()
  casting = false
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(32)
  m:start(self)
  sol.timer.start(enemy, math.random(10)*500, function() enemy:restart() end)
end

function enemy:on_post_draw()
  if casting then
    local x, y, layer = self:get_position()
    self:get_map():draw_sprite(dark_magic_sprite, x, y)
  end
end