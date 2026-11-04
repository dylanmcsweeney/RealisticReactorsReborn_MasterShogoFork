local state = {}

function state.ensure()
    state.cleanup()
    -- Version-less saves with the modern storage layout are repaired below;
    -- replaying historical destructive migrations would lose reactor state.
    if not storage.version then
        for _, r in pairs(storage.reactors or {}) do
            assert(r.furnace and r.core and r.eccs_L and r.eccs_R and r.control_current ~= nil,
                "RRR: missing schema version with unsupported reactor layout; restore a backup or request migration support")
        end
        storage.version = 24
    end
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
    storage.version = 26
end


function state.cleanup(surface_index)
    local function gone(entity)
        return not entity or not entity.valid or (surface_index and entity.surface.index == surface_index)
    end
    for id, r in pairs(storage.reactors or {}) do
        if gone(r.furnace) then
            for _, key in ipairs({"core","displayer","interface","eccs_L","eccs_R","power","lamp","light","interface_warning","cooling_warning","name_render"}) do
                local e=r[key]; if e and e.valid then e.destroy() end
            end
            storage.reactors[id]=nil
            if storage.stats then storage.stats[id]=nil end
        end
    end
    for key, g in pairs(storage.guis or {}) do
        if not g.gui or not g.gui.valid then storage.guis[key]=nil end
    end
    for _, name in ipairs({"towers","ruins"}) do
        for key, value in pairs(storage[name] or {}) do
            if gone(value.entity) then
                for _, part in ipairs({"steam","glow"}) do
                    local e=value[part];if e and e.valid then e.destroy() end
                end
                storage[name][key]=nil
            end
        end
    end
    for key,e in pairs(storage.sarcophagus or {}) do
        if gone(e) then storage.sarcophagus[key]=nil end
    end
    for _, name in ipairs({"fallout","delayed_fallout"}) do
        for key,v in pairs(storage[name] or {}) do
            if not v.surface or not v.surface.valid or v.surface.index==surface_index then storage[name][key]=nil end
        end
    end
    for key,v in pairs(storage.falloutclouds or {}) do
        if gone(v.cloud) then storage.falloutclouds[key]=nil end
    end
    for _, name in ipairs({"towers", "falloutclouds"}) do
        local packed={}
        for _, v in pairs(storage[name] or {}) do packed[#packed+1]=v end
        storage[name]=packed
    end
end

script.on_event({defines.events.on_pre_surface_deleted, defines.events.on_pre_surface_cleared}, function(event)
    state.cleanup(event.surface_index)
end)
script.on_event({defines.events.on_surface_deleted, defines.events.on_surface_cleared}, function(event)
    init_heat_pipes()
end)

return state
