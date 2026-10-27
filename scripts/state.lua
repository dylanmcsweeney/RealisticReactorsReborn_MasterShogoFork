local state = {}

function state.ensure()
    -- Version-less saves with the modern storage layout are repaired below;
    -- replaying historical destructive migrations would lose reactor state.
    storage.version = storage.version or 24
    for _, key in ipairs({"reactors", "towers", "connected_reactors", "ruins",
        "fallout", "falloutclouds", "geigers", "sarcophagus", "delayed_fallout",
        "player_selections", "stats", "guis", "all_heat_pipes", "heatnet_changelog",
        "last_func_update", "settings"}) do
        storage[key] = storage[key] or {}
    end
    storage.overtime = storage.overtime or 0
    storage.tick_delayer = storage.tick_delayer or 0
    storage.name_counter = storage.name_counter or 0
    storage.gui_count = storage.gui_count or table_length(storage.guis)
    for _, setting in pairs(sttngs) do
        if storage.settings[setting.name] == nil then
            local source = setting.setting_type == "startup" and settings.startup or settings.global
            storage.settings[setting.name] = source[setting.name].value
        end
    end
    for _, task in pairs(on_tick_tasks) do
        storage.last_func_update[task.name] = storage.last_func_update[task.name] or game.tick
    end
end

function state.upgrade_2_1()
    for _, reactor in pairs(storage.reactors) do
        -- Do not replace the furnace/core: their contents, temperatures and
        -- crafting progress are the saved reactor's authoritative state.
        reactor.power_usage = reactor.power_usage or {starting=0, cooling=0, interface=0}
        reactor.bonus_cells = reactor.bonus_cells or {}
        reactor.hidden_output_inventory = reactor.hidden_output_inventory or {}
        reactor.connected_neighbours_IDs = reactor.connected_neighbours_IDs or {}
        reactor.quality = reactor.furnace.quality.level
        reactor.control = reactor.interface.get_or_create_control_behavior()
        local stopped = reactor.state == 0
        local decay = reactor.state == 3 and storage.settings["RRR-scram-behaviour"] == "decay heat (v1.0.x)"
        reactor.furnace.disabled_by_script = stopped or decay
        reactor.furnace.minable_flag = stopped
        for _, entity in ipairs({reactor.core, reactor.displayer}) do
            entity.disabled_by_script = stopped or decay
            entity.minable_flag = false
        end
        reactor.interface.minable_flag = false
        reactor.eccs_L.minable_flag = false
        reactor.eccs_R.minable_flag = false
    end
    for key, entity in pairs(storage.sarcophagus) do
        if entity.valid then entity.minable_flag = false
        else storage.sarcophagus[key] = nil end
    end
    -- This graph is derived from actual entities; rebuilding cannot consume fuel.
    init_heat_pipes()
    storage.version = 25
end

return state
