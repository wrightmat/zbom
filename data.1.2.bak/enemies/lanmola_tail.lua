local enemy = ...

-- Lanmola: segmented enemy who appears from underground- this defines the tail segment.

function enemy:on_created()
  self:set_life(8)
  self:set_damage(2)
  self:create_sprite("enemies/lanmola_tail")
  self:set_size(16, 16)
  self:set_origin(8, 8)
  self:go(40)
end

function enemy:go(speed)
  local mt = sol.movement.create("target")
  mt:set_target(self:get_map():get_entity("lanmola_body_6"))
  mt:set_ignore_obstacles(true)
  mt:set_speed(speed)
  mt:start(self)
end

function enemy:on_restarted()
  self:go(40)
end

function enemy:on_obstacle_reached()
  self:go(40)
end

function enemy:on_dying()
  sol.timer.start(self:get_map(), 1000, function()
    self:get_map():get_entity("lanmola_body_6"):set_life(0)
    sol.timer.start(self:get_map(), 900, function()
      self:get_map():get_entity("lanmola_body_5"):set_life(0)
      sol.timer.start(self:get_map(), 800, function()
        self:get_map():get_entity("lanmola_body_4"):set_life(0)
	sol.timer.start(self:get_map(), 700, function()
	  self:get_map():get_entity("lanmola_body_3"):set_life(0)
	  sol.timer.start(self:get_map(), 600, function()
	    self:get_map():get_entity("lanmola_body_2"):set_life(0)
	    sol.timer.start(self:get_map(), 500, function()
	      self:get_map():get_entity("lanmola_body_1"):set_life(0)
	      sol.timer.start(self:get_map(), 400, function()
		self:get_map():get_entity("miniboss_lanmola"):set_life(0)
	      end)
	    end)
	  end)
	end)
      end)
    end)
  end)
end
