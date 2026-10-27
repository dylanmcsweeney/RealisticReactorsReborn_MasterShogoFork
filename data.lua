MOD_PATH = "__RealisticReactorsReborn__"

reactor_collision_layer = "item"
combinator_collision_layer = "blueprint-data"
eccs_collision_layer = "item"
lamp_collision_layer = "item"

if not data.raw["collision-layer"]["blueprint-data"] then
	data:extend{
		{
			type = "collision-layer",
			name = "blueprint-data",
		}
	}
end

require("prototypes.entities")
require("prototypes.items")
require("prototypes.recipes")
require("prototypes.signals")
require("prototypes.technology")
require("prototypes.sprites_font")
require("prototypes.lamps")
require("prototypes.fx")
require("prototypes.keybind")
require("prototypes.tipsandtricks")

if settings.startup["RRR-disable-vanilla-reactor"].value then
	--if data.raw.technology["nuclear-power"].effects[1].recipe == "nuclear-reactor" then
	--	data.raw.technology["nuclear-power"].effects[1]=nil
	--end
	data.raw.recipe["nuclear-reactor"].hidden=true
	data.raw.reactor["nuclear-reactor"].minable = {mining_time = 1.5, result = "RRR-realistic-reactor"}
	table.insert(data.raw.technology["nuclear-power"].prerequisites, "efficiency-module-2")
end

data.raw["heat-pipe"]["heat-pipe"].heat_buffer.specific_heat = "1MJ"
data.raw["boiler"]["heat-exchanger"].energy_source.specific_heat = "1MJ"