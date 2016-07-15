local map = ...
local game = map:get_game()
local warned = false

local shadow = sol.surface.create(2256, 1072)
local lights = sol.surface.create(2256, 1072)
shadow:set_blend_mode("color_modulate")
lights:set_blend_mode("additive_blending")

--------------------------------
-- Dungeon 1: Hyrulean Sewers --
--------------------------------

if game:get_value("i1027") == nil then game:set_value("i1027", 0) end
if game:get_value("i1030") == nil then game:set_value("i1030", 0) end
if game:get_value("i1032") == nil then game:set_value("i1032", 0) end

function map:on_started(destination)
  local magic_counter = 0
  -- Only need to build the shadow surface once, but need to update the
  -- glowing things periodically (not every draw cycle!) in case of update,
  glow_timer = sol.timer.start(map, 250, function()
    shadow:clear()
    shadow:fill_color({032,064,128,128})
    lights:clear()
    for e in map:get_entities("torch_") do
      if e:get_sprite():get_animation() == "lit" then
        local xx,yy = e:get_position()
        local sp = sol.sprite.create("entities/torch_light")
        sp:set_blend_mode("alpha_blending")
        sp:draw(lights, xx-32, yy-40)
      end
    end
    for e in map:get_entities("switch_") do
      if e:get_distance(game:get_hero()) <= 300 then
        local xx,yy = e:get_position()
        local sp = sol.sprite.create("entities/torch_light_tile")
        sp:set_blend_mode("alpha_blending")
        sp:draw(lights, xx-8, yy-8)
      end
    end
    -- Slowly drain magic when using lantern.
    if magic_counter >= 50 then
      game:remove_magic(1)
      magic_counter = 0
    end
    magic_counter = magic_counter + 1

    return true
  end)
  
  if not game:get_value("b1036") then boss_heart:set_enabled(false) end
  if not game:get_value("b1043") then chest_big_key:set_enabled(false) end
  if not game:get_value("b1047") then boss_big_poe:set_enabled(false) end
  if not game:get_value("b1786") then chest_alchemy_stone:set_enabled(false) end
  
  if game:get_value("i1027") <= 4 then
    tentacle_sword_1:set_enabled(false)
    tentacle_sword_2:set_enabled(false)
    tentacle_sword_3:set_enabled(false)
  end
  if not game:get_value("b2000") then
    chest_sword:set_enabled(false)
  else
    switch_sword:set_activated(true)
  end
  if not game:get_value("b1040") then
    chest_key_1:set_enabled(false)
  end
  if not game:get_value("b1041") then
    chest_key_2:set_enabled(false)
  end
  if game:get_value("i1030") >= 2 then
    water_drain:remove()
    switch_drain_water:set_activated()
  end
  if game:get_value("i1032") >= 2 then
    map:open_doors("door_2")
    map:open_doors("door_3")
  end
end

function switch_sword:on_activated()
  chest_sword:set_enabled(true)
  sol.audio.play_sound("chest_appears")
end

function switch_arrow_key_1:on_activated()
  chest_key_1:set_enabled(true)
  sol.audio.play_sound("chest_appears")
  arrows:set_enabled(false)
end

function switch_key_2_1:on_activated()
  if switch_key_2_2:is_activated(true) then
    chest_key_2:set_enabled(true)
    sol.audio.play_sound("chest_appears")
  end
end

function switch_key_2_2:on_activated()
  if switch_key_2_1:is_activated(true) then
    chest_key_2:set_enabled(true)
    sol.audio.play_sound("secret")
  end
end

function switch_drain_water:on_activated()
  sol.audio.play_sound("water_drain")
  water_drain:remove()
  game:set_value("i1030", 2)
  game:start_dialog("_sewer_water")
end

function sensor_boss:on_activated()
  if boss_big_poe ~= nil then
    map:close_doors("door_boss")
    boss_big_poe:set_enabled(true)
    sol.audio.play_music("boss")
  end
end
function sensor_door_open:on_activated()
  map:open_doors("door_boss")
end

if boss_big_poe ~= nil then
 function boss_big_poe:on_dead()
  map:open_doors("door_boss")
  sol.audio.play_sound("boss_killed")
  boss_heart:set_enabled(true)
  sol.audio.play_sound("chest_appears")
  chest_big_key:set_enabled(true)
  sol.audio.play_music("sewers")
 end
end

for enemy in map:get_entities("tentacle") do
  enemy.on_dead = function()
    if not map:has_entities("tentacle_orig") and not game:get_value("b1786") then
      chest_alchemy_stone:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

function map:on_obtained_treasure(item, variant, savegame_variable)
  if tentacle_sword_1 ~= nil then tentacle_sword_1:set_enabled(true) end
  if tentacle_sword_2 ~= nil then tentacle_sword_2:set_enabled(true) end
  if tentacle_sword_3 ~= nil then tentacle_sword_3:set_enabled(true) end
end

function map:on_draw(dst_surface)
  local x,y = map:get_camera():get_position()
  local w,h = map:get_camera():get_size()
    
  if game:has_item("lamp") and game:get_magic() > 0 then
    local xx,yy = map:get_entity("hero"):get_position()
    local sp = sol.sprite.create("entities/torch_light_hero")
    sp:set_blend_mode("alpha_blending")
    sp:draw(lights, xx-64, yy-64)
  else
    game:start_dialog("_cannot_see_need_magic")
    warned = true
  end
  
  lights:draw_region(x,y,w,h,shadow,x,y)
  shadow:draw_region(x,y,w,h,dst_surface)
end