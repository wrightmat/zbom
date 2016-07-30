local map = ...
local game = map:get_game()

--------------------------------------------------------------------------------------
-- Outside World E11 (Lakebed Lair Entr) - Entrance to Lakebed Lair (dynamic water) --
--------------------------------------------------------------------------------------

if game:get_value("i1030")==nil then game:set_value("i1030", 0) end
local ordona_speaking = false
local shadow = sol.surface.create(1120, 1120)
local lights = sol.surface.create(1120, 1120)
shadow:fill_color({32,64,128,255})
shadow:set_blend_mode("multiply")
lights:set_blend_mode("add")

function map:on_started(destination)
  if game:get_value("b1134") then
    -- If the dungeon has been completed, the water returns.
    map:set_entities_enabled("water", true)
    map:set_entities_enabled("wake", true)

    if game:get_value("i1910") < 5 then
      torch_1:get_sprite():set_animation("lit")
      sol.timer.start(1000, function()
        hero:freeze()
        ordona_speaking = true
        game:start_dialog("ordona.5.lake_hylia", game:get_player_name(), function()
          sol.timer.start(500, function() ordona_speaking = false end)
          hero:unfreeze()
          game:add_max_stamina(100)
          game:set_stamina(game:get_max_stamina())
          torch_1:get_sprite():set_animation("unlit")
          game:set_value("i1910", 5)
        end)
      end)
    end
  elseif game:get_value("i1030") >= 2 then
    -- If the switch has been flipped in the sewers, the water is gone.
    map:set_entities_enabled("water", false)
    map:set_entities_enabled("wake", false)
    sx, sy, sl = statue:get_position()
    tx, ty, tl = temple_entr:get_position()
    statue:set_position(sx, sy, 0)
    temple_entr:set_position(tx, ty, 1)
  end
end

if game:get_time_of_day() ~= "night" and ordona_speaking then
  function map:on_draw(dst_surface)
    -- Show torch overlay for Ordona dialog
    local x,y = game:get_map():get_camera():get_position()
    local w,h = game:get_map():get_camera():get_size()
    local xx, yy = map:get_entity("torch_5"):get_position()
    local sp = sol.sprite.create("entities/torch_light")
    sp:set_blend_mode("blend")
    sp:draw(lights, xx-32, yy-32)
    lights:draw_region(x,y,w,h,shadow,x,y)
    shadow:draw_region(x,y,w,h,dst_surface)
  end
end