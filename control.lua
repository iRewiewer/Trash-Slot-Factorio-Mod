local function create_trash_slot(player)
    if player.gui.left.trash_slot then return end
    local frame = player.gui.left.add{
        type = "frame",
        name = "trash_slot",
        direction = "vertical",
        caption = "Trash"
    }
    frame.add{
        type = "sprite-button",
        name = "trash_button",
        sprite = "item/iron-chest",
        style = "slot_button"
    }
end

local function destroy_trash_slot(player)
    if player.gui.left.trash_slot then
        player.gui.left.trash_slot.destroy()
    end
end

local function ensure_global_table()
    if not global then
        global = {}
    end
    if not global.trash_hidden then
        global.trash_hidden = {}
    end
    for _, ply in pairs(game.players) do
        if global.trash_hidden[ply.index] == nil then
            global.trash_hidden[ply.index] = false
        end
    end
end

script.on_configuration_changed(function()
    ensure_global_table()
end)

script.on_event(defines.events.on_player_created, function(event)
    ensure_global_table()
    local idx = event.player_index
    if global.trash_hidden[idx] == nil then
        global.trash_hidden[idx] = false
    end
end)

script.on_event(defines.events.on_gui_opened, function(event)
    local player = game.players[event.player_index]
    ensure_global_table()
    if event.gui_type == 3 then
        if not global.trash_hidden[event.player_index] then
            create_trash_slot(player)
        end
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local player = game.players[event.player_index]
    destroy_trash_slot(player)
end)

script.on_event(defines.events.on_gui_click, function(event)
    if not (event.element and event.element.valid) then return end
    if event.element.name == "trash_button" then
        local player = game.players[event.player_index]
        if player.cursor_stack and player.cursor_stack.valid_for_read then
            player.cursor_stack.clear()
        end
    end
end)

script.on_event("delete_selected_item", function(event)
    local player = game.players[event.player_index]
    if player.cursor_stack and player.cursor_stack.valid_for_read then
        player.cursor_stack.clear()
    end
end)

script.on_event("hide_trash_ui", function(event)
    ensure_global_table()
    local pid = event.player_index
    local player = game.players[pid]

    global.trash_hidden[pid] = not global.trash_hidden[pid]

    if global.trash_hidden[pid] then
        player.print("Trash UI is now hidden. Press U again to re-enable.")
    else
        player.print("Trash UI re-enabled. It will show next time you open an inventory GUI.")
    end
end)
