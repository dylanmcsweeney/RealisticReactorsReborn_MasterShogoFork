on_tick_tasks = {}
require "scripts.stats"
require "scripts.migration"
require "scripts.formulas"
require "scripts.heatnet"
require "scripts.fx"
require "scripts.on_tick"
require "scripts.util"
require "scripts.construct_destruct"
sttngs = require("settings")
-- VARIABLE DECLARATION
TICKS_PER_UPDATE = 15 
	-- each reactor and cooling tower gets updated once every 15 ticks (60 ticks = 1 s)
CHANGE_MULTIPLIER = 0.2 
	-- used to multiply the temperature change 
	-- CHANGE_MULTIPLIER and TICKS_PER_UPDATE work together and are balanced: 
	-- 0.2 CHANGE_MULTIPLIER = 15 TICKS_PER_UPDATE
REACTOR_MASS = 6000	--increased from 4000 because of the reactor output nerf  -- ONLY USED FOR ENVIRONMENTAL COOLING NOW
	-- used to calculate temperature changes when emergency cooling is used
	-- the mass is an estimate best guess based on many tries and errors 
BONUS_CELL_MULTIPLIER = 0.5
	-- multiplier for breeder bonus cell production. 
	-- BONUS_CELL_MULTIPLIER=1 and bonus_cell_Production=100 means 1 additional empty cell per minute
POWER_USAGE_STARTING=3600000 -- 3600 KW
POWER_USAGE_INTERFACE=200000 -- 200 KW
POWER_USAGE_COOLING=1000000 -- 1 MW when when reactor was cooled (static) or 1 MW per 20 MW cooling (non-static)
	-- electric power usage of the reactor

-- entity names
REACTOR_FURNACE_NAME = "RRR-realistic-reactor"
REACTOR_DISPLAYER_NAME = "RRR-realistic-reactor-displayer"
REACTOR_POWER_NAME = "RRR-realistic-reactor-power-normal"
BREEDER_FURNACE_NAME = "RRR-breeder-reactor"
BREEDER_DISPLAYER_NAME = "RRR-breeder-reactor-displayer"
BREEDER_POWER_NAME = "RRR-realistic-reactor-power-breeder"
REACTOR_RUIN_NAME = "RRR-reactor-ruin"
BREEDER_RUIN_NAME = "RRR-breeder-ruin"
SARCOPHAGUS_ENTITY_NAME="RRR-reactor-sarcophagus"
INTERFACE_ENTITY_NAME = "RRR-realistic-reactor-interface"
BREEDER_INTERFACE_ENTITY_NAME = "RRR-realistic-breeder-interface"
ECCS_L_NAME = "RRR-realistic-reactor-eccs-L"
ECCS_R_NAME = "RRR-realistic-reactor-eccs-R"
TOWER_ENTITY_NAME = "RRR-cooling-tower"
STEAM_ENTITY_NAME = "RRR-cooling-tower-steam"
HEAT_PIPE_ENTITY_NAME = "heat-pipe"
RUIN_SMOKE_NAME = "RRR-ruin-smoke"
--signal names
SIGNAL_CORE_TEMP = {type="virtual", name="signal-reactor-core-temp"}
SIGNAL_STATE_STOPPED = {type="virtual", name="signal-state-stopped"}
SIGNAL_STATE_STARTING = {type="virtual", name="signal-state-starting"}
SIGNAL_STATE_RUNNING = {type="virtual", name="signal-state-running"}
SIGNAL_STATE_SCRAMED = {type="virtual", name="signal-state-scramed"}
SIGNAL_CONTROL_START = {type="virtual", name="signal-control-start"}
SIGNAL_CONTROL_SCRAM = {type="virtual", name="signal-control-scram"}
SIGNAL_COOLANT_AMOUNT = {type="virtual", name="signal-coolant-amount"}
--SIGNAL_COOLANT_TEMP = {type="virtual", name="signal-coolant-temperature"}
SIGNAL_URANIUM_FUEL_CELLS = {type="item", name="uranium-fuel-cell"}
SIGNAL_USED_URANIUM_FUEL_CELLS = {type="item", name="depleted-uranium-fuel-cell"}
SIGNAL_REACTOR_POWER_OUTPUT = {type="virtual", name="signal-reactor-power-output"}
SIGNAL_REACTOR_EFFICIENCY = {type="virtual", name="signal-reactor-efficiency"}
SIGNAL_REACTOR_CELL_BONUS = {type="virtual", name="signal-reactor-cell-bonus"}
SIGNAL_REACTOR_ELECTRIC_POWER = {type="virtual", name="signal-reactor-electric-power"}
SIGNAL_NEIGHBOUR_BONUS  = {type="virtual", name="signal-neighbour-bonus"}
SIGNAL_CONTROL_TARGET  = {type="virtual", name="signal-controlrods-target"}
SIGNAL_CONTROL_CURRENT  = {type="virtual", name="signal-controlrods-current"}
SIGNAL_COOLING  = {type="virtual", name="signal-cooling"}






-- INITIALIZING AND UPDATING FUNCTIONS

-- mod initialization
script.on_init(function()
	storage.overtime = 0
	storage.last_func_update = {}
	for _, task in pairs(on_tick_tasks) do
		storage.last_func_update[task.name] = game.tick
	end
	storage.settings = {}
	for _, s in pairs(sttngs) do
		if s.setting_type == "startup" then
			storage.settings[s.name] = settings.startup[s.name].value
		else
			storage.settings[s.name] = settings.global[s.name].value
		end
	end
	storage.name_counter = 0
	storage.reactors = storage.reactors or {} -- storage.reactors stores the reactor and its parts(core, circuit interface, eccs)
	storage.towers = storage.towers or {} -- storage.towers stores the cooling tower and the steam maker entity
	storage.connected_reactors = {} -- storage.connected_reactors stores values during build_connected_reactors_list
	storage.ruins = {} -- storage.ruins stores reactor ruins
	storage.fallout = {}
	storage.falloutclouds = {}
	storage.geigers = {}
	storage.sarcophagus = {}
	if not game.forces["radioactivity"] then
		game.create_force("radioactivity")
	end
	if not game.forces["radioactivity-strong"] then
		game.create_force("radioactivity-strong")
	end
	storage.delayed_fallout={}
	storage.tick_delayer = 0
	gui_init()
	
	storage.player_selections = {}
	init_heat_pipes()
	storage.version=25
	
	for _,force in pairs (game.forces) do
		if force.technologies["nuclear-power"].researched then
			force.recipes["RRR-realistic-reactor"].enabled = true
			force.recipes["RRR-cooling-tower"].enabled = true
			if storage.settings["RRR-meltdown-mode"] == "meltdown with ruin + sarcophagus" then
				force.recipes["RRR-reactor-sarcophagus"].enabled = true
			end
		end
		--force.recipes["RRR-breeder-reactor"].enabled = true
	end
	--game.write_file("RealisticReactors.log"," ") -- this line cleans the log file on game start

end)

-- registers event to remove a reactor ghost after a meltdown
--function register_remove_reactor_ghost_event(tick,position)
--	storage.tick_remove_reactor_ghost = tick + 1
--	storage.remove_reactor_ghost_position = position
--end
script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	storage.settings = {}
	for _, s in pairs(sttngs) do
		if s.setting_type == "startup" then
		
			storage.settings[s.name] = settings.startup[s.name].value
		else
			storage.settings[s.name] = settings.global[s.name].value
		end
	end
	if event.setting == "RRR-overlay-text-mode" then
		for _, reactor in pairs(storage.reactors) do
			reactor.name_render.only_in_alt_mode = storage.settings["RRR-overlay-text-mode"] == "in alt overlay"
			if storage.settings["RRR-overlay-text-mode"] == "on hover" or storage.settings["RRR-overlay-text-mode"] == "never" then
				reactor.name_render.text = ""
				reactor.name_render.scale = 1.5
			elseif storage.settings["RRR-overlay-text"] == "reactor name" then
				reactor.name_render.text = reactor.name
				reactor.name_render.scale = 1
			end
		end
	end
	if event.setting == "RRR-overlay-text" then
		for _, reactor in pairs(storage.reactors) do
			reactor.name_render.color = {r=1,g=1,b=1,a=1}
			if storage.settings["RRR-overlay-text"] == "reactor name" then
				if storage.settings["RRR-overlay-text-mode"] == "on hover" then
					reactor.name_render.text = ""
					reactor.name_render.scale = 1.5
				else
					reactor.name_render.text = reactor.name
					reactor.name_render.scale = 1
				end
			else
				reactor.name_render.scale = 1.5
			end
		end
	end
end)


remote.add_interface("RRR-interface", {
    add_heatpipe = function(entity)
		-- todo: other mod also registering the connected heat pipes, for underground for example
		game.print("deprecated function: add_heatpipe (Realistic Reactors Reborn) please report this issue to the RRR team")
    end,
	remove_heatpipe = function(entity)
		-- todo: other mod also registering the connected heat pipes, for underground for example
		game.print("deprecated function: remove_heatpipe (Realistic Reactors Reborn) please report this issue to the RRR team")
	end
})

tick_budget = 0
tick_budget_per_reactor = 0
for _, task in pairs(on_tick_tasks) do 
	if task.reactor_scaling then
		tick_budget_per_reactor = tick_budget_per_reactor + (task.reactor_scaling / task.ticks_per_update * task.performance_hit)
	else
		tick_budget = tick_budget + (task.performance_hit / task.ticks_per_update)
	end
end


script.on_event(defines.events.on_research_finished, function (event)
	if event.research.name == "RRR-control-rods" then
		--update guis
		for key, gui in pairs(storage.guis) do
			local reactor_key, playerid = splitty(key,"-")
			local reactor = storage.reactors[reactor_key]
			local style_affix = "-blue"
			if reactor.furnace.name == BREEDER_FURNACE_NAME then
				style_affix = "-red"
			end
			if reactor.control_rods_tech == 0 then
				gui.gui.rr_buttons_flow.rr_textbox.style.width = 71
				gui.gui.rr_buttons_flow.add{type = "sprite-button",name = "rr_button_control", sprite = "RRR-button-control-off", style = "RRR-button"..style_affix, index = 3}
				gui.gui.rr_buttons_flow.rr_button_control.style.top_padding 		= 1
				gui.gui.rr_buttons_flow.rr_button_control.style.right_padding 	= 1
				gui.gui.rr_buttons_flow.rr_button_control.style.bottom_padding 	= 1
				gui.gui.rr_buttons_flow.rr_button_control.style.left_padding 		= 1	
				gui.gui.rr_buttons_flow.rr_button_control.style.height 		= 21
				gui.gui.rr_buttons_flow.rr_button_control.style.width 		= 21
			end
		end
		--update reactors
		for _, reactor in pairs(storage.reactors) do
			if reactor.furnace and reactor.furnace.valid and reactor.furnace.force == event.research.force then
				reactor.control_rods_tech = 1
			end
		end
	end
end)
