local state = require("scripts.state")
script.on_configuration_changed(function()
	state.ensure()

	if storage.version <11 then
		for _, reactor in pairs(storage.reactors) do
			reset_reactor(reactor)
		end
		storage.version = 11
		
	end
	if storage.version <12 then
		for _, reactor in pairs(storage.reactors) do
			reactor.displayer.destroy()
			local is_breeder = reactor.furnace.name == BREEDER_FURNACE_NAME
			local displayer = reactor.core.surface.create_entity
			{
				name = is_breeder and BREEDER_DISPLAYER_NAME or REACTOR_DISPLAYER_NAME,
				position = {x = reactor.core.position.x, y = reactor.core.position.y},
				force = reactor.core.force
			}
			displayer.operable = false 
			displayer.destructible = false
			displayer.minable_flag = false
			displayer.disabled_by_script = true
			reactor.displayer = displayer
			reactor.core.operable = false
			reactor.core.minable_flag = false
		end
		storage.version = 12
	end
	if storage.version <13 then
		storage.name_counter = 0
		for _, reactor in pairs(storage.reactors) do
			storage.name_counter = storage.name_counter+1
			reactor.name = tostring(storage.name_counter)
			reactor.name_render = rendering.draw_text{text = storage.name_counter, alignment = "center", surface = reactor.furnace.surface, target = {x=reactor.furnace.position.x, y=reactor.furnace.position.y-1}, only_in_alt_mode = true, color = {r=1,g=1,b=1,a=1}}
			reactor.control_current = (reactor.control_current-1)*10+1
			reactor.control_target= (reactor.control_target-1)*10+1
		end
		for key, gui in pairs (storage.guis) do
			if gui.valid then
				gui.destroy()
			end
		end
		storage.guis = {}
		storage.gui_count = 0
		storage.version = 13
	end
	
	if storage.version <14 then
		local new_reactors = {}
		for _, reactor in pairs(storage.reactors) do
			new_reactors[reactor.id] = reactor
		end
		reactors = new_reactors
		storage.version = 14
	end
	if storage.version <15 then
		local running_reactors = 0
		for _, reactor in pairs(storage.reactors) do
			if reactor.state == 1 or reactor.state == 2 then
				running_reactors = running_reactors+1
			end
		end
		if running_reactors > 0 then
			for _, player in pairs(game.connected_players) do
				local gui = player.gui.center.add{type = "frame", name = "RRR-migration-gui", caption = "", direction = "vertical"}
				gui.add{type = "label", caption="Reactor characteristics have changed. what should we do?"}
				local flow = gui.add{type = "flow", name = "RRR-migration-gui-flow",direction = "horizontal"}
				local button = flow.add{type = "button", name = "RRR-migration-power-down-reactors", caption = "Power down reactors"}
				local button = flow.add{type = "button", name = "RRR-migration-do-nothing", caption = "do nothing"}
			
			end
			--game.tick_paused = true
		end
		storage.version = 15
	end
	
	if storage.version <16 then
		for _, reactor in pairs(storage.reactors) do
			for a,b in pairs(reactor.bonus_cells) do
				if b>50 then
					reactor.bonus_cells[a] = 50
				end
			end
		end
		storage.version =16
	end
	
	if storage.version <17 then
		local new_guis = {}
		for id, gui in pairs(storage.guis) do
			new_guis[id] = {gui = gui}
		end
		storage.guis = new_guis
		storage.version =17
	end
	if storage.version <18 then
		for _, reactor in pairs(storage.reactors) do
			if reactor.name_render then
				reactor.name_render.scale = 1.5
				reactor.name_render.text = ""
			end
			reactor.signals["cooling"] = {signal=SIGNAL_COOLING, count=0, index=14}
		end
		for key, gui in pairs (storage.guis) do
			if gui.gui.valid then
				gui.gui.destroy()
			end
			if gui.box and gui.box.valid then
				gui.box.destroy()
			end
			if gui.text and gui.text.valid then
				gui.text.destroy()
			end
		end
		storage.guis = {}
		storage.gui_count = 0
		storage.player_selections = {-1}
		storage.version = 18
	end
	if storage.version <19 then
		for _, reactor in pairs(storage.reactors) do
			reactor.displayer.insert{name = "RRR-dummy-fuel-cell", count = 50}
		end
		storage.version = 19
	end
	if storage.version <22 then
		storage.overtime = 0
		storage.last_func_update = {}
		--on_tick_tasks["iterate_reactor_states"] = { performance_hit = 5, ticks_per_update = 15, reactor_scaling = 1, func = function(event)
		for _, task in pairs(on_tick_tasks) do
			storage.last_func_update[task.name] = game.tick
		end
		storage.version = 22
	end
	--added control rods tech:
	if storage.version <23 then
		for key, gui in pairs (storage.guis) do
			if gui.gui.valid and gui.gui.control then
				gui.gui.control.destroy()
				gui.gui.rr_buttons_flow.rr_button_control.destroy()
				gui.gui.rr_buttons_flow.rr_textbox.style.width = 93
			end
		end
		for _, reactor in pairs(storage.reactors) do
			reactor.control_current = 0
			reactor.control_target = 0
			reactor.temperature_offset = 0
			reactor.control_rods_tech = 0
			reactor.signals["control-current"].count = 0
		end
		storage.last_func_update = {}
		for _, task in pairs(on_tick_tasks) do
			storage.last_func_update[task.name] = game.tick
		end
		storage.version = 23
	end
	--for _, reactor in pairs(storage.reactors) do
	--	if reactor.furnace and reactor.furnace.valid then
	--		if reactor.furnace.force.technologies["RRR-control-rods"].researched then
	--			reactor.control_rods_tech = 1
	--		end
	--	end
	--end
	if storage.version <24 then
		init_heat_pipes()
		storage.version = 24
	end
	for unit_number, tbl in pairs(storage.all_heat_pipes) do
		if not tbl.entity or not tbl.entity.valid then
			remove_heat_pipe(unit_number)
		end
	end
	storage.settings = {}
	for _, s in pairs(sttngs) do
		if s.setting_type == "startup" then
		
			storage.settings[s.name] = settings.startup[s.name].value
		else
			storage.settings[s.name] = settings.global[s.name].value
		end
	end
	
	if storage.version < 25 then state.upgrade_2_1() end
	local recipe_blacklist = {
		["RRR-realistic-reactor"] = true,
		["RRR-breeder-reactor"] = true,
		["RRR-cooling-tower"] = true,
		["RRR-water-cooling"] = true,
		["RRR-steam-cooling"] = true,
		["RRR-cooling-tower-steam"] = true,
	}
	
	for i,reactor in pairs(storage.reactors) do --updating signals for removed fuel cell mods
		if reactor.furnace.get_inventory(defines.inventory.crafter_input).is_empty() then
			reactor.signals["uranium-fuel-cells"].signal = {type="item", name="uranium-fuel-cell"}
			reactor.signals["uranium-fuel-cells"].count = 0
		end
		reactor.quality = reactor.furnace.quality.level
		reactor.signals["used-uranium-fuel-cells"] = nil
		--if reactor.furnace.get_burnt_result_inventory().is_empty() then
		--	reactor.signals.parameters["used-uranium-fuel-cells"].signal = {type="item", name="used-up-uranium-fuel-cell"}
		--	reactor.signals.parameters["used-uranium-fuel-cells"].count = 0
		--end
		reactor.signals["neighbour-bonus"] = {signal=SIGNAL_NEIGHBOUR_BONUS, count=0, index=11}
	end
	
	for i, ruin in pairs(storage.ruins) do --if ruin setting was changed
		ruin.entity.minable_flag = not (settings.startup["RRR-meltdown-mode"].value == "meltdown with ruin") or (ruin.entity.health >999)
	end
	
	for _,force in pairs (game.forces) do --bugfix for reactor recipe not showing up
		if force.technologies["nuclear-power"].researched then
			force.recipes["RRR-realistic-reactor"].enabled = true
			force.recipes["RRR-cooling-tower"].enabled = true
			if settings.startup["RRR-meltdown-mode"].value == "meltdown with ruin + sarcophagus" then
				force.recipes["RRR-reactor-sarcophagus"].enabled = true
			end
		end
		--force.recipes["breeder-reactor"].enabled = true
	end
	for _, force in pairs(game.forces) do
		for _, recipe in pairs(force.recipes) do
			if recipe.name:sub(1,4) == "RRR-" and not recipe_blacklist[recipe.name] then
				recipe.productivity_bonus = math.max((recipe.productivity_bonus or 0),0.01)
			end
		end
	end
	
--	--msg("RealisticReactors - current mod version (after migration): "..storage.version)

	-- -- downgrade from version 10000+ or so
	-- storage.falloutclouds = storage.falloutclouds or {}
	-- storage.tick_delayer = 0
	-- if not storage.gui_count then storage.gui_count = 0 end
	-- storage.stats = storage.stats or {}
	-- storage.guis = storage.guis or {}
	-- storage.all_heat_pipes = storage.all_heat_pipes or {}
	-- storage.version = 10
	-- for _, reactor in pairs(storage.reactors) do
	-- 	if (not reactor.eccs or not reactor.eccs.valid) and not reactor.eccs_L and not reactor.eccs_R then
	-- 		local reactor_core = reactor.displayer
	-- 		local eccs_L = reactor_core.surface.create_entity
	-- 		{
	-- 			name = ECCS_L_NAME,
	-- 			position = {x = reactor_core.position.x-1, y = reactor_core.position.y+1},
	-- 			force = reactor_core.force
	-- 		}
	-- 		eccs_L.operable = false 
	-- 		eccs_L.destructible = false
	-- 		eccs_L.minable = false
	-- 		local eccs_R = reactor_core.surface.create_entity
	-- 		{
	-- 			name = ECCS_R_NAME,
	-- 			position = {x = reactor_core.position.x+1, y = reactor_core.position.y+1},
	-- 			force = reactor_core.force
	-- 		}
	-- 		eccs_R.operable = false 
	-- 		eccs_R.destructible = false
	-- 		eccs_R.minable = false
	-- 		
	-- 		reactor.eccs = nil
	-- 		reactor.eccs_L = eccs_L
	-- 		reactor.eccs_R = eccs_R
	-- 	end
	-- 		
	-- end
end)
