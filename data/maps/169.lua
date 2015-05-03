local map = ...
local game = map:get_game()

---------------------------------------------------------
-- Cave of Ordeals - 50 floors of enemies and trials   --
---------------------------------------------------------

game:set_value("i1609", 0)

function random_8(lower, upper)
  math.randomseed(os.time())
  return math.random(math.ceil(lower/8), math.floor(upper/8))*8
end

function map:on_started(destination)
  if game:get_value("i1840") >= 7 then
    blocker:set_enabled(false)
    npc_moblin:remove()
  end
end

function map:on_update()
  if map:get_entities_count("enemy") == 0 then
    room1_tran:set_enabled(true)
    room2_tran:set_enabled(true)
    room3_tran:set_enabled(true)
    room4_tran:set_enabled(true)
  else
    room1_tran:set_enabled(false)
    room2_tran:set_enabled(false)
    room3_tran:set_enabled(false)
    room4_tran:set_enabled(false)
  end
end

function room1_dest:on_activated()
  game:set_value("i1609", game:get_value("i1609")+1)
  print("Room 1. Floor number: "..game:get_value("i1609"))
    if game:get_value("i1609") == 1 then
      -- Room 1: 10 Keese
      for i=1,10 do
	ex = random_8(72,352)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese",name="enemy" })
      end
    elseif game:get_value("i1609") == 6 then
      -- Room 6: Red Chuchus
      for i=1,6 do
	ex = random_8(72,352)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_red",name="enemy" })
      end
    elseif game:get_value("i1609") == 11 then
      -- Room 11: Peahats
      for i=1,2 do
	ex = random_8(72,352)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="peahat",name="enemy" })
      end
    elseif game:get_value("i1609") == 16 then
      -- Room 16: Moths
      for i=1,14 do
	ex = random_8(72,352)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="moth",name="enemy" })
      end
    elseif game:get_value("i1609") == 21 then
      -- Room 21: Ice Keese
      for i=1,10 do
	ex = random_8(72,352)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese_ice",name="enemy" })
      end
    elseif game:get_value("i1609") == 26 then

    elseif game:get_value("i1609") == 31 then

    elseif game:get_value("i1609") == 36 then

    elseif game:get_value("i1609") == 41 then

    elseif game:get_value("i1609") == 46 then

    end
end

function room2_dest:on_activated()
  game:set_value("i1609", game:get_value("i1609")+1)
  print("Room 2. Floor number: "..game:get_value("i1609"))
    if game:get_value("i1609") == 2 then
      -- Room 2: rats, keese
      for i=1,5 do
	ex = random_8(552,720)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese",name="enemy" })
      end
      for i=1,5 do
	ex = random_8(552,720)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="rat",name="enemy" })
      end
    elseif game:get_value("i1609") == 7 then
      -- Room 7: keese, tentacles
      for i=1,4 do
	ex = random_8(552,720)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese",name="enemy" })
      end
      for i=1,4 do
	ex = random_8(552,720)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="tentacle",name="enemy" })
      end
    elseif game:get_value("i1609") == 12 then
      -- Room 12: Tektites
      for i=1,4 do
	ex = random_8(552,720)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="tektite_red",name="enemy" })
      end
      for i=1,4 do
	ex = random_8(552,720)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="tektite_blue",name="enemy" })
      end
    elseif game:get_value("i1609") == 17 then
      -- Room 17: Helmasaurs and rats
      for i=1,4 do
	ex = random_8(552,720)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="helmasaur_red",name="enemy" })
      end
      for i=1,4 do
	ex = random_8(552,720)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="rat",name="enemy" })
      end
    elseif game:get_value("i1609") == 22 then
      -- Room 22: Keese, Rats and Poes
      for i=1,6 do
	ex = random_8(552,720)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese",name="enemy" })
      end
      for i=1,4 do
	ex = random_8(552,720)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="rat",name="enemy" })
      end
      for i=1,2 do
	ex = random_8(552,720)
	ey = random_8(72,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="poe",name="enemy" })
      end
    elseif game:get_value("i1609") == 27 then

    elseif game:get_value("i1609") == 32 then

    elseif game:get_value("i1609") == 37 then

    elseif game:get_value("i1609") == 42 then

    elseif game:get_value("i1609") == 47 then

    end
end

function room3_dest:on_activated()
  game:set_value("i1609", game:get_value("i1609")+1)
  print("Room 3. Floor number: "..game:get_value("i1609"))
    if game:get_value("i1609") == 3 then
      -- Room 3: green soldiers
      for i=1,5 do
	ex = random_8(72,240)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="soldier_green",name="enemy" })
      end
    elseif game:get_value("i1609") == 8 then
      -- Room 8: fire keese
      for i=1,8 do
	ex = random_8(72,240)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese_fire",name="enemy" })
      end
    elseif game:get_value("i1609") == 13 then
      -- Room 13: Green ChuChus
      for i=1,12 do
	ex = random_8(72,240)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_green",name="enemy" })
      end
    elseif game:get_value("i1609") == 18 then
      -- Room 18: Peahat and moths
      for i=1,4 do
	ex = random_8(72,240)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="moth",name="enemy" })
      end
      map:create_enemy({x=152,y=528,layer=0,direction=0,breed="peahat",name="enemy" })
    elseif game:get_value("i1609") == 23 then
      -- Room 23: Armos
      map:create_enemy({x=128,y=504,layer=0,direction=0,breed="armos",name="enemy" })
      map:create_enemy({x=176,y=504,layer=0,direction=0,breed="armos",name="enemy" })
      map:create_enemy({x=88,y=536,layer=0,direction=0,breed="armos",name="enemy" })
      map:create_enemy({x=216,y=536,layer=0,direction=0,breed="armos",name="enemy" })
      map:create_enemy({x=112,y=576,layer=0,direction=0,breed="armos",name="enemy" })
      map:create_enemy({x=184,y=576,layer=0,direction=0,breed="armos",name="enemy" })
    elseif game:get_value("i1609") == 28 then

    elseif game:get_value("i1609") == 33 then

    elseif game:get_value("i1609") == 38 then

    elseif game:get_value("i1609") == 43 then

    elseif game:get_value("i1609") == 48 then

    end
end

function room4_dest:on_activated()
  game:set_value("i1609", game:get_value("i1609")+1)
  print("Room 4. Floor number: "..game:get_value("i1609"))
    if game:get_value("i1609") == 4 then
      -- Room 4: green knights
      for i=1,6 do
	ex = random_8(440,608)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="knight_green",name="enemy" })
      end
    elseif game:get_value("i1609") == 9 then
      -- Room 9: poe, fire keese
      for i=1,2 do
	ex = random_8(440,608)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="poe",name="enemy" })
      end
      for i=1,4 do
	ex = random_8(440,608)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese_fire",name="enemy" })
      end
    elseif game:get_value("i1609") == 14 then
      -- Room 14: Dodongos
      for i=1,3 do
	ex = random_8(440,608)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="dodongo",name="enemy" })
      end
    elseif game:get_value("i1609") == 19 then
      -- Room 19: Chu Horde
      for i=1,6 do
	ex = random_8(440,608)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_green",name="enemy" })
      end
      for i=1,5 do
	ex = random_8(440,608)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_red",name="enemy" })
      end
      for i=1,4 do
	ex = random_8(440,608)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_blue",name="enemy" })
      end
    elseif game:get_value("i1609") == 24 then
      -- Room 24: Redead
      for i=1,5 do
	ex = random_8(440,608)
	ey = random_8(440,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="redead",name="enemy" })
      end
    elseif game:get_value("i1609") == 29 then

    elseif game:get_value("i1609") == 34 then

    elseif game:get_value("i1609") == 39 then

    elseif game:get_value("i1609") == 44 then

    elseif game:get_value("i1609") == 49 then
      room4_tran:set_destination("treasure_dest")
    end
end

function room5_dest:on_activated()
  game:set_value("i1609", game:get_value("i1609")+1)
  print("Room 5 (Recovery). Floor number: "..game:get_value("i1609"))
end

function room5_exit:on_activated()
  game:get_value("i1609",0)
end

function npc_moblin:on_interaction()
  if game:get_value("b2026") then
    game:start_dialog("moblin.0.trading", function(answer)
      if answer == 1 then
        -- give it the meat, get the dog food
        game:start_dialog("moblin.0.trading_yes", function()
          hero:start_treasure("trading", 7)
          game:set_value("b2027", true)
          game:set_value("b2026", false)
	  blocker:set_enabled(false)
        end)
      else
        -- don't give it the meat
        game:start_dialog("moblin.0.trading_no")
      end
    end)
  else
    game:start_dialog("moblin.0.cave_ordeals")
  end
end

function sensor_exit:on_activated()
  game:start_dialog("exit.cave_ordeals")
end
