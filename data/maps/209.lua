local map = ...
local game = map:get_game()

-------------------------------------------
-- Dungeon 5: Snowpeak Caverns (Floor 2) --
-------------------------------------------

local state_star_boss = 1

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
  if not game:get_value("b1147") then boss_stalfos:set_enabled(false) end
  if not game:get_value("b1149") then boss_heart:set_enabled(false) end
end

function switch_star_boss:on_activated()
  local pit_positions = nil
  local i = 0
  for entity in map:get_entities("hole_boss") do
    i = i + 1
    if state_star_boss == 2 then
      local pit_positions = (pit_positions_boss_2[i])
      state_star_boss = 1
    else
      local pit_positions = (pit_positions_boss_1[i])
      state_star_boss = 2
    end
    entity:set_position(pit_positions.x, pit_positions.y)
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
