local particle_system = {}

function particle_system:new(game)
  local object = {}
  setmetatable(object, self)
  self.__index = self
  return object
end

function particle_system:initialize(game)
  self.game = game
  if not self.type then
    print("Aborting. Call 'particle_system:set_type()' before initializing.")
    return false
  end
  if not self.time then self.time = 1 end
  if not self.count then self.count = 5 end
  if not self.size then self.size = 10 end
  if not self.color then self.color = {255, 255, 255} end
  self.particles = {}

  if self.type == "spark" then
    self.alive = true
    for i=1, self.count do
      self.particles[i] = {}
      self.particles[i].x = self.x
      self.particles[i].y = self.y
      self.particles[i].xspeed = math.random(-self.size,self.size)
      self.particles[i].yspeed = math.random((-self.size*2),(self.size/2)) + (self.ysp or 0)
    end
    return self
  elseif self.type == "fire" then
    self.alive = true
    for i=1, self.count do
      self.particles[i] = {}
      self.particles[i].x = self.x + -2 + math.random(5)
      self.particles[i].y = self.y + -10 + math.random(10)
      self.particles[i].xspeed = -2.5 + math.random(5)
      self.particles[i].yspeed = -15 + math.random(10)
    end
    return self
  else
    print('Type not recognized. Pass "spark" or "fire".')
  end
end

function particle_system:set_type(type)
  self.type = type
end

function particle_system:set_position(x, y, layer)
  self.x = x
  self.y = y
  self.layer = layer or 1
end

function particle_system:set_size(size)
  self.size = size
end

function particle_system:set_particle_count(count)
  self.count = count
  if self.count > 5000 then
    print('Particle maximum is currently 5,000')
    self.count = 5000
  end
end

function particle_system:set_particle_color(color)
  self.color = color
end

function particle_system:set_decay_time(time)
  self.time = time
  self.time_initial = time
end

function particle_system:set_y_speed(ysp)
  self.ysp = ysp
end

function particle_system:is_active()
  return self.alive
end

function particle_system:on_update(dt)
  self.time = self.time - dt
  alpha = (self.time / self.time_initial) * 255
  if alpha < 0 then alpha = 0 end
  rawset (self.color, 4, alpha)

  -- Spark type (particles bursting outward, becoming less opaque as they go)
  if self.type == "spark" then
    if self.time < 0 then
      self.alive = false
      return
    end
    for i,v in ipairs(self.particles) do
      v.x = v.x + v.xspeed*dt
      v.yspeed = v.yspeed + (self.size/2)*dt
      v.y = v.y + v.yspeed*dt
    end

  -- Fire type (particles moving upward, becoming more red and less opaque as they go)
  elseif self.type == "fire" then
    if self.time < 0 then
      self.alive = false
      return
    end
    for i=#self.particles, self.count do
      self.particles[i].x = self.x + -2 + math.random(5)
      self.particles[i].y = self.y + -10 + math.random(10)
      self.particles[i].xspeed = -2.5 + math.random(5)
      self.particles[i].yspeed = -10 + math.random(8)
    end
    for i,v in ipairs(self.particles) do
      print(i)
      v.x = v.x + v.xspeed*dt
      v.y = v.y + v.yspeed*dt
    end
  end
end

function particle_system:on_draw(dst_surface)
  if self.type == "spark" then
    for i,v in ipairs(self.particles) do
      dst_surface:fill_color(self.color, 0.5+v.x, 0.5+v.y, 1, 1)
    end
  elseif self.type == "fire" then
    for i,v in ipairs(self.particles) do
      blue = rawget (self.color, 2)
      green = rawget (self.color, 3)
      if (self.time / self.time_initial) >= 0.5 then
        blue = blue - 1
      end
      if (self.time / self.time_initial) < 0.5 then
        green = green - 1
      end
      rawset (self.color, 2, blue)
      rawset (self.color, 3, green)
      dst_surface:fill_color(self.color, 0.5+v.x, 0.5+v.y, 1, 1)
    end
  end
end

return particle_system
