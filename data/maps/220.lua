local map = ...
local game = map:get_game()

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

function switch_star_boss:on_activated()
  local c = map:get_entities_count("hole_boss")
  for i=1,c do
    local ex, ey, el = map:get_entity("hole_boss_"..c):get_position()
    if (ex == pit_positions_boss_2[c].x) and (ey == pit_positions_boss_2[c].y) then
      map:get_entity("hole_boss_"..i):set_position(pit_positions_boss_1[i].x, pit_positions_boss_1[i].y)
    else
      map:get_entity("hole_boss_"..i):set_position(pit_positions_boss_2[i].x, pit_positions_boss_2[i].y)
    end
  end
end
