local map = ...
local game = map:get_game()

-----------------------------------------------------------
-- Castle Town houses (game houses, castle inside, etc.) --
-----------------------------------------------------------

if game:get_value("i1924")==nil then game:set_value("i1924", 0) end --Juba
if game:get_value("i1032")==nil then game:set_value("i1032", 0) end

local playing_chests = false
local playing_slots = false
local already_played_chests = false
local chests_rewards = {5, 20, 100}  -- Possible rupee rewards in chest game.
local slots_bet = 0
local slots_reward = 0
local slots_man_sprite = nil
local slots_timer
local slots_slots = {
  [slot_machine_left] =   {initial_frame = 6, initial_delay = 70, current_delay = 0, symbol = -1},
  [slot_machine_middle] = {initial_frame = 15, initial_delay = 90, current_delay = 0, symbol = -1},
  [slot_machine_right] =  {initial_frame = 9, initial_delay = 60, current_delay = 0, symbol = -1}
}  -- The key is also the entity.
local chests_question_dialog_finished
local slots_question_dialog_finished
local slots_choose_bet_dialog_finished
local open_chest
local slots_timeout

function map:on_started(destination)
  chest_1.on_empty = open_chest
  chest_2.on_empty = open_chest
  chest_3.on_empty = open_chest
  for npc, v in pairs(slots_slots) do
    v.sprite = npc:get_sprite()
    v.sprite:set_frame(v.initial_frame)
    function npc:on_interaction()
      map:activate_slot_machine(self)
    end
  end
  slots_man_sprite = slots_man:get_sprite()
  npc_zirna:set_enabled(false)
  if game:get_value("i1032") >= 3 then
    -- Council disbands after Zelda kidnapped
    elder_ulo:remove()
    elder_juba:remove()
    elder_gin:remove()
    elder_larin:remove()
    elder_gonpho:remove()
    elder_koshi:remove()
    elder_zelda:remove()
  else
    elder_juba_office:remove()
    elder_gonpho_office:remove()
    elder_koshi_office:remove()
  end

  -- Activate any night-specific dynamic tiles
  if game:get_time_of_day() == "night" then
    for entity in map:get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function elder_ulo:on_interaction()
  if game:get_value("i1032") > 2 then
    game:start_dialog("ulo.2.council_zelda", game:get_player_name())
  else
    game:start_dialog("ulo.2.council", game:get_player_name())
  end
end

function elder_juba:on_interaction()
  if game:get_value("i1032") > 2 then
    game:start_dialog("juba.0.council_zelda")
  else
    game:start_dialog("juba.0.council")
  end
end
function elder_juba_office:on_interaction()
  if game:get_value("i1923") > 1 and game:get_value("b1134") then
    game:start_dialog("juba.2.office", function()
      hero:start_treasure("flippers", 0)
    end)
    game:set_value("i1924", 2)
  else
    game:start_dialog("juba.1.office")
    game:set_value("i1924", 1)
  end
end

function elder_gin:on_interaction()
  if game:get_value("i1032") > 2 then
    game:start_dialog("gin.0.council_zelda")
  else
    game:start_dialog("gin.0.council")
  end
end

function elder_zelda:on_interaction()
  game:start_dialog("zelda.0.council", game:get_player_name())
end

function elder_larin:on_interaction()
  if game:get_value("i1032") > 2 then
    game:start_dialog("larin.0.council_zelda")
  else
    game:start_dialog("larin.0.council")
  end
end

function elder_gonpho:on_interaction()
  if game:get_value("i1032") > 2 then
    game:start_dialog("gonpho.0.council_zelda")
  else
    game:start_dialog("gonpho.0.council")
  end
end

function elder_koshi:on_interaction()
  if game:get_value("i1032") > 2 then
    game:start_dialog("koshi.0.council_zelda")
  else
    game:start_dialog("koshi.0.council")
  end
end

function sensor_zirna_cutscene:on_activated()
  -- If the player has been to library and heard
  -- Ordona speak, then continue the story with a
  -- Dark Interloper cutscene where they take Zelda
  if game:get_value("i1032") == 2 then
    local hx, hy, hl = map:get_hero():get_position()
    npc_zirna:set_enabled(true)
    sol.audio.play_music("battle")
    local m = sol.movement.create("target")
    m:set_ignore_obstacles(true)
    m:set_speed(48)
    m:set_target(872, 400)
    m:start(npc_zirna, function()
    npc_zirna:get_sprite():set_animation("walking")
      m:set_target(976, 400)
      m:start(npc_zirna, function()
        m:set_target(976, 248)
        m:start(npc_zirna, function()
	  game:start_dialog("zirna.0.council", function()
	    map:move_camera(992, 160, 350, function()
              game:start_dialog("zelda.0.zirna", function()
                local zix, ziy, zil = npc_zirna:get_position()
                dark_appears = map:create_npc({name="dark_appears", x=zix, y=ziy, layer=1, direction=0, subtype=0, sprite="entities/dark_appears"})
	        sol.timer.start(1000, function()
		  dark_appears:set_enabled(true)
                  dark_appears:set_position(992, 127)
		  sol.timer.start(2000, function()
                    npc_zirna:set_position(992, 127)
    	            npc_zirna:get_sprite():set_animation("pose1")
	            game:start_dialog("zirna.0.council_2", function()
                      zex, zey, zel = elder_zelda:get_position()
		      dark_appears:set_enabled(true)
		      dark_appears:set_position(zex, zey)
		      elder_zelda:remove()
		      sol.timer.start(1000, function()
		        dark_appears:set_position(992, 127)
		        dark_appears:set_enabled(true)
		        npc_zirna:remove()
		        dark_appears:remove()
		        game:set_value("i1032", 3)
		        sol.timer.start(1000, function()
			  sol.audio.play_music("castle")
		        end)
		      end)
                    end) --dialog
		  end)
                end)
	      end) --dialog
	    end, 500, 2000) --camera
          end) --dialog
        end)
      end)
    end)
  end
end


function chests_man:on_interaction()
  -- chest game dialog
  if playing_chests then
    -- the player is already playing: tell him to choose a chest
    game:start_dialog("chest_game.choose_chest")
  else
    -- see if the player can still play
    local unauthorized = map:get_game():get_value("b16")
    if unauthorized then
      -- the player already won much money
      game:start_dialog("chest_game.not_allowed")
    else
      if not already_played_game_1 then
        -- first time: long dialog with the game rules
        game:start_dialog("chest_game.intro", chests_question_dialog_finished)
      else
        -- quick dialog to play again
        game:start_dialog("chest_game.play_again", chests_question_dialog_finished)
      end
    end
  end
end

function slots_man:on_interaction()
  -- slots game dialog
  if playing_slots then
    -- the player is already playing: tell him to stop the reels
    game:start_dialog("slot_game.playing")
  else
    -- dialog with the game rules
    game:start_dialog("slot_game.intro", slots_question_dialog_finished)
  end
end

function arrow_man:on_interaction()
  --if playing_arrows then
    --game:start_dialog("arrow_game.playing")
  --else
    game:start_dialog("arrow_game.intro")
  --end
end

function map:activate_slot_machine(npc)
  if playing_slots then
    slots_man_sprite:set_direction(0)
    local slot = slots_slots[npc]
    if slot.symbol == -1 then
      -- stop this reel
      local sprite = slot.sprite
      local current_symbol = math.floor(sprite:get_frame() / 3)
      slot.symbol = (current_symbol + math.random(2)) % 7
      slot.current_delay = slot.current_delay + 100
      sprite:set_frame_delay(slot.current_delay)

      -- test code to win every game:
      -- for _, v in pairs(game_2_slots) do
      --    v.symbol = slot.symbol
      --    v.current_delay = slot.current_delay + 100
      --    v.sprite:set_frame_delay(v.current_delay)
      -- end

      sol.audio.play_sound("switch")
      hero:freeze()
    end
  else
    sol.audio.play_sound("wrong")
    game:start_dialog("slot_game.pay_first")
    hero:unfreeze()
  end
end

function chests_question_dialog_finished(answer)
  if answer == 2 then
    -- the player does not want to play the game
    game:start_dialog("chest_game.not_playing")
  else
    -- wants to play chest game
    if game:get_money() < 20 then
      -- not enough money
      sol.audio.play_sound("wrong")
      game:start_dialog("chest_game.not_enough_money")
    else
      -- enough money: reset the 3 chests, pay and start the game
      chest_1:set_open(false)
      chest_2:set_open(false)
      chest_3:set_open(false)
      game:remove_money(20)
      game:start_dialog("chest_game.good_luck")
      playing_chests = true
    end
  end
end

function slots_question_dialog_finished(answer)
  if answer == 2 then
    -- don't want to play the game
    game:start_dialog("slot_game.not_playing")
  else
    -- wants to play slots game
    game:start_dialog("slot_game.choose_bet", slots_choose_bet_dialog_finished)
  end
end

function slots_choose_bet_dialog_finished(answer)
  if answer == 1 then
    -- bet 5 rupees
    game_2_bet = 5
  else
    -- bet 20 rupees
    game_2_bet = 20
  end
  if map:get_game():get_money() < slots_bet then
    -- not enough money
    sol.audio.play_sound("wrong")
    game:start_dialog("slot_game.not_enough_money")
  else
    -- enough money: pay and start the game
    game:remove_money(slots_bet)
    game:start_dialog("slot_game.just_paid")
    playing_slots = true

    -- start the slot machine animations
    for k, v in pairs(slots_slots) do
      v.symbol = -1
      v.current_delay = v.initial_delay
      v.sprite:set_animation("started")
      v.sprite:set_frame_delay(v.current_delay)
      v.sprite:set_frame(v.initial_frame)
      v.sprite:set_paused(false)
    end
  end
end

function map:on_obtained_treasure(item, variant, savegame_variable)
  if item:get_name() == "rupee_bag" then
    sol.audio.play_sound("secret")
    game:start_dialog("chest_game.rupee_bag")
    playing_chest_game = false
  end
end

-- Function called when the player opens an empty chest (i.e. a chest
-- whose feature is to call the script).
function open_chest(chest)
  if not playing_chests then
    -- trying to open a chest but not playing yet
    game:start_dialog("chest_game.pay_first")
    chest:set_open(false)
    sol.audio.play_sound("wrong")
    hero:unfreeze()
  else
    -- give a random reward
    local index = math.random(#chests_rewards)
    local amount = chests_rewards[index]
    if amount == 100 and not already_played_chests then
      -- don't give best prize at the first attempt
      amount = 5
    end
    -- give the rupees
    if amount == 5 then
      hero:start_treasure("rupee", 2)
    elseif amount == 20 then
      hero:start_treasure("rupee", 3)
    elseif amount == 100 then
      hero:start_treasure("rupee_bag", 2) -- give bigger rupee bag
    end
    if amount == 100 then
      -- the maximum reward was found: the game will now refuse to let the hero play again
      game:set_value("b16", true)
    end
    playing_chests = false
    already_played_chests = true
  end
end

-- Updates the slot machine
function map:on_update()
  if playing_slots then
    -- stop the reels when necessary
    local nb_finished = 0
    for k, v in pairs(slots_slots) do
      if v.sprite:is_paused() then
	 nb_finished = nb_finished + 1
      end
    end
    for k, v in pairs(slots_slots) do
      local frame = v.sprite:get_frame()
      if not v.sprite:is_paused() and frame == v.symbol * 3 then
	 v.sprite:set_paused(true)
	 v.initial_frame = frame
	 nb_finished = nb_finished + 1
	 if nb_finished < 3 then
	   hero:unfreeze()
	 else
	   playing_slots = false
	   slots_timer = sol.timer.start(500, slots_timeout)
	 end
      end
    end
  end
end

-- This function gives the reward to the player in the slot machine game
function slots_timeout()
  -- see if the player has won
  local i = 1
  local green_found = false
  local blue_found = false
  local red_found = false
  local symbols = {-1, -1, -1}
  for k, v in pairs(slots_slots) do
    symbols[i] = v.symbol
    if symbols[i] == 0 then
      green_found = true
    elseif symbols[i] == 2 then
      blue_found = true
    elseif symbols[i] == 4 then
      red_found = true
    end
    i = i + 1
  end

  local function slots_give_reward()
    if slots_reward + game:get_money() > 100 then
      hero:start_treasure("rupee_bag", 2) -- give bigger rupee bag and fill it up!
    end
    game:add_money(slots_reward)
  end

  if symbols[1] == symbols[2] and symbols[2] == symbols[3] then
    -- three identical symbols
    if symbols[1] == 0 then -- 3 green rupees
      game:start_dialog("slot_game.reward.green_rupees", slots_give_reward)
      slots_reward = 5 * slots_bet
    elseif symbols[1] == 2 then -- 3 blue rupees
      game:start_dialog("slot_game.reward.blue_rupees", slots_give_reward)
      slots_reward = 7 * slots_bet
    elseif symbols[1] == 4 then -- 3 red rupees
      game:start_dialog("slot_game.reward.red_rupees", slots_give_reward)
      slots_reward = 10 * slots_bet
    elseif symbols[1] == 5 then -- 3 Yoshi
      game:start_dialog("slot_game.reward.yoshi", slots_give_reward)
      slots_reward = 20 * slots_bet
    else -- other symbol
      game:start_dialog("slot_game.reward.same_any", slots_give_reward)
      slots_reward = 4 * slots_bet
    end
  elseif green_found and blue_found and red_found then
    -- three rupees with different colors
    game:start_dialog("slot_game.reward.different_rupees", slots_give_reward)
    slots_reward = 15 * slots_bet
  else
    game:start_dialog("slot_game.reward.none", slots_question_dialog_finished)
    slots_reward = 0
  end
  if slots_reward ~= 0 then
    sol.audio.play_sound("secret")
  else
    sol.audio.play_sound("wrong")
  end
  hero:unfreeze()
end
