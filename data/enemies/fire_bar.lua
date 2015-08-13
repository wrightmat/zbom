local enemy = ...
local son1, son2, son3, son4

function enemy:on_created()
  self:set_life(1); self:set_damage(0)
  self:set_size(16, 16); self:set_origin(8, 8)
  self:set_invincible()
  self:set_obstacle_behavior("flying")

  son1 = self:create_enemy{
    name = son_name,
    breed = "fireball_animated",
    x = 0,
    y = 0,
    layer = 0,
  }
  son1:go_circle(self, 16, true)
  son1:set_optimization_distance(0)

  son2 = self:create_enemy{
    name = son_name,
    breed = "fireball_animated",
    x = 0,
    y = 0,
    layer = 0,
  }
  son2:go_circle(self, 32, true)
  son2:set_optimization_distance(0)

  son3 = self:create_enemy{
    name = son_name,
    breed = "fireball_animated",
    x = 0,
    y = 0,
    layer = 0,
  }
  son3:go_circle(self, 48, true)
  son3:set_optimization_distance(0)

  son4 = self:create_enemy{
    name = son_name,
    breed = "fireball_animated",
    x = 0,
    y = 0,
    layer = 0,
  }
  son4:go_circle(self, 64, true)
  son4:set_optimization_distance(0)

  son1:set_enabled(true)
  son2:set_enabled(true)
  son3:set_enabled(true)
  son4:set_enabled(true)
end

function enemy:on_restarted()
  son1:set_enabled(true)
  son2:set_enabled(true)
  son3:set_enabled(true)
  son4:set_enabled(true)

  son1:go_circle(self, 16, true)
  son1:set_optimization_distance(0)
  son2:go_circle(self, 32, true)
  son2:set_optimization_distance(0)
  son3:go_circle(self, 48, true)
  son3:set_optimization_distance(0)
  son4:go_circle(self, 64, true)
  son4:set_optimization_distance(0)
end

function enemy:on_disabled()
  son1:set_enabled(false)
  son2:set_enabled(false)
  son3:set_enabled(false)
  son4:set_enabled(false)
end
