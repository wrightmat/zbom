local item = ...

function item:on_created()
  self:set_savegame_variable("i1838")
  self:set_assignable(true)
  item:set_dug_soil(false)
end

function item:on_using()
  local game = item:get_game()
  local hero = game:get_hero()

  -- Handle stakes.
  item:set_dug_soil(false)
  sol.timer.start(item, 50, function()
    if item:has_dug_soil() then
      sol.audio.play_sound("shovel")  -- TODO: different sound when soil dug.
    else
      sol.audio.play_sound("shovel")
    end
    item:set_dug_soil(false)
  end)

  -- Start the animation.
  hero:set_animation("shovel")
  sol.audio.play_sound("shovel")

  -- End the animation and restore control.
  sol.timer.start(hero, 500, function()
    hero:set_animation("stopped")
    hero:unfreeze()
  end)
end

function item:has_dug_soil()
  return item.dug_soil
end

function item:set_dug_soil(dug_soil)
  item.dug_soil = dug_soil
end