if data.raw.recipe["mixed-oxide"] and data.raw.recipe["mixed-oxide"].icon == "__Clowns-Nuclear__/graphics/icons/nuclear-fuel-mixed-oxide.png" then
	data:extend({{
    type = "item",
    name = "RRR-clowns-mox-cell",
    icon = MOD_PATH.."/graphics/icons/mox_fuel_cell.png",
    icon_size = 32,
    --flags = {"goes-to-main-inventory"},
    subgroup = "intermediate-product",
    order = "r[uranium-processing]-a[uranium-fuel-cell]",
    fuel_categories = {"nuclear"},
    burnt_result = "depleted-uranium-fuel-cell",
    fuel_value = "7GJ",
    stack_size = 50
  }})


	data.raw.recipe["mixed-oxide"].icon = MOD_PATH.."/graphics/icons/clowns_mox_recipe.png"
	data.raw.recipe["mixed-oxide"].results[1].name="RRR-clowns-mox-cell"

end

if data.raw.recipe["MOX-fuel-reprocessing"] and data.raw.recipe["MOX-fuel-reprocessing"].results  and data.raw.recipe["MOX-fuel-reprocessing"].results[2] and data.raw.recipe["MOX-fuel-reprocessing"].results[2].amount >3 then
	data.raw.recipe["MOX-fuel-reprocessing"].results[2].amount = 3

end