local adoption={}

local function find(surface,name,position,force)
    local entities=surface.find_entities_filtered{name=name,position=position,force=force}
    assert(#entities<=1,"RRR adoption: ambiguous existing component "..(type(name)=="string" and name or "interface"))
    return entities[1]
end

function adoption.scan()
    local known={}
    for _,r in pairs(storage.reactors) do known[r.furnace.unit_number]=true end
    local towers={};for _,t in pairs(storage.towers) do towers[t.entity.unit_number]=true end
    local ruins={};for _,r in pairs(storage.ruins) do ruins[r.entity.unit_number]=true end
    local sarcophagi={};for _,e in pairs(storage.sarcophagus) do sarcophagi[e.unit_number]=true end
    local clouds={}
    for _,c in pairs(storage.falloutclouds) do clouds[c.cloud]=true end
    local count=0
    for _,surface in pairs(game.surfaces) do
        for _,furnace in pairs(surface.find_entities_filtered{name={REACTOR_FURNACE_NAME,BREEDER_FURNACE_NAME}}) do
            if not known[furnace.unit_number] then
                local position={furnace.position.x,furnace.position.y+1}
                local name=furnace.name==BREEDER_FURNACE_NAME and BREEDER_INTERFACE_ENTITY_NAME or INTERFACE_ENTITY_NAME
                local interface=find(surface,{INTERFACE_ENTITY_NAME,BREEDER_INTERFACE_ENTITY_NAME},position,furnace.force)
                interface=interface or assert(surface.create_entity{name=name,position=position,force=furnace.force})
                furnace.disabled_by_script=true;furnace.minable_flag=true
                add_reactor(furnace,interface,true)
                local r=storage.reactors[interface.unit_number]
                r.adoption_locked=true;r.name="Adopted reactor "..interface.unit_number
                r.signals.core_temperature.count=r.core.temperature
                r.core.set_heat_setting{temperature=0,mode="add"}
                count=count+1
            end
        end
        for _,tower in pairs(surface.find_entities_filtered{name=TOWER_ENTITY_NAME}) do
            if not towers[tower.unit_number] then
                local steam=find(surface,STEAM_ENTITY_NAME,tower.position,tower.force)
                if steam then table.insert(storage.towers,{id=tower.unit_number,entity=tower,steam=steam})
                else add_cooling_tower(tower) end
            end
        end
        for _,ruin in pairs(surface.find_entities_filtered{name={REACTOR_RUIN_NAME,BREEDER_RUIN_NAME}}) do
            if not ruins[ruin.unit_number] then
                table.insert(storage.ruins,{id=ruin.unit_number,entity=ruin,tick=game.tick,
                    meltdown_tick=game.tick,spread=6,pollution_mult=1,
                    steam=find(surface,RUIN_SMOKE_NAME,{ruin.position.x,ruin.position.y+0.3},ruin.force),
                    glow=find(surface,"RRR-ruin-glow",ruin.position,ruin.force)})
            end
        end
        for _,cloud in pairs(surface.find_entities_filtered{name="RRR-fallout-cloud"}) do
            if not clouds[cloud] then table.insert(storage.falloutclouds,{cloud=cloud,pollution_mult=1}) end
        end
        for _,e in pairs(surface.find_entities_filtered{name=SARCOPHAGUS_ENTITY_NAME}) do
            if not sarcophagi[e.unit_number] and e.health<e.max_health then
                e.minable_flag=false;e.destructible=false;table.insert(storage.sarcophagus,e)
            end
        end
    end
    if count>0 then
        init_heat_pipes();update_heatnet()
        log("RRR direct adoption: "..count.." reactors stopped and awaiting acknowledgement")
        adoption.show_pending()
    end
    return count
end

function adoption.pending(force)
    local count=0
    for _,r in pairs(storage.reactors) do
        if r.adoption_locked and r.furnace.force==force then count=count+1 end
    end
    return count
end

function adoption.acknowledge(force)
    for _,r in pairs(storage.reactors) do
        if r.furnace.force==force then r.adoption_locked=nil end
    end
end

local function show(player)
    if player.gui.screen.rrr_adoption then return end
    local count=adoption.pending(player.force);if count==0 then return end
    local frame=player.gui.screen.add{type="frame",name="rrr_adoption",caption="Reactor adoption",direction="vertical"}
    frame.auto_center=true
    local text=frame.add{type="label",caption="Adopted reactors: "..count..". They are stopped.\nBuildings, physical contents and core temperatures were preserved.\nNames, timers, history and storage-only bonuses were reset.\nHidden items held only by the previous mod could not be recovered.\nEnabling controls permits existing START signals to restart reactors.\nYou can reopen this dialog with /rrr-adoption."}
    text.style.single_line=false
    local buttons=frame.add{type="flow",direction="horizontal"}
    buttons.add{type="button",name="rrr_adoption_enable",caption="Enable reactor controls"}
    buttons.add{type="button",name="rrr_adoption_later",caption="Keep stopped"}
end

local previous_click=script.get_event_handler(defines.events.on_gui_click)
script.on_event(defines.events.on_gui_click,function(event)
    if not event.element or not event.element.valid then return end
    local name=event.element.name
    if name~="rrr_adoption_enable" and name~="rrr_adoption_later" then
        if previous_click then previous_click(event) end
        return
    end
    local player=game.get_player(event.player_index)
    if name=="rrr_adoption_enable" then
        if game.is_multiplayer() and not player.admin then player.print("An administrator must enable adopted reactor controls.");return end
        adoption.acknowledge(player.force)
    end
    player.gui.screen.rrr_adoption.destroy()
end)
commands.add_command("rrr-adoption","Review adopted reactors and enable their controls.",function(event)
    if event.player_index then show(game.get_player(event.player_index)) end
end)
function adoption.show_pending()
    for _,player in pairs(game.connected_players) do show(player) end
end

script.on_nth_tick(60,function()
    for _,player in pairs(game.connected_players) do
        storage.adoption_prompted=storage.adoption_prompted or {}
        if not storage.adoption_prompted[player.index] and adoption.pending(player.force)>0 then
            show(player);storage.adoption_prompted[player.index]=true
        end
    end
end)

return adoption
