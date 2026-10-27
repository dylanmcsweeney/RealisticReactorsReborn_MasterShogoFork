data:extend({
	{
	type = "item",
	name = "RRR-dummy-fuel-cell",
	localised_name = "Dummy fuel cell (RRR)",
	flags = {"hide-from-bonus-gui","hide-from-fuel-tooltip"},
	hidden = true,
	icon = MOD_PATH.."/graphics/icons/infinite-fuel-cell.png",
	icon_size = 64,
	subgroup = "intermediate-product",
	order = "r[uranium-processing]-a[uranium-fuel-cell]",
	fuel_categories = {"nuclear"},
	burnt_result = "RRR-dummy-fuel-cell",
	fuel_value = "9223372035GJ",
	stack_size = 50
	},
  --Nuclear Reactor
  {
    type = "item",
    name = "RRR-realistic-reactor",
    icon = MOD_PATH.."/graphics/icons/nuclear-reactor.png",
	--icon  = "__base__/graphics/icons/nuclear-reactor.png",
	icon_size = 32,
   -- flags = {"goes-to-quickbar"},
    subgroup = "energy",
    order = "f[nuclear-energy]-a[reactor]r",
    place_result = "RRR-realistic-reactor",
	weight = 1 * tons,
    stack_size = 10
  },
  --ruin
--  {
--    type = "item",
--    name = "RRR-reactor-ruin",
--    icon = MOD_PATH.."/graphics/icons/nuclear-reactor.png",
--	--icon  = "__base__/graphics/icons/nuclear-reactor.png",
--	icon_size = 32,
--   -- flags = {"goes-to-quickbar"},
--    subgroup = "energy",
--    order = "f[nuclear-energy]-a[reactor]",
--    place_result = "RRR-reactor-ruin",
--    stack_size = 10
--  },
  --Breeder Reactor
    {
    type = "item",
    name = "RRR-breeder-reactor",
    icon = MOD_PATH.."/graphics/icons/breeder-reactor.png",
	--icon  = "__base__/graphics/icons/nuclear-reactor.png",
	icon_size = 32,
   -- flags = {"goes-to-quickbar"},
    subgroup = "energy",
    order = "f[nuclear-energy]-a[reactor]b",
    place_result = "RRR-breeder-reactor",
	weight = 1 * tons,
    stack_size = 10
  },
  -- Cooling Tower
  {
    type = "item",
    name = "RRR-cooling-tower",
    icon = MOD_PATH.."/graphics/icons/cooling-tower.png",
	icon_size = 32,
   -- flags = {"goes-to-quickbar"},
    subgroup = "energy",
    order = "b[steam-power]-d[cooling-tower]",
    place_result = "RRR-cooling-tower",
	weight = 0.5 * tons,
    stack_size = 10
  },
    -- sarcophagus
  {
    type = "item",
    name = "RRR-reactor-sarcophagus",
    icon = MOD_PATH.."/graphics/icons/sarcophagus2.png",
	icon_size = 32,
   -- flags = {"goes-to-quickbar"},
    subgroup = "energy",
    order = "f[nuclear-energy]-a[reactor]z",
    place_result = "RRR-reactor-sarcophagus",
	weight = 1 * tons,
    stack_size = 1
  }
 })