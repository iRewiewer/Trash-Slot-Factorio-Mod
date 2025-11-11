local DEFAULT_LOC = { 10, 40 }

local function ensure_script_data()
    storage = storage or {}
    storage.trash_hidden = storage.trash_hidden or {}
    storage.trash_pos = storage.trash_pos or {}
end

local function get_player(pid)
    return game.get_player(pid)
end

local function create_trash_slot(player)
    if player.gui.screen.trash_slot then return end

    local frame = player.gui.screen.add{
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

    local saved = storage.trash_pos[player.index]
    frame.location = saved or DEFAULT_LOC
end

local function destroy_trash_slot(player)
    if player.gui.screen.trash_slot and player.gui.screen.trash_slot.valid then
        player.gui.screen.trash_slot.destroy()
    end
end

local function refresh_trash_visibility(player)
    if storage.trash_hidden[player.index] then
        destroy_trash_slot(player)
    else
        create_trash_slot(player)
    end
end

script.on_init(function()
    ensure_script_data()
    for _, p in pairs(game.players) do
        if storage.trash_hidden[p.index] == nil then
            storage.trash_hidden[p.index] = false
        end
    end
end)

script.on_configuration_changed(function(_)
    ensure_script_data()
    for _, p in pairs(game.players) do
        if storage.trash_hidden[p.index] == nil then
            storage.trash_hidden[p.index] = false
        end
        refresh_trash_visibility(p)
    end
end)

script.on_event(defines.events.on_player_created, function(event)
    ensure_script_data()
    local idx = event.player_index
    if storage.trash_hidden[idx] == nil then
        storage.trash_hidden[idx] = false
    end
    local p = get_player(idx)
    refresh_trash_visibility(p)
end)

script.on_event(defines.events.on_gui_opened, function(event)
    ensure_script_data()
    local p = get_player(event.player_index)
    if not storage.trash_hidden[p.index] then
        create_trash_slot(p)
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    local p = get_player(event.player_index)
    destroy_trash_slot(p)
end)

script.on_event(defines.events.on_gui_location_changed, function(event)
    local elem = event.element
    if not (elem and elem.valid) then return end
    if elem.name == "trash_slot" then
        ensure_script_data()
        storage.trash_pos[event.player_index] = elem.location
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
    local elem = event.element
    if not (elem and elem.valid) then return end
    if elem.name == "trash_button" then
        local p = get_player(event.player_index)
        if p and p.cursor_stack and p.cursor_stack.valid_for_read then
            p.cursor_stack.clear()
        end
    end
end)

script.on_event("delete_selected_item", function(event)
    local p = get_player(event.player_index)
    if p and p.cursor_stack and p.cursor_stack.valid_for_read then
        p.cursor_stack.clear()
    end
end)

script.on_event("hide_trash_ui", function(event)
    ensure_script_data()
    local pid = event.player_index
    local p = get_player(pid)

    local new_state = not storage.trash_hidden[pid]
    storage.trash_hidden[pid] = new_state

    if new_state then
        destroy_trash_slot(p)
        p.print({"", "Trash UI is now hidden. Press the toggle again to re-enable."})
    else
        create_trash_slot(p)
        p.print({"", "Trash UI re-enabled."})
    end
end)
