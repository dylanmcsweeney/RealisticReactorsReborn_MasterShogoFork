-- these are the graphics for the output parts of the tips and tricks section
-- data:extend(
-- {
	-- {
		-- type = "sprite",
		-- name = "signal_control_start",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/signal_start.png",
		-- priority = "extra-high-no-scale",
		-- width = 32,
		-- height = 32,
		-- flags = {"gui-icon"},
	-- },
	-- {
		-- type = "sprite",
		-- name = "signal_reactor_power_output",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/signal_power.png",
		-- priority = "extra-high-no-scale",
		-- width = 32,
		-- height = 32,
		-- flags = {"gui-icon"},
	-- },
	-- {
		-- type = "sprite",
		-- name = "signal_reactor_efficiency",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/signal_efficiency.png",
		-- priority = "extra-high-no-scale",
		-- width = 32,
		-- height = 32,
		-- flags = {"gui-icon"},
	-- },	
	-- -- reactor table
	-- {
		-- type = "sprite",
		-- name = "tab-r-1",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/tab-r-1.png",
		-- priority = "extra-high-no-scale",
		-- width = 1414,
		-- height = 39,
	-- },	
	-- {
		-- type = "sprite",
		-- name = "tab-r-2",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/tab-r-2.png",
		-- priority = "extra-high-no-scale",
		-- width = 1414,
		-- height = 39,
	-- },	
	-- {
		-- type = "sprite",
		-- name = "tab-r-3",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/tab-r-3.png",
		-- priority = "extra-high-no-scale",
		-- width = 1414,
		-- height = 39,
	-- },	
	-- {
		-- type = "sprite",
		-- name = "tab-r-4",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/tab-r-4.png",
		-- priority = "extra-high-no-scale",
		-- width = 1414,
		-- height = 39,
	-- },	
	-- {
		-- type = "sprite",
		-- name = "tab-r-5",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/tab-r-5.png",
		-- priority = "extra-high-no-scale",
		-- width = 1414,
		-- height = 39,
	-- },		
	-- -- breeder table
	-- {
		-- type = "sprite",
		-- name = "tab-b-1",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/tab-b-1.png",
		-- priority = "extra-high-no-scale",
		-- width = 1641,
		-- height = 39,
	-- },	
	-- {
		-- type = "sprite",
		-- name = "tab-b-2",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/tab-b-2.png",
		-- priority = "extra-high-no-scale",
		-- width = 1641,
		-- height = 39,
	-- },	
	-- {
		-- type = "sprite",
		-- name = "tab-b-3",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/tab-b-3.png",
		-- priority = "extra-high-no-scale",
		-- width = 1641,
		-- height = 39,
	-- },	
	-- {
		-- type = "sprite",
		-- name = "tab-b-4",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/tab-b-4.png",
		-- priority = "extra-high-no-scale",
		-- width = 1641,
		-- height = 39,
	-- },	
	-- {
		-- type = "sprite",
		-- name = "tab-b-5",
		-- filename = "__RealisticReactorsReborn__/graphics/tips_and_tricks/tab-b-5.png",
		-- priority = "extra-high-no-scale",
		-- width = 1641,
		-- height = 39,
	-- },		
	
-- })


local tip_trigger = {
	type = "or",
	triggers = {
		{
			type = "research",
			technology = "nuclear-power"
		},
		{
			type = "build-entity",
			entity = "RRR-realistic-reactor"
		},
		{
			type = "build-entity",
			entity = "RRR-breeder-reactor"
		},
		{
			type = "research",
			technology = "RRR-control-rods"
		},
		{
			type = "research",
			technology = "RRR-breeder-reactors"
		},
	}
}

data:extend(
{
	{
		type = "tips-and-tricks-item-category",
		name = "RealisticReactors",
		order = "z-[RealisticReactors]"
	},

	-- Title
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_Title",
		category = "RealisticReactors",
		tag = "[entity=RRR-realistic-reactor-displayer]",
		order = "a",
		is_title = true,
		trigger = tip_trigger,
		--image = "__RealisticReactorsReborn__/graphics/tips_and_tricks/title_pic.png"
		
	   simulation = {
		  mods = {"RealisticReactorsReborn"},
		  init = [[
			local bp="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M8zzjPM84zzPO84zzPOM8zzjPM87zjPM84zzPOM8zzvOM8zzjPM84zzPO84zzPOM8zzjPM87zjPM84zzPOM8zzvOM8zzjPM84zzPO84zzPOM8zzjPM87zjPM84zzPOM8zzvOM8zzjPM84zxPO84TzPOE8TzjPE87zhPM84TxPOM8TzvOE8zzhPE84zxPO84TzPOE8TzjPE87zhPM84TxPOM8TzvOE8zzhPE84zxPO84TzPOE8TzjPE87zhPM84TxPOM8TzvOE8zzhPE84zxPO84TzPOE8TzjPI87ziPM84jyPOM8jzvOI8zziPI84zyPO84jzPOI8jzjPI87ziPM84jyPOM8jzvOI8zziPI84zyPO84jzPOI8jzjPI87ziPM84jyPOM8jzvOI8zziPI84zyPO84jzPOI8jzjPI87ziPM84jyPOM+N89w4z43z3DjPjfPcOM+N89w4z43z3DjPjfPcOM+N89w4z43z3DjPjfPcOM+N89w4z43z3DjPjfPcOM+N89w4z43z3DjPjfPcOM+N89w4z43z3DjPjfPcOM+N89w4z43z3DjPhfNcOM+F81w4z4XzXDjPhfNcOM+F81w4z4XzXDjPhfNcOM+F81w4z4XzXDjPhfNcOM+F81w4z4XzXDjPhfNcOM+F81w4z4XzXDjPhfNcOM+F81w4z4XzXDjPhfNcOM+F81w4zwPO84DzPOA8DzjPA87zgPM84DwPOM8DzvOA8zzgPA84zwPO84DzPOA8DzjPA87zgPM84DwPOM8DzvOA8zzgPA84zwPO84DzPOA8DzjPA87zgPM84DwPOM8DzvOA8zzgPA84zwPO84DzPOA8DzjPsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ8XsQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxD2fswxn7cMY+nLEPZ+zDGftwxj6csQ9n7MMZ+3DGPpyxDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+nLAPJ+zDCftwwj6csA8n7MMJ+3DCPpywDyfswwn7cMI+3Ok1Xi4Xm/36w/Cz19eH9e1us90vlotf1ru7Y42YwmpIoBhDTAr9p0//BwjBRSg="
			game.tick_paused = true
			game.simulation.camera_alt_info = false
			game.simulation.camera_zoom = 0.7
			local result = {game.surfaces[1].create_entities_from_blueprint_string
			{
			  string = bp,
			  position = {0, 0},
			}}
		  ]],
		  update = [[

		  ]],
		}		
		
	},
	
	
	-- How to operate a reactor
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_Operate",
		category = "RealisticReactors",
		tag = "[virtual-signal=signal-control-start]",
		order = "b",
		indent = 1,
		trigger = tip_trigger,
		image = "__RealisticReactorsReborn__/graphics/tips_and_tricks/reactor_interface.png"
	},
	
	-- Meltdown
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_Meltdown",
		category = "RealisticReactors",
		tag = "[entity=RRR-reactor-sarcophagus]",
		order = "c",
		indent = 1,
		trigger = tip_trigger,
	},	
	
	-- Power output and efficiency
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_Output",
		category = "RealisticReactors",
		tag = "[virtual-signal=signal-reactor-power-output][virtual-signal=signal-reactor-efficiency]",
		order = "d",
		indent = 1,
		trigger = tip_trigger,
	},	
	--NEW
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_ECCS",
		category = "RealisticReactors",
		tag = "[entity=pump][entity=pump]",
		order = "e",
		indent = 1,
		trigger = tip_trigger,
	},	
	
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_ControlRods",
		category = "RealisticReactors",
		tag = "[virtual-signal=signal-controlrods-current][virtual-signal=signal-controlrods-target]",
		order = "f",
		indent = 1,
		trigger = tip_trigger,
	},	
	{
		type = "tips-and-tricks-item",
		name = "RealisticReactors_Quality",
		category = "RealisticReactors",
		tag = "[quality=uncommon]",
		order = "g",
		indent = 1,
		trigger = tip_trigger,
	},	
	-- -- Output Reactor
	-- {
		-- type = "tips-and-tricks-item",
		-- name = "RealisticReactors_OutputReactor",
		-- category = "RealisticReactors",
		-- tag = "[entity=realistic-reactor]",
		-- order = "e",
		-- indent = 2,
		-- trigger =
		-- {
			-- type = "research",
			-- technology = "nuclear-power"
		-- },
		-- image = "__RealisticReactorsReborn__/graphics/tips_and_tricks/output_reactor.png"
	-- },
	
	-- -- Output Breeder
	-- {
		-- type = "tips-and-tricks-item",
		-- name = "RealisticReactors_OutputBreeder",
		-- category = "RealisticReactors",
		-- tag = "[entity=realistic-reactor-breeder]",
		-- order = "f",
		-- indent = 2,
		-- trigger =
		-- {
			-- type = "research",
			-- technology = "nuclear-power"
		-- },
		-- image = "__RealisticReactorsReborn__/graphics/tips_and_tricks/output_breeder.png"
	-- },	
	
	
	
})