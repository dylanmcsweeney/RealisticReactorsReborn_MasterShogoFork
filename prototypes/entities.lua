local debug_core = false

REACTOR_SHIFT = {0.03, -0.38375}
REACTOR_GLOW = {intensity = 0.6, size = 9.9, shift = REACTOR_SHIFT, color = {r = 0.07, g = 0.63, b = 0.55}}
BREEDER_GLOW = {intensity = 0.4, size = 9.9, shift = REACTOR_SHIFT, color = {r = 0.8, g = 0.4, b = 0.15}}
RUIN_GLOW = {intensity = 0.22, size = 6.5, shift = {0.0, 0.0}, color = {r = 0.35, g = 0.8, b = 1.0}}
-- entity parts
resistances_immune=		
		{
		{
			type = "physical",
			percent = 100
		},
		{
			type = "impact",
			percent = 100
		},
		{
			type = "fire",
			percent = 100
		},
		{
			type = "acid",
			percent = 100
		},
		{
			type = "poison",
			percent = 100
		},
		{
			type = "explosion",
			percent = 100
		},
		{
			type = "laser",
			percent = 99
		},
		}
		
empty_sprite =
{
  filename = "__core__/graphics/empty.png",
  priority = "extra-high",
  frame_count = 1,
  width = 1,
  height = 1
}

interface_led =
{
  filename = "__base__/graphics/entity/combinator/activity-leds/decider-combinator-LED-S.png",
  width = 8,
  height = 8,
  frame_count = 1,
  --shift = {-0.28125, -0.34375}
  shift = {-0.15, -0.24},
  scale = 0.3
}
--{
--      shadow =
--      {
--        red = util.by_pixel(25, 20),
--        green = util.by_pixel(9, 20)
--      },
--      wire =
--      {
--        red = util.by_pixel(9, 7.5),
--        green = util.by_pixel(-6.5, 7.5) unten
--      }
--    },
local red_point = {x=6.9,y=10.8}
local green_point = {x=-6.1,y=10.8}

interface_connection =
{
  shadow =
  {
    red =   util.by_pixel(red_point.x+16, red_point.y+12.5),--{0.796875, 0.5},
    green = util.by_pixel(green_point.x+16, green_point.y+12.5)--{0.203125, 0.5},
  },
  wire =
  {
    red =   util.by_pixel(red_point.x, red_point.y),--{0.296875, 0.0625},
    green = util.by_pixel(green_point.x, green_point.y)--{-0.296875, 0.0625},
  }
}

-- default reactor (running reactor)
reactor_template =
{
    type = "reactor",
    name = "RRR-realistic-reactor",
	icon = MOD_PATH.."/graphics/icons/nuclear-reactor.png",
    icon_size = 32,
	order = "f[nuclear-energy]-a[reactor]",
    flags = {"placeable-neutral", "not-on-map","not-deconstructable","not-blueprintable", "no-automated-item-insertion", "no-automated-item-removal"},

	
	--placeable_by = { item="iron-plate", count = 1},
    --minable = {mining_time = 1.5, result = "RRR-realistic-reactor"},
    max_health = 500,
	collision_mask = {layers = {}},
    corpse = "big-remnants",
    consumption = "4MW",
    neighbour_bonus = 1,
	selection_priority =5,
	selectable_in_game = false,
	energy_source =
    {
      type = "burner",
      fuel_categories = {"nuclear"},
      effectivity = 0.00011,
      fuel_inventory_size = 1,
      burnt_inventory_size = 1,
	  light_flicker = {
	  minimum_intensity=0,
	  maximum_intensity = 0,
	  minimum_light_size=0,
	  light_intensity_to_size_coefficient=0,
	  }
    },
	light = {intensity = 0, size = 0, shift = REACTOR_SHIFT, color = {r = 0.07, g = 0.63, b = 0.55}},
    --burner = --replaced by energy_source
    --{
    --  fuel_category = "nuclear",
    --  effectivity = 1,
    --  fuel_inventory_size = 1,
    --  burnt_inventory_size = 1
    --},
    --collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
    --selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
	--collision_box = {{-1.4, -1.4}, {1.4, 0.7}},
    --selection_box = {{-1.5, -3}, {1.5, 0.5}},
	collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
	--selection_box = {{-1.4, -3}, {1.4, 1.4}},
	working_sound =
	{
		sound = { filename = MOD_PATH.."/sound/reactor-active.ogg", volume = 0.6 },
		idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
		apparent_volume = 1.5
	},
    --picture =
    --{
    --  layers =
    --  {
    --    --{
	--	--  filename = MOD_PATH.."/graphics/entity/nuclear-reactor.png",
    --    --  width = 140,
    --    --  height = 160,
    --    --  shift = {0.6875, -0.59375}
    --    --}
    --  }
    --},
    working_light_picture =
    {
    --  filename = MOD_PATH.."/graphics/entity/workinglight-yellow.png",
    --  width = 140,
    --  height = 160,
    --  shift = {0.6875, -0.59375},
	--  priority = "extra-high",
    --  blend_mode = "additive"
	  filename = MOD_PATH.."/graphics/transparent32.png",
      width = 32,
      height = 32,
    },
    --light = {intensity = 2, size = 9.9, shift = {0.0, 0.0}, color = {r = 1.0, g = 0.5, b = 0.0}},
    heat_buffer =
    {
      max_temperature = 1100,
      specific_heat = "5MJ",
      max_transfer = "10GW",
	  minimum_glow_temperature = 350,
      glow_alpha_modifier = 0.6,
      connections =
     {}
    },
    connection_patches_connected =
    {
      sheet =
      {
        filename = MOD_PATH.."/graphics/entity/reactor-connect-patches-empty.png",
        width = 32,
        height = 32,
        variation_count = 12
      }
    },
    connection_patches_disconnected =
    {
      sheet =
      {
        filename = MOD_PATH.."/graphics/entity/reactor-connect-patches-empty.png",
        width = 32,
        height = 32,
        variation_count = 12,
        y = 32
      }
    },
	--pipe_covers = pipecoverspictures(),
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
    meltdown_action = nil
   
  }
  
if data.raw["fuel-category"]["MOX"] then
	table.insert(reactor_template.energy_source.fuel_categories,"MOX")
end

if data.raw["fuel-category"]["PE-MOX"] then
	table.insert(reactor_template.energy_source.fuel_categories,"PE-MOX")
end

reactor_template.lower_layer_picture = {

		  filename = MOD_PATH.."/graphics/entity/reactor_hr.png",
          width = 288,
          height = 348,
		  scale=0.3542,
          shift = REACTOR_SHIFT
        }
reactor_template.lower_layer_picture.filename = MOD_PATH.."/graphics/entity/reactor-pipes.png"

reactor_template.heat_lower_layer_picture = {

		  filename = MOD_PATH.."/graphics/entity/reactor_hr.png",
          width = 288,
          height = 348,
		  scale=0.3542,
          shift = REACTOR_SHIFT
        }
	
reactor_template.heat_lower_layer_picture.filename = MOD_PATH.."/graphics/entity/reactor-pipes-heated.png"




-- display dummy for normal reactor
reactor_normal=table.deepcopy(reactor_template)
reactor_normal.name = "RRR-realistic-reactor-displayer"
--reactor_normal.flags = {"placeable-neutral", "not-on-map","not-deconstructable","not-blueprintable"}
reactor_normal.placeable_by = { item="RRR-realistic-reactor", count = 1}
reactor_normal.minable = {mining_time = 1.5, result = "RRR-realistic-reactor"}
reactor_normal.consumption = 0.00001 .."W"
reactor_normal.collision_box = {{-1.3, -1.3}, {1.3, 1.4}}
--reactor_normal.selection_box = {{-1.4, -1.9}, {1.4, 0.5}}
reactor_normal.selection_box = {{-1.4, -1.8}, {1.4, 1.35}}
--reactor_normal.selectable_in_game = false
reactor_normal.heat_buffer.connections={}
reactor_normal.light = REACTOR_GLOW
reactor_normal.dying_explosion = "nuclear-reactor-explosion"
reactor_normal.resistances = resistances_immune
reactor_normal.energy_source.light_flicker ={
											minimum_intensity=0.4,
											maximum_intensity = 0.7,
											minimum_light_size=0.6,
											derivation_change_frequency=0.05,
											derivation_change_deviation=0.001,
											border_fix_speed=0.008,
											light_intensity_to_size_coefficient=0.05,
											color = {r = 0.07, g = 0.63, b = 0.55}
											}
reactor_normal.working_light_picture =
    {
      filename = MOD_PATH.."/graphics/entity/reactor-lights-color.png",
      width = 288,
      height = 348,
      shift = REACTOR_SHIFT,
	  scale=0.3542,
      blend_mode = "additive",
	  draw_as_glow = true,
      --hr_version =
      --{
      --  filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-lights-color.png",
      --  width = 320,
      --  height = 320,
      --  scale = 0.5,
      --  shift = REACTOR_SHIFT
      --  blend_mode = "additive"
      --}
    }
	
reactor_normal.picture =
    {
      layers =
      {
        {

		  filename = MOD_PATH.."/graphics/entity/reactor_hr.png",
          width = 288,
          height = 348,
		  scale=0.3542,
          shift = REACTOR_SHIFT
        },
		{
		filename = MOD_PATH.."/graphics/entity/reactor-shadow.png",
		width = 174,
		height = 160,
		shift = {1.2185, -0.59375},
		draw_as_shadow = true,
		}
      }
    }
reactor_normal.heat_buffer.heat_picture =
      {
        filename = MOD_PATH.."/graphics/entity/reactor-heated.png",
        width = 288,
        height = 348,
        shift = REACTOR_SHIFT,
		scale=0.3542,
        --hr_version =
        --{
        --  filename = "__base__/graphics/entity/nuclear-reactor/hr-reactor-heated.png",
        --  width = 216,
        --  height = 256,
        --  scale = 0.5,
        --  shift = REACTOR_SHIFT,
        --}
      }
reactor_normal.heat_buffer.heat_glow =
      {
        filename = MOD_PATH.."/graphics/entity/reactor-heat-glow.png",
        priority = "extra-high",
        width = 288,
        height = 348,
        tint = heat_glow_tint,
        shift = REACTOR_SHIFT,
		scale=0.3542,
      }

 -- display dummy for breeder reactor
reactor_breeder = table.deepcopy(reactor_normal)
reactor_breeder.name = "RRR-breeder-reactor-displayer"
reactor_breeder.icon = MOD_PATH.."/graphics/icons/breeder-reactor.png"
reactor_breeder.minable = {mining_time = 1.5, result = "RRR-breeder-reactor"}
reactor_breeder.placeable_by = { item="RRR-breeder-reactor", count = 1}
reactor_breeder.picture.layers[1].filename = MOD_PATH.."/graphics/entity/breeder_hr.png"
reactor_breeder.heat_buffer.heat_glow.filename = MOD_PATH.."/graphics/entity/breeder-heat-glow.png"
reactor_breeder.heat_buffer.heat_picture.filename = MOD_PATH.."/graphics/entity/breeder-heated.png"
reactor_breeder.working_light_picture.filename = MOD_PATH.."/graphics/entity/breeder-lights-color.png"
reactor_breeder.light = BREEDER_GLOW
reactor_breeder.dying_explosion = "nuclear-reactor-explosion"
reactor_breeder.energy_source.light_flicker ={
											minimum_intensity=0.4,
											maximum_intensity = 0.7,
											minimum_light_size=0.6,
											derivation_change_frequency=0.05,
											derivation_change_deviation=0.001,
											border_fix_speed=0.008,
											light_intensity_to_size_coefficient=0.05,
											color = {r = 0.59, g = 0.35, b = 0.04}
											}
--reactor_breeder.picture.layers[1].width = 174
--reactor_breeder.picture.layers[1].height = 160
--reactor_breeder.picture.layers[1].scale = 1

if mods["heat_glow"] then
	reactor_normal.heat_lower_layer_picture.filename = MOD_PATH.."/graphics/entity/reactor-pipes-heated-mod.png"
	reactor_normal.heat_buffer.heat_picture.filename = MOD_PATH.."/graphics/entity/reactor-heated-mod.png"
	reactor_breeder.heat_lower_layer_picture.filename = MOD_PATH.."/graphics/entity/reactor-pipes-heated-mod.png"
	reactor_breeder.heat_buffer.heat_picture.filename = MOD_PATH.."/graphics/entity/breeder-heated-mod.png"
end
      



-- heat interface
--apply_heat_pipe_glow = function(layer)
--  layer.tint = heated_pipes_tint
--  local light_layer = util.copy(layer)
--  light_layer.draw_as_light = true
--  light_layer.tint = heat_glow_tint
--  return
--  {
--    layers =
--    {
--      layer,
--      light_layer
--    }
--  }
--end


	local heat_interface = table.deepcopy(data.raw["heat-interface"]["heat-interface"]) --table.deepcopy(reactor_template)
	heat_interface.name = "RRR-realistic-reactor-heat"
	heat_interface.resistances = resistances_immune
	heat_interface.flags = {"player-creation", "not-deconstructable","not-blueprintable","not-rotatable"}
	heat_interface.collision_mask = {layers = {}} --{layers = {[reactor_collision_layer]=true}} -- heat interface
	--heat_interface.consumption = i.."MW"
	--heat_interface.heat_buffer.max_transfer = i.."MW"
	heat_interface.collision_box = reactor_template.collision_box
	heat_interface.selection_priority =1
	heat_interface.health = 99999999
	heat_interface.picture =nil
	
	heat_interface.heat_buffer. max_temperature = 1100
	
	-- vanilla values:
	heat_interface.heat_buffer.specific_heat = "10MJ"
    heat_interface.heat_buffer.max_transfer = "10GW"
    heat_interface.heat_buffer.default_temperature = 0
    heat_interface.heat_buffer.min_working_temperature = 0
	
	heat_interface.heat_buffer.connections =
      {
        {
          position = {1, -1},
          direction = defines.direction.north
        },
        {
          position = {0, -1},
          direction = defines.direction.north
        },
        {
          position = {-1, -1},
          direction = defines.direction.north
        },
        {
          position = {1, -1},
          direction = defines.direction.east
        },
        {
          position = {1, 0},
          direction = defines.direction.east
        },
        {
          position = {-1, 0},
          direction = defines.direction.west
        },
        {
          position = {-1, -1},
          direction = defines.direction.west
        }
      }
	
	if debug_core then
		heat_interface.selection_box = {{-1.4, -2.5}, {1.4, 1.35}}
		heat_interface.selectable_in_game = true
		heat_interface.selectable_in_game = true
	end
	data:extend{heat_interface}

 
-- Circuit interface entity for nuclear reactor
reactor_interface =
{
  type = "constant-combinator",
  name = "RRR-realistic-reactor-interface",
  collision_mask = {layers = {[combinator_collision_layer] = true}}, -- reactor_interface
  icon = reactor_template.icon,
  icon_size = reactor_template.icon_size,
  order = "f[nuclear-energy]-a[reactor]",
  flags = {"placeable-neutral","placeable-player", "player-creation"},
  resistances = resistances_immune,
  minable = {hardness = 0.2, mining_time = 0.5, result = "constant-combinator"},
  placeable_by = {item="constant-combinator", count = 1},
  max_health = reactor_template.max_health,
  collision_box = {{-1.4, -0.25}, {1.4, 0.4}},
  selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
  item_slot_count = 14,

  sprites =
  {
    north =
    {
      filename = MOD_PATH.."/graphics/entity/nuclear-reactor-interface.png",
      priority = "high",
      frame_count = 1,
      width = 32,
      height = 32,
	  shift = util.by_pixel(1,0)
    },
    east =
    {
      filename = MOD_PATH.."/graphics/entity/nuclear-reactor-interface.png",
      priority = "high",
      frame_count = 1,
      width = 32,
      height = 32,
	  shift = util.by_pixel(1,0)
    },
    south =
    {
      filename = MOD_PATH.."/graphics/entity/nuclear-reactor-interface.png",
      priority = "high",
      frame_count = 1,
      width = 32,
      height = 32,
	  shift = util.by_pixel(1,0)
    },
    west =
    {
      filename = MOD_PATH.."/graphics/entity/nuclear-reactor-interface.png",
      priority = "high",
      frame_count = 1,
      width = 32,
      height = 32,
	  shift = util.by_pixel(1,0)
    }
  },
  activity_led_sprites =
  {
    north = interface_led,
    east = interface_led,
    south = interface_led,
    west = interface_led
  },
  activity_led_light =
  {
    intensity = 0.4,
    size = 0.3,
	color = {r = 0.02, g = 0.05, b = 0.55}
  },
  activity_led_light_offsets =
  {
    interface_led.shift,
    interface_led.shift,
    interface_led.shift,
    interface_led.shift
  },
  circuit_wire_connection_points =
  {
    interface_connection,
    interface_connection,
    interface_connection,
    interface_connection
  },
  circuit_wire_max_distance = 7.5,
  order = "z"
}

local breeder_interface = table.deepcopy(reactor_interface)
breeder_interface.name = "RRR-realistic-breeder-interface"
breeder_interface.sprites.north.filename = MOD_PATH.."/graphics/entity/breeder-interface.png"
breeder_interface.sprites.east.filename = MOD_PATH.."/graphics/entity/breeder-interface.png"
breeder_interface.sprites.south.filename = MOD_PATH.."/graphics/entity/breeder-interface.png"
breeder_interface.sprites.west.filename = MOD_PATH.."/graphics/entity/breeder-interface.png"


-- ECCS entity for nuclear reactor
reactor_eccs_L =
{
	type = "storage-tank",
	name = "RRR-realistic-reactor-eccs-L",
	icon = reactor_template.icon,
	icon_size = reactor_template.icon_size,
	order = "f[nuclear-energy]-a[reactor]",
	flags = {"player-creation", "not-deconstructable","not-blueprintable","not-rotatable"},
	placeable_by = {item = "pump", count = 1},
	resistances = resistances_immune,
	--placeable_by = {item="iron-plate", count = 1},
	max_health = reactor_template.max_health,
	collision_mask = {layers = {}}, -- {"ghost-layer"}, eccs
	collision_box = {{-0.5, -0.5}, {0.5, 0.5}},
	selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
	selection_priority =10,
	icon_draw_specification = {scale = 0.25},
	--drawing_box = {{-1.4,-1.4},{-1,-1}}, --doesnt affect alt-info-overlay
	fluid_box =
	{
		base_area = 50,
		volume = 1000,
		pipe_covers = pipecoverspictures(),
		pipe_connections =
		{
			{ direction = defines.direction.south, position = {0, 0} },  --{position = {1, 2}},
			{ direction = defines.direction.west, position = {0, 0} }    --{position = {2, 1}}
		},
		hide_connection_info = true,
	},
	window_bounding_box = {{-0.1,-0.1}, {0.1,0.1}},
	pictures =
	{
		picture =
		{
		north = empty_sprite,
		east = empty_sprite,
		south = empty_sprite,
		west = empty_sprite
		},
		fluid_background = empty_sprite,
		window_background = empty_sprite,
		flow_sprite = empty_sprite,
		gas_flow = empty_sprite
	},
	flow_length_in_ticks = 360,
	--circuit_wire_connection_points = reactor_interface.circuit_wire_connection_points,
	circuit_wire_max_distance = 5,
	order = "z",
	--circuit_wire_connection_points = circuit_connector_definitions["storage-tank"].points,
	circuit_connector_sprites = circuit_connector_definitions["storage-tank"] and circuit_connector_definitions["storage-tank"].sprites or nil,
	--  circuit_wire_max_distance = default_circuit_wire_max_distance,

}
local reactor_eccs_R = table.deepcopy(reactor_eccs_L)
reactor_eccs_R.name = "RRR-realistic-reactor-eccs-R"
reactor_eccs_R.fluid_box.pipe_connections =
    {
      { direction = defines.direction.east, position = {0, 0} },  --{position = {-2, 1}},
      { direction = defines.direction.south, position = {0, 0} }, --{position = {-1, 2}},
    }
data:extend{reactor_eccs_L,reactor_eccs_R}
for i=1,10 do
	leveled_reactor_eccs_L = table.deepcopy(reactor_eccs_L)
	leveled_reactor_eccs_L.name = "RRR-realistic-reactor-eccs-L-"..i
	leveled_reactor_eccs_L.fluid_box.volume = 1000*(1+i/10)
	leveled_reactor_eccs_L.localised_name = {"entity-name.RRR-realistic-reactor-eccs-L"}
	leveled_reactor_eccs_L.localised_description = {"entity-description.RRR-realistic-reactor-eccs-L"}
	
	leveled_reactor_eccs_R = table.deepcopy(reactor_eccs_R)
	leveled_reactor_eccs_R.name = "RRR-realistic-reactor-eccs-R-"..i
	leveled_reactor_eccs_R.fluid_box.volume = 1000*(1+i/10)
	leveled_reactor_eccs_R.localised_name = {"entity-name.RRR-realistic-reactor-eccs-R"}
	leveled_reactor_eccs_R.localised_description = {"entity-description.RRR-realistic-reactor-eccs-R"}
	data:extend{leveled_reactor_eccs_L,leveled_reactor_eccs_R}
end

-- Power draining entity for normal reactor
reactor_power_normal =
  {
    type = "electric-energy-interface",
    name = "RRR-realistic-reactor-power-normal",
	icon = reactor_normal.icon,
	icon_size = reactor_normal.icon_size,
    flags = {"player-creation", "not-deconstructable","not-blueprintable"},
	order = "f[nuclear-energy]-a[reactor]",
    max_health = 150,
	resistances = resistances_immune,
	collision_mask = {layers = {}}, -- {"ghost-layer"}, power interface
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-1.4, -1.4}, {1.4, 1.4}},
    drawing_box = {{-0.5, -2.5}, {0.5, 0.3}},
	selectable_in_game = false,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
	  input_flow_limit= "17MW",
	  buffer_capacity = "17MJ"
    },
	energy_production = "0kW",
	energy_usage = "0kW",
  }

-- Power draining entity 2 for nuclear reactor
reactor_power_breeder = table.deepcopy(reactor_power_normal)
reactor_power_breeder.name = "RRR-realistic-reactor-power-breeder"
reactor_power_breeder.icon = reactor_breeder.icon
reactor_power_breeder.icon_size = reactor_breeder.icon_size


reactor_ruin = {
    type = "simple-entity-with-owner",
    name = "RRR-reactor-ruin",
	icon = MOD_PATH.."/graphics/icons/nuclear-reactor.png",
    icon_size = 32,
	max_health = 1000,
	order = "f[nuclear-energy]-a[reactor]",
    flags = {"player-creation", "not-deconstructable","not-blueprintable", "not-repairable"},
	--flags = {"placeable-neutral", "placeable-player", "player-creation"},
	--resistances=resistances_immune,
	placeable_by = { item="RRR-reactor-sarcophagus", count = 1},
    collision_box = {{-1.5, -1.5}, {1.5, 1.5}},	
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},	
	minable = {hardness=1, mining_time = 4, result = nil},
	fast_replaceable_group = "RRR-reactor-ruins",	
	picture =
	{ 
		filename = MOD_PATH.."/graphics/entity/reactor_ruin.png",
		width = 174,
		height = 160,
		shift = {1.2185, -0.59375},
		frame_count=1
	},	
}
if settings.startup["RRR-meltdown-mode"].value == "meltdown with ruin + sarcophagus" then
	reactor_ruin.selection_box = {{-2.5, -2.5}, {2.5, 2.5}}
	reactor_ruin.selection_priority = 1
	reactor_ruin.minable = {hardness=999999, mining_time = 999999, result = nil}
elseif settings.startup["RRR-meltdown-mode"].value == "meltdown with ruin" then
	--reactor_ruin.minable = {hardness=1, mining_time = 4, result = nil} --already set
end

breeder_ruin = table.deepcopy(reactor_ruin)
breeder_ruin.name = "RRR-breeder-ruin"
breeder_ruin.icon = MOD_PATH.."/graphics/icons/breeder-reactor.png"
--breeder_ruin.minable = {hardness=999999, mining_time = 999999, result = "RRR-breeder-reactor"}
--if settings.startup["RRR-meltdown-mode"].value == "meltdown with ruin" then
--	breeder_ruin.minable = {hardness=1, mining_time = 4, result = nil}
--end
breeder_ruin.pictures ={layers={
{
	filename = MOD_PATH.."/graphics/entity/breeder_ruin.png",
	width = 174,
	height = 160,
	shift = {1.2185, -0.59375},
	frame_count=1
},
{
	filename = MOD_PATH.."/graphics/entity/breeder_ruin.png",
	width = 174,
	height = 160,
	shift = {1.8185, -0.19375},
	frame_count=1,
	draw_as_shadow = true
},
}}

sarcophagus = table.deepcopy(reactor_ruin)
sarcophagus.name = "RRR-reactor-sarcophagus"
sarcophagus.icon = MOD_PATH.."/graphics/icons/sarcophagus2.png"
sarcophagus.flags = {"player-creation", "not-blueprintable", "not-repairable"}
sarcophagus.minable = {mining_time = 2} --, result = "RRR-reactor-sarcophagus"}
sarcophagus.collision_box = {{-2.2, -2.1}, {2.2, 2.1}}
sarcophagus.selection_box = {{-2.3, -2.4}, {2.1, 2.0}}
sarcophagus.picture ={layers={
{
	filename = MOD_PATH.."/graphics/entity/sarcophagus.png",
	width = 300,
	height = 300,
	shift = {0, -0.12},
	frame_count=1,
	scale=0.56
},
{
	filename = MOD_PATH.."/graphics/entity/sarcophagus-shadow.png",
	width = 410,
	height = 300,
	shift = {0.9, -0.12},
	frame_count=1,
	scale=0.56,
	draw_as_shadow = true
},
}}


-- Cooling tower
cooling_tower =
{
  type = "furnace",
  name = "RRR-cooling-tower",
  icon = MOD_PATH.."/graphics/icons/cooling-tower.png",
  icon_size = 32,
  flags = {"placeable-neutral", "placeable-player", "player-creation"},
  minable = {hardness = 0.2, mining_time = 0.5, result = "RRR-cooling-tower"},
  max_health = 500,
  corpse = "medium-remnants",
   icon_draw_specification = {scale = 0},
  resistances =
  {
    {
      type = "fire",
      percent = 70
    }
  },
  collision_box = {{-1.3, -1.3}, {1.3, 1.3}},
  selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
  drawing_box = {{-1.5, -3}, {1.5, 1.5}},
  fluid_boxes =
  {
    {
      production_type = "input",
	  volume = 1000,
      base_area = 25,
      base_level = -1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        {flow_direction="input", direction = defines.direction.west, position = {-1, -1}},  --{position = {-2, -1},type = "input"},
        {flow_direction="input", direction = defines.direction.west, position = {-1, 1}},   --{position = {-2, 1},type = "input"},
        {flow_direction="input", direction = defines.direction.north, position = {-1, -1}}, --{position = {-1, -2},type = "input"},
        {flow_direction="input", direction = defines.direction.south, position = {-1, 1}}   --{position = {-1, 2},type = "input"}
      }
    },
    {
      production_type = "output",
	  volume = 1000,
      base_area = 25,
      base_level = 1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        {flow_direction="output", direction = defines.direction.north, position = {1, -1}}, --{position = {1, -2},type = "output"},
        {flow_direction="output", direction = defines.direction.south, position = {1, 1}},  --{position = {1, 2},type = "output"},
        {flow_direction="output", direction = defines.direction.east, position = {1, -1}},  --{position = {2, -1},type = "output"},
        {flow_direction="output", direction = defines.direction.east, position = {1, 1}}    --{position = {2, 1},type = "output"}
      }
    }
  },
  source_inventory_size = 0,
  result_inventory_size = 0,
  crafting_categories = {"water-cooling"},
  energy_usage = "120kW",
  crafting_speed = 1,
  energy_source =
  {
    type = "electric",
    usage_priority = "primary-input",
    emissions = 0,
  },
  graphics_set ={animation =
  { 
	  layers=
	  {
		{
			filename = MOD_PATH.."/graphics/entity/cooling-tower-hr.png",
			width = 308,
			height = 310,
			frame_count = 1,
			shift = {0.695, -0.66},
			scale = 0.505
			
		},
		{
			filename = MOD_PATH.."/graphics/entity/cooling-tower-hr-shadow.png",
			width = 308,
			height = 310,
			frame_count = 1,
			shift = {0.695, -0.66},
			scale = 0.505,
			draw_as_shadow = true,
		}
	  }
  }
}}

-- Steam creator for cooling tower
cooling_tower_smoke =
{
  type = "furnace",
  name = "RRR-cooling-tower-steam",
  icon = cooling_tower.icon,
  icon_size = 32,
  order = "f[nuclear-energy]-a[reactor]",
  flags = {"not-blueprintable", "not-deconstructable","placeable-off-grid","hide-alt-info"},
  max_health = cooling_tower.max_health,
  collision_mask = {layers = {}}, -- "ghost-layer"}, --cooling tower
  collision_box = {{-0.5,-0.5},{0.5,0.5}},
  selection_box = {{-0.5,-0.5},{0.5,0.5}},
  resistances=resistances_immune,
  selectable_in_game = false,
  fluid_boxes =
  {
    {
      production_type = "input",
	  volume = 1000,
      base_area = 0.1,
      pipe_connections = { }
    },
    {
      production_type = "output",
	  volume = 1000,
      base_area = 0.1,
      pipe_connections = { }
    }
  },
  source_inventory_size = 0,
  result_inventory_size = 0,
  crafting_categories = {"steaming"},
  energy_usage = "1W",
  crafting_speed = 0.0001,
  energy_source =
  {
    type = "burner",
    effectivity = 1,
    fuel_inventory_size = 1,
    emissions = 0,
    light_flicker =
    {
      minimum_intensity = 0,
      maximum_intensity = 0
    },
    smoke =
    {
      {
        name = "RRR-cooling-tower-smoke-type",
		type = "trivial-smoke",
        deviation = {0.05, 0.05},
		frequency = 10,
        position = {0.15, -1.95},
        starting_vertical_speed = 0.011,
		starting_vertical_speed_deviation = 0.004,
        starting_frame_deviation = 60,
      }
    }
  },
  animation = empty_sprite
}

ruin_smoke = table.deepcopy(cooling_tower_smoke)
ruin_smoke.name = "RRR-ruin-smoke"
ruin_smoke.energy_source.smoke[1].name = "RRR-ruin-smoke-type"
ruin_smoke.energy_source.smoke[1].position = {0.0, -1.8}

local function trivial_smoke(opts)
  return
  {
    type = "trivial-smoke",
    name = opts.name,
	render_layer = "entity-info-icon-above",
    duration = opts.duration or 600,
    fade_in_duration = opts.fade_in_duration or 0,
    fade_away_duration = opts.fade_away_duration or ((opts.duration or 600) - (opts.fade_in_duration or 0)),
    spread_duration = opts.spread_duration or 600,
    start_scale = opts.start_scale or 0.20,
    end_scale = opts.end_scale or 1.0,
    color = opts.color,
    cyclic = true,
    affected_by_wind = opts.affected_by_wind or true,
    animation =
    {
      width = 152,
      height = 120,
      line_length = 5,
      frame_count = 60,
      shift = {-0.53125, -0.4375},
      priority = "high",
      animation_speed = 0.25,
      filename = "__base__/graphics/entity/smoke/smoke.png",
      flags = { "smoke" },
	  --scale = opts.scale or 1
    }
  }
end
data:extend({
  -- electricity warning
  {
    type = "simple-entity",
    name = "RRR-electricity-warning",
	flags = {"placeable-off-grid"},
    picture =
    {
      filename = "__core__/graphics/icons/alerts/electricity-icon-red.png",
      priority = "high",
      width = 64,
      height = 64,
      frame_count = 1,
      animation_speed = 1,
	  scale = 0.44,
    },
	duration = 60,
	fade_in_duration = 3,
	fade_away_duration = 3,
	spread_duration = 0,
	start_scale = 1,
	end_scale = 1,
	cyclic = true,
	affected_by_wind = false,
	movement_slow_down_factor = 0.5,
	show_when_smoke_off = true,
	render_layer = "entity-info-icon-above",
    --duration = 60,
    --fade_away_duration = 1,
	--affected_by_wind = false,
	--show_when_smoke_off = true,
	--render_layer = "smoke",
	--cyclic = true,
	--spread_duration = 6,

    --fade_in_duration = opts.fade_in_duration or 0,
    --spread_duration = opts.spread_duration or 600,
    --start_scale = opts.start_scale or 0.20,
    --end_scale = opts.end_scale or 1.0,
    --color = opts.color,

  },
   
   -- smoke for cooling tower
   trivial_smoke{
	name = "RRR-cooling-tower-smoke-type", 
	flags = {"placeable-off-grid","not-on-map"},
	color = {r = 0.65, g = 0.65, b = 0.65, a = 0.3}, 
	start_scale = 0.77,
	end_scale = 1.3,
	duration = 260,
	spread_duration = 260,
	fade_away_duration = 100,
	affected_by_wind = true,
	fade_in_duration = 20,
    starting_frame_deviation = 60,
	deviation = {0.1, 0.1},
    frequency = 10,
    position = {0.0, -2.25},
    starting_vertical_speed = 0.00,
		
	},
	
	-- smoke for reactor ruin
   {
	name = "RRR-ruin-smoke-type",
	type = "trivial-smoke",
	flags = {"placeable-off-grid","not-on-map"},
	blend_mode = "additive-soft",
	--color = {r = 0.9, g = 0.9, b = 0.9, a = 0.3}, 
	start_scale = 0.4,
	end_scale = 6.0,
	duration = 1000,
	spread_duration = 1000,
	fade_away_duration = 990,
	affected_by_wind = true,
	fade_in_duration = 10,
    starting_frame_deviation = 60,
	deviation = {0.1, 0.1},
    --frequency = 10,
    position = {0.0, -2.25},
    starting_vertical_speed = 0.00,
	cyclic = true,
	animation =
    {
      width = 152,
      height = 120,
      line_length = 5,
      frame_count = 60,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {-0.53125, -0.4375},
      priority = "high",
      animation_speed = 0.25,
      filename = MOD_PATH.."/graphics/smoke.png",
      --flags = { "smoke" }
    }
	},
	
  
 })

local normal_furnace = table.deepcopy(data.raw.furnace["electric-furnace"])
normal_furnace.name = "RRR-realistic-reactor"
normal_furnace.corpse = "big-remnants"
normal_furnace.icon = MOD_PATH.."/graphics/icons/nuclear-reactor.png"
normal_furnace.icon_size=32
normal_furnace.flags = {"placeable-neutral", "player-creation"}
normal_furnace.placeable_by = { item="RRR-realistic-reactor", count = 1}
normal_furnace.minable = {mining_time = 1.5, result = "RRR-realistic-reactor"}
normal_furnace.consumption = 0.00001 .."W"
normal_furnace.collision_box = {{-1.3, -1.3}, {1.3, 1.4}}
--normal_furnace.selection_box = {{-1.4, -1.9}, {1.4, 0.5}}
normal_furnace.selection_box = {{-1.4, -1.8}, {1.4, 1.35}}
normal_furnace.selectable_in_game = true
normal_furnace.selection_priority =5
normal_furnace.icon_draw_specification = {scale = 0.7,shift ={0,0.2}}
normal_furnace.icons_positioning =
    {
      {inventory_index = defines.inventory.crafter_modules, shift = {0, 1.5}, scale = 0.25}
    }
--normal_furnace.heat_buffer.connections={}
normal_furnace.light = REACTOR_GLOW
normal_furnace.module_slots = settings.startup["RRR-reactor_modules"].value
normal_furnace.allowed_effects = {"consumption", "speed", "productivity", "pollution", "quality"}
normal_furnace.dying_explosion = "nuclear-reactor-explosion"
normal_furnace.crafting_categories = {"RRR-furnace-recipes"}
normal_furnace.graphics_set = {animation = table.deepcopy(reactor_normal.picture)}
normal_furnace.render_layer = "object-under"
normal_furnace.result_inventory_size = 2
normal_furnace.crafting_speed = 0.1
normal_furnace.ignore_output_full  = true
normal_furnace.energy_source =
    {
      type = "void",
    }

-- for reference:
temp = {
    type = "furnace",
    name = "RRR-reactor-furnace",
    icon = "__base__/graphics/icons/electric-furnace.png",
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    minable = {mining_time = 0.2, result = "electric-furnace"},
    fast_replaceable_group = "furnace",
    max_health = 350,
    corpse = "electric-furnace-remnants",
    dying_explosion = "electric-furnace-explosion",
    resistances =
    {
      {
        type = "fire",
        percent = 80
      }
    },
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    damaged_trigger_effect = nil,--hit_effects.entity(),
    module_slots = 2,
    icon_draw_specification = {shift = {0, -0.1}},
    icons_positioning =
    {
      {inventory_index = defines.inventory.crafter_modules, shift = {0, -0.8}, scale = 0.5}
    },
    allowed_effects = {"consumption", "speed", "productivity", "pollution", "quality"},
    crafting_categories = {"smelting"},
    result_inventory_size = 1,
    crafting_speed = 2,
    energy_usage = "180kW",
    source_inventory_size = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions_per_minute = { pollution = 1 }
    },
    impact_category = "metal",
    open_sound = nil,--sounds.electric_large_open,
    close_sound = nil,--sounds.electric_large_close,
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/electric-furnace.ogg",
        volume = 0.85,
        modifiers = volume_multiplier("main-menu", 4.2),
        advanced_volume_control = {attenuation = "exponential"}
      },
      max_sounds_per_type = 4,
      audible_distance_modifier = 0.7,
      fade_in_ticks = 4,
      fade_out_ticks = 20
    },
    graphics_set =
    {
      animation =
      {
        layers =
        {
          {
            filename = "__base__/graphics/entity/electric-furnace/electric-furnace.png",
            priority = "high",
            width = 239,
            height = 219,
            shift = util.by_pixel(0.75, 5.75),
            scale = 0.5
          },
          {
            filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
            priority = "high",
            width = 227,
            height = 171,
            draw_as_shadow = true,
            shift = util.by_pixel(11.25, 7.75),
            scale = 0.5
          }
        }
      },
      working_visualisations =
      {
        {
          fadeout = true,
          animation =
          {
            layers =
            {
              {
                filename = "__base__/graphics/entity/electric-furnace/electric-furnace-heater.png",
                priority = "high",
                width = 60,
                height = 56,
                frame_count = 12,
                animation_speed = 0.5,
                draw_as_glow = true,
                shift = util.by_pixel(1.75, 32.75),
                scale = 0.5
              },
              {
                filename = "__base__/graphics/entity/electric-furnace/electric-furnace-light.png",
                blend_mode = "additive",
                width = 202,
                height = 202,
                repeat_count = 12,
                draw_as_glow = true,
                shift = util.by_pixel(1, 0),
                scale = 0.5,
              },
            }
          },
        },
        {
          fadeout = true,
          animation =
          {
            filename = "__base__/graphics/entity/electric-furnace/electric-furnace-ground-light.png",
            blend_mode = "additive",
            width = 166,
            height = 124,
            draw_as_light = true,
            shift = util.by_pixel(3, 69),
            scale = 0.5,
          },
        },
        {
          animation =
          {
            filename = "__base__/graphics/entity/electric-furnace/electric-furnace-propeller-1.png",
            priority = "high",
            width = 37,
            height = 25,
            frame_count = 4,
            animation_speed = 0.5,
            shift = util.by_pixel(-20.5, -18.5),
            scale = 0.5
          }
        },
        {
          animation =
          {
            filename = "__base__/graphics/entity/electric-furnace/electric-furnace-propeller-2.png",
            priority = "high",
            width = 23,
            height = 15,
            frame_count = 4,
            animation_speed = 0.5,
            shift = util.by_pixel(3.5, -38),
            scale = 0.5
          }
        }
      },
      water_reflection =
      {
        pictures =
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-reflection.png",
          priority = "extra-high",
          width = 24,
          height = 24,
          shift = util.by_pixel(5, 40),
          variation_count = 1,
          scale = 5
        },
        rotate = false,
        orientation_to_variation = false
      }
    }
  }
  
breeder_furnace = table.deepcopy(normal_furnace)
breeder_furnace.name = "RRR-breeder-reactor"
breeder_furnace.icon = MOD_PATH.."/graphics/icons/breeder-reactor.png"
breeder_furnace.placeable_by = { item="RRR-breeder-reactor", count = 1}
breeder_furnace.minable = {mining_time = 1.5, result = "RRR-breeder-reactor"}
breeder_furnace.graphics_set = {animation = table.deepcopy(reactor_breeder.picture)}
breeder_furnace.module_slots = settings.startup["RRR-breeder_modules"].value



data:extend({ 
  normal_furnace,
  breeder_furnace,
  --reactor_default,
  reactor_interface,
  breeder_interface,
  reactor_power_normal,
  reactor_power_breeder,
  reactor_normal,
  reactor_breeder,
  cooling_tower,
  cooling_tower_smoke,
  ruin_smoke,
  reactor_ruin,
  breeder_ruin,
  sarcophagus
})

