local map = ...
local game = map:get_game()
local i = 0
local state = 1

-------------------------------------------
-- Dungeon 5: Snowpeak Caverns (Floor 2) --
-------------------------------------------

-- initial positions for pits (before star switch activated)
local pit_positions_boss_1 = {
  {x = 480, y = 264},
  {x = 584, y = 344},
  {x = 696, y = 280},
  {x = 880, y = 240},
  {x = 800, y = 104},
  {x = 768, y = 864}
}
-- new positions for pits (after star switch activated)
local pit_positions_boss_2 = {
  {x = 512, y = 288},
  {x = 704, y = 256},
  {x = 768, y = 168},
  {x = 912, y = 64},
  {x = 816, y = 368},
  {x = 880, y = 864}
}

function map:on_started(destination)
  boss_stalfos:set_enabled(false)
end

function switch_star_boss:on_activated()
  for entity in map:get_entities("hole_boss") do
    i = i + 1
    if state == 2 then
      local position = (pit_positions_boss_2[i])
      state = 1
    else
      local position = (pit_positions_boss_1[i])
      state = 2
    end
    entity:set_position(position.x, position.y)
  end
end

function sensor_boss:on_activated()
  if boss_stalfos ~= nil then
    map:close_doors("door_boss")
    boss_stalfos:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if boss_stalfos ~= nil then
  function boss_stalfos:on_dead()
    map:open_doors("door_boss")
    sol.audio.play_sound("boss_killed")
    boss_heart:set_enabled(true)
    sol.timer.start(1000, function()
      sol.audio.play_music("temple_snow")
    end)
  end
end
