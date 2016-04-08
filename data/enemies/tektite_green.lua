local enemy = ...

-- Tektite: a jumping enemy which moves toward the hero.

local state -- States: "stopped", "going_hero", "jumping", "prepare_jump", "finish_jump", "going_random"
local speed = 20
local detection_distance = 80
local jump_duration = 1000 -- Time in milliseconds.
local max_height = 20 -- Height for the jump, in pixels.
local jumping_speed = 80 -- Speed of the movement during the jump.

function enemy:on_created()
  self:set_life(1); self:set_damage(2)
  local sprite = self:create_sprite("enemies/tektite_green")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)

  function sprite:on_animation_finished(animation)
    if animation == "immobilized" then -- state: finish_jump
      state = "stopped"
      sprite:set_animation("stopped")
      sol.timer.start(self, 200, function()
        enemy:go_hero()
      end)
    end
  end
end

function enemy:on_restarted()
  is_pushing_enemy = false 
  self:check_hero()
end

function enemy:go_hero()
  state = "going_hero"
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(speed)
  m:set_target(self:get_map():get_hero())
  m:start(self)
  -- Prepare jump.
  sol.timer.start(self, 1500, function()
    self:prepare_jump()
  end)
end

function enemy:prepare_jump()
  state = "prepare_jump"
  self:stop_movement()
  self:get_sprite():set_animation("shaking")
  sol.timer.start(self, 1500, function()
    enemy:jump()
  end)
end

function enemy:finish_jump()
  state = "finish_jump"
  self:stop_movement()
  self:get_sprite():set_animation("immobilized")
  self:set_can_attack(true) -- Allow to attack the hero again.
end

function enemy:jump()
  -- Set jumping state, animation and sound.
  state = "jumping"
  local sprite = self:get_sprite()
  sprite:set_animation("walking")
  sol.audio.play_sound("jump")
  self:set_invincible(true) -- Set invincible.
  self:set_can_attack(false) -- Do not attack hero during jump.
  -- Start shift on sprite.
  local function f(t) -- Shifting function.
    return math.floor(4 * max_height * (t / jump_duration - (t / jump_duration) ^ 2))
  end
  local t = 0
  local refreshing_time = 10
  sol.timer.start(self, refreshing_time, function() -- Update shift each 10 milliseconds.
    sprite:set_xy(0, -f(t))
    t = t + refreshing_time
    if t > jump_duration then return false 
      else return true 
    end
  end)
  -- Add a shadow sprite.
  local shadow = self:create_sprite("entities/shadow")
  shadow:set_animation("big")
  local new_frame_delay = math.floor(jump_duration/shadow:get_num_frames())
  shadow:set_frame_delay(new_frame_delay)
  -- Add movement towards near the hero during the jump. The jump does not target the hero.
  -- The angle is partially random to avoid too many enemies overlapping.
  local m = sol.movement.create("straight")
  local angle = self:get_angle(self:get_map():get_hero())
  math.randomseed(os.time()) -- Initialize random seed.
  local d = 2*math.random() - 1 -- Random real number in [-1,1].
  angle = angle + d*math.pi/2 -- Alter jumping angle, randomly. /4
  m:set_speed(jumping_speed)
  m:set_angle(angle)
  m:start(self)
  -- Finish the jump.
  sol.timer.start(self, jump_duration, function()
    self:remove_sprite(shadow) -- Remove shadow sprite.
    sol.timer.start(self, 1, function() -- TODO: remove this after #868 is fixed.
      self:set_default_attack_consequences() -- Stop invincibility after jump.
      self:finish_jump()
    end)
  end)
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_obstacle_reached(movement)
  if not going_hero then
    self:go_random()
    self:check_hero()
  end
end

function enemy:on_hurt()
  if timer ~= nil then
    timer:stop()
    timer = nil
  end
end

function enemy:check_hero()
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer and self:get_distance(hero) < 100

  if near_hero and state ~= "going_hero" then
    self:go_hero()
  elseif not near_hero and state == "going_hero" then
    self:go_random()
  end
  timer = sol.timer.start(self, 2000, function() self:check_hero() end)
end

function enemy:go_random()
  state = "going_random"
  sol.timer.start(self, 2000, function() self:check_hero() end)
end