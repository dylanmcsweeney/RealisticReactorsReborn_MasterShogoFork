local categories = {
"thorium",
"deuterium",
}


function insert_categories(reactor)
	for _, cat in pairs(categories) do
		if data.raw["fuel-category"][cat] then
			table.insert(reactor.energy_source.fuel_categories,cat)
		end
	end
end



insert_categories(data.raw.reactor["RRR-breeder-reactor"])
insert_categories(data.raw.reactor["RRR-realistic-reactor"])


require("prototypes.apm_fix")
require("prototypes.item_sprites_and_furnace_recipes")

for _,cat in pairs{
"boiler",
"heat-pipe",
"heat-interface",
} do
	for _, prototype in pairs(data.raw[cat]) do
		if  prototype.heat_buffer and prototype.heat_buffer.max_temperature then
			prototype.heat_buffer.max_temperature = math.max(prototype.heat_buffer.max_temperature,1100)
		elseif prototype.energy_source and prototype.energy_source.max_temperature then
			prototype.energy_source.max_temperature = math.max(prototype.energy_source.max_temperature,1100)
		end
	end
end

--transplutonic fix
if data.raw["technology"]["nuclear-power"] then
	local found_unlock = false
	for a,b in pairs(data.raw["technology"]["nuclear-power"].effects) do
		if b.type == "unlock-recipe" and b.recipe == "RRR-realistic-reactor" then
			found_unlock=true
		end
	end
	
	if not found_unlock then
		table.insert(data.raw["technology"]["nuclear-power"].effects, {type = "unlock-recipe", recipe = "RRR-realistic-reactor"})
	end
end