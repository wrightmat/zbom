-- This script handles global behavior of this quest,
-- that is, things not related to a particular savegame.
local quest_manager = {}

-- Initializes the behavior of destructible entities.
local function initialize_destructibles()
  -- Show a dialog when the player cannot lift them.
  local destructible_meta = sol.main.get_metatable("destructible")
  -- destructible_meta represents the shared behavior of all destructible objects.

  function destructible_meta:on_looked()
    -- Here, self is the destructible object.
    local game = self:get_game()
    if self:get_can_be_cut()
        and not self:get_can_explode()
        and not self:get_game():has_ability("sword") then
      -- The destructible can be cut, but the player no cut ability.
      game:start_dialog("_cannot_lift_should_cut");
    elseif not game:has_ability("lift") then
      -- No lift ability at all.
      game:start_dialog("_cannot_lift_too_heavy");
    else
      -- Not enough lift ability.
      game:start_dialog("_cannot_lift_still_too_heavy");
    end
  end
end

-- Initialize sensor behavior specific to this quest.
local function initialize_sensor()

  local sensor_meta = sol.main.get_metatable("sensor")

  function sensor_meta:on_activated()

    local game = self:get_game()
    local hero = self:get_map():get_hero()
    local name = self:get_name()
    local dungeon = game:get_dungeon()

    -- Sensors prefixed by "dungeon_room_N" save exploration state of room "N" of current dungeon floor.
    -- Optional treasure savegame value appended to end will play signal chime if value is false and hero has compass in inventory. "dungeon_room_N_bxxx"
    local room, signal = name:match("^dungeon_room_(%d+)_(%U%d+)")
    if room ~= nil then
      game:set_explored_dungeon_room(nil, nil, tonumber(room))
      if signal ~= nil and not game:get_value(signal) then
        if game:has_dungeon_compass(game:get_dungeon_index()) then
          sol.audio.play_sound("signal")
        end
      end
    end
  end
end

-- Initializes the behavior of enemies.
local function initialize_enemies()
  -- Enemies: redefine the damage of the hero's sword.
  -- (The default damages are less important.)
  local enemy_meta = sol.main.get_metatable("enemy")

  function enemy_meta:on_hurt_by_sword(hero, enemy_sprite)
    -- Here, self is the enemy.
    local game = self:get_game()
    local sword = game:get_ability("sword")
    local damage_factors = { 1, 2, 4, 8 }  -- Damage factor of each sword.
    local damage_factor = damage_factors[sword]
    if hero:get_state() == "sword spin attack" then
      game:remove_stamina(1)
      damage_factor = damage_factor * 2  -- The spin attack is twice as powerful, but costs more stamina.
    end

    local reaction = self:get_attack_consequence_sprite(enemy_sprite, "sword")
    self:remove_life(reaction * damage_factor)
  end
end

-- Initializes map entity related behaviors.
local function initialize_entities()
  initialize_destructibles()
  initialize_enemies()
  initialize_sensor()
end

local function initialize_maps()
  local map_metatable = sol.main.get_metatable("map")
  local night_overlay = nil

  function map_metatable:on_draw(dst_surface)
    -- Put the night overlay on any outdoor map if it's night time
    if (self:get_game():is_in_outside_world() and self:get_game():get_time_of_day() == "night") or
	(self:get_world() == "dungeon_2" and self:get_id() == "20" and self:get_game():get_time_of_day() == "night") or
	(self:get_world() == "dungeon_2" and self:get_id() == "21" and self:get_game():get_time_of_day() == "night") or
	(self:get_world() == "dungeon_2" and self:get_id() == "22" and self:get_game():get_time_of_day() == "night") then
      if night_overlay == nil then
        night_overlay = sol.surface.create(320, 240)
        night_overlay:fill_color{0, 51, 102}
        night_overlay:set_opacity(0.45 * 255)
        night_overlay:draw(dst_surface)
      else
        night_overlay:draw(dst_surface)
      end
    end
  end

  function map_metatable:on_started(destination)
    function random_8(lower, upper)
      math.randomseed(os.time())
      return math.random(math.ceil(lower/8), math.floor(upper/8))*8
    end

    -- Night time is more dangerous - add various enemies
    if self:get_game():get_map():get_world() == "outside_world" and
    self:get_game():get_time_of_day() == "night" then
      local keese_random = math.random()
      if keese_random < 0.7 then
	local ex = random_8(1,1120)
	local ey = random_8(1,1120)
	self:create_enemy({ breed="keese", x=ex, y=ey, layer=2, direction=1 })
	sol.timer.start(self, 1100, function()
	  local ex = random_8(1,1120)
	  local ey = random_8(1,1120)
	  self:create_enemy({ breed="keese", x=ex, y=ey, layer=2, direction=1 })
	end)
      elseif keese_random >= 0.7 then
	local ex = random_8(1,1120)
	local ey = random_8(1,1120)
	self:create_enemy({ breed="keese", x=ex, y=ey, layer=2, direction=1 })
	sol.timer.start(self, 1100, function()
	  local ex = random_8(1,1120)
	  local ey = random_8(1,1120)
	  self:create_enemy({ breed="keese", x=ex, y=ey, layer=2, direction=1 })
	end)
	sol.timer.start(self, 1100, function()
	  local ex = random_8(1,1120)
	  local ey = random_8(1,1120)
	  self:create_enemy({ breed="keese", x=ex, y=ey, layer=2, direction=1 })
	end)
      end
      local poe_random = math.random()
      if poe_random <= 0.5 then
	local ex = random_8(1,1120)
	local ey = random_8(1,1120)
	self:create_enemy({ breed="poe", x=ex, y=ey, layer=2, direction=1 })
      elseif keese_random <= 0.2 then
	local ex = random_8(1,1120)
	local ey = random_8(1,1120)
	self:create_enemy({ breed="poe", x=ex, y=ey, layer=2, direction=1 })
	sol.timer.start(self, 1100, function()
	  local ex = random_8(1,1120)
	  local ey = random_8(1,1120)
	  self:create_enemy({ breed="poe", x=ex, y=ey, layer=2, direction=1 })
	end)
      end
      local redead_random = math.random()
      if poe_random <= 0.1 then
	local ex = random_8(1,1120)
	local ey = random_8(1,1120)
	self:create_enemy({ breed="redead", x=ex, y=ey, layer=0, direction=1 })
      end
    end
  end

end

local function initialize_game()
  local game_metatable = sol.main.get_metatable("game")

  -- Stamina functions mirror magic and life functions
  function game_metatable:get_stamina()
    return self:get_value("i1024")
  end

  function game_metatable:set_stamina(value)
    if value > self:get_max_stamina() then value = self:get_max_stamina() end
    return self:set_value("i1024", value)
  end

  function game_metatable:add_stamina(value)
    stamina = self:get_value("i1024") + value
    if value >= 0 then
      if stamina > self:get_max_stamina() then stamina = self:get_max_stamina() end
      return self:set_value("i1024", stamina)
    end
  end

  function game_metatable:remove_stamina(value)
    stamina = self:get_value("i1024") - value
    if value >= 0 then
      if stamina < 0 then stamina = 0 end
      return self:set_value("i1024", stamina)
    end
  end

  function game_metatable:get_max_stamina()
    return self:get_value("i1025")
  end

  function game_metatable:set_max_stamina(value)
    if value >= 20 then -- stamina can't be too low or hero can't do anything!
      return self:set_value("i1025", value)
    end
  end

  function game_metatable:add_max_stamina(value)
    stamina = self:get_value("i1025")
    if value > 0 then
      return self:set_value("i1025", stamina+value)
    end
  end

  function game_metatable:get_random_map_position()
    function random_8(lower, upper)
      math.randomseed(os.time())
      return math.random(math.ceil(lower/8), math.floor(upper/8))*8
    end
    function random_points()
      local x = random_8(1, 1120)
      local y = random_8(1, 1120)
	print('random point: x= '..x..', y= '..y..', traversable= '..tostring(self:get_map():get_ground(x,y,1)))
      if self:get_map():get_ground(x,y,1) ~= "traversable" then
         random_points()
      else
        return x,y
      end
    end
  
  end

end

-- Performs global initializations specific to this quest.
function quest_manager:initialize_quest()
  initialize_game()
  initialize_maps()
  initialize_entities()
end

return quest_manager