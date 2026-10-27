local fluids = require("scripts.fluids")
local qualities = {}
for a,b in pairs(prototypes.quality) do
	if b.name ~= "unknown" then
	
		qualities[b.level] = b.name
	end
end



local function apply_signals(control, signals, wipe)
	if not control.sections[1] then
		control.add_section()
	end
	
	
	
	for id, param in pairs(signals) do
		if wipe then 
			control.sections[1].clear_slot(param.index)
		else
			--param.count = 0/0
			if tostring(param.count) == "nan" then
				error(param.signal.name.." is NaN")
			end
			if param.signal.type == "item" then
				control.sections[1].set_slot(param.index, {value = {type = param.signal.type, name = param.signal.name, quality = param.signal.quality}, min = param.count})
			else
				control.sections[1].set_slot(param.index, {value = param.signal.name, min = param.count})
			end
		end
	end
end

-- cooling towers
--on_tick_tasks["iterate_cooling_towers"] = 
table.insert(on_tick_tasks,{ name = "iterate_cooling_towers", performance_hit = 0.31, ticks_per_update = 30, func = function(event)
	if not storage.iterate_cooling_towers or not storage.towers[storage.iterate_cooling_towers] then
	storage.iterate_cooling_towers = next(storage.towers)
	else
		storage.iterate_cooling_towers = next(storage.towers,storage.iterate_cooling_towers)
	end
	if not storage.iterate_cooling_towers then
		storage.iterate_cooling_towers = next(storage.towers)
	end
	local tower = storage.towers[storage.iterate_cooling_towers]
     -- enable or disable steamer
	 if not tower then return end
    if tower.entity.is_crafting() then
		
        tower.steam.disabled_by_script = false
     else
        tower.steam.disabled_by_script = true
     end
end})

--reactor signals
--on_tick_tasks["iterate_reactor_signals"] = 
table.insert(on_tick_tasks,{ name = "iterate_reactor_signals", performance_hit = 25.6, ticks_per_update = 20, reactor_scaling = 1, func = function(event)
	if not storage.iterate_reactor_signals or not storage.reactors[storage.iterate_reactor_signals] then
		storage.iterate_reactor_signals = next(storage.reactors)
	else
		storage.iterate_reactor_signals = next(storage.reactors,storage.iterate_reactor_signals)
	end
	if not storage.iterate_reactor_signals then
		storage.iterate_reactor_signals = next(storage.reactors)
	end
	local reactor = storage.reactors[storage.iterate_reactor_signals]
	if not reactor then return end
	local inventory = reactor.furnace.get_inventory(defines.inventory.crafter_input)
	if inventory.is_empty() then
		reactor.signals["uranium-fuel-cells"].count = 0
		reactor.signals["uranium-fuel-cells"].signal = {type="item", name="uranium-fuel-cell"}
	else
		reactor.signals["uranium-fuel-cells"].signal = {type="item", name=inventory[1].name, quality = inventory[1].quality}
		reactor.signals["uranium-fuel-cells"].count = inventory[1].count
	end
	-- destroy energy warning
	if game.tick - reactor.interface_warning_tick >=60  and reactor.interface_warning and reactor.interface_warning.valid then
		reactor.interface_warning.destroy()
	end
	reactor.signals["core_temperature"].count = reactor.core.temperature + reactor.temperature_offset
	reactor.signals["control-current"].count = math.ceil(reactor.control_current)
	if reactor.power.energy >= (POWER_USAGE_INTERFACE * TICKS_PER_UPDATE / 60* storage.settings["RRR-energy_consumption_multiplier"]) then   --- TICKS_PER_UPDATE // TODO: compare with correct power usage (not critical)
		apply_signals(reactor.control, reactor.signals)
		reactor.power_usage.interface = math.floor(POWER_USAGE_INTERFACE/60)
	else
		reactor.power_usage.interface = 0
		apply_signals(reactor.control, reactor.signals,true)
		-- show energy warning
		if game.tick - reactor.interface_warning_tick >=120 then
			reactor.interface_warning=reactor.interface.surface.create_entity{name="RRR-electricity-warning", position = reactor.interface.position, force = "neutral"}
			reactor.interface_warning.destructible = false
			reactor.interface_warning_tick = game.tick
		end
	end
end})

--reactor states
--on_tick_tasks["iterate_reactor_states"] = 
table.insert(on_tick_tasks,{ name = "iterate_reactor_states", performance_hit = 21.8, ticks_per_update = 20, reactor_scaling = 1, func = function(event)--cooling reactors
	if not storage.iterate_reactor_states or not storage.reactors[storage.iterate_reactor_states] then
		storage.iterate_reactor_states = next(storage.reactors)
	else
		storage.iterate_reactor_states = next(storage.reactors,storage.iterate_reactor_states)
	end
	if not storage.iterate_reactor_states then
		storage.iterate_reactor_states = next(storage.reactors)
	end
	if not storage.iterate_reactor_states then return end
	update_reactor_states(storage.iterate_reactor_states,event)	--update function
end})

-- reator temperature
--on_tick_tasks["iterate_reactor_temp"] = 
table.insert(on_tick_tasks,{ name = "iterate_reactor_temp", performance_hit = 5.6, ticks_per_update = 20, reactor_scaling = 1, func = function(event)--cooling reactors
	if not storage.iterate_reactor_temp or not storage.reactors[storage.iterate_reactor_temp] then
		storage.iterate_reactor_temp = next(storage.reactors)
	else
		storage.iterate_reactor_temp = next(storage.reactors,storage.iterate_reactor_temp)
	end
	if not storage.iterate_reactor_temp then
		storage.iterate_reactor_temp = next(storage.reactors)
	end
	if not storage.iterate_reactor_temp then return end
	update_reactor_temperature(storage.iterate_reactor_temp,event)	--update function
	--if not storage.skip_temp_iteration then	--if reactor is destroyed, the function has set the next value
		
	--else
	--	storage.skip_temp_iteration = nil
	--end
end})

table.insert(on_tick_tasks,{ name = "iterate_inventories", performance_hit = 0.45, ticks_per_update = 1800, reactor_scaling = 0.5, func = function(event)--cooling reactors
	if not storage.iterate_inventories or not storage.reactors[storage.iterate_inventories] then
		storage.iterate_inventories = next(storage.reactors)
	else
		storage.iterate_inventories = next(storage.reactors,storage.iterate_inventories)
	end
	if not storage.iterate_inventories then
		storage.iterate_inventories = next(storage.reactors)
	end
	if not storage.iterate_inventories then return end
	local reactor = storage.reactors[storage.iterate_inventories]
	
	local id = next(reactor.hidden_output_inventory)
	if id and reactor.furnace.get_output_inventory().is_empty() then
		local item = id:sub(1,id:match(".*()%-")-1)
		local quality = id:sub(id:match(".*()%-")+1)
		if prototypes.item[item] then
			if reactor.hidden_output_inventory[id] > 0  then
				reactor.furnace.get_output_inventory()[2].set_stack({name=item, count=math.floor(reactor.hidden_output_inventory[id]), quality = quality})
				
				reactor.hidden_output_inventory[id]=nil
				reactor.refresh_inventory = true
			else
				reactor.hidden_output_inventory[id] = nil
			end
		end
	end
end})



local function find_most_urgent (tick)
	local oldest_update = tick
	local found_index = nil
	for i, task in pairs(on_tick_tasks) do
		local t = storage.last_func_update[task.name]
		if t < oldest_update then
			oldest_update = t
			found_index = i
		end
	end
	return found_index
end
	
script.on_event(defines.events.on_tick, function(event)

-- iterate_overlays = 1.5
-- iterate_cooling_towers = 0.31
-- iterate_reactor_signals = 25.6
-- iterate_reactor_states = 21.8
-- iterate_reactor_temp = 5.6
--iterate_inventories = 0.45
 --game.print(on_tick_tasks[6].name)
--	for i=1,1000 do
--		on_tick_tasks[6].func(event)
--	end
--do return end
	--storage.dbg = 1
	--sarcophagus healing
	if event.tick % 180 ==0 then 
		for key, entity in pairs(storage.sarcophagus) do
			local max_health = entity.max_health
			entity.health = entity.health + max_health/math.max(1,storage.settings["RRR-sarcophagus-duration"]) * 3 * max_health/1000
			if entity.health >=max_health then
				entity.minable_flag = true
				entity.destructible = true
				storage.sarcophagus[key]=nil
			end
		end
	end
	-- radiation around reactor ruin
	if game.tick % 180 == 60 then -- max 2x radiation
		if storage.settings["RRR-fallout-mode"] == "radioactivity" or storage.settings["RRR-fallout-mode"] == "clouds and radioactivity" then
		
			for i,tbl in pairs(storage.ruins) do
				local ruin = tbl.entity
				if storage.settings["RRR-meltdown-mode"] == "meltdown with ruin" then
					ruin.health = ruin.health + 1000/math.max(1,storage.settings["RRR-sarcophagus-duration"]) /60*180--storage.settings["RRR-fallout-duration"]*5
					if ruin.health ==1000 then
						--entity.minable = true
						--entity.destructible = true
						remove_reactor_ruin(ruin)
						ruin.minable_flag = true
						ruin = nil
					end
				end
				if ruin and ruin.valid then
					periodic_pollution(ruin,0.1*tbl.pollution_mult)
					if tbl.tick + (storage.settings["RRR-fallout-duration"]*30) < game.tick then
						
						tbl.tick = game.tick
						tbl.spread = tbl.spread + 1
						circular_radiation(ruin.surface,ruin.position,0,math.min(16,tbl.spread))
					end
				end
			end
		end
		
	end
	
	
	-- radioactive cloud
	if event.tick % 180 ==120 then
		if storage.settings["RRR-fallout-mode"] == "clouds and radioactivity" then
	
			if storage.ruins ~= nil then
				for key,ruin in pairs(storage.ruins) do
					if ruin.meltdown_tick + 60*storage.settings["RRR-clouds_generation"] > game.tick then
						-- create fallout cloud
						local cloud = ruin.entity.surface.create_entity({
							name="RRR-fallout-cloud",
							position=ruin.entity.position,
							force = "radioactivity-strong"
						})	
						table.insert(storage.falloutclouds, {cloud = cloud, pollution_mult = ruin.pollution_mult})
					else
						-- disable steamer entity of ruin
						ruin.steam.disabled_by_script = true
					end
				end
			end

			if storage.fallout ~= nil then
				for key,meltdown in pairs(storage.fallout) do 
					if meltdown.tick+60*storage.settings["RRR-clouds_generation"] < game.tick then--and storage.settings["RRR-sarcophagus-mode"] == "no sarcophagus" then
						--remove cloud creating entry
						storage.fallout[key] = nil
					else
						
						-- create fallout cloud
						local cloud = meltdown.surface.create_entity({
							name="RRR-fallout-cloud",
							position=meltdown.position,
							force = "radioactivity-strong"
						})	
						table.insert(storage.falloutclouds,  {cloud = cloud, pollution_mult = meltdown.pollution_mult})
						
					end
				end
			end
			
		end
	end
		-- fallout radiation (from clouds)
	if event.tick % 79 ==0 then
		if storage.settings["RRR-fallout-mode"] == "clouds and radioactivity" then
			if storage.falloutclouds ~= nil then
				if #storage.falloutclouds > 0 then
					local rnd = math.random(#storage.falloutclouds)
					--for _,cloud in pairs(storage.falloutclouds) do --fallout 300 secs
					if storage.falloutclouds[rnd] and storage.falloutclouds[rnd].cloud and storage.falloutclouds[rnd].cloud.valid then
						periodic_pollution(storage.falloutclouds[rnd].cloud,0.05*storage.falloutclouds[rnd].pollution_mult)
						storage.falloutclouds[rnd].cloud.surface.create_entity({
							name="RRR-permanent-radiation",
							position=storage.falloutclouds[rnd].cloud.position,
							force = "radioactivity"
						})
					else
						table.remove(storage.falloutclouds,rnd)
					end
				end
			end
		end
	end
	
	
	-- delayed fallout
	if storage.delayed_fallout[event.tick] then
		circular_radiation(storage.delayed_fallout[event.tick].surface, storage.delayed_fallout[event.tick].position, storage.delayed_fallout[event.tick].min_radius or 0, storage.delayed_fallout[event.tick].fallout_size)
		storage.delayed_fallout[event.tick] = nil
	end
	
	-- registered tick for update event of connected reactors list
	if event.tick == storage.tick_update_connected_reactors then
		if storage.settings["RRR-manually-check-neighbours"] == false then
			--logging("---------------------------------------------------------------")
			--logging("Updating connected reactors list")
			--logging("Tick: " .. event.tick)
			--logging("---------------------------------------------------------------")
			update_heatnet()
			--for _, surface in pairs(game.surfaces) do
			--	checked_reactors = {}		
			--	for i,reactor in pairs(storage.reactors) do
			--		if reactor.core.surface == surface and not checked_reactors[reactor.id] then
			--			build_connected_reactors_list(reactor)
			--		end
			--	end
			--end
			--logging("")
		end
	end

	
	
	-- reactor update events
	
	for _, reactor in pairs(storage.reactors) do
		if reactor.refresh_inventory then
			refresh_inventory(reactor)
		end
	end
	

	local tick = event.tick
	local reactor_count =  table_length(storage.reactors)
	--game.print(tick_budget_per_reactor)
	local tick_budget_total = reactor_count * tick_budget_per_reactor + tick_budget+ storage.overtime

	local p_hit = 0
	local plan = {}
	
	while true do
		local most_urgent_index = find_most_urgent(tick)
		if not most_urgent_index then
			break
		end
		local task = on_tick_tasks[most_urgent_index]
		if (p_hit == 0 or p_hit + task.performance_hit <= tick_budget_total) then
			--game.print(game.tick.." "..task.name.." " ..(storage.last_func_update[task.name]-tick))
			task.func(event)
			p_hit = p_hit + task.performance_hit
			storage.last_func_update[task.name] = storage.last_func_update[task.name] + task.ticks_per_update/(task.reactor_scaling and math.max(0.5,task.reactor_scaling*reactor_count ) or 1)
		elseif storage.last_func_update[task.name] < tick-2 then
			if p_hit + task.performance_hit <= tick_budget_total*1.2+1 then
			
				--game.print(game.tick.." "..task.name.." " ..(storage.last_func_update[task.name]-tick))
				task.func(event)
				storage.last_func_update[task.name] = storage.last_func_update[task.name] + task.ticks_per_update/(task.reactor_scaling and math.max(0.5,task.reactor_scaling*reactor_count) or 1)
				p_hit = p_hit + task.performance_hit
			else
				storage.overtime = storage.overtime +1
				break
			end
		else
			break
		end
		-- Breche ab, wenn die maximale Arbeitszeit mit Überstunden erreicht ist
		if p_hit >= tick_budget_total*1.2 then
			break
		end
	end
	--game.print(game.tick.." "..p_hit)
	--game.print(storage.overtime)
	storage.overtime = math.max(0,storage.overtime -0.05 )

	
	
	
	
	
	stats_tick(event)
	light_tick(event)
end)

function refresh_inventory(reactor)
	local output = reactor.furnace.get_output_inventory()
	local output1 = nil
	local output2 = nil
	if output[1] and output[1].valid_for_read then
		output1 = {name = output[1].name, count = output[1].count, quality = output[1].quality}
	end
	if output[2] and output[2].valid_for_read then
		output2 = {name = output[2].name, count = output[2].count, quality = output[2].quality}
	end
	if output1 then
		output[1].clear()
		if not output2 then
			output[2].set_stack(output1)
		elseif output2 and (output2.name == output1.name and output2.quality == output1.quality) then
			output2.count = output2.count + output1.count
			output[2].set_stack(output2)
		else
			reactor.hidden_output_inventory[output1.name.."-"..output1.quality.name] = (reactor.hidden_output_inventory[output1.name.."-"..output1.quality.name] or 0) + output1.count
		end
	end
	reactor.refresh_inventory = false
end



function update_reactor_temperature(index, update_event)

	-- load the reactor
	local reactor = storage.reactors[index]
	if not reactor then return end
	local powerusagecooling = POWER_USAGE_COOLING
	local time_passed = math.max(1,update_event.tick - reactor.last_temp_update)
	reactor.last_temp_update = update_event.tick
	local change_mult = CHANGE_MULTIPLIER * (time_passed / 15)
	local reactor_core_temperature = reactor.core.temperature
	local reactor_state = reactor.state
	local powersignal = reactor.signals["power-output"].count
	local reactor_efficiency = reactor.efficiency
	local reactor_power_energy = reactor.power.energy
	local burner = to_burner(reactor.furnace)
	
	--apply efficiency by adding a fuel bonus
	if reactor_efficiency > 0 then
		local fuel_consumption = (powersignal/60*1000000)*(time_passed)*(100/reactor_efficiency)
		local remaining_fuel = burner.remaining_burning_fuel - fuel_consumption
		local fuel_value = burner.fuel_value
		
		if remaining_fuel - fuel_consumption > 0 then
			reactor.furnace.crafting_progress = 1-(remaining_fuel/math.max(1,fuel_value))--displayer.burner.remaining_burning_fuel = remaining_fuel - fuel_consumption
		else
			reactor.furnace.crafting_progress = 1
			reactor.refresh_inventory = true
		end

	else
		--no fuel bonus, efficiency=0 (reactor stopped)
	end	
	
	--apply starting power consumption
	if reactor_state == 1 then
		--apply cooling power consumption
		reactor.power_usage.starting = math.floor(POWER_USAGE_STARTING / 60)
	else
		reactor.power_usage.starting = 0
	end
	
	-- do environment cooling if state is stopped
	if reactor_state == 0 then
		if reactor_core_temperature > 15 then
			--logging("Reactor state is stopped, apply cooling by the environment")
			
			--[[
			local Tmix_env = ((reactor_core_temperature * REACTOR_MASS) + (15 * 10000)) / (REACTOR_MASS + 10000)
			--logging("Tmix_env: " .. Tmix_env)
			local Tdelta_reactor_env = reactor_core_temperature - Tmix_env	
			--logging("Tdelta_reactor_env: " .. Tdelta_reactor_env)
			local Tchange_reactor_env = (Tdelta_reactor_env * change_mult * 0.1)
			--logging("-> Tchange_reactor_env: " .. Tchange_reactor_env)
			if (reactor_core_temperature - Tchange_reactor_env) > 15 then
				reactor.core.temperature = reactor_core_temperature - Tchange_reactor_env
				reactor_core_temperature = reactor_core_temperature - Tchange_reactor_env
			else
				reactor.core.temperature = 15
				reactor_core_temperature = 15
			end
			]]
			
			if reactor_core_temperature > 15.125 then
				reactor_core_temperature = reactor_core_temperature - 0.05 * (time_passed / 15) -- -2MW
			else
				reactor_core_temperature = 15
			end
						
			--logging("Reactor core temperature after environment cooling: " .. reactor_core_temperature)
		end
	end
	
	-- do decay heat effect if state is scramed
	if reactor_state == 3 and storage.settings["RRR-scram-behaviour"] == "decay heat (v1.0.x)" then
		reactor_core_temperature = reactor_core_temperature + powersignal/40
	end
	
	reactor.power_usage.cooling = 0 -- supposed to be overwritten
	--local cooling_history = reactor.cooling_history
	--cooling_history = 0--cooling_history--*24/25 --devaluing previous history (only used by graph)
	local cooling = 0
	
	--remove cooling power alert (gfx)
	if game.tick - reactor.cooling_warning_tick >=60  and reactor.cooling_warning and reactor.cooling_warning.valid then
		reactor.cooling_warning.destroy()
	end
 	
	-- check fluid level in eccs and calculate temperature changes
	local fluid_L = reactor.eccs_L.get_fluid(1)
	local fluid_R = reactor.eccs_R.get_fluid(1)
	local Tchange_reactor = 0
	local Tchange_fluid = 0
	local eccs_power = storage.settings["RRR-eccs_power"]
	
	if fluid_L == nil and fluid_R == nil then
		--do nothing, no coolant
		--reactor.signals["coolant-amount"].count = 0		
		
	else
		--reactor has coolant
		local temp_L = fluid_L and fluid_L.temperature or 15
		local temp_R = fluid_R and fluid_R.temperature or 15
		local amount_L = fluid_L and fluid_L.amount or 0
		local amount_R = fluid_R and fluid_R.amount or 0
		
		
		local fluid_temperature = temp_L--fluid.temperature
		local fluid_amount = amount_L - amount_R--fluid.amount
		local reactor_quality_mult = 1+math.min(10,reactor.quality)/10
		if fluid_amount <0 then
			fluid_temperature = temp_R
			--fluid_amount = math.max(math.floor(time_passed * -eccs_power*0.24), fluid_amount)
			fluid_amount = math.max(math.floor(-4000*reactor_quality_mult/60*time_passed), fluid_amount)
		else
			--fluid_amount = math.min(math.floor(time_passed * eccs_power*0.24), fluid_amount)
			fluid_amount = math.min(math.floor(4000*reactor_quality_mult/60*time_passed), fluid_amount)
		end
		fluid_amount= fluid_amount/2
		local source = fluid_amount < 0 and reactor.eccs_R or reactor.eccs_L
		local destination = fluid_amount < 0 and reactor.eccs_L or reactor.eccs_R
		fluid_amount = (fluid_amount < 0 and -1 or 1) * fluids.transferable(source, destination, math.abs(fluid_amount))
		local before_cooling_temperature = reactor_core_temperature
		--reactor.signals["coolant-amount"].count = fluid_amount --the eccs works like a storage tank, this is not useful
		
		if math.abs(fluid_amount) < 30 then
			--do nothing, not enough coolant
		else
			local REACTOR_MASS = 6000 * 270 / eccs_power
			--calculate the mixing temperature with richmann's mixing rule
			local Tmix = ((reactor_core_temperature * REACTOR_MASS) + (math.abs(fluid_amount) * fluid_temperature)) / (REACTOR_MASS + math.abs(fluid_amount))
			
			-- check which is hotter and cool/heat accordingly
			local Tdelta_reactor = reactor_core_temperature - Tmix
			local Tdelta_fluid = fluid_temperature - Tmix
			
			if Tdelta_reactor > Tdelta_fluid then
				-- reactor is hotter than fluid (that is how it should be)
				
				Tchange_reactor = (Tdelta_reactor * change_mult)
				Tchange_fluid = (Tdelta_fluid * change_mult)

				if fluid_temperature - Tchange_fluid > 100 then
					-- resulting fluid would be too hot (max 100°, set by game)
					
					--reduce both temperature changes by the same factor, so that resulting fluid is = 100°
					efficiency_factor = (100 - fluid_temperature) / (Tdelta_fluid * change_mult * -1)
					Tchange_reactor = (Tchange_reactor * efficiency_factor)
					Tchange_fluid = (Tchange_fluid * efficiency_factor)					

				end			
				
				
			else
				-- fluid is hotter than reactor (it's possible to heat the reactor with a hot fluid)
				Tchange_reactor = (Tdelta_reactor * change_mult)
				Tchange_fluid = (Tdelta_fluid * change_mult)
				
				if reactor_core_temperature - Tchange_reactor > 100 then
					Tchange_reactor = 0
					Tchange_fluid = 0
					--do nothing, reactor is already 100°
					-- this is necessary, because theoretically it would be possible to heat the reactor with steam to 1000°, thus causing the meltdown

				end
				
			end

			
			-- --save the fluid back to the eccs
			-- fluid.temperature = fluid_temperature
			-- fluid.amount = fluid_amount
			-- reactor.eccs.fluidbox[1] = fluid
			
		end -- not enough coolant 
		
		
		--do the actual cooling
		local cooled = true
		if Tchange_reactor ~=0 then
			if storage.settings["RRR-static-cooling-power-consumption"] then
				-- static cooling power consumption
				
				if reactor_power_energy < (powerusagecooling * time_passed / 60* storage.settings["RRR-energy_consumption_multiplier"]) then
					-- not enough energy - don't cool
					cooled = false
				else
					-- cool/heat the core and the fluid
					reactor_core_temperature = reactor_core_temperature - Tchange_reactor
					fluid_temperature = fluid_temperature - Tchange_fluid
					-- cooling power consumption
					if Tchange_reactor>0.1 then
						reactor.power_usage.cooling = math.floor(powerusagecooling / 60)
					end
					cooling = cooling + Tchange_reactor * 10 / 1
				end
			else
				local max_cooling = reactor_power_energy / (powerusagecooling * time_passed / 60* storage.settings["RRR-energy_consumption_multiplier"])
				local cooling_mult = 1
				if max_cooling < math.abs(Tchange_reactor) then
					cooled = false
					cooling_mult = max_cooling/math.abs(Tchange_reactor)
				end
				cooling = cooling + Tchange_reactor * cooling_mult * 10 / 1
				reactor_core_temperature = reactor_core_temperature - Tchange_reactor * cooling_mult
				--cool the fluid
				fluid_temperature = fluid_temperature - Tchange_fluid * cooling_mult
				
				--cooling power consumption

				--dynamic cooling power consumption
				reactor.power_usage.cooling = math.floor(Tchange_reactor * cooling_mult * powerusagecooling / 60 / (time_passed/15))
				--cooling = cooling + reactor.power_usage.cooling*60/1000000/1* storage.settings["RRR-energy_consumption_multiplier"]
	
			end
		
		end
		
		--save the fluid back to the eccs
		--fluid.temperature = fluid_temperature
		--fluid.amount = fluid_amount
		--reactor.eccs.fluidbox[1] = fluid
		if math.abs(fluid_amount) >= 1 then
			local accepted = fluids.transfer(source, destination, math.abs(fluid_amount), fluid_temperature)
			local fraction = accepted / math.abs(fluid_amount)
			reactor_core_temperature = before_cooling_temperature + (reactor_core_temperature - before_cooling_temperature) * fraction
			reactor.power_usage.cooling = reactor.power_usage.cooling * fraction
			cooling = cooling * fraction
		end
		if cooling*60/time_passed > reactor.signals.cooling.count then
		--	reactor.signals.cooling.count= reactor.signals.cooling.count*(1-time_passed/400)+cooling*60/time_passed*(time_passed/400) + time_passed*0.05
			reactor.signals.cooling.count= reactor.signals.cooling.count*(1-time_passed/255)+cooling*60/time_passed*(time_passed/255) + time_passed*0.05
		else
		--	reactor.signals.cooling.count= math.max(0,reactor.signals.cooling.count*(1-time_passed/400)+cooling*60/time_passed*(time_passed/400) - time_passed*0.05)
			reactor.signals.cooling.count= math.max(0,reactor.signals.cooling.count*(1-time_passed/255)+cooling*60/time_passed*(time_passed/255)- time_passed*0.05)
		end
		if not cooled then
			-- core wasn't cooled - show energy warning signal
			if game.tick - reactor.cooling_warning_tick >=120 then
				reactor.cooling_warning=reactor.furnace.surface.create_entity{name="RRR-electricity-warning", position = reactor.furnace.position, force = "neutral"}
				reactor.cooling_warning.destructible = false
				reactor.cooling_warning_tick = game.tick
			end
		end
		
	end --empty eccs
	
	reactor.cooling_history = reactor.cooling_history + cooling

	-- update reactor signals
	reactor.signals["electric-power"].count = (reactor_power_energy/math.max(0.1,reactor.power.energy))*100
	
	-- set power usage value of power entity
	reactor.power.power_usage = (reactor.power_usage.starting + reactor.power_usage.cooling + reactor.power_usage.interface) * storage.settings["RRR-energy_consumption_multiplier"]
	--game.print()
	-- start nuclear meltdown
	reactor.core.temperature = reactor_core_temperature
	reactor.displayer.temperature = reactor_core_temperature + reactor.temperature_offset
	reactor.signals.core_temperature.count = reactor_core_temperature + reactor.temperature_offset
	--game.print(reactor_core_temperature)
	if reactor_core_temperature + reactor.temperature_offset >= math.min(1100,1000*(1+reactor.quality*0.01)) and storage.settings["RRR-meltdown-mode"] ~= "no meltdown" then
		--logging("Core temperature > 998°, MELTDOWN")
		--storage.iterate_reactor_temp = next(storage.reactors, storage.iterate_reactor_temp)
		--storage.skip_temp_iteration = true
		-- destroy the reactor core (will trigger meltdown)
		reactor.furnace.damage(25/60*time_passed*(3+reactor_core_temperature + reactor.temperature_offset-math.min(1100,1000*(1+reactor.quality*0.01))),game.forces.neutral)
		--if reactor.displayer.health <=5 then
		--	game.print("deto")
		--	reactor.displayer.damage(1000, game.forces.neutral)
		--	storage.iterate_reactor_temp = next(storage.reactors, storage.iterate_reactor_temp)
		--	storage.skip_temp_iteration = true
		--end
	end
	--else
	--	reactor.core.temperature = reactor_core_temperature
	--end

end



function update_reactor_states(index, update_event)
	--logging("---")
	-- load the reactor
	local reactor = storage.reactors[index]
	--logging("Updating reactor ID: " .. reactor.id)
	--logging("Reactor core ID: " .. reactor.core_id)
	--logging("Reactor type: ".. reactor.displayer.name)
	--logging("Reactor model: " .. reactor.core.name)
	--logging("Reactor state: " .. reactor.state)
	local running_time = math.ceil((update_event.tick - reactor.state_active_since)/60)
	--logging("-> state active for (s): " .. running_time) 
	local burner = to_burner(reactor.furnace)
		
	-- get control signals
	local signal_start = false
	local signal_scram = false
	for _,wire in ipairs{defines.wire_connector_id.circuit_green, defines.wire_connector_id.circuit_red} do
		local network = reactor.control.get_circuit_network(wire)
		if network then
			--logging("-> Found circuit network. Network ID: " .. network.network_id)
			if network.get_signal(SIGNAL_CONTROL_SCRAM) > 0 then
				signal_scram = true
				--logging("--> found SCRAM signal")
			elseif network.get_signal(SIGNAL_CONTROL_START) > 0 then
				signal_start = true
				--logging("--> found START signal")
			end
			if reactor.control_rods_tech > 0 then
				local control_target = network.get_signal(SIGNAL_CONTROL_TARGET)
				--game.print(control_target)
				if control_target~=0 and update_event.tick > reactor.manual_control_tick + 60 then
					reactor.control_target = control_target
				end
			end
		end
	end
	local dt = update_event.tick-reactor.last_states_update
	
	-- check for changed states
	--logging("Checking for changed reactor state")
	local reactor_state = reactor.state
	local state_changed = false
	if reactor_state == 0 then --off
		if reactor.furnace.get_inventory(defines.inventory.crafter_input).is_empty() == false then
			reactor.fuel_starvation = 0
			if signal_start == true
			and reactor.power.energy >= (POWER_USAGE_STARTING * TICKS_PER_UPDATE * 4 / 60* storage.settings["RRR-energy_consumption_multiplier"])
			and signal_scram == false then
				state_changed = true
				change_reactor_state(1, reactor, update_event)
			end
		end	
		
	elseif reactor_state == 1 then --starting
		
		if signal_scram == true then
			state_changed = true
			change_reactor_state(3, reactor, update_event)
		elseif running_time >= storage.settings["RRR-reactor-starting-duration"] then
			state_changed = true
			change_reactor_state(2, reactor, update_event)
		elseif reactor.power.energy < (POWER_USAGE_STARTING * TICKS_PER_UPDATE * 4 / 60* storage.settings["RRR-energy_consumption_multiplier"]) then
			--ToDo: show alarm on map?
			game.print("The starting phase of a nuclear reactor was aborted, because the reactor core didn't get enough electric energy from the grid. The fuel cell is lost.")
			state_changed = true
			change_reactor_state(0, reactor, update_event)
		elseif running_time >= 1 and (reactor.furnace.get_inventory(defines.inventory.crafter_input).is_empty() and burner.remaining_burning_fuel == 0 and burner.currently_burning == nil ) then
			game.print("Reactor start failed: No fuel or output inventory full.")
			reactor.fuel_starvation = reactor.fuel_starvation + dt
			--state_changed = true
			--change_reactor_state(0, reactor, update_event)
		else
			reactor.fuel_starvation = 0
		end
		
	elseif reactor_state == 2 then --running
		
		if signal_scram == true then
			state_changed = true
			change_reactor_state(3, reactor, update_event)
		elseif burner.remaining_burning_fuel == 0 and burner.currently_burning == nil and reactor.furnace.get_inventory(defines.inventory.crafter_input).is_empty() or burner.heat == 0 then
			reactor.fuel_starvation = reactor.fuel_starvation + dt
			--state_changed = true
			--change_reactor_state(0, reactor, update_event)
		else
			reactor.fuel_starvation = 0
		end		
	
	elseif reactor_state == 3 then --scramming
		if running_time >= storage.settings["RRR-reactor-scram-duration"] then
			state_changed = true
			local burnt_result = burner.currently_burning and burner.currently_burning.name.burnt_result
			if storage.settings["RRR-scram-behaviour"] ~= "stop half-empty" then
				if burnt_result then
					reactor.furnace.get_output_inventory().insert({name = burnt_result.name, count = 1, quality = burner.currently_burning.quality})
				end
				respawn_furnace(reactor)
			end
			change_reactor_state(0, reactor, update_event)			
		elseif reactor.furnace.get_inventory(defines.inventory.crafter_input).is_empty() and burner.remaining_burning_fuel == 0 then
			reactor.fuel_starvation = reactor.fuel_starvation + dt
		elseif storage.settings["RRR-scram-behaviour"] == "limit to current cell" and burner.remaining_burning_fuel < (reactor.signals["power-output"].count/60*1000000*(200)*(100/math.max(1,reactor.signals["efficiency"].count))) then --200 ticks
			
			local burnt_result = burner.currently_burning and burner.currently_burning.name.burnt_result
			state_changed = true
			if burnt_result then
				reactor.furnace.get_output_inventory().insert({name = burnt_result.name, count = 1, quality = burner.currently_burning.quality})
			end
			respawn_furnace(reactor)
			change_reactor_state(0, reactor, update_event)
		end
		
	end	
	if reactor.fuel_starvation >=180 then
		reactor.fuel_starvation = 0
		state_changed = true
		change_reactor_state(0, reactor, update_event)
	end
	
	running_time = math.ceil((update_event.tick - reactor.state_active_since)/60)
	if reactor.control_rods_tech > 0 then
		if reactor.power.energy >= (POWER_USAGE_STARTING * TICKS_PER_UPDATE * 4 / 60* storage.settings["RRR-energy_consumption_multiplier"]) then
			local control_speed = 0.012
			if reactor_state == 0 then
				control_speed = 0.045
			elseif reactor.control_target < reactor.control_current then
				control_speed = control_speed /3
			end
			control_speed = control_speed / math.max(0.3,reactor.signals.core_temperature.count/1000)
			control_speed = control_speed *storage.settings["RRR-control_rods_speed"]
			control_speed = control_speed *(1 + reactor.quality/10 + reactor.control_rods_tech/5)
			if reactor.control_target > reactor.control_current then
				reactor.control_current = math.min(100,reactor.control_target, reactor.control_current + control_speed*dt)
			elseif reactor.control_target < reactor.control_current then
				reactor.control_current = math.max(-100,reactor.control_target, reactor.control_current - control_speed*dt)
			end
			reactor.signals["control-current"].count = math.ceil(reactor.control_current)
		end
	end
	if state_changed == false then
		--logging("-> reactor state unchanged")
	else
		reactor_state = reactor.state
	end
	
	--update reactor signals
	if reactor_state  == 1 then
		reactor.signals["state_starting"].count = storage.settings["RRR-reactor-starting-duration"] - running_time
		reactor.signals["neighbour-bonus"].count = 0
	end
	
	if reactor_state  == 3 then
		reactor.signals["state_scramed"].count = storage.settings["RRR-reactor-scram-duration"] - running_time
		reactor.signals["neighbour-bonus"].count = 0
	end	
	if reactor_state  == 0 then
		-- reactor is not running
		reactor.signals["power-output"].count = 0
		reactor.signals["efficiency"].count = 0
		reactor.signals["cell-bonus"].count = 0
		reactor.signals["neighbour-bonus"].count = 0
	end
	

	-- check reactor and replace it with the appropriate version depending on temperature and connected reactors
	if reactor_state == 1 or reactor_state == 2 or reactor_state == 3 then
		
		--logging("---Updating reactor stats---")
		
		-- check how many running reactors are connected
		local reactor_neighbours = 1
		--logging("Checking running reactor neighbours:")
		local neighbours = 0
		for i,rid in pairs(reactor.connected_neighbours_IDs) do
			----logging("- connected reactor ID: " .. rid)
			neighbours = neighbours + 1
		end
		--logging("- Number of connected reactors: " .. neighbours)		
		
		for i,id in pairs(reactor.connected_neighbours_IDs) do
			--logging("- checking connected reactor ID: " .. id)
			
			if id == reactor.id then
				-- same reactor, do nothing
				--logging("-> this is the current reactor")					
			else
				-- found another reactor, check if it is running
				for i,global_reactor in pairs(storage.reactors) do
					if global_reactor.id == id then
						--logging("-> loaded connected reactor ID: " .. global_reactor.id)
						if global_reactor.state == 2 then
							reactor_neighbours = reactor_neighbours +1
							--logging("--> reactor is running, bonus: " .. reactor_neighbours)
						else
							--logging("--> reactor is not running, no bonus")
						end
					end
				end
			end
		end
		--logging("-> Running reactor neighbours: " .. reactor_neighbours)	
		reactor.neighbours = reactor_neighbours
		--reactor.signals.parameters["neighbour-bonus"].count = reactor_neighbours
		
		--load reactor parameters: 
		-- power , efficiency, bonus_cells, (max_power, max_efficiency)
		--logging("Calculating reactor stats:")
		local reactor_parameters
		if storage.settings["RRR-calculate-stats-function"] == "temperature sweetspot" then
			reactor_parameters = calculate_stats_ingo(reactor,running_time,dt,burner)
		else
			reactor_parameters = calculate_stats_ownly(reactor,running_time,dt,burner)
		end
		--logging("-> Temperature="..reactor.core.temperature.." PowerOutput="..reactor_parameters.power.." Efficiency="..math.floor(reactor_parameters.efficiency).." BonusCellAmount: "..reactor_parameters.bonus_cells)
		
		--apply material bonus by adding empty fuel cell
		local burnt_result
		local currently_burning
		local quality_name
		--logging("Applying empty fuel cell bonus:")
		if burner.currently_burning == nil then
		else
			--logging("- currently burning: "..burner.currently_burning.name)
			if reactor_parameters.bonus_cells == 0 then
				-- do nothing
				-- normal reactor or breeder too cold
				--logging("-> adding nothing, too cold or no breeder reactor")
			else
				currently_burning = burner.currently_burning.name
				-- add bonus to current empty fuel cell amount
				burnt_result = currently_burning.burnt_result
				quality_name = reactor.furnace.result_quality and reactor.furnace.result_quality.name or "normal"
				--burner.currently_burning.quality.name
				
				local result_swap = false
				if burnt_result.name == "apm_fuel_cell_mox_used" then
					burnt_result.name = prototype.item["apm_nuclear_breeder_uranium_inventory_enriched"]
					result_swap = true
				end
				local burn_duration = ((currently_burning.fuel_value/1000000)*(reactor_parameters.efficiency/100))/math.max(1,reactor_parameters.power)--*15/dt -- burn duration in ticks
				--game.print(burn_duration)
				--local cell_bonus_amount

				if storage.settings["RRR-calculate-stats-function"] == "temperature sweetspot" then
					--adding bonus cell per time
					cell_bonus_amount = ((reactor_parameters.bonus_cells*dt)/900)*BONUS_CELL_MULTIPLIER -- reactor_parameters.bonus_cells=100 means one cell per minute
				else
					--adding bonus cells per used fuel
					cell_bonus_amount = reactor_parameters.bonus_cells / math.max(1,burn_duration)
				end
				
				reactor.bonus_cells[burnt_result.name.."-"..quality_name] = (reactor.bonus_cells[burnt_result.name.."-"..quality_name] or 0) + cell_bonus_amount * (game.tick-reactor.last_states_update) / 60
				if not result_swap then
					reactor.furnace.bonus_progress = math.max(0, reactor.bonus_cells[burnt_result.name.."-"..quality_name]) 
					if reactor.bonus_cells[burnt_result.name.."-"..quality_name] >= 1 then
						--game.print(reactor.bonus_cells[burnt_result.name.."-"..quality_name])
						reactor.refresh_inventory = true
						reactor.bonus_cells[burnt_result.name.."-"..quality_name] = reactor.bonus_cells[burnt_result.name.."-"..quality_name] -1
					end
				end
				--logging("- bonus cell amount: "..cell_bonus_amount)
				
				-- msg("reactor.bonus_cells:     "..reactor.bonus_cells[burnt_result.name])
				-- msg("bonus amount (time):     "..((reactor_parameters.bonus_cells*TICKS_PER_UPDATE)/900)*BONUS_CELL_MULTIPLIER)
				-- msg("")
				-- msg("bonus amount (duration): "..reactor_parameters.bonus_cells / burn_duration)
				-- msg("---")				
				
			end
		end
		if not reactor.refresh_inventory and burnt_result then
			for id, progress in pairs(reactor.hidden_output_inventory) do
				if progress >= 1 and id:sub(1, #burnt_result.name) == burnt_result.name then
					if not reactor.furnace.get_output_inventory()[2].valid_for_read then
						reactor.furnace.get_output_inventory().insert({name=burnt_result.name, count=math.floor(reactor.hidden_output_inventory[id]), quality = id:sub(#burnt_result.name+2)})
						reactor.hidden_output_inventory[id] = nil
						reactor.refresh_inventory = true
					end
				end
			end
		end
		--if burnt_result and reactor.bonus_cells[burnt_result.name.."-"..quality_name] and reactor.bonus_cells[burnt_result.name.."-"..quality_name] > 1 then
		--	reactor.refresh_inventory = true
		--	-- add used-up-uranium-fuel-cell
		--	--logging("Inserting used-up-uranium-fuel-cell:")
		--	--game.players[1].print("bonuscell")
		--	if not reactor.furnace.get_output_inventory().is_empty() then
		--		--burnt fuel inventory not empty
		--		if reactor.furnace.get_output_inventory().can_insert{name = burnt_result.name, count = 1, quality = quality_name} then
		--			-- same cell
		--			--reactor.furnace.get_output_inventory().insert({name=burnt_result.name, count=1, quality = quality_name})   -- NEW: spawns from furnace now
		--			reactor.bonus_cells[burnt_result.name.."-"..quality_name] = reactor.bonus_cells[burnt_result.name.."-"..quality_name] -1
		--			--logging("-> inserted")
		--		else
		--			--different cell, wait
		--			--logging("-> can't insert, different used up cell present. waiting...")
		--		end
		--	else
		--		--burnt fuel inventory empty
		--		--reactor.furnace.get_output_inventory().insert({name=burnt_result.name,count=1, quality = quality_name})   -- NEW: spawns from furnace now
		--		reactor.bonus_cells[burnt_result.name.."-"..quality_name] = reactor.bonus_cells[burnt_result.name.."-"..quality_name] -1
		--		--logging("-> inserted")
		--	end	
		--	
		--end
		
		
		-- update reactor signals 
		reactor.signals["power-output"].count = reactor_parameters.power
		reactor.signals["efficiency"].count = math.floor(reactor_parameters.efficiency)
		reactor.signals["cell-bonus"].count = reactor_parameters.bonus_cells*100
		reactor.efficiency = reactor_parameters.efficiency
		if reactor_state == 2 or reactor_state == 1 then
			reactor.power_output_last_tick = reactor_parameters.power
		end
		
		
		-- replace reactor with updated level version
		--logging("Replace reactor model:")
		--local reactor_to_build = "RRR-realistic-reactor-"..math.max(1,reactor_parameters.power)
		--logging("-Reactor to be: "..reactor_to_build)
		--logging("-Current reactor: "..reactor.core.name)
		--if reactor.core.name==reactor_to_build then
			--logging("-> Reactor already build.")
		--else
		 if not (reactor_state ==3 and storage.settings["RRR-scram-behaviour"] == "decay heat (v1.0.x)") then
			reactor.core.set_heat_setting{temperature = 0.05/30*reactor_parameters.power, mode = "add"}
			--replace_reactor(reactor,reactor_to_build)
		end
		
	
	end
	
	
	-- UPDATE DISPLAYER --
	reactor.displayer.temperature = reactor.core.temperature + reactor.temperature_offset
	
	reactor.last_states_update = game.tick
end

-- changes reactor state
function change_reactor_state(new_state, reactor, update_event)
	--logging("-> changing reactor state to: " .. new_state)
	reactor.state = new_state
	reactor.state_active_since = update_event.tick
	reactor.lamp.destroy()
	reactor.light.destroy()
	local light_color = "black"
	if new_state == 0 then
		-- set signals
		reactor.signals["state_stopped"].count = 1
		reactor.signals["state_starting"].count = 0
		reactor.signals["state_running"].count = 0
		reactor.signals["state_scramed"].count = 0
		-- configure reactor
		--replace_reactor(reactor,"realistic-reactor-1")
		reactor.displayer.disabled_by_script = true
		reactor.furnace.disabled_by_script = true
		reactor.furnace.minable_flag = true
		reactor.core.disabled_by_script = true
		reactor.temperature_offset=0
	elseif new_state == 1 then
		--set signals
		reactor.signals["state_stopped"].count = 0
		reactor.signals["state_starting"].count = 1
		reactor.signals["state_running"].count = 0
		reactor.signals["state_scramed"].count = 0	
		-- configure reactor
		reactor.displayer.disabled_by_script = false
		reactor.furnace.disabled_by_script = false
		reactor.furnace.minable_flag = false
		reactor.core.disabled_by_script = false
		--reactor.debug_start_cell = true
		light_color = "yellow"
	elseif new_state == 2 then	
		-- set signals
		reactor.signals["state_stopped"].count = 0
		reactor.signals["state_starting"].count = 0
		reactor.signals["state_running"].count = 1
		reactor.signals["state_scramed"].count = 0
		-- configure reactor
		reactor.displayer.disabled_by_script = false
		reactor.furnace.disabled_by_script = false
		reactor.furnace.minable_flag = false
		reactor.core.disabled_by_script = false
		
		light_color = "green"
	elseif new_state == 3 then
		--set signals
		reactor.signals["state_stopped"].count = 0
		reactor.signals["state_starting"].count = 0
		reactor.signals["state_running"].count = 0
		reactor.signals["state_scramed"].count = 1	
		-- configure reactor
		if storage.settings["RRR-scram-behaviour"] == "decay heat (v1.0.x)" then
			reactor.core.disabled_by_script = true
			reactor.displayer.disabled_by_script = true
			local burner = to_burner(reactor.furnace)
			if burner.currently_burning and burner.currently_burning.name.burnt_result then
				reactor.furnace.get_output_inventory().insert{name = burner.currently_burning.name.burnt_result.name, count = 1, quality = burner.currently_burning.quality}
			end
			--reactor.displayer.burner.currently_burning = nil
			--reactor.displayer.burner.remaining_burning_fuel = 0
			respawn_furnace(reactor) --also disables it
		else
			reactor.core.disabled_by_script = false
			reactor.displayer.disabled_by_script = false
			reactor.furnace.disabled_by_script = false
		end
		reactor.furnace.minable_flag = false
		light_color = "red"
	end
	reactor.lamp = reactor.core.surface.create_entity{name = "RRR-"..light_color.."-lamp", position = {reactor.core.position.x+0.017,reactor.core.position.y+0.88}, force = reactor.core.force.name}
	reactor.light = reactor.core.surface.create_entity{name = "RRR-"..light_color.."-light", position = {reactor.core.position.x+0.017,reactor.core.position.y+0.88}, force = reactor.core.force.name}

	--if reactor.displayer.name == "realistic-reactor-breeder" then
	--	reactor.lamp = reactor.core.surface.create_entity{name = "RRR-"..light_color.."-lamp", position = {reactor.core.position.x+0.62,reactor.core.position.y+0.6}, force = reactor.core.force.name}
	--	reactor.light = reactor.core.surface.create_entity{name = "RRR-"..light_color.."-light", position = {reactor.core.position.x+0.62,reactor.core.position.y+0.6}, force = reactor.core.force.name}
	--else
	--	reactor.lamp = reactor.core.surface.create_entity{name = "RRR-"..light_color.."-lamp", position = {reactor.core.position.x-0.62,reactor.core.position.y+0.6}, force = reactor.core.force.name}
	--	reactor.light = reactor.core.surface.create_entity{name = "RRR-"..light_color.."-light", position = {reactor.core.position.x-0.62,reactor.core.position.y+0.6}, force = reactor.core.force.name}
	--end
	if storage.settings["RRR-overlay-text"] ~= "reactor name" and new_state == 0 then
		reactor.name_render.text = ""
	end
	reactor.lamp.destructible = false
	reactor.light.destructible = false
end


