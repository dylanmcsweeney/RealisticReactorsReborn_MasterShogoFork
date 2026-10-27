
-- todo:
-- REACTOR_ENTITY_NAME
-- BREEDER_ENTITY_NAME


script.on_event(defines.events.on_pre_ghost_deconstructed, function(event)
	if event.ghost.type == "item-request-proxy" then return end
	if event.ghost.ghost_name == INTERFACE_ENTITY_NAME or event.ghost.ghost_name == BREEDER_INTERFACE_ENTITY_NAME then --interface ghost has been mined via deconstruction planner
		-- look for a reactor
		local entities = event.ghost.surface.find_entities_filtered{name={REACTOR_FURNACE_NAME,BREEDER_FURNACE_NAME}, position = {event.ghost.position.x,event.ghost.position.y}}
		
		for _, ent in pairs(entities) do
			if ent.name == REACTOR_FURNACE_NAME then
				local interface = event.ghost.surface.create_entity
				{
					name = INTERFACE_ENTITY_NAME,
					position = event.ghost.position,
					force = event.ghost.force
				}
				add_reactor(ent,interface)
				break
			elseif ent.name == BREEDER_FURNACE_NAME then
				local interface = event.ghost.surface.create_entity
				{
					name = BREEDER_INTERFACE_ENTITY_NAME,
					position = event.ghost.position,
					force = event.ghost.force
				}
				add_reactor(ent,interface)
				break
			end
		end
	elseif event.ghost.ghost_name == REACTOR_FURNACE_NAME or event.ghost.ghost_name == BREEDER_FURNACE_NAME then
	
		local interface = {}
		interface[1] = event.ghost.surface.find_entity(INTERFACE_ENTITY_NAME,{event.ghost.position.x,event.ghost.position.y+1})
		interface[2] = event.ghost.surface.find_entity(BREEDER_INTERFACE_ENTITY_NAME,{event.ghost.position.x,event.ghost.position.y+1})
		interface[3] = event.ghost.surface.find_entities_filtered{ghost_name=INTERFACE_ENTITY_NAME,position={event.ghost.position.x,event.ghost.position.y+1}}
		interface[3] = interface[3][1]
		interface[4] = event.ghost.surface.find_entities_filtered{ghost_name=BREEDER_INTERFACE_ENTITY_NAME,position={event.ghost.position.x,event.ghost.position.y+1}}
		interface[4] = interface[4][1]
		for _,int in pairs(interface) do
			int.destroy()
		end
	
	
	end
end)

script.on_event({defines.events.on_pre_player_mined_item, defines.events.on_robot_pre_mined, defines.events.on_entity_died,defines.events.script_raised_destroy,defines.events.on_space_platform_mined_entity }, function(event)
	if event.entity.name=="entity-ghost" then
		if event.entity.ghost_name == INTERFACE_ENTITY_NAME or event.entity.ghost_name == BREEDER_INTERFACE_ENTITY_NAME then --interface ghost has been mined manually
			local entities = event.entity.surface.find_entities_filtered{name={REACTOR_FURNACE_NAME,BREEDER_FURNACE_NAME}, position = {event.entity.position.x,event.entity.position.y}}
		
			for _, ent in pairs(entities) do
				if ent.name == REACTOR_FURNACE_NAME then
					local interface = event.entity.surface.create_entity
					{
						name = INTERFACE_ENTITY_NAME,
						position = event.entity.position,
						force = event.entity.force
					}
					add_reactor(ent,interface)
					break
				elseif ent.name == BREEDER_FURNACE_NAME then
					local interface = event.entity.surface.create_entity
					{
						name = BREEDER_INTERFACE_ENTITY_NAME,
						position = event.entity.position,
						force = event.entity.force
					}
					add_reactor(ent,interface)
					break
				end
			end
		elseif event.entity.ghost_name == REACTOR_FURNACE_NAME or event.entity.ghost_name == BREEDER_FURNACE_NAME then
		--remove interface on reactor ghost removal
			local interface = {}
			interface[1] = event.entity.surface.find_entity(INTERFACE_ENTITY_NAME,{event.entity.position.x,event.entity.position.y+1})
			interface[2] = event.entity.surface.find_entity(BREEDER_INTERFACE_ENTITY_NAME,{event.entity.position.x,event.entity.position.y+1})
			interface[3] = event.entity.surface.find_entities_filtered{ghost_name=INTERFACE_ENTITY_NAME,position={event.entity.position.x,event.entity.position.y+1}}
			interface[3] = interface[3][1]
			interface[4] = event.entity.surface.find_entities_filtered{ghost_name=BREEDER_INTERFACE_ENTITY_NAME,position = {event.entity.position.x,event.entity.position.y+1}}
			interface[4] = interface[4][1]
			for _,int in pairs(interface) do
				int.destroy()
			end
		end
	elseif event.entity.name == REACTOR_FURNACE_NAME or event.entity.name == BREEDER_FURNACE_NAME then
		local interface = {}
		interface[1] = event.entity.surface.find_entities_filtered{ghost_name=INTERFACE_ENTITY_NAME,position={event.entity.position.x,event.entity.position.y+1}}
		interface[1] = interface[1][1]
		interface[2] = event.entity.surface.find_entities_filtered{ghost_name=BREEDER_INTERFACE_ENTITY_NAME,position = {event.entity.position.x,event.entity.position.y+1}}
		interface[2] = interface[2][1]
		if interface[1] then
			interface[1].destroy()
		elseif interface[2] then
			interface[2].destroy()
		else
			remove_reactor(event)
		end
	elseif event.entity.name == TOWER_ENTITY_NAME then
		remove_cooling_tower(event.entity)
	elseif event.entity.name == REACTOR_RUIN_NAME or event.entity.name == BREEDER_RUIN_NAME then
		remove_reactor_ruin(event.entity)
	elseif event.entity.type == "heat-pipe" then
		remove_heat_pipe(event.entity.unit_number)
	end
end)

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.on_space_platform_built_entity, defines.events.script_raised_built, defines.events.script_raised_revive}, function(event)
	if event.entity.name == "RRR-reactor-sarcophagus" then
		event.entity.health = 0.1
		event.entity.destructible = false
		event.entity.minable_flag = false
		table.insert(storage.sarcophagus, event.entity)
		local fallout = event.entity.surface.find_entities_filtered{name="RRR-permanent-radiation",area={{event.entity.position.x-5,event.entity.position.y-5},{event.entity.position.x+5,event.entity.position.y+5}}}
		for i, entity in pairs (fallout) do
			if i%20 ~=1 then
				entity.destroy()
			end
		end
	--build event: reactors
	elseif event.entity.name == REACTOR_FURNACE_NAME or event.entity.name == BREEDER_FURNACE_NAME then
		event.entity.disabled_by_script = true
		event.entity.minable_flag = true
		--look for interface
		local interface_entity = event.entity.surface.find_entity(INTERFACE_ENTITY_NAME,{event.entity.position.x,event.entity.position.y+1})
		if not interface_entity then
			interface_entity = event.entity.surface.find_entity(BREEDER_INTERFACE_ENTITY_NAME,{event.entity.position.x,event.entity.position.y+1})
		end
		--look for interface ghost
		local interface_ghost
		if not interface_entity then
			interface_ghost = event.entity.surface.find_entities_filtered{ghost_name=INTERFACE_ENTITY_NAME,position={event.entity.position.x,event.entity.position.y+1}}
			if #interface_ghost == 0 then
				interface_ghost = event.entity.surface.find_entities_filtered{ghost_name=BREEDER_INTERFACE_ENTITY_NAME,position={event.entity.position.x,event.entity.position.y+1}}
			end
		end
		
		if interface_entity == nil and #interface_ghost == 0 then --no interface found
			--logging("Building new circuit interface")
			--add new circuit interface
			local interface
			if event.entity.name == REACTOR_FURNACE_NAME then --different interfaces for different reactors
				interface = event.entity.surface.create_entity
				{
					name = INTERFACE_ENTITY_NAME,
					position = {event.entity.position.x, event.entity.position.y + 1},
					force = event.entity.force
				}
			else
				interface = event.entity.surface.create_entity
				{
					name = BREEDER_INTERFACE_ENTITY_NAME,
					position = {event.entity.position.x, event.entity.position.y + 1},
					force = event.entity.force
				}
			end
			add_reactor(event.entity,interface)
			
		elseif interface_entity ~= nil then -- interface found
			--logging("Found existing circuit interface")
			add_reactor(event.entity,interface_entity)
			
		else --interface ghost found
			event.entity.destructible = true
			event.entity.minable_flag = true
		end
		
	elseif event.entity.name == INTERFACE_ENTITY_NAME or event.entity.name == BREEDER_INTERFACE_ENTITY_NAME then --build event: interfaces
		local reactors = event.entity.surface.find_entities_filtered{type = "reactor", position = {event.entity.position.x,event.entity.position.y-1}}
		local reactor_entity
		for _, ent in pairs(reactors) do
			if ent.name == REACTOR_FURNACE_NAME or ent.name == BREEDER_FURNACE_NAME then
				reactor_entity = ent
			end
		end
		
		if reactor_entity and reactor_entity.position.x == event.entity.position.x and reactor_entity.position.y == event.entity.position.y-1 then --reactor found and location is correct
			add_reactor(reactor_entity,event.entity)
		else
			event.entity.destructible = true
			event.entity.minable_flag = true
		end
		
	elseif event.entity.name == TOWER_ENTITY_NAME then --build event: cooling tower
		add_cooling_tower(event.entity)
		
	elseif event.entity.type == "heat-pipe" then
		add_heat_pipe(event.entity)
		
	elseif event.entity.name=="constant-combinator" then --build event: constant combinator (manually built)
		--check if there is an interface ghost under the constant combinator
		local interface_ghost = event.entity.surface.find_entities_filtered{ghost_name=INTERFACE_ENTITY_NAME,position=event.entity.position}
		if #interface_ghost == 0 then
			interface_ghost = event.entity.surface.find_entities_filtered{ghost_name=BREEDER_INTERFACE_ENTITY_NAME,position=event.entity.position}
		end
		if #interface_ghost > 0 then --interface ghost under constant combinator
			event.entity.destroy() --remove constant combinator
			local surface = interface_ghost[1].surface -- store attributes of the interface ghost
			local position = interface_ghost[1].position 
			local force = interface_ghost[1].force
			local name = interface_ghost[1].ghost_name
			interface_ghost[1].revive() --revive interface ghost (maintains circuit wire connections)
			if name == INTERFACE_ENTITY_NAME then --build normal reactor ghost
				surface.create_entity{
					name = "entity-ghost",
					position = {position.x, position.y - 1},
					force = force,
					inner_name = REACTOR_ENTITY_NAME,
					expires = false,
				}
			else --build breeder reactor ghost
				surface.create_entity{
					name = "entity-ghost",
					position = {position.x, position.y - 1},
					force = force,
					inner_name = BREEDER_ENTITY_NAME,
					expires = false,
				}
			end
		end
	end
	
end)




-- adds core, eccs, lamp, light, electric interface to the reactor core when it is build
function add_reactor(furnace,interface)
	local reactor_quality = furnace.quality.level
	reactor_core = furnace.surface.create_entity{name = "RRR-realistic-reactor-heat", position = {furnace.position.x, furnace.position.y}, force = furnace.force.name}
	reactor_core.set_heat_setting{temperature = 0, mode = "add"}
	reactor_core.temperature = 15
	--reactor is actually the reactor core
	reactor_core.destructible = false
	reactor_core.operable = false
	reactor_core.minable_flag = false
	--logging("---------------------------------------------------------------")
    --logging("Adding new reactor: "..furnace.name)
	--logging("Reactor core ID: " .. reactor_core.unit_number)
	--interface.operable = false 
	interface.destructible = false 
	interface.minable_flag = false
	local is_breeder = furnace.name == BREEDER_FURNACE_NAME
	--logging("Reactor ID: " .. interface.unit_number)
	local displayer = reactor_core.surface.create_entity
	{
		name = is_breeder and BREEDER_DISPLAYER_NAME or REACTOR_DISPLAYER_NAME,
		position = {x = reactor_core.position.x, y = reactor_core.position.y},
		force = reactor_core.force
	}
	displayer.operable = false 
	displayer.destructible = false
	displayer.minable_flag = false
	displayer.disabled_by_script = true
	displayer.insert{name = "RRR-dummy-fuel-cell", count = 50}
	--add the eccs
	local ECCS_AFFIX = ""
	if reactor_quality > 0 then
		ECCS_AFFIX = "-"..math.min(reactor_quality,10)
	end
	local eccs_L = reactor_core.surface.create_entity
	{
		name = ECCS_L_NAME..ECCS_AFFIX,
		position = {x = reactor_core.position.x-1, y = reactor_core.position.y+1},
		force = reactor_core.force
	}
	eccs_L.operable = false 
	eccs_L.destructible = false
	eccs_L.minable_flag = false
	local eccs_R = reactor_core.surface.create_entity
	{
		name = ECCS_R_NAME..ECCS_AFFIX,
		position = {x = reactor_core.position.x+1, y = reactor_core.position.y+1},
		force = reactor_core.force
	}
	eccs_R.operable = false 
	eccs_R.destructible = false
	eccs_R.minable_flag = false
	
	--add power entity
	local power = reactor_core.surface.create_entity
	{
		name = is_breeder and BREEDER_POWER_NAME or REACTOR_POWER_NAME,
		position = reactor_core.position,
		force = reactor_core.force
	}
	power.destructible=false
	power.energy = math.max(0,(1.5-storage.settings["RRR-energy_consumption_multiplier"])) * 17000000
	--add light
	local reactor_lamp
	local reactor_light
	reactor_lamp = reactor_core.surface.create_entity{name = "RRR-black-lamp", position = {reactor_core.position.x+0.017,reactor_core.position.y+0.88}, force = reactor_core.force.name}
	reactor_light = reactor_core.surface.create_entity{name = "RRR-black-light", position = {reactor_core.position.x+0.017,reactor_core.position.y+0.88}, force = reactor_core.force.name}

	reactor_lamp.destructible = false
	reactor_light.destructible = false
	
	-- reactor is not active when it is build (state=stopped)
	reactor_core.disabled_by_script = true
	
	--max power for gui
	if storage.settings["RRR-calculate-stats-function"] == "ingo's formulas" then
		reactor_max_power = 123
		reactor_max_efficiency = 200
	else
		reactor_max_power = 250
		reactor_max_efficiency = 210
	end
	local reactor = {
		id = interface.unit_number,	-- ID of the reactor (doesn't change)
		name = "", -- user defined name for identification
		name_render = rendering.draw_text{text = "", alignment = "center", surface = furnace.surface, target = {x=furnace.position.x, y=furnace.position.y-1}, only_in_alt_mode = storage.settings["RRR-overlay-text-mode"] == "in alt overlay", color = {r=1,g=1,b=1,a=1}},
		core_id = reactor_core.unit_number, -- ID of the core (changes when core is replaced)
		core = reactor_core, -- core entity
		interface = interface, -- interface entity
		eccs_L = eccs_L, -- eccs entity
		quality = reactor_quality,
		eccs_R = eccs_R, -- eccs entity
		power = power, -- power entity
		furnace = furnace, -- furnace entity
		displayer = displayer, -- visual appearance
		position = reactor_core.position, -- core position = reactor position
		state = 0, -- reactor state
		state_active_since = game.tick, -- state begin
		connected_neighbours_IDs = {}, -- list with IDs of connected reactors 
		neighbours = 0, -- number of connected reactors
		control = interface.get_or_create_control_behavior(), -- control behaviour for interface signals
		efficiency = 0, -- reactor efficiency
		bonus_cells = {}, -- list of bonus cell amount for breeder
		cooling_history=0, -- average power loss through cooling in the last TICKS_PER_UPDATE*8 ticks 
		lamp = reactor_lamp, --reactor lamp dummy
		light = reactor_light, --light dummy for the lamp
		interface_warning_tick = 0, --last tick an electricity warning was displayed on the interface (for imitating the game's behaviour)
		interface_warning = nil, --electricity warning dummy (interface)
		cooling_warning_tick = 0, --last tick an electricity warning was displayed on the cooling
		cooling_warning = nil, --electricity warning dummy (cooling)
		power_usage = {starting = 0,cooling = 0, interface = 0}, --portions of the power consumption
		last_states_update = game.tick,
		fuel_last_tick = 0, -- fuel value in the core on last tick
		--fluid_amount_last_tick = 0, -- fluid amount in eccs on last tick
		power_output_last_tick = 0, --power output in MW on last tick (only updated in start or running phase)
		last_temp_update = game.tick,
		refresh_inventory = false,
		hidden_output_inventory = {},
		max_power = reactor_max_power, --dynamic maximum value for gui
		max_efficiency = reactor_max_efficiency, --dynamic maximum value for gui
		control_current = 0,
		control_target = 0,
		control_rods_tech = reactor_core.force.technologies["RRR-control-rods"].researched and 1 or 0,
		manual_control_tick = 1,
		temperature_offset = 0,
		pollution_mult = 1,
		fuel_starvation= 0,
		signals = -- signals for interface
		{
		
			["core_temperature"] = {signal=SIGNAL_CORE_TEMP, count=0, index=1},
			["state_stopped"] = {signal=SIGNAL_STATE_STOPPED, count=1, index=2},
			["state_starting"] = {signal=SIGNAL_STATE_STARTING, count=0, index=3},
			["state_running"] = {signal=SIGNAL_STATE_RUNNING, count=0, index=4},
			["state_scramed"] = {signal=SIGNAL_STATE_SCRAMED, count=0, index=5},
			["power-output"] = {signal=SIGNAL_REACTOR_POWER_OUTPUT, count=0, index=6},
			["uranium-fuel-cells"] = {signal=SIGNAL_URANIUM_FUEL_CELLS, count=0, index=7},
			["efficiency"] = {signal=SIGNAL_REACTOR_EFFICIENCY, count=0, index=8},
			["cell-bonus"] = {signal=SIGNAL_REACTOR_CELL_BONUS, count=0, index=9},
			["electric-power"] = {signal=SIGNAL_REACTOR_ELECTRIC_POWER, count=0, index=10},
			["neighbour-bonus"] = {signal=SIGNAL_NEIGHBOUR_BONUS, count=0, index=11},
			["control-current"] = {signal=SIGNAL_CONTROL_CURRENT, count=0, index=12},
			["control-target"] = {signal=SIGNAL_CONTROL_TARGET, count=0, index=13},
			["cooling"] = {signal=SIGNAL_COOLING, count=0, index=14},
			--["coolant-amount"] = {signal=SIGNAL_COOLANT_AMOUNT, count=0, index=6},
			--["used-uranium-fuel-cells"] = {signal=SIGNAL_USED_URANIUM_FUEL_CELLS, count=0, index=9},
		  
		}
	}
	if storage.settings["RRR-overlay-text"] ~= "reactor name" or storage.settings["RRR-overlay-text-mode"] == "on hover" then
		reactor.name_render.scale = 1.5
	end
	--reactor.core.get_fuel_inventory().insert{name="RRR-dummy-fuel-cell", count = 50}
	storage.reactors[reactor.id] = reactor

	add_heat_pipe(reactor_core, reactor.id)
end

-- removes other reactor parts when its reactor core is removed
function remove_reactor(event)
	for i,reactor in pairs(storage.reactors) do
		if reactor.furnace == event.entity  then
			
			remove_heat_pipe(reactor.core.unit_number)
			
			local dead_reactor_core = reactor.core
			local dead_reactor_id = reactor.id
			local dead_reactor_name = reactor.furnace.name
			local surface = reactor.core.surface		
						
			-- cause meltdown?
			if reactor.state ~= 0 and storage.settings["RRR-meltdown-mode"] ~= "no meltdown" then
				surface.pollute(dead_reactor_core.position, 75000*reactor.pollution_mult) --0.006 evo @ 0.80 /2
				--if game.forces["enemy"] then
				--	game.forces["enemy"].evolution_factor=math.min(1,game.forces["enemy"].evolution_factor+0.007)
				--end
				-- working reactor destroyed, causing meltdown
				
				-- do the meltdown explosion		
				if storage.settings["RRR-meltdown-explosion"] == "atomic" then
					--create atomic explosion
					surface.create_entity({
						name="RRR-fallout-explosion",
						position=dead_reactor_core.position
					})
				else
					-- create normal explosion
					surface.create_entity({
						name="medium-explosion",
						position=dead_reactor_core.position
					})					
				end
				
				-- create reactor ruin
				local ruin = "none"
				
				-- 2 spaces:
				local nearby_ruins = surface.find_entities_filtered{name = {REACTOR_RUIN_NAME,BREEDER_RUIN_NAME,SARCOPHAGUS_ENTITY_NAME}, area = {{dead_reactor_core.position.x-2.5,dead_reactor_core.position.y-2.5},{dead_reactor_core.position.x+2.5,dead_reactor_core.position.y+2.5}}}
				if (storage.settings["RRR-meltdown-mode"] == "meltdown with ruin" or storage.settings["RRR-meltdown-mode"] == "meltdown with ruin + sarcophagus") and not nearby_ruins[1] then
				
					-- create reactor ruin
					if dead_reactor_name == REACTOR_FURNACE_NAME then
						ruin = surface.create_entity{
							name=REACTOR_RUIN_NAME,
							position=dead_reactor_core.position,
							force=dead_reactor_core.force, 
							create_build_effect_smoke = false
						}
					else
						ruin = surface.create_entity{
							name=BREEDER_RUIN_NAME,
							position=dead_reactor_core.position,
							force=dead_reactor_core.force, 
							create_build_effect_smoke = false
						}
					end
					ruin.destructible = false
					
					-- set health of ruin (for only ruin mode...)
					if storage.settings["RRR-meltdown-mode"] == "meltdown with ruin" then
						ruin.health = 0.1
						ruin.minable_flag = false
					end
					
					-- create steam producing entity
					local steam
                    if storage.settings["RRR-fallout-mode"] == "clouds and radioactivity" then
                        steam = surface.create_entity
                        {
                            name = RUIN_SMOKE_NAME,
                            position = {dead_reactor_core.position.x,dead_reactor_core.position.y+0.3},
                            force = dead_reactor_core.force
                        }
                        steam.operable = false 
                        steam.destructible = false 
                        steam.get_fuel_inventory().insert({name="solid-fuel", count=50}) -- at 1 watt, this is enough fuel to run for 39 years, should suffice
                        steam.set_fluid(1, {name="water", amount=1}) -- water for dummy steam puff recipe
                        steam.disabled_by_script = false -- start active - it's always active
                    end
					local glow = surface.create_entity
						{
							name = "RRR-ruin-glow",
							position = {dead_reactor_core.position.x,dead_reactor_core.position.y},
							force = dead_reactor_core.force
						}
					-- reactor ruin is saved in global table
					table.insert(storage.ruins,
					{
						id = ruin.unit_number, --same id as reactor
						entity = ruin,
						steam = steam,
						glow = glow,
						tick = game.tick,--changes during radiation creation
						meltdown_tick = game.tick,
						spread = 6,
						pollution_mult = reactor.pollution_mult
					})
					
				end				
				
				--create radiation and cloud
				if storage.settings["RRR-fallout-mode"] == "clouds and radioactivity" then
					local fallout_size = 4
					if storage.settings["RRR-meltdown-mode"] == "meltdown with ruin" then
						fallout_size = 2 + math.floor(math.min(1,storage.settings["RRR-fallout-duration"] / storage.settings["RRR-sarcophagus-duration"])*8) -- (4-2) + 600/1800*(fallout_growth+2) = 300/1800 = gets bigger 6 times up to 10
					end
					-- create fallout cloud
					local cloud = surface.create_entity({
						name="RRR-fallout-cloud",
						position=dead_reactor_core.position,
						force = "radioactivity-strong"
					})
					storage.falloutclouds = storage.falloutclouds or {}
					table.insert(storage.falloutclouds,{cloud=cloud, pollution_mult = reactor.pollution_mult})
					if storage.settings["RRR-meltdown-mode"] == "meltdown without ruin" then
						table.insert(storage.fallout,{tick = game.tick, position = dead_reactor_core.position, surface = surface, pollution_mult = reactor.pollution_mult})
					end
					--create delayed event for fallout around the dead_reactor_core
					local delay = 2
					while storage.delayed_fallout[event.tick+delay] do 
						delay = delay + 1
					end
					storage.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,min_radius = 0, fallout_size = math.floor(fallout_size/2)}
					
					delay = 180
					while storage.delayed_fallout[event.tick+delay] do 
						delay = delay + 1
					end
					storage.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,min_radius = 0, fallout_size = fallout_size}
					
				elseif storage.settings["RRR-fallout-mode"] == "radioactivity" then
				
					--create delayed event for fallout around the dead_reactor_core
					if storage.settings["RRR-meltdown-explosion"] == "atomic" then
						local fallout_size = 4
						if storage.settings["RRR-meltdown-mode"] == "meltdown with ruin" then
							fallout_size = 2 + math.floor(math.min(1,storage.settings["RRR-fallout-duration"] / storage.settings["RRR-sarcophagus-duration"])*8) -- (4-2) + 600/1800*(fallout_growth+2) = 300/1800 = gets bigger 6 times up to 10
						end
						local delay = 60
						while storage.delayed_fallout[event.tick+delay] do 
							delay = delay + 1
						end
						storage.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,fallout_size = fallout_size}
					else
						local fallout_size = 6
						if storage.settings["RRR-meltdown-mode"] == "meltdown with ruin" then
							fallout_size = 4 + math.floor(math.min(1,storage.settings["RRR-fallout-duration"] / storage.settings["RRR-sarcophagus-duration"])*8) -- (4-2) + 600/1800*(fallout_growth+2) = 300/1800 = gets bigger 6 times up to 10
						end
						local skips = 0
						local delay = 1
							while storage.delayed_fallout[event.tick+delay] do 
								delay = delay + 1
							end
							 if delay >11 then
							 	skips =skips + 1
							 end
						
						local delay2 = 60
							while storage.delayed_fallout[event.tick+delay2] do 
								delay2 = delay2 + 1
							end
							 if delay2 >70 then
							 	skips =skips + 1
							 end
						
						local delay3 = 120
							while storage.delayed_fallout[event.tick+delay3] do 
								delay3 = delay3 + 1
							end
							 if delay3 >130 then
							 	skips =skips + 1
							 end
							
						if skips == 0 then
							storage.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,min_radius = 1, fallout_size = math.floor(fallout_size/6)} --1
							storage.delayed_fallout[event.tick+delay2]={surface=surface,position = dead_reactor_core.position,min_radius = 2, fallout_size = math.floor(fallout_size/3)} --2
							storage.delayed_fallout[event.tick+delay3]={surface=surface,position = dead_reactor_core.position,min_radius = 3, fallout_size = math.floor(fallout_size*2/3)} --4
							
							delay = 180
							 while storage.delayed_fallout[event.tick+delay] do 
							 	delay = delay + 1
							 end
							storage.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,min_radius = 5, fallout_size = fallout_size} --6
						else
							delay = 1
							 while storage.delayed_fallout[event.tick+delay] do 
							 	delay = delay + 1
							 end
							storage.delayed_fallout[event.tick+delay]={surface=surface,position = dead_reactor_core.position,min_radius = 0, fallout_size = fallout_size} --5
						end
					end
					
					--table.insert(storage.fallout,{tick = game.tick, position = dead_reactor_core.position, surface = surface, ruin = ruin, spread = fallout_size}) --i think this one is only for clouds
				end
							
				-- remove the reactor ghost
				-- problem: ghost does not exist yet, it will be created in the next tick
				--> register event to remove the reactor ghost
				--register_remove_reactor_ghost_event(event.tick,dead_reactor_core.position)
				
			end	--meltdown		
			
			-- remove ghosts if ruin was build
			if event.name == defines.events.on_entity_died and (storage.settings["RRR-meltdown-mode"] == "meltdown without ruin" or storage.settings["RRR-meltdown-mode"] == "no meltdown") then 
				reactor.interface.destructible=true
				reactor.interface.damage(1000000,game.forces.neutral,"laser") --retain wire connections in the ghost
			else
				reactor.interface.destroy() -- remove interface entity
			end
			
			--remove other stuff
			reactor.eccs_L.destroy() -- remove eccs
			reactor.eccs_R.destroy() -- remove eccs
			reactor.power.destroy() -- remove power entity
			if reactor.name_render and reactor.name_render.valid then reactor.name_render.destroy() end
			if reactor.displayer.valid then reactor.displayer.destroy() end
			if reactor.core.valid then reactor.core.destroy() end
			if reactor.lamp.valid then reactor.lamp.destroy() end
			if reactor.light.valid then reactor.light.destroy() end
			if reactor.interface_warning and reactor.interface_warning.valid then reactor.interface_warning.destroy() end
			if reactor.cooling_warning and reactor.cooling_warning.valid then reactor.cooling_warning.destroy() end
			if event.name == defines.events.on_entity_died and reactor.state ~= 0 and (storage.settings["RRR-meltdown-mode"] == "meltdown with ruin" or storage.settings["RRR-meltdown-mode"] == "meltdown with ruin + sarcophagus") then
				reactor.furnace.destroy() --only destroy when there should not remain a ghost
			end
			
			--remove global table entry
			storage.reactors[i] = nil
		
		end 
	end
end

-- adds the steam entity to the cooling tower when it is build
function add_cooling_tower(tower)
-- the steam entity makes happy clouds when the tower is active
-- this is needed because the cooling tower is an electric furnace, and only burner furnaces can produce smoke
  --logging("---------------------------------------------------------------")
  --logging("Adding new cooling tower with ID: " .. tower.unit_number)
  local steam = tower.surface.create_entity
  {
    name = STEAM_ENTITY_NAME,
    position = tower.position,
    force = tower.force
  }
  steam.operable = false -- disable opening the happy cloud maker's GUI
  steam.destructible = false -- it can't be destroyed (we remove it when the cooling tower dies)
  steam.get_fuel_inventory().insert({name="solid-fuel", count=50}) -- at 1 watt, this is enough fuel to run for 39 years, should suffice
  steam.set_fluid(1, {name="water", amount=1}) -- water for dummy steam puff recipe
  steam.disabled_by_script = true -- start inactive
  table.insert(storage.towers,
  {
    id = tower.unit_number,
    entity = tower,
    steam = steam
  })
  --logging("-> tower successfully added")
  --logging("")
end

-- remove reactor ruin
function remove_reactor_ruin(dead_ruin)
	--when the reactor ruin was replaced by a sarcophagus, the steam creator entity needs to be removed 
	--logging("---------------------------------------------------------------")
	--logging("Removing reactor ruin ID: " .. dead_ruin.unit_number)
	for i,ruin in pairs(storage.ruins) do
	--logging("Checking storage.ruins: "..dead_ruin.unit_number)
		if ruin.id == dead_ruin.unit_number then
			--logging("-> found matching entry")
			if ruin.steam and ruin.steam.valid then ruin.steam.destroy() end
			if ruin.glow and ruin.glow.valid then ruin.glow.destroy() end
			storage.ruins[i]=nil
		end
	end
end

-- removes the steam entity when its cooling tower is removed 
function remove_cooling_tower(dead_tower)
--logging("---------------------------------------------------------------")
--logging("Removing cooling tower ID: " .. dead_tower.unit_number)
  for i,tower in pairs(storage.towers) do
    if tower.id == dead_tower.unit_number then
      --logging("-> found tower, removing it and all its parts")
	  tower.steam.destroy() -- remove happy cloud maker
      table.remove(storage.towers, i) -- remove table entry so we stop trying to update this tower
    end
  end
--logging("-> tower successfully removed")
--logging("")
end