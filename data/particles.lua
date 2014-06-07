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
    print("Aborting. Call 'particle_system:set_type' before initializing.")
    return false
  end
  if not self.time then self.time = 1 end
  if not self.count then self.count = 5 end
  if not self.color then self.color = {255, 255, 255} end
  self.particles = {}

  if self.type == "sparkle" then
    self.alive = true
    for i=1, self.count do
      self.particles[i] = {}
      self.particles[i].x = self.x
      self.particles[i].xspeed = math.random(-100,100)
      self.particles[i].y = self.y
      self.particles[i].yspeed = math.random(-200,50) + (self.ysp or 0)
    end
    return self
  elseif self.type == "dust" then
    self.alive = true
    if not self.time then self.time = 0 end
    return self
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

function particle_system:set_particle_count(count)
  self.count = count
end

function particle_system:set_particle_color(color)
  self.color = color
end

function particle_system:set_decay_time(time)
  self.time = time
end

function particle_system:set_y_speed(ysp)
  self.ysp = ysp
end

function particle_system:is_active()
  return self.alive
end

function particle_system:on_update(dt)
  self.time = self.time - dt

  if self.type == "sparkle" then
    if self.time < 0 then
      self.alive = false
      return
    end
    for i,v in ipairs(self.particles) do
      v.x = v.x + v.xspeed*dt
      v.yspeed = v.yspeed + 500*dt
      v.y = v.y + v.yspeed*dt
    end
  elseif self.type == "dust" then
    if self.time > 0.25 then
      self.alive = false
      return
    end
  end
end

function particle_system:on_draw(dst_surface)
  if self.type == "sparkle" then
    for i,v in ipairs(self.particles) do
      dst_surface:fill_color(self.color, 0.5+v.x, 0.5+v.y, 1, 1)
    end
  elseif self.type == "dust" then
    dst_surface:fill_color(self.color, self.x-self.time*16, self.y-self.time*16, 1, 1)
    dst_surface:fill_color(self.color, self.x+self.time*16, self.y-self.time*16, 1, 1)
    dst_surface:fill_color(self.color, self.x-self.time*16, self.y+self.time*16, 1, 1)
    dst_surface:fill_color(self.color, self.x+self.time*16, self.y+self.time*16, 1, 1)
  else
    --dst_surface:clear()
  end
end

return particle_system
