--BLUE_BACKGROUND = {icon_size = 32, icon = MOD_PATH.."/graphics/icons/dark/signal_blue.png"}
--RED_BACKGROUND = {icon_size = 32, icon = MOD_PATH.."/graphics/icons/dark/signal_red_background.png"}
--GREEN_BACKGROUND = {icon_size = 32, icon = MOD_PATH.."/graphics/icons/dark/signal_green_background.png"       }
--YELLOW_BACKGROUND = {icon_size = 32, icon = MOD_PATH.."/graphics/icons/dark/signal_yellow_background.png"}
--GREY_BACKGROUND = {icon_size = 32, icon = MOD_PATH.."/graphics/icons/dark/signal_grey_background.png"}
--ORANGE_BACKGROUND = {icon_size = 32, icon = MOD_PATH.."/graphics/icons/dark/signal_orange_background.png"}
local r = nil--{icon_size = 64, icon = MOD_PATH.."/graphics/icons/radioactive-special2.png"}
BLUE_BACKGROUND,RED_BACKGROUND,GREEN_BACKGROUND,YELLOW_BACKGROUND,GREY_BACKGROUND,ORANGE_BACKGROUND = r,r,r,r,r,r
ext={
{
	type = "item-subgroup",
	name = "RRR-reactor-signals",
	group = "signals",
	order = "f"
},
-- signal-reactor-core-temp
{
	type = "virtual-signal",
	name = "signal-reactor-core-temp",
	icons =
	{
	  BLUE_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/signal_core_temp.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-a"
},

--signal-reactor-power-output
{
	type = "virtual-signal",
	name = "signal-reactor-power-output",
	icons =
	{
	 BLUE_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/signal_reactor_power_output.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-b"
},

--signal-reactor-electric-power
{
	type = "virtual-signal",
	name = "signal-reactor-electric-power",
	icons =
	{
	 BLUE_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/signal_reactor_electric_power.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-d"
},

-- signal-reactor-efficiency
{
	type = "virtual-signal",
	name = "signal-reactor-efficiency",
	icons =
	{
	 BLUE_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/signal_reactor_efficiency.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-c"
},

-- signal-breeder_cell-bonus
{
	type = "virtual-signal",
	name = "signal-reactor-cell-bonus",
	icons =
	{
	 BLUE_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/signal_cell_bonus.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-d"
},

-- signal-coolant-amount"
{
	type = "virtual-signal",
	name = "signal-cooling",
	icons =
	{
	 BLUE_BACKGROUND,
	  {icon_size = 176, icon = MOD_PATH.."/graphics/icons/cooling.png"}
	},
	icon_size = 176,
	subgroup = "RRR-reactor-signals",
	order = "a-e"
},

-- signal-state-stopped
{
	type = "virtual-signal",
	name = "signal-state-stopped",
	icons =
	{
	 GREY_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/black.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-f"
},

-- signal-state-starting
{
	type = "virtual-signal",
	name = "signal-state-starting",
	icons =
	{
	 YELLOW_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/yellow.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-g"
},

-- signal-state-running
{
	type = "virtual-signal",
	name = "signal-state-running",
	icons =
	{
	 GREEN_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/green.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-h"
},

-- signal-state-scramed
{
	type = "virtual-signal",
	name = "signal-state-scramed",
	icons =
	{
	 RED_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/red.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-i"
},

-- -- signal-uranium-fuel-cells
-- {
	-- type = "virtual-signal",
	-- name = "signal-uranium-fuel-cells",
	-- icons =
	-- {
	  --BLUE_BACKGROUND,
	  -- {icon_size = 32, icon = "__base__/graphics/icons/uranium-fuel-cell.png"}
	-- },
	-- icon_size = 32,
	-- subgroup = "RRR-reactor-signals",
	-- order = "a-j"
-- },

-- -- signal-used-uranium-fuel-cells
-- {
	-- type = "virtual-signal",
	-- name = "signal-used-uranium-fuel-cells",
	-- icons =
	-- {
	  --BLUE_BACKGROUND,
	  -- {icon_size = 32, icon = "__base__/graphics/icons/used-up-uranium-fuel-cell.png"}
	-- },
	-- icon_size = 32,
	-- subgroup = "RRR-reactor-signals",
	-- order = "a-k"
-- },

-- signal-control-start
{
	type = "virtual-signal",
	name = "signal-control-start",
	icons =
	{
	 ORANGE_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/signal_control_start.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "b-a"
},

-- signal-control-scram
{
	type = "virtual-signal",
	name = "signal-control-scram",
	icons =
	{
	 ORANGE_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/signal_control_scram.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "b-c"
},

{
	type = "virtual-signal",
	name = "signal-neighbour-bonus",
	icons =
	{
	 BLUE_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/neighbours.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-f"
},

{
	type = "virtual-signal",
	name = "signal-controlrods-current",
	icons =
	{
	 BLUE_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/control_rods.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-y"
},
{
	type = "virtual-signal",
	name = "signal-controlrods-target",
	icons =
	{
	 BLUE_BACKGROUND,
	  {icon_size = 32, icon = MOD_PATH.."/graphics/icons/signal_state.png"}
	},
	icon_size = 32,
	subgroup = "RRR-reactor-signals",
	order = "a-z"
},

}
for _, prototype in pairs(ext) do
	if prototype.icons and prototype.icons[1] == nil then
		table.remove(prototype.icons,1)
	end
end


data:extend(ext)