
  -- sarcophagus
if settings.startup["RRR-meltdown-mode"].value == "meltdown with ruin + sarcophagus" then
	data:extend({{
    type = "recipe",
    name = "RRR-reactor-sarcophagus",
    enabled = false,
    energy_required = 100,
    ingredients =
    {
      {type = "item", name = "concrete", amount = 1000},
      {type = "item", name = "steel-plate", amount = 600},
      {type = "item", name = "pipe", amount = 50},
      {type = "item", name = "pump", amount = 10},
	  {type = "item", name = "advanced-circuit", amount = 100}
    },
    results = { {type = "item", name = "RRR-reactor-sarcophagus", amount = 1}}
  }})
end

data:extend({
	
  {
    type = "recipe-category",
    name = "steaming"
  },
  {
    type = "recipe-category",
    name = "water-cooling"
  },
  
  
  -- ITEM RECIPIES --
  --
 -- Nuclear Reactor
  {
	
    type = "recipe",
    name = "RRR-realistic-reactor",
    enabled = false,
    energy_required = 20,
    ingredients =
    {
      {type = "item", name = "concrete",  amount = 500},
      {type = "item", name = "steel-plate",  amount = 500},
      {type = "item", name = "advanced-circuit",  amount = 500},
      {type = "item", name = "copper-plate",  amount = 500},
	  {type = "item", name = "efficiency-module-2",  amount = 3}
    },
    results = {{type = "item", name = "RRR-realistic-reactor", amount = 1}}
  },
  -- Breeder Reactor
  {
    type = "recipe",
    name = "RRR-breeder-reactor",
    enabled = false,
    energy_required = 20,
    ingredients =
    {
      {type = "item", name = "concrete", amount = 500},
      {type = "item", name = "steel-plate", amount = 500},
      {type = "item", name = "advanced-circuit", amount = 500},
      {type = "item", name = "copper-plate", amount = 500},
	  {type = "item", name = "productivity-module-3", amount = 3}
    },
    results = {{type = "item", name = "RRR-breeder-reactor", amount = 1}}
  },
 
 -- Cooling Tower
  {
    type = "recipe",
    name = "RRR-cooling-tower",
    enabled = false,
    energy_required = 20,
    ingredients =
    {
      {type = "item", name = "concrete", amount = 200},
      {type = "item", name = "steel-plate", amount = 100},
      {type = "item", name = "pipe", amount = 100},
      {type = "item", name = "pump", amount = 10}
    },
    results = {{type = "item", name = "RRR-cooling-tower", amount = 1}}
  },
  

  
  -- OTHER RECIPIES
  --
  
  -- Cooling tower water cooling recipe
  {
    type = "recipe",
    name = "RRR-water-cooling",
    categories = {"water-cooling"},
    enabled = true,
    hidden = true,
    energy_required = 0.5,
    ingredients =
    {
      {type="fluid", name="water", amount=500}
    },
    results =
    {
      {type="fluid", name="water", amount=480}
    },
    icon = "__base__/graphics/icons/fluid/water.png",
	icon_size = 64,
    subgroup = "fluid-recipes",
    order = "z"
  },
   {
    type = "recipe",
    name = "RRR-steam-cooling",
    categories = {"water-cooling"},
    enabled = true,
    hidden = true,
    energy_required = 0.7,
    ingredients =
    {
      {type="fluid", name="steam", amount=300}
    },
    results =
    {
      {type="fluid", name="water", amount=25}
    },
    icon = "__base__/graphics/icons/fluid/water.png",
	icon_size = 64,
    subgroup = "fluid-recipes",
    order = "z"
  },
 -- Cooling tower steam dummy recipe
  {
    type = "recipe",
    name = "RRR-cooling-tower-steam",
    categories = {"steaming"},
    enabled = true,
    hidden = true,
    energy_required = 600,
    ingredients =
    {
      {type="fluid", name="water", amount=0.1}
    },
    results =
    {
      {type="fluid", name="water", amount=0}
    },
    icon = "__base__/graphics/icons/fluid/water.png",
	icon_size = 64,
    subgroup = "fluid-recipes",
    order = "z"
  }
  
  })
