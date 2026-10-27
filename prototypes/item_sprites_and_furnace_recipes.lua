local nuclear_categories = {
	"nuclear",
	"MOX",
	"PE-MOX",
	'apm_nuclear_uranium', 
	'apm_nuclear_mox', 
	'apm_nuclear_neptunium', 
	'apm_nuclear_thorium',
	'apm_nuclear_deuterium',
	'apm_nuclear_breeder',
	--atomic overhaul
	"space-nuclear-fuel",
	"nuclear-breeder",
	--PlutoniumBreeding
	"nuclear",
	--PlutoniumEnergy
	"MOX",
	"nuclear-breeder",
}
--for _, cat in pairs(data.raw.furnace["RRR-realistic-reactor"].crafting_categories) do
--	table.insert(nuclear_categories, cat)
--end
--for _, cat in pairs(data.raw.furnace["RRR-breeder-reactor"].crafting_categories) do
--	table.insert(nuclear_categories, cat)
--end
for _, cat in pairs(data.raw.reactor["nuclear-reactor"].energy_source.fuel_categories) do
	table.insert(nuclear_categories, cat)
end
local function table_contains(t, value)
	for _, val in pairs(t) do
		if val == value then
			return true
		end
	end
	return false
end

local function make_sprites(item)
	for _, quality in pairs(data.raw.quality) do
		if quality.icon or quality.icons and quality.icons[1] and (quality.icons[1].filename or quality.icons[1][1]) then
			--if item.name.."-"..quality.name == "uranium-fuel-cell-legendary" then error(1)end
			local spr = {
				type="sprite",
				name = item.name.."-"..quality.name,				
				priority = "extra-high",
				layers = {}
			}
			if item.icons then
				for _, icon in pairs(item.icons) do
					table.insert(spr.layers,{
						filename = icon.icon or icon.filename or icon[1],
						height = icon.icon_size or 64,
						width = icon.icon_size or 64,
						scale = icon.scale,
					})
				end
			elseif item.icon then
				table.insert(spr.layers,{
					filename = item.icon,
					height = item.icon_size or 64,
					width = item.icon_size or 64,
				})
			end
			if quality.name ~="normal" then
				if quality.icon then
					table.insert(spr.layers,{
						filename = quality.icon,
						height = quality.icon_size or 64,
						width = quality.icon_size or 64,
						scale = 24/( quality.icon_size or 64), --12px maybe
						shift = {-20,20},
					})
				elseif quality.icons then
					table.insert(spr.layers,{
						filename =  quality.icons[1].icon or quality.icons[1].filename or quality.icons[1][1],
						height = quality.icons[1].icon_size or 64,
						width = quality.icons[1].icon_size or 64,
						scale = 24/(quality.icons[1].icon_size or 64),
						shift = {-20,20},
					})
				end
			end
			if #spr.layers >0 then
				data:extend{spr}
			else
				error(item.name.." "..quality.name)
			end
		end
	end
end
data:extend{
{
    type = "recipe-category",
    name = "RRR-furnace-recipes"
  }
}


for _, item in pairs(data.raw.item) do
	local nuclear_fuel = false
	for _, category in pairs(item.fuel_categories or {}) do
		if table_contains(nuclear_categories, category) then nuclear_fuel = true; break end
	end
	if nuclear_fuel then
		make_sprites(item)
		if item.burnt_result and data.raw.item[item.burnt_result] then
			make_sprites(data.raw.item[item.burnt_result])
			data:extend{
				{
					type = "recipe",
					name = "RRR-"..item.name,
					localised_name = {"?", item.localised_name or {"item-name."..item.name},
						{"entity-name."..item.name}, item.name},
					categories = {"RRR-furnace-recipes"},
					energy_required = 100000000,
					hidden = true,
					ingredients = {{type = "item", name = item.name, amount = 1}},
					results = {{type="item", name=item.burnt_result, amount=1}},
					allow_productivity = true
				}
			}
		end
	end
end

