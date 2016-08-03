local map = ...
local game = map:get_game()

------------------------------
-- Outside G4 (King's Tomb) --
------------------------------
-- For each grave, two candles must be lit with the lantern -
-- each lit candles causes a poe to appear, and when all five
-- graves are lit, the King's Tomb opens up.

if game:get_value("i1610")==nil then game:set_value("i1610", 0) end

function map:on_started(destination)
  if game:get_value("i1610") ~= 1 then
    torch_king_1:set_enabled(false)
    torch_king_2:set_enabled(false)
    torch_king_3:set_enabled(false)
    torch_king_4:set_enabled(false)
    torch_king_5:set_enabled(false)
    torch_king_6:set_enabled(false)
    torch_king_7:set_enabled(false)
    torch_king_8:set_enabled(false)
    torch_king_9:set_enabled(false)
    torch_king_10:set_enabled(false)
    hole:set_enabled(false)
  end
  sol.timer.start(map, 1000, function()
    if torch_king_1:is_enabled() and torch_king_2:is_enabled() and torch_king_3:is_enabled() and
     torch_king_4:is_enabled() and torch_king_5:is_enabled() and torch_king_6:is_enabled() and
     torch_king_7:is_enabled() and torch_king_8:is_enabled() and torch_king_9:is_enabled() and
     torch_king_10:is_enabled() and game:get_value("i1610") == 0 then
      sol.audio.play_sound("secret")
      local poe = map:create_enemy({x=752,y=528,layer=1,direction=0,breed="poe_big",treasure_name="poe_soul"})
      poe:get_sprite():fade_in(100)
      hole:set_enabled(true)
      game:set_value("i1610", 1)
    end
    return true
  end)
end

function torch_grave1_1:on_interaction_item(lamp)
  torch_grave1_1:get_sprite():set_animation("lit")
  sol.audio.play_sound("ghost")
  local poe = map:create_enemy({x=312,y=360,layer=1,direction=0,breed="poe",treasure_name="poe_soul"})
  poe:get_sprite():fade_in(80)
  if torch_grave1_2:get_sprite():get_animation() == "lit" then
    map:move_camera(752, 472, 300, function()
      torch_king_1:set_enabled(true)
      torch_king_6:set_enabled(true)
    end)
  end
end
function torch_grave1_2:on_interaction_item(lamp)
  torch_grave1_2:get_sprite():set_animation("lit")
  sol.audio.play_sound("ghost")
  local poe = map:create_enemy({x=312,y=360,layer=1,direction=0,breed="poe",treasure_name="poe_soul"})
  poe:get_sprite():fade_in(80)
  if torch_grave1_1:get_sprite():get_animation() == "lit" then
    map:move_camera(752, 472, 300, function()
      torch_king_1:set_enabled(true)
      torch_king_6:set_enabled(true)
    end)
  end
end

function torch_grave2_1:on_interaction_item(lamp)
  torch_grave2_1:get_sprite():set_animation("lit")
  sol.audio.play_sound("ghost")
  local poe = map:create_enemy({x=416,y=144,layer=1,direction=0,breed="poe",treasure_name="poe_soul"})
  poe:get_sprite():fade_in(80)
  if torch_grave2_2:get_sprite():get_animation() == "lit" then
    map:move_camera(752, 472, 300, function()
      torch_king_2:set_enabled(true)
      torch_king_7:set_enabled(true)
    end)
  end
end
function torch_grave2_2:on_interaction_item(lamp)
  torch_grave2_2:get_sprite():set_animation("lit")
  sol.audio.play_sound("ghost")
  local poe = map:create_enemy({x=416,y=144,layer=1,direction=0,breed="poe",treasure_name="poe_soul"})
  poe:get_sprite():fade_in(80)
  if torch_grave2_1:get_sprite():get_animation() == "lit" then
    map:move_camera(752, 472, 300, function()
      torch_king_2:set_enabled(true)
      torch_king_7:set_enabled(true)
    end)
  end
end

function torch_grave3_1:on_interaction_item(lamp)
  torch_grave3_1:get_sprite():set_animation("lit")
  sol.audio.play_sound("ghost")
  local poe = map:create_enemy({x=736,y=176,layer=1,direction=0,breed="poe",treasure_name="poe_soul"})
  poe:get_sprite():fade_in(80)
  if torch_grave3_2:get_sprite():get_animation() == "lit" then
    map:move_camera(752, 472, 300, function()
      torch_king_3:set_enabled(true)
      torch_king_8:set_enabled(true)
    end)
  end
end
function torch_grave3_2:on_interaction_item(lamp)
  torch_grave3_2:get_sprite():set_animation("lit")
  sol.audio.play_sound("ghost")
  local poe = map:create_enemy({x=736,y=176,layer=1,direction=0,breed="poe",treasure_name="poe_soul"})
  poe:get_sprite():fade_in(80)
  if torch_grave3_1:get_sprite():get_animation() == "lit" then
    map:move_camera(752, 472, 300, function()
      torch_king_3:set_enabled(true)
      torch_king_8:set_enabled(true)
    end)
  end
end

function torch_grave4_1:on_interaction_item(lamp)
  torch_grave4_1:get_sprite():set_animation("lit")
  sol.audio.play_sound("ghost")
  local poe = map:create_enemy({x=992,y=400,layer=1,direction=0,breed="poe",treasure_name="poe_soul"})
  poe:get_sprite():fade_in(80)
  if torch_grave4_2:get_sprite():get_animation() == "lit" then
    map:move_camera(752, 472, 300, function()
      torch_king_4:set_enabled(true)
      torch_king_9:set_enabled(true)
    end)
  end
end
function torch_grave4_2:on_interaction_item(lamp)
  torch_grave4_2:get_sprite():set_animation("lit")
  sol.audio.play_sound("ghost")
  local poe = map:create_enemy({x=992,y=400,layer=1,direction=0,breed="poe",treasure_name="poe_soul"})
  poe:get_sprite():fade_in(80)
  if torch_grave4_1:get_sprite():get_animation() == "lit" then
    map:move_camera(752, 472, 300, function()
      torch_king_4:set_enabled(true)
      torch_king_9:set_enabled(true)
    end)
  end
end

function torch_grave5_1:on_interaction_item(lamp)
  torch_grave5_1:get_sprite():set_animation("lit")
  sol.audio.play_sound("ghost")
  local poe = map:create_enemy({x=944,y=896,layer=1,direction=0,breed="poe",treasure_name="poe_soul"})
  poe:get_sprite():fade_in(80)
  if torch_grave5_2:get_sprite():get_animation() == "lit" then
    map:move_camera(752, 472, 300, function()
      torch_king_5:set_enabled(true)
      torch_king_10:set_enabled(true)
    end)
  end
end
function torch_grave5_2:on_interaction_item(lamp)
  torch_grave5_2:get_sprite():set_animation("lit")
  sol.audio.play_sound("ghost")
  local poe = map:create_enemy({x=944,y=896,layer=1,direction=0,breed="poe",treasure_name="poe_soul"})
  poe:get_sprite():fade_in(80)
  if torch_grave5_1:get_sprite():get_animation() == "lit" then
    map:move_camera(752, 472, 300, function()
      torch_king_5:set_enabled(true)
      torch_king_10:set_enabled(true)
    end)
  end
end