local function create_trash_slot(player)
    if player.gui.left.trash_slot then
        return
    end

    local trash_slot = player.gui.left.add({
        type = "frame",
        name = "trash_slot",
        direction = "vertical",
        caption = "Trash"
    })

    trash_slot.add({
        type = "sprite-button",
        name = "trash_button",
        sprite = "item/iron-chest",
        style = "slot_button"
    })
end

local function destroy_trash_slot(player)
    if player.gui.left.trash_slot then
        player.gui.left.trash_slot.destroy()
    end
end

script.on_event(defines.events.on_gui_opened, function(event)
    local player = game.players[event.player_index]
    if event.gui_type == 3 then
        create_trash_slot(player)
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local player = game.players[event.player_index]
    destroy_trash_slot(player)
end)

script.on_event(defines.events.on_gui_click, function(event)
    local player = game.players[event.player_index]
    if event.element.name == "trash_button" then
        if player.cursor_stack and player.cursor_stack.valid_for_read then
            player.cursor_stack.clear()
        end
    end
end)
