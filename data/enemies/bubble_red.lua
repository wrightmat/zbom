local enemy = ...
local behavior = require("enemies/generic/bubble")

-- Bubble: an invincible enemy that moves in diagonal directions
-- and bounces against walls - this removes life and magic from the hero.

local properties = {
  sprite = "enemies/bubble_red",
}
behavior:create(enemy, properties)

function enemy:on_attacking_hero(hero)
  if not hero:is_invincible() then
    hero:start_hurt(enemy, 2)
    if self:get_game():get_magic() > 0 then
      self:get_game():remove_magic(6)
      sol.audio.play_sound("magic_bar")
    end
  end
end