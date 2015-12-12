local map = ...
local game = map:get_game()

-----------------------------------------------------------
-- Castle Town houses (game houses, castle inside, etc.) --
-----------------------------------------------------------

if game:get_value("i1026")==nil then game:set_value("i1026", 0) end
if game:get_value("i1032")==nil then game:set_value("i1032", 0) end
if game:get_value("i1820")==nil then game:set_value("i1820", 0) end
if game:get_value("i1924")==nil then game:set_value("i1924", 0) end --Juba

local playing_chests = false
local playing_slots = false
local playing_arrows = false
local already_played_chests = false
local chests_rewards = {5, 20, 100}  -- Possible rupee rewards in chest game.
local unauthorized = map:get_game():get_value("b16")
local arrow_plays = map:get_game():get_value("i17")
if arrow_plays == nil then arrow_plays = 0 end
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
local arrow_score = 0
local i = 0
local score_text = nil
local score_x = 0
local score_y = 0

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
  if game:get_value("i1032") >= 3 and not game:get_value("b1699") then
    -- Council disbands after Zelda kidnapped.
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

  -- Replace shop items if they're bought.
  if game:get_value("i1820") >= 2 then -- Shield.
    self:create_shop_treasure({
	name = "shop_item_4",
	layer = 0,
	x = 1392,
	y = 472,
	price = 40,
	dialog = "_item_description.bow.2",
	treasure_name = "arrow",
	treasure_variant = 3
    })
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function elder_ulo:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("b1699") then
    game:start_dialog("ulo.6.council")
  elseif game:get_value("i1032") > 2 then
    game:start_dialog("ulo.2.council_zelda", game:get_player_name())
  else
    game:start_dialog("ulo.2.council", game:get_player_name())
  end
end

function elder_juba:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("b1699") then
    game:start_dialog("juba.3.council")
  elseif game:get_value("i1032") > 2 then
    game:start_dialog("juba.0.council_zelda")
  else
    game:start_dialog("juba.0.council")
  end
end
function elder_juba_office:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("i1923") >= 1 and game:get_value("b1134") and not game:get_value("b1816") then
    game:start_dialog("juba.2.office", function()
      hero:start_treasure("flippers", 1)
    end)
    game:set_value("i1924", 2)
  else
    if not game:get_value("b1134") and math.random(2) == 1 then
      game:start_dialog("juba.1.lakebed")
    else
      game:start_dialog("juba.1.office")
    end
    if game:get_value("i1924") == 0 then game:set_value("i1924", 1) end
  end
end

function elder_gin:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("b1699") then
    game:start_dialog("gin.2.council")
  elseif game:get_value("i1032") > 2 then
    game:start_dialog("gin.0.council_zelda")
  else
    game:start_dialog("gin.0.council")
  end
end

function elder_zelda:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("b1699") then
    game:start_dialog("zelda.2.council", game:get_player_name())
  else
    game:start_dialog("zelda.0.council", game:get_player_name(), function()
      if game:get_value("i1032") >= 1 then
        game:start_dialog("zelda.1.council")
      else
        game:start_dialog("zelda.0.goto_old_hyrule", function()
          if not game:has_item("glove") then game:start_dialog("zelda.0.goto_old_hyrule_glove") end
        end)
      end
    end)
  end
end

function elder_larin:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("b1699") then
    game:start_dialog("larin.2.council")
  elseif game:get_value("i1032") > 2 then
    game:start_dialog("larin.0.council_zelda")
  else
    game:start_dialog("larin.0.council")
  end
end

function elder_gonpho:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("b1699") then
    game:start_dialog("gonpho.1.council")
  elseif game:get_value("i1032") > 2 then
    game:start_dialog("gonpho.0.council_zelda")
  else
    game:start_dialog("gonpho.0.council")
  end
end

function elder_gonpho_office:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("gonpho.0.office")
end

function elder_koshi:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("b1699") then
    game:start_dialog("koshi.1.council")
  elseif game:get_value("i1032") > 2 then
    game:start_dialog("koshi.0.council_zelda")
  else
    game:start_dialog("koshi.0.council")
  end
end

function elder_koshi_office:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("koshi.0.office")
end

function house_bed:on_activated()
  snores:set_enabled(true)
  bed:set_enabled(true)
  bed:get_sprite():set_animation("hero_sleeping")
  hero:freeze()
  hero:set_visible(false)
  sol.timer.start(1000, function()
    snores:remove()
    bed:get_sprite():set_animation("hero_waking")
    sleep_timer = sol.timer.start(1000, function()
      sensor_sleep:set_enabled(false)
      hero:set_visible(true)
      hero:start_jumping(4, 24, true)
      bed:get_sprite():set_animation("empty_open")
      sol.audio.play_sound("hero_lands")
    end)
    sleep_timer:set_with_sound(false)
  end)
end

function sensor_sleep:on_activated()
  game:start_dialog("_sleep_bed", function(answer)
    if answer == 1 then
      hero:teleport("2", "house_bed", "fade")
      game:set_life(game:get_max_life())
      game:set_stamina(game:get_max_stamina())
      if game:get_value("i1026") < 1 then game:set_max_stamina(game:get_max_stamina()-20) end
      if game:get_value("i1026") > 3 then game:set_max_stamina(game:get_max_stamina()+20) end
      game:set_value("i1026", 0)
      game:switch_time_of_day()
      if game:get_time_of_day() == "day" then
        for entity in map:get_entities("night_") do
          entity:set_enabled(false)
        end
        night_overlay = nil
      else
        for entity in map:get_entities("night_") do
          entity:set_enabled(true)
        end
      end
    end
  end)
end

function sensor_zirna_cutscene:on_activated()
  game:set_dialog_style("default")
  -- If the player has been to library and heard Ordona speak, then
  -- continue the story with a Dark Interloper cutscene where they take Zelda.
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
    	            npc_zirna:get_sprite():set_animation("casting")
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
  game:set_dialog_style("default")
  -- Chest game dialog.
  if playing_chests then
    -- The player is already playing: tell him to choose a chest.
    game:start_dialog("chest_game.choose_chest")
  else
    -- See if the player can still play.
    if unauthorized then
      -- The player already won the wallet, so discourage play.
      game:start_dialog("chest_game.not_allowed", chests_question_dialog_finished)
    else
      if not already_played_game_1 then
        -- First time: long dialog with the game rules.
        game:start_dialog("chest_game.intro", chests_question_dialog_finished)
      else
        -- Quick dialog to play again.
        game:start_dialog("chest_game.play_again", chests_question_dialog_finished)
      end
    end
  end
end

function slots_man:on_interaction()
  game:set_dialog_style("default")
  -- slots game dialog
  if playing_slots then
    -- The player is already playing: tell him to stop the reels.
    game:start_dialog("slot_game.playing")
  else
    -- Dialog with the game rules.
    game:start_dialog("slot_game.intro", slots_question_dialog_finished)
  end
end

function arrow_man:on_interaction()
  game:set_dialog_style("default")
  -- Arrow game dialog.
  if playing_arrows then
    -- Player is already playing the game.
    game:start_dialog("arrow_game.playing")
  elseif game:has_item("bow") then
    -- Dialog with game rules.
    game:start_dialog("arrow_game.intro", arrow_question_dialog_finished)
  else
    -- Game not open until bow is obtained.
    game:start_dialog("arrow_game.not_open")
  end
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
    -- The player does not want to play the game.
    game:start_dialog("chest_game.not_playing")
  else
    -- Wants to play chest game.
    if game:get_money() < 20 then
      -- Not enough money.
      sol.audio.play_sound("wrong")
      game:start_dialog("slot_game.not_enough_money")
    else
      -- Enough money: reset the 3 chests, pay and start the game.
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
    -- Don't want to play the game.
    game:start_dialog("slot_game.not_playing")
  else
    -- Wants to play slots game.
    game:start_dialog("slot_game.choose_bet", slots_choose_bet_dialog_finished)
  end
end

function slots_choose_bet_dialog_finished(answer)
  if answer == 1 then
    -- bet 5 rupees
    slots_bet = 5
  else
    -- bet 20 rupees
    slots_bet = 20
  end
  if map:get_game():get_money() < slots_bet then
    -- Not enough money.
    sol.audio.play_sound("wrong")
    game:start_dialog("slot_game.not_enough_money")
  else
    -- Enough money: pay and start the game.
    game:remove_money(slots_bet)
    game:start_dialog("slot_game.just_paid")
    playing_slots = true

    -- Start the slot machine animations.
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

function arrow_question_dialog_finished(answer)
  arrow_score = 0
  if answer == 2 then
    -- The player does not want to play the game.
    game:start_dialog("arrow_game.not_playing")
  else
    -- Wants to play arrow game.
    if game:get_money() < 50 then
      -- not enough money
      sol.audio.play_sound("wrong")
      game:start_dialog("slot_game.not_enough_money")
    else
      -- Enough money: create the targets and start them moving.
      game:remove_money(50)
      if game:get_value("i1802") < 10 then
        game:start_dialog("arrow_game.not_enough_arrows", function()
          game:set_value("i1802", game:get_value("i1802")+10)
        end)
      else
        game:start_dialog("arrow_game.good_luck")
      end
      local nb_targets = (arrow_plays + 1) * 3
      if nb_targets > 20 then nb_targets = 20 end
      for i=1,nb_targets do
        sol.timer.start(map, math.random(10)*500, function()
          map:create_switch({
            name = "arrow_game_switch_"..i,
            x = 1952,
            y = 784,
            layer = 0,
            subtype = "arrow_target",
            sprite = "entities/switch_eye_down",
            sound = "arrow_hit",
            needs_block = false,
            inactivate_when_leaving = false
          })
          playing_arrows = true
        end)
      end

      local time = math.random(6)*8
      if time < 15 then time = 15 end
      sol.timer.start(map, time, function()
        for switch in map:get_entities("arrow_game_switch") do
          -- move targets to the left of the screen
          local sx,sy,sl = switch:get_position()
          switch:set_position(sx-1, sy, sl)
          -- remove switch when at left end of room
          if sx <= 1792 then switch:remove() end
        end

        if playing_arrows == true and not map:has_entities("arrow_game_switch") then
          playing_arrows = false
          if arrow_score > 200 then
            game:start_dialog("arrow_game.reward.great", arrow_score)
          else
            game:start_dialog("arrow_game.reward.good", arrow_score)
          end
          game:add_money(arrow_score)

          if game:get_value("i17") == nil then
            game:set_value("i17", 1)
          else
            game:set_value("i17", game:get_value("i17")+1)
          end
        end
        return true
      end)
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
    -- Trying to open a chest but not playing yet.
    game:start_dialog("chest_game.pay_first")
    chest:set_open(false)
    sol.audio.play_sound("wrong")
    hero:unfreeze()
  else
    -- Give a random reward.
    local index = math.random(#chests_rewards)
    local amount = chests_rewards[index]
    if amount == 100 and not already_played_chests then
      -- Don't give best prize at the first attempt.
      amount = 5
    end
    -- Give the rupees.
    if amount == 5 then
      hero:start_treasure("rupee", 2)
    elseif amount == 20 then
      hero:start_treasure("rupee", 3)
    elseif amount == 100 then
      if game:get_item("rupee_bag"):get_variant() == 1 then
        -- Give bigger rupee bag.
        hero:start_treasure("rupee_bag", 2)
      else
        hero:start_treasure("rupee", 4)
      end
    end
    if amount == 100 then
      -- The maximum reward was found: the game will discourage playing again.
      game:set_value("b16", true)
    end
    playing_chests = false
    already_played_chests = true
  end
end

-- Updates the slot machine.
function map:on_update()
  if playing_slots then
    -- Stop the reels when necessary.
    local nb_finished = 0
    for k, v in pairs(slots_slots) do
      if v.sprite:is_paused() then nb_finished = nb_finished + 1 end
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

  if playing_arrows then
    for switch in map:get_entities("arrow_game_switch") do
      switch.on_activated = function()
        local this_score = math.floor(math.random(5)+(arrow_plays*2)/4)
        arrow_score = arrow_score + this_score
        score_x, score_y = switch:get_position()
        score_text = sol.text_surface.create({ horizontal_alignment = "center", font = "bom", text = this_score })
      end
    end
  end

  function map:on_draw(dst_surface)
    if score_text ~= nil then
      score_text:draw(dst_surface, score_x, score_y)
      sol.timer.start(map, 1000, function() score_text = nil end)
    end
  end

end

-- This function gives the reward to the player in the slot machine game.
function slots_timeout()
  -- See if the player has won.
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
    if slots_reward + game:get_money() > 200 then
      if game:get_item("rupee_bag"):get_variant() == 1 then
        -- Give bigger rupee bag.
        hero:start_treasure("rupee_bag", 2)
      else
        hero:start_treasure("rupee", 4)
      end
    end
    game:add_money(slots_reward)
  end

  if symbols[1] == symbols[2] and symbols[2] == symbols[3] then
    -- Three identical symbols.
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
    -- Three rupees with different colors.
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

function shop_item_3:on_buying()
  if self:get_game():get_first_empty_bottle() == nil then
    game:start_dialog("shop.no_bottle")
    return false
  else
    hero:start_treasure("potion", 3)
    game:remove_money(200)
  end
end

function npc_shopkeeper:on_interaction()
  game:set_dialog_style("default")
  if math.random(4) == 1 and game:get_item("rupee_bag"):get_variant() < 2 then
    -- Randomly mention the bigger wallet.
    game:start_dialog("shopkeep.1")
  else
    game:start_dialog("shopkeep.0")
  end
end

function npc_attendant_dialog()
  game:set_dialog_style("default")
  if game:get_value("b1170") then game:start_dialog("council_attendant.7")
  elseif game:get_value("b1150") then game:start_dialog("council_attendant.6")
  elseif game:get_value("b1134") then game:start_dialog("council_attendant.5")
  elseif game:get_value("b1117") then game:start_dialog("council_attendant.4")
  elseif game:get_value("b1082") then game:start_dialog("council_attendant.3")
  elseif game:get_value("b1061") then game:start_dialog("council_attendant.2")
  elseif game:get_value("b1033") then game:start_dialog("council_attendant.8") end
end
function npc_attendant:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("i1032") >= 3 then
    game:start_dialog("council_attendant.1", npc_attendant_dialog)
  else
    game:start_dialog("council_attendant.0")
  end
end

function sensor_door_throne:on_activated()
  map:open_doors("door_throne")
end