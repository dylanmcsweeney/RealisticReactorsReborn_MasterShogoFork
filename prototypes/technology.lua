data:extend({
  {
    type = "technology",
    name = "RRR-breeder-reactors",
    icon = MOD_PATH.."/graphics/technology/breeder-reactors.png",
    icon_size = 128,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "RRR-breeder-reactor"
      }
    },
    prerequisites = {"nuclear-power", "productivity-module-3"},
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
		{"military-science-pack", 1},
		{"production-science-pack", 1},
		{"utility-science-pack", 1}
      },
      time = 30,
      count = 800
    },
    order = "a-h-d"
  },
  {
    type = "technology",
    name = "RRR-control-rods",
    icon = MOD_PATH.."/graphics/technology/Control_rods_schematic.png",
    icon_size = 256,
    effects =
    {{
		type = "nothing",
		effect_description = {"modifier-description.RRR-control-rods"},
	},
    },
    prerequisites = {"nuclear-power"},
    unit =
    {
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
		{"production-science-pack", 1},
      },
      time = 15,
      count = 300
    },
    order = "a-h-d"
  }
})

-- insert recipes in technology
  table.insert(data.raw["technology"]["nuclear-power"].effects, {type = "unlock-recipe", recipe = "RRR-realistic-reactor"})
  table.insert(data.raw["technology"]["nuclear-power"].effects, {type = "unlock-recipe", recipe = "RRR-cooling-tower"})
  if settings.startup["RRR-meltdown-mode"].value == "meltdown with ruin + sarcophagus" then
	table.insert(data.raw["technology"]["nuclear-power"].effects, {type = "unlock-recipe", recipe = "RRR-reactor-sarcophagus"})
  end

