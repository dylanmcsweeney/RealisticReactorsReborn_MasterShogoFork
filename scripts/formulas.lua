-- calculate power output, efficiency, bonus cell production

function calculate_stats_ingo(reactor,running_time,dt, burner)
	--[[
		TODO:
		- Reactor quality and fuel quality formula
		- Module support (pollution, speed, efficiency and productivity (productivity has a base value of 1%, at least according to the tooltip))
		- Temperature can exceed 1000°, 10° per reactor quality level
		- reactor.fuel_starvation [0-180] (reactor needs to be able to bridge 3 seconds without any fuel) - maybe using reactor.power_output_last_tick?
		- control rods, reactor.temperature_offset
		done
	]]
	--local temperature = reactor.core.temperature
	--reactor.temperature_offset = 0
	local orig_temperature = reactor.core.temperature
	local temperature = orig_temperature^(1+((math.max(0,reactor.control_current)/1500)))
	temperature = (temperature-orig_temperature)*storage.settings["RRR-control_rods_temperature_effect"] + orig_temperature
	local control_mult = storage.settings["RRR-control_rods_speed"] * dt
	if temperature-orig_temperature > reactor.temperature_offset then
		reactor.temperature_offset = reactor.temperature_offset*(1-control_mult/300) + (temperature-orig_temperature)*(control_mult/300) + 0.015*control_mult
	else
		reactor.temperature_offset = reactor.temperature_offset*(1-control_mult/1500) + (temperature-orig_temperature)*(control_mult/1500) - 0.0015*control_mult
	end
	
	local reactor_neighbours = math.min(reactor.neighbours,4)
	local power 
	local power_breeder
	local efficiency
	local bonus_cells
	local fuel_cell = to_burner(reactor.furnace).currently_burning
	local fuel_quality = nil --unused--FUEL
	--local reactor_quality = reactor.quality --unused (level, integer)
	local fuel_cell_name = ""
	if fuel_cell ~= nil then
		fuel_quality = fuel_cell.quality -- unused--FUEL
		fuel_cell = fuel_cell.name --is prototype, not name
		fuel_cell_name = fuel_cell.name 
	end
	local bonus_cells_multiplier = 1
	reactor.signals["neighbour-bonus"].count = reactor_neighbours
	
	--set or calculate values
	if reactor.state == 2 and temperature<500 then --running below 500
		
		if reactor_neighbours == 1 then
				power = 30
				power_breeder = 30
			elseif reactor_neighbours == 2 then
				power = 33
				power_breeder = 33
			elseif reactor_neighbours == 3 then
				power = 36
				power_breeder = 36
			else
				power = 39
				power_breeder = 39
			end
		efficiency=100
		bonus_cells=0
		
	elseif reactor.state == 1 then --start
		
		if temperature <= 500 then
			--power on a cold reactor
			if reactor_neighbours == 1 then
				power_target = 30
				power_breeder_target = 30
			elseif reactor_neighbours == 2 then
				power_target = 33
				power_breeder_target = 33
			elseif reactor_neighbours == 3 then
				power_target = 36
				power_breeder_target = 36
			else
				power_target = 39
				power_breeder_target = 39
			end
			--power=math.min(((39/storage.settings["RRR-reactor-starting-duration"])*running_time)+1,40) -- running time: 0s=1MW, start_duration(default:30s)=40MW 
			--power_breeder=math.min(((39/storage.settings["RRR-reactor-starting-duration"])*running_time)+1,40) -- running time: 0s=1MW, start_duration(default:30s)=40MW
		else
			-- power on a warm reactor
			power_target = math.max(((1/6)*temperature)-(130/3),40) -- 500°=40MW, 980°=120MW
			power_breeder_target = math.max(((1/12)*temperature)-(5/3),40) --500°=40MW, 980°=80MW			
		end
		
		power=math.min((((power_target-1)/storage.settings["RRR-reactor-starting-duration"])*running_time)+1,power_target) -- running time: 0s=1MW, start_duration(default:30s)= output of a running reactor at this temp 
		power_breeder=math.min((((power_breeder_target-1)/storage.settings["RRR-reactor-starting-duration"])*running_time)+1,power_breeder_target) -- running time: 0s=1MW, start_duration(default:30s)= output of a running breeder at this temp			
		efficiency=100
		bonus_cells=0
		
	elseif reactor.state == 3 then --scram
		
		power=(((reactor.power_output_last_tick-1)/storage.settings["RRR-reactor-scram-duration"])*(storage.settings["RRR-reactor-scram-duration"]-running_time))+1 --running time: scram_duration(default:180s)=power_output_last_tick, 0s=1MW
		power_breeder=(((reactor.power_output_last_tick-1)/storage.settings["RRR-reactor-scram-duration"])*(storage.settings["RRR-reactor-scram-duration"]-running_time))+1 --running time: scram_duration(default:180s)=power_output_last_tick, 0s=1MW
		efficiency=200
		bonus_cells=0
		
	else --running above 500
		
		power = math.max(((1/6)*temperature)-(130/3),40) -- 500°=40MW, 980°=120MW
		power_breeder = math.max(((1/12)*temperature)-(5/3),40) --500°=40MW, 980°=80MW
		bonus_cells = math.max(((1/680)*temperature)-(15/34),0) --350°=0 Cells, 980°=1 Cell

		if reactor_neighbours==1 then		
			-- one reactor
			if temperature <= 620 then
				efficiency = math.max((5/6)*temperature-(950/3),100) 
			else
				efficiency = math.max(-(5/6)*temperature+(2150/3),50)  
			end
		
		elseif reactor_neighbours==2 then
			-- two reactors
			if temperature <= 620 then
				efficiency = math.max((5/6)*temperature-(950/3),100) 
			elseif temperature > 620 and temperature <= 740 then
				efficiency = 200
			else
				efficiency = math.max(-(5/6)*temperature+(2450/3),50)  
			end			
			
		elseif reactor_neighbours==3 then
			-- three reactors
			if temperature <= 620 then
				efficiency = math.max((5/6)*temperature-(950/3),100) 
			elseif temperature > 620 and temperature <= 860 then
				efficiency = 200
			else
				efficiency = math.max(-(5/6)*temperature+(2750/3),50)  
			end				
			
		else
			-- four reactors
			if temperature <= 620 then
				efficiency = math.max((5/6)*temperature-(950/3),100)
			else
				efficiency = 200
			end
			
		end
		
	end
	max_power = 123
	max_efficiency = 200
	--reactor count modifier
	power = power*(0.7+0.075*reactor_neighbours)
	power_breeder = power_breeder*(0.7+0.075*reactor_neighbours)
	
	
	if fuel_cell == nil then
	--SigmaOne's Mods: Nuclear fuel (same stats as uranium power)
	elseif fuel_cell_name ==  "mox-fuel-cell" and (fuel_cell.fuel_value == 8500000000 or fuel_cell.fuel_value == 8000000000 and script.active_mods["Bluetonium"]) then
		bonus_cells_multiplier = 0.66
	--Plutonium Energy
	elseif fuel_cell_name == "plutonium-fuel-cell" then --plutonium
	--"Plutonium fuel cell" - Nuclear Fuel (4000000000) and "Breeder fuel cell (Pu)" - Nuclear Fuel Cycle (3500000000) and "pu-fuel-cell" = bluetonium breeder fuel cycle
	elseif fuel_cell_name == "breeder-fuel-cell" or fuel_cell_name == "pu-fuel-cell" then
		bonus_cells_multiplier = 0.5
	--Uranium Power & Patched Mad Clowns
	elseif fuel_cell_name == "fuel-assembly-mox" or fuel_cell_name == "rr-clowns-mox-cell" then
	--"MOX fuel cell" - Advanced Atomics (12000000000) and "MOX fuel cell" - Nuclear Fuel Cycle (8000000000)
	elseif fuel_cell_name == "mox-fuel-cell" then --mox
		bonus_cells_multiplier = 1.45
	-- "MOX fuel cell" - plutonium energy (20GJ)
	elseif fuel_cell_name == "MOX-fuel" then
		bonus_cells_multiplier = 0.6
	-- "Thorium fuel cell" - MadClown01's AngelBob Nuclear Extension or bluetonium (4gj, basically free thorium, 10 used cells = +3 u235)
	elseif fuel_cell_name == "thorium-fuel-cell" or fuel_cell_name == "apm_breeder_thorium_loaded" or fuel_cell_name == "apm_fuel_rod_thorium" then
		bonus_cells_multiplier = 0.8
		if fuel_cell_name == "thorium-fuel-cell" and script.active_mods["Bluetonium"] then
			bonus_cells_multiplier = 0.6
		end
	-- "Amator Phasma Nuclear"
	elseif fuel_cell_name == "apm_fuel_cell_mox" or fuel_cell_name == "apm_fuel_rod_mox" then
		bonus_cells_multiplier = 0.8
	-- "Amator Phasma Nuclear"
	elseif fuel_cell_name:sub(1,22) == "apm_nuclear_fuel_cell_" then
	--Default/other fuel cells 
		if script.active_mods["Nuclear Fuel"] then
			bonus_cells_multiplier = 0.2
		else
			bonus_cells_multiplier = 0.8
		end
	end
	bonus_cells_multiplier = bonus_cells_multiplier * 1.25
	
	
	
	
	
	-------------------------------------------------------------------
	---- QUALITY BONUSES
	local combined_quality_level = (fuel_quality and fuel_quality.level or 0) + reactor.quality -- make it additive
	
	efficiency = efficiency * (1+0.1*combined_quality_level)
	max_efficiency = max_efficiency * (1+0.1*combined_quality_level)
	
	power_breeder = power_breeder * (1+0.1*reactor.quality)
	power = power * (1+0.1*reactor.quality)
	max_power = max_power * (1+0.1*reactor.quality)
	---- /QUALITY BONUSES
	-------------------------------------------------------------------


	-------------------------------------------------------------------
	---- CONTROL RODS
	if reactor.control_current >=0 then
		efficiency = efficiency * (1-(reactor.control_current)/300)
		power = power * (1+(reactor.control_current)/1000)
		power_breeder = power_breeder * (1+(reactor.control_current)/1000)
		power = power^(1+((reactor.control_current)/2000))
		power_breeder = power_breeder^(1+((reactor.control_current)/2000))
		power = power+((reactor.control_current)/10)
		power_breeder = power_breeder+((reactor.control_current)/10)
	else
		efficiency = efficiency * (1-math.abs(reactor.control_current)/225)
		power = math.max(1,power * (1-math.abs(reactor.control_current)/100)^0.5)
		power_breeder = math.max(1,power_breeder * (1-math.abs(reactor.control_current)/100)^0.5)
	end
	--game.print(power)
	---- CONTROL RODS
	-------------------------------------------------------------------
	--
	--if reactor.state  == 1 then
	--	power = math.floor(power * ((running_time)/storage.settings["RRR-reactor-starting-duration"])^2)
	--	bonus_cells = bonus_cells * ((running_time)/storage.settings["RRR-reactor-starting-duration"])^2
	--end
	--if reactor.state  == 3 then
	--	power = math.floor(reactor.power_output_last_tick * ((storage.settings["RRR-reactor-scram-duration"] - (running_time)/3.5)/storage.settings["RRR-reactor-scram-duration"])^11+0.45)
	--	bonus_cells = bonus_cells * ((storage.settings["RRR-reactor-scram-duration"] - (running_time)/3.5)/storage.settings["RRR-reactor-scram-duration"])^11
	--end	
	--bonus_cells = bonus_cells + 0.01
	
	-------------------------------------------------------------------
	---- MODULES
	
	local module_pollution = 0
	local module_consumption = 0
	local module_speed = 0
	local module_productivity = 0
	--local module_quality = 0 --using base game to determine quality
	
	local pollution_multiplier = storage.settings["RRR-pollution_effectivity"]
	local consumption_multiplier = storage.settings["RRR-efficiency_effectivity"]
	local speed_multiplier = storage.settings["RRR-speed_effectivity"]
	local productivity_multiplier = storage.settings["RRR-productivity_effectivity"]
	--local quality_multiplier = storage.settings["RRR-quality_effectivity"]
	
	
	local module_inventory = reactor.furnace.get_module_inventory()
	for i=1, #module_inventory do
		local item = module_inventory[i]
		if item and item.valid_for_read then
			local quali = item.quality.level
			local effects = item.prototype.module_effects
			if effects.pollution and effects.pollution < 0 then
				module_pollution = module_pollution - effects.pollution*pollution_multiplier * (1 + quali*0.3)
			end
			if effects.consumption and effects.consumption < 0 then
				module_consumption = module_consumption - effects.consumption*consumption_multiplier * (1 + quali*0.3)
			end
			if effects.speed and effects.speed > 0 then
				module_speed = module_speed + effects.speed*speed_multiplier * (1 + quali*0.3)
			end
			if effects.productivity and effects.productivity > 0 then
				module_productivity = module_productivity + effects.productivity*productivity_multiplier * (1 + quali*0.3)
			end
			--if effects.quality and effects.quality > 0 then
			--	module_quality = module_quality + effects.quality*quality_multiplier
			--end
		end
	end
	
	--bonus_cells = bonus_cells + (module_productivity * (1+bonus_cells_multiplier)/2) --in return code..
	power_breeder = power_breeder*(1+module_speed)
	power = power*(1+module_speed)
	max_power = max_power*(1+module_speed)
	efficiency = efficiency/math.max(0.2,1-module_consumption)
	max_efficiency = max_efficiency/math.max(0.2,1-module_consumption) --under optimal conditions - 4 reactors
	reactor.pollution_mult = reactor.pollution_mult *0.999 + math.max(0.1,1-module_pollution) * 0.001
	
	---- /MODULES
	-------------------------------------------------------------------
	
	-------------------------------------------------------------------
	---- STARVATION
	if fuel_cell == nil and reactor.fuel_starvation < 180 then
		power = reactor.power_output_last_tick * 0.95
		power_breeder = reactor.power_output_last_tick * 0.95
	end
	---- /STARVATION
	-------------------------------------------------------------------
	
	-- return values	
	if reactor.furnace.name == REACTOR_FURNACE_NAME then
		bonus_cells = 0.01+(module_productivity * (1+bonus_cells_multiplier)/2)
		reactor.max_power = max_power
		reactor.max_efficiency = max_efficiency
		return {power = power, efficiency = efficiency, bonus_cells = bonus_cells, max_power = max_power, max_efficiency = reactor.max_efficiency }
	end
	if reactor.furnace.name == BREEDER_FURNACE_NAME then 
		bonus_cells = 0.01+bonus_cells * bonus_cells_multiplier + (module_productivity * (1+bonus_cells_multiplier)/2)
		reactor.max_power = max_power*2/3
		reactor.max_efficiency = max_efficiency
		return {power = power_breeder, efficiency = efficiency, bonus_cells = bonus_cells, max_power = max_power*2/3, max_efficiency = reactor.max_efficiency}
	end
	 --under optimal conditions - 4 reactors
	
end










function calculate_stats_ownly(reactor,running_time,dt, burner)
	local fuel_cell = burner.currently_burning
	local fuel_quality = nil
	local fuel_cell_name = ""
	if fuel_cell ~= nil then
		fuel_quality = fuel_cell.quality
		fuel_cell = fuel_cell.name --is prototype, not name
		fuel_cell_name = fuel_cell.name
	end
	local orig_temperature = reactor.core.temperature
	local temperature = orig_temperature^(1+((math.max(0,reactor.control_current)/1500)))
	temperature = (temperature-orig_temperature)*storage.settings["RRR-control_rods_temperature_effect"] + orig_temperature
	local control_mult = storage.settings["RRR-control_rods_speed"] * dt
	if temperature-orig_temperature > reactor.temperature_offset then
		reactor.temperature_offset = reactor.temperature_offset*(1-control_mult/300) + (temperature-orig_temperature)*(control_mult/300) + 0.015*control_mult
	else
		reactor.temperature_offset = reactor.temperature_offset*(1-control_mult/1500) + (temperature-orig_temperature)*(control_mult/1500) - 0.0015*control_mult
	end
	--game.print(string.format("%.2f -> %.2f",reactor.temperature_offset, temperature-orig_temperature))
	
	
	local neighbours = reactor.neighbours
	local reactors = neighbours
	reactors = math.min(4,reactors)
	reactors = math.max(1,reactors)
	local efficiency
	local power
	local min_efficiency = 1
	local max_efficiency = 200
	local max_power = 150
	local max_temperature_delta = 1000*(1+reactor.quality*0.005)-500
	local bonus_cells = 0
	local bonus_cells_multiplier = 1
	if temperature > 1000 then 
		temperature = (temperature-1000)/2+1000
	end
	--temperature = math.max(0,temperature - 500)
	--
	temperature = temperature / 2
	
	-- https://rechneronline.de/funktionsgraphen/

	reactor.signals["neighbour-bonus"].count = reactor.neighbours
	if fuel_cell == nil then
		power=0
		efficiency=0
		
	--SigmaOne's Mods: Nuclear fuel (same stats as uranium power)
	elseif fuel_cell_name ==  "mox-fuel-cell" and (fuel_cell.fuel_value == 8500000000 or fuel_cell.fuel_value == 8000000000 and script.active_mods["Bluetonium"]) then --mox
		efficiency = (3+temperature*0.11)^1.19+80
		power = (1+temperature*0.16)^1.08+35
		min_efficiency = 84
		max_efficiency = 205
		max_power = 150
		bonus_cells_multiplier = 0.66
		max_power = (1+max_temperature_delta*0.16)^1.08+35
		--game.print(fuel_cell_name)
	--Plutonium Energy
	elseif fuel_cell_name == "plutonium-fuel-cell" then --plutonium
		power = (2.2+temperature*0.034)^0.57*25+10
		efficiency = (2.5+temperature*0.034)^0.45*39.5+45
		min_efficiency = 102
		max_efficiency = 195
		max_power = 145
		max_power = (2.5+max_temperature_delta*0.034)^0.45*39.5+45
		
	--"Plutonium fuel cell" - Nuclear Fuel (4000000000) and "Breeder fuel cell (Pu)" - Nuclear Fuel Cycle (3500000000)
	--"pu-fuel-cell" = bluetonium breeder fuel cycle
	elseif fuel_cell_name == "breeder-fuel-cell" or fuel_cell_name == "pu-fuel-cell" then --plutonium (although breeder cells are usually mox i think)
		power = (2.2+temperature*0.034)^0.57*25+10
		efficiency = (2.5+temperature*0.034)^0.45*39.5+45
		min_efficiency = 102
		max_efficiency = 195
		max_power = 145
		bonus_cells_multiplier = 0.5
		max_power = (2.2+max_temperature_delta*0.034)^0.57*25+10
		
	--Uranium Power & Patched Mad Clowns
	elseif fuel_cell_name == "fuel-assembly-mox" or fuel_cell_name == "rr-clowns-mox-cell" then --mox
		efficiency = (3+temperature*0.11)^1.19+80
		power = (1+temperature*0.16)^1.08+35
		min_efficiency = 84
		max_efficiency = 205
		max_power = 150
		max_power = (1+max_temperature_delta*0.16)^1.08+35
		
	--"MOX fuel cell" - Advanced Atomics (12000000000) and "MOX fuel cell" - Nuclear Fuel Cycle (8000000000)
	elseif fuel_cell_name == "mox-fuel-cell" then --mox
		efficiency = (3+temperature*0.11)^1.19+80
		power = (1+temperature*0.16)^1.08+35
		min_efficiency = 84
		max_efficiency = 205
		max_power = 150
		bonus_cells_multiplier = 1.45
		max_power = (1+max_temperature_delta*0.16)^1.08+35
		
	-- "MOX fuel cell" - plutonium energy (20GJ)
	elseif fuel_cell_name == "MOX-fuel" then
		efficiency = ((3+temperature*0.11)^1.19+80)
		power = ((1+temperature*0.16)^1.08+35)*0.5
		min_efficiency = 84
		max_efficiency = 205
		max_power = 150*0.5
		bonus_cells_multiplier = 0.6
		max_power = ((1+max_temperature_delta*0.16)^1.08+35)*0.5
		
	-- "Thorium fuel cell" - MadClown01's AngelBob Nuclear Extension or bluetonium (4gj, basically free thorium, 10 used cells = +3 u235)
	elseif fuel_cell_name == "thorium-fuel-cell" or fuel_cell_name == "apm_breeder_thorium_loaded" or fuel_cell_name == "apm_fuel_rod_thorium" then
		efficiency= 190-(1.5+temperature*0.1)^1.45*0.18
		power = 	140-(1.5+temperature*0.1)^1.6*0.072
		min_efficiency = 79
		max_efficiency = 204
		max_power = 155
		bonus_cells_multiplier = 0.8
		max_power = 155-(1.5+max_temperature_delta*0.1)^1.6*0.08
		if fuel_cell_name == "thorium-fuel-cell" and script.active_mods["Bluetonium"] then
			bonus_cells_multiplier = 0.6
		end
		--game.print(fuel_cell_name)
		--game.print(efficiency/200 .." "..power/150)
	elseif fuel_cell_name == "apm_fuel_cell_mox" or fuel_cell_name == "apm_fuel_rod_mox" then
		efficiency = ((3+temperature*0.11)^1.19+80)
		power = ((1+temperature*0.16)^1.08+35)*0.5
		min_efficiency = 84
		max_efficiency = 205
		max_power = 150*0.5
		bonus_cells_multiplier = 0.8
		max_power = ((1+max_temperature_delta*0.16)^1.08+35)*0.5
		
	elseif fuel_cell_name:sub(1,22) == "apm_nuclear_fuel_cell_" then
		efficiency=(800+temperature*5)^0.64*0.96+29
		power=(1+temperature*0.07)^1.15*1.52*tonumber(fuel_cell_name:sub(23))/45+45
		min_efficiency = 94
		max_efficiency = 200
		max_power = 138
		max_power = (1+max_temperature_delta*0.07)^1.15*1.52*tonumber(fuel_cell_name:sub(23))/45+45
		
	--Default/other fuel cells 
	else --uranium
		efficiency=(800+temperature*5)^0.64*0.96+29
		power=(1+temperature*0.07)^1.15*1.52+45
		min_efficiency = 94
		max_efficiency = 200
		max_power = 138
		max_power = (1+max_temperature_delta*0.07)^1.15*1.52+45
		if script.active_mods["Nuclear Fuel"] then
			bonus_cells_multiplier = 0.2
		else
			bonus_cells_multiplier = 0.8
		end
	end
	--breeder
	if reactor.furnace.name == BREEDER_FURNACE_NAME then
		bonus_cells = (0.1+(efficiency-min_efficiency)/math.max(1,max_efficiency-min_efficiency)*0.85)*bonus_cells_multiplier --15% - 100% *multiplier
		power = power /(1+(efficiency-min_efficiency)/math.max(1,max_efficiency-min_efficiency)*0.75)
		max_power = max_power /(1+math.max(1,max_efficiency-min_efficiency)/math.max(1,max_efficiency-min_efficiency)*0.75)
		efficiency = efficiency/(1.15+math.max(1,efficiency-min_efficiency)/math.max(1,max_efficiency-min_efficiency)*0.85)
		max_efficiency = max_efficiency/(1.15+math.max(1,max_efficiency-min_efficiency)/math.max(1,max_efficiency-min_efficiency)*0.85)
	end
	
	--reactor count modifier
	efficiency = efficiency*(0.7+0.075*reactors)
	--max_efficiency = math.floor(max_efficiency*(0.7+0.075*reactors))
	power = power / 1.1         -- why did i do this? Oo
	max_power = max_power/1.1   -- why did i do this? Oo
	power = power *(0.5+0.125*reactors)
	max_power = max_power*(0.5+0.125*reactors)
	power = power * (1+neighbours/100)
	max_power = max_power * (1+neighbours/100)
	power = math.min(250,power)
	max_power = math.min(250,max_power)
	
	-------------------------------------------------------------------
	---- QUALITY BONUSES
	local combined_quality_level = (fuel_quality and fuel_quality.level or 0) + reactor.quality -- make it additive
	
	efficiency = efficiency * (1+0.1*combined_quality_level)
	max_efficiency = max_efficiency * (1+0.1*combined_quality_level)
	
	power = power * (1+0.1*reactor.quality)
	max_power = max_power * (1+0.1*reactor.quality)
	---- /QUALITY BONUSES
	-------------------------------------------------------------------


	-------------------------------------------------------------------
	---- CONTROL RODS
	reactor.max_power = max_power
	if reactor.control_current >=0 then
		efficiency = efficiency * (1-(reactor.control_current)/300)
		power = power * (1+(reactor.control_current)/1000)
		power = power^(1+((reactor.control_current)/2000))
		power = power+((reactor.control_current)/10)
	else
		efficiency = efficiency * (1-math.abs(reactor.control_current)/225)
		power = math.max(1,power * (1-math.abs(reactor.control_current)/100)^0.5)
	end
	---- CONTROL RODS
	-------------------------------------------------------------------
	
	if reactor.state  == 1 then
		power = math.floor(power * ((running_time)/storage.settings["RRR-reactor-starting-duration"])^2)
		bonus_cells = bonus_cells * ((running_time)/storage.settings["RRR-reactor-starting-duration"])^2
	end
	if reactor.state  == 3 then
		power = math.floor(reactor.power_output_last_tick * ((storage.settings["RRR-reactor-scram-duration"] - (running_time)/3.5)/storage.settings["RRR-reactor-scram-duration"])^11+0.45)
		bonus_cells = bonus_cells * ((storage.settings["RRR-reactor-scram-duration"] - (running_time)/3.5)/storage.settings["RRR-reactor-scram-duration"])^11
	end	
	bonus_cells = bonus_cells + 0.01
	
	-------------------------------------------------------------------
	---- MODULES
	
	local module_pollution = 0
	local module_consumption = 0
	local module_speed = 0
	local module_productivity = 0
	--local module_quality = 0 --using base game to determine quality
	
	local pollution_multiplier = storage.settings["RRR-pollution_effectivity"]
	local consumption_multiplier = storage.settings["RRR-efficiency_effectivity"]
	local speed_multiplier = storage.settings["RRR-speed_effectivity"]
	local productivity_multiplier = storage.settings["RRR-productivity_effectivity"]
	--local quality_multiplier = storage.settings["RRR-quality_effectivity"]
	
	
	local module_inventory = reactor.furnace.get_module_inventory()
	for i=1, #module_inventory do
		local item = module_inventory[i]
		if item and item.valid_for_read then
			local quali = item.quality.level
			local effects = item.prototype.module_effects
			if effects.pollution and effects.pollution < 0 then
				module_pollution = module_pollution - effects.pollution*pollution_multiplier * (1 + quali*0.3)
			end
			if effects.consumption and effects.consumption < 0 then
				module_consumption = module_consumption - effects.consumption*consumption_multiplier * (1 + quali*0.3)
			end
			if effects.speed and effects.speed > 0 then
				module_speed = module_speed + effects.speed*speed_multiplier * (1 + quali*0.3)
			end
			if effects.productivity and effects.productivity > 0 then
				module_productivity = module_productivity + effects.productivity*productivity_multiplier * (1 + quali*0.3)
			end
			--if effects.quality and effects.quality > 0 then
			--	module_quality = module_quality + effects.quality*quality_multiplier
			--end
		end
	end
	
	--game.print(module_consumption..", "..module_speed..", "..module_productivity..", "..module_quality)
	bonus_cells = bonus_cells + (module_productivity * (1+bonus_cells_multiplier)/2)
	power = power*(1+module_speed)
	efficiency = efficiency/math.max(0.2,1-module_consumption)
	reactor.max_efficiency = max_efficiency/math.max(0.2,1-module_consumption) --under optimal conditions - 4 reactors
	reactor.pollution_mult = reactor.pollution_mult *0.999 + math.max(0.1,1-module_pollution) * 0.001
	
	---- /MODULES
	-------------------------------------------------------------------
	
	
	if fuel_cell == nil and reactor.fuel_starvation < 180 then
		power = reactor.power_output_last_tick * 0.95
	end


	return {power=power,efficiency = efficiency, bonus_cells = bonus_cells, max_power = max_power, max_efficiency = max_efficiency, quality = module_quality}
end