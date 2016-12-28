local map = ...
local game = map:get_game()

local music_volume = 100
local exiting = false

---------------------------------------------------------
-- Cave of Ordeals - 50 floors of enemies and trials   --
---------------------------------------------------------
-- Every 5 rooms is a "rest room"
-- 1: 10 keese, 2: 5 rats, 5 keese, 3: 5 green soldiers, 4: 6 green knights
-- 6: 6 red chuchus, 7: 4 keese, 4 tentacles, 8: 8 fire keese, 9: 2 poe, 4 fire keese
-- 11: 2 peahats, 12: 4 red tektites, 13: 12 green chuchus, 14: 3 dodongos
-- 16: 14 moths, 17: 4 red helmasaurs, 4 rats, 18: 4 moths, 1 peahat, 19: chu horde
-- 21: 10 ice keese, 22: 6 keese, 4 rats, 2 poes, 23: 6 armos, 24: 5 redead
-- 26: 8 yellow chuchus, 27: 10 skeletors, 28: 5 lizalfos, 29: 4 regular wizzrobes
-- 31: 10 red helmasaurs, 32: 2 dodongos, 4 fire keese, 33: 4 armos, 4 fire keese, 34: 2 redeads, 2 poes
-- 36: big poe, 6 poes, 37: 8 ice keese, 2 redeads, 38: 2 ice wizzrobes, 2 fire wizzrobes, 39: 6 lynels
-- 41: 6 blue bari, 6 red bari 42: 10 ropes, 2 redeads, 2 poes, 43: 8 red hardhats, 44: 3 regular, 3 fire, 3 ice wizzrobes
-- 46: 4 redeads, 2 skeletors, 47: 4 gigas, 4 rats, 48: 4 purple leevers, 8 green leevers, 2 lynel, 49: 2 peahats, 2 redead, 4 red tektites, big poe

if game:get_value("i1609")==nil then game:set_value("i1609",0) end
if game:get_value("i1609") < 50 then game:set_value("i1609",0) end

function random_8(lower, upper)
  math.randomseed(os.time() - os.clock() * 1000)
  return math.random(math.ceil(lower/8), math.floor(upper/8))*8
end

function map:on_started(destination)
  if not game:get_value("b2026") then quest_trading_food:remove() end
  if game:get_value("i1840") >= 7 then
    blocker:set_enabled(false)
    npc_moblin:remove()
  end
end

function map:on_update()
  if not map:has_entities("enemy") and not exiting then
    exiting = true
    sol.audio.play_sound("chest_appears")
    -- fade out battle music and fade in cave music
    for music_volume=100,1,-1 do
      sol.audio.set_music_volume(music_volume)
    end
    sol.timer.start(self, 1000, function()
      sol.audio.play_music("cave_ordeals")
      for music_volume=1,100,1 do
        sol.audio.set_music_volume(music_volume)
      end
    end)
    room1_tran:set_enabled(true)
    room2_tran:set_enabled(true)
    room3_tran:set_enabled(true)
    room4_tran:set_enabled(true)
  end
end

function room1_dest:on_activated()
  exiting = false
  music_volume = 100
  sol.audio.play_music("battle")
  sol.audio.set_music_volume(music_volume)
  room1_tran:set_enabled(false)
  game:set_value("i1609", game:get_value("i1609")+1)

    if game:get_value("i1609") == 1 then
      -- Room 1: 10 Keese
      for i=1,10 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 6 then
      -- Room 6: Red Chuchus
      for i=1,6 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_red",name="enemy" })
      end
    elseif game:get_value("i1609") == 11 then
      -- Room 11: Peahats
      for i=1,2 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="peahat",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 16 then
      -- Room 16: Moths
      for i=1,14 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="moth",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 21 then
      -- Room 21: Ice Keese
      for i=1,10 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese_ice",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 26 then
      -- Room 26: Yellow Chus
      for i=1,8 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_yellow",name="enemy" })
      end
    elseif game:get_value("i1609") == 31 then
      -- Room 31: Red Helmasaurs
      for i=1,10 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="helmasaur_red",name="enemy" })
      end
    elseif game:get_value("i1609") == 36 then
      -- Room 36: Poes and Big Poe
      for i=1,6 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="poe",name="enemy" })
      end
      map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="poe_big",name="enemy" })
    elseif game:get_value("i1609") == 41 then
      -- Room 41: Red and Blue Baris
      for i=1,6 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="bari_red",name="enemy" })
      end
      for i=1,6 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="bari_blue",name="enemy" })
      end
    elseif game:get_value("i1609") == 46 then
      -- Room 46: Undead Hoarde
      for i=1,4 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="redead",name="enemy" })
      end
      for i=1,2 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="skeletor",name="enemy" })
      end
      for i=1,2 do
	ex = random_8(96,256)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="giga",name="enemy" })
      end
    end
end

function room2_dest:on_activated()
  exiting = false
  music_volume = 100
  sol.audio.play_music("battle")
  sol.audio.set_music_volume(music_volume)
  room2_tran:set_enabled(false)
  game:set_value("i1609", game:get_value("i1609")+1)

    if game:get_value("i1609") == 2 then
      -- Room 2: rats, keese
      for i=1,5 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese",name="enemy", treasure_name="random_enemy" })
      end
      for i=1,5 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="rat",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 7 then
      -- Room 7: keese, tentacles
      for i=1,4 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese",name="enemy", treasure_name="random_enemy" })
      end
      for i=1,4 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="tentacle",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 12 then
      -- Room 12: Tektites
      for i=1,4 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="tektite_red",name="enemy", treasure_name="random_enemy" })
      end
      for i=1,4 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="tektite_blue",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 17 then
      -- Room 17: Helmasaurs and rats
      for i=1,4 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="helmasaur_red",name="enemy", treasure_name="random_enemy" })
      end
      for i=1,4 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="rat",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 22 then
      -- Room 22: Keese, Rats and Poes
      for i=1,6 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese",name="enemy", treasure_name="random_enemy" })
      end
      for i=1,4 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="rat",name="enemy", treasure_name="random_enemy" })
      end
      for i=1,2 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="poe",name="enemy" })
      end
    elseif game:get_value("i1609") == 27 then
      -- Room 27: Skeletors
      for i=1,10 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="skeletor",name="enemy" })
      end
    elseif game:get_value("i1609") == 32 then
      -- Room 32: Dodongos and fire keese
      for i=1,4 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese_fire",name="enemy" })
      end
      for i=1,2 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="dodongo",name="enemy" })
      end
    elseif game:get_value("i1609") == 37 then
      -- Room 37: Ice Keese and Wizzrobes
      for i=1,8 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese_ice",name="enemy" })
      end
      for i=1,2 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="wizzrobe_ice",name="enemy" })
      end
    elseif game:get_value("i1609") == 42 then
      -- Room 42: Ropes, Redead and Poes
      for i=1,10 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="rope",name="enemy" })
      end
      ex = random_8(472,680)
      ey = random_8(96,240)
      map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="redead",name="enemy" })
      ex = random_8(472,680)
      ey = random_8(96,240)
      map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="redead",name="enemy" })
      ex = random_8(472,680)
      ey = random_8(96,240)
      map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="poe",name="enemy" })
      ex = random_8(472,680)
      ey = random_8(96,240)
      map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="poe",name="enemy" })
    elseif game:get_value("i1609") == 47 then
      -- Room 47: Rats, et al.
      for i=1,3 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="helmasaur_purple",name="enemy" })
      end
      for i=1,6 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="rat",name="enemy" })
      end
      for i=1,3 do
	ex = random_8(472,680)
	ey = random_8(96,240)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_dark",name="enemy" })
      end
    end
end

function room3_dest:on_activated()
  exiting = false
  music_volume = 100
  sol.audio.play_music("battle")
  sol.audio.set_music_volume(music_volume)
  room3_tran:set_enabled(false)
  game:set_value("i1609", game:get_value("i1609")+1)

    if game:get_value("i1609") == 3 then
      -- Room 3: green soldiers
      for i=1,5 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="soldier_green",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 8 then
      -- Room 8: fire keese
      for i=1,8 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese_fire",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 13 then
      -- Room 13: Green ChuChus
      for i=1,12 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_green",name="enemy" })
      end
    elseif game:get_value("i1609") == 18 then
      -- Room 18: Peahat and moths
      for i=1,4 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="moth",name="enemy", treasure_name="random_enemy" })
      end
      map:create_enemy({x=152,y=528,layer=0,direction=0,breed="peahat",name="enemy", treasure_name="random_enemy" })
    elseif game:get_value("i1609") == 23 then
      -- Room 23: Armos
      map:create_enemy({x=128,y=504,layer=0,direction=0,breed="armos",name="enemy", treasure_name="arrow" })
      map:create_enemy({x=176,y=504,layer=0,direction=0,breed="armos",name="enemy", treasure_name="arrow" })
      map:create_enemy({x=88,y=536,layer=0,direction=0,breed="armos",name="enemy", treasure_name="arrow" })
      map:create_enemy({x=216,y=536,layer=0,direction=0,breed="armos",name="enemy", treasure_name="arrow" })
      map:create_enemy({x=112,y=576,layer=0,direction=0,breed="armos",name="enemy", treasure_name="arrow" })
      map:create_enemy({x=184,y=576,layer=0,direction=0,breed="armos",name="enemy", treasure_name="arrow" })
    elseif game:get_value("i1609") == 28 then
      -- Room 28: Lizalfos
      for i=1,5 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="lizalfos",name="enemy" })
      end
    elseif game:get_value("i1609") == 33 then
      -- Room 33: Armos and fire keese
      for i=1,4 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="armos",name="enemy", treasure_name="arrow" })
      end
      for i=1,4 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese_fire",name="enemy" })
      end
    elseif game:get_value("i1609") == 38 then
      -- Room 38: Ice and Fire Wizzrobes
      for i=1,3 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="wizzrobe_fire",name="enemy" })
      end
      for i=1,3 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="wizzrobe_ice",name="enemy" })
      end
    elseif game:get_value("i1609") == 43 then
      -- Room 43: Hardhard beetles
      for i=1,8 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="hardhat_beetle_red",name="enemy" })
      end
    elseif game:get_value("i1609") == 48 then
      -- Room 48: Leevers and Lynels
      for i=1,4 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="leever_purple",name="enemy" })
      end
      for i=1,8 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="leever_green",name="enemy" })
      end
      for i=1,2 do
	ex = random_8(72,288)
	ey = random_8(464,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="lynel",name="enemy" })
      end
    end
end

function room4_dest:on_activated()
  exiting = false
  music_volume = 100
  sol.audio.play_music("battle")
  sol.audio.set_music_volume(music_volume)
  room4_tran:set_enabled(false)
  game:set_value("i1609", game:get_value("i1609")+1)

    if game:get_value("i1609") == 4 then
      -- Room 4: green knights
      for i=1,6 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="knight_green",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 9 then
      -- Room 9: poe, fire keese
      for i=1,2 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="poe",name="enemy" })
      end
      for i=1,4 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="keese_fire",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 14 then
      -- Room 14: Dodongos
      for i=1,3 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="dodongo",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 19 then
      -- Room 19: Chu Horde
      for i=1,6 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_green",name="enemy" })
      end
      for i=1,5 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_red",name="enemy" })
      end
      for i=1,4 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="chuchu_blue",name="enemy" })
      end
    elseif game:get_value("i1609") == 24 then
      -- Room 24: Redead
      for i=1,5 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="redead",name="enemy", treasure_name="random_enemy" })
      end
    elseif game:get_value("i1609") == 29 then
      -- Room 29: Wizzrobs
      for i=1,5 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="wizzrobe",name="enemy" })
      end
    elseif game:get_value("i1609") == 34 then
      -- Room 34: Redead and poes
      for i=1,3 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="redead",name="enemy" })
      end
      for i=1,5 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="poe",name="enemy" })
      end
    elseif game:get_value("i1609") == 39 then
      -- Room 39: Lynels
      for i=1,6 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="lynel",name="enemy" })
      end
    elseif game:get_value("i1609") == 44 then
      -- Room 44: Wizzrobe hoard
      for i=1,3 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="wizzrobe",name="enemy" })
      end
      for i=1,3 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="wizzrobe_ice",name="enemy" })
      end
      for i=1,3 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="wizzrobe_fire",name="enemy" })
      end
    elseif game:get_value("i1609") == 49 then
      -- Room 49: Final challenge!
      for i=1,2 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="peahat",name="enemy" })
      end
      for i=1,2 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="redead",name="enemy" })
      end
      for i=1,4 do
	ex = random_8(472,680)
	ey = random_8(472,600)
	map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="tektite_red",name="enemy" })
      end
      map:create_enemy({x=ex,y=ey,layer=0,direction=0,breed="poe_big",name="enemy" })

      -- go to treasure room finally!
      game:set_value("i1609", 50) 
      room4_tran:set_destination("treasure_dest")
    end
end

function room5_dest:on_activated()
  game:set_value("i1609", game:get_value("i1609")+1)
  if game:get_value("i1609") >= 50 then hero:teleport(169, "treasure_dest") end
end

function room5_exit:on_activated()
  if game:get_value("i1609") < 50 then game:set_value("i1609", 0) end
end

function treasure_dest:on_activated()
  -- Give Red Tunic, Blue Tunic, or Purple Tunic (basically upgrade the best one the player has)
  if game:get_item("tunic"):get_variant() == 1 then
    map:create_chest({layer=0,x=1208,y=501,sprite="entities/chest_big", treasure_name="tunic", treasure_variant=2})
  elseif game:get_item("tunic"):get_variant() == 2 then
    map:create_chest({layer=0,x=1208,y=501,sprite="entities/chest_big",treasure_name="tunic", treasure_variant=3})
  elseif game:get_item("tunic"):get_variant() == 3 then
    map:create_chest({layer=0,x=1208,y=501,sprite="entities/chest_big",treasure_name="tunic", treasure_variant=4})
  end
end

function npc_moblin:on_interaction()
  if game:get_value("b2026") then
    game:start_dialog("moblin.0.trading", function(answer)
      if answer == 1 then
        -- Give it the Meat, get the Dog Food.
        game:start_dialog("moblin.0.trading_yes", function()
          hero:start_treasure("trading", 7)
          game:set_value("b2027", true)
          game:set_value("b2026", false)
          blocker:set_enabled(false)
          quest_trading_food:remove()
        end)
      else
        -- Don't give it the meat.
        game:start_dialog("moblin.0.trading_no")
      end
    end)
  else
    game:start_dialog("moblin.0.cave_ordeals")
  end
end

function sensor_exit:on_activated()
  if game:get_hero():get_direction() == 1 then
    game:start_dialog("exit.cave_ordeals", game:get_value("i1609"))
  end
end