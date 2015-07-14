local game = ...

-- Define the existing dungeons and their floors for the minimap menu.
game.dungeons = {
  [1] = {
    floor_width = 2256,
    floor_height = 2256,
    lowest_floor = -1,
    highest_floor = 0,
    maps = { "201", "202" },
    boss = {
      floor = 0,
      x = 2032,
      y = 536,
      savegame_variable = "b1046",
    },
  },
  [2] = {
    floor_width = 2032,
    floor_height = 1760,
    lowest_floor = 0,
    highest_floor = 0,
    maps = { "203" },
    boss = {
      floor = 0,
      x = 1130,
      y = 30,
      savegame_variable = "b1058",
    },
  },
  [3] = {
    floor_width = 2032,
    floor_height = 1760,
    lowest_floor = 0,
    highest_floor = 0,
    maps = { "204" },
    boss = {
      floor = 0,
      x = 824,
      y = 1024,
      savegame_variable = "b1079",
    },
  },
  [4] = {
    floor_width = 1696,
    floor_height = 1760,
    lowest_floor = 0,
    highest_floor = 0,
    maps = { "205" },
    boss = {
      floor = 0,
      x = 200,
      y = 464,
      savegame_variable = "b1110",
    },
  },
  [5] = {
    floor_width = 2032,
    floor_height = 1600,
    lowest_floor = -1,
    highest_floor = 0,
    maps = { "206", "207" },
  },
  [6] = {
    floor_width = 1024,
    floor_height = 1760,
    lowest_floor = -2,
    highest_floor = -1,
    maps = { "208", "209" },
  },
  [7] = {
    floor_width = 912,
    floor_height = 800,
    lowest_floor = 0,
    highest_floor = 7,
    maps = { "210", "211", "212", "213", "214", "215", "216", "217" },
  },
  [8] = {
    floor_width = 2032,
    floor_height = 1760,
    lowest_floor = -1,
    highest_floor = 0,
    maps = { "218", "219" },
  },
}

-- Returns the index of the current dungeon if any, or nil.
function game:get_dungeon_index()
  local world = self:get_map():get_world()
  local index = tonumber(world:match("^dungeon_([0-9]+)$"))
  return index
end

-- Returns the current dungeon if any, or nil.
function game:get_dungeon()
  local index = self:get_dungeon_index()
  return self.dungeons[index]
end

function game:is_dungeon_finished(dungeon_index)
  return self:get_value("dungeon_" .. dungeon_index .. "_finished")
end

function game:set_dungeon_finished(dungeon_index, finished)
  if finished == nil then
    finished = true
  end
  self:set_value("dungeon_" .. dungeon_index .. "_finished", finished)
end

function game:has_dungeon_map(dungeon_index)
  dungeon_index = dungeon_index or self:get_dungeon_index()
  return self:get_value("dungeon_" .. dungeon_index .. "_map")
end

function game:has_dungeon_compass(dungeon_index)
  dungeon_index = dungeon_index or self:get_dungeon_index()
  return self:get_value("dungeon_" .. dungeon_index .. "_compass")
end

function game:has_dungeon_big_key(dungeon_index)
  dungeon_index = dungeon_index or self:get_dungeon_index()
  return self:get_value("dungeon_" .. dungeon_index .. "_big_key")
end

function game:has_dungeon_boss_key(dungeon_index)
  dungeon_index = dungeon_index or self:get_dungeon_index()
  return self:get_value("dungeon_" .. dungeon_index .. "_boss_key")
end

-- Returns the name of the boolean variable that stores the exploration
-- of dungeon room, or nil.
function game:get_explored_dungeon_room_variable(dungeon_index, floor, room)
  dungeon_index = dungeon_index or game:get_dungeon_index()
  room = room or 1

  if floor == nil then
    if game:get_map() ~= nil then
      floor = game:get_map():get_floor()
    else
      floor = 0
    end
  end

  local room_name
  if floor >= 0 then
    room_name = tostring(floor + 1) .. "f_" .. room
  else
    room_name = math.abs(floor) .. "b_" .. room
  end

  return "dungeon_" .. dungeon_index .. "_explored_" .. room_name
end

-- Returns whether a dungeon room has been explored.
function game:has_explored_dungeon_room(dungeon_index, floor, room)
  return self:get_value(
    self:get_explored_dungeon_room_variable(dungeon_index, floor, room)
  )
end

-- Changes the exploration state of a dungeon room.
function game:set_explored_dungeon_room(dungeon_index, floor, room, explored)
  if explored == nil then
    explored = true
  end

  self:set_value(
    self:get_explored_dungeon_room_variable(dungeon_index, floor, room),
    explored
  )
end