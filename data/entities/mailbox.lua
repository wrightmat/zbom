local entity = ...
local game = entity:get_game()
local map = entity:get_game():get_map()

-- Mailbox uses a model so I don't have to attach the dialog to every
-- entity. Leaves open possibility of mail system in the future too.

function entity:on_interaction()
  if self:get_name() == "mailbox_link" then
    game:start_dialog("mailbox.link")
  else
    game:start_dialog("mailbox")
  end
end