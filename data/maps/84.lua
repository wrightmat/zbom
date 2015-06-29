local map = ...

local function send_hero(from_sensor, to_sensor)

  local hero_x, hero_y = hero:get_position()
  local from_sensor_x, from_sensor_y = from_sensor:get_position()
  local to_sensor_x, to_sensor_y = to_sensor:get_position()

  hero_x = hero_x + to_sensor_x - from_sensor_x
  hero_y = hero_y + to_sensor_y - from_sensor_y
  hero:set_position(hero_x, hero_y)
end

function sensor_a1:on_activated()

  send_hero(sensor_a1, sensor_a2)
end

function sensor_b1:on_activated()

  send_hero(sensor_b1, sensor_b2)
end

function sensor_c1:on_activated()

  send_hero(sensor_c1, sensor_c2)
end
