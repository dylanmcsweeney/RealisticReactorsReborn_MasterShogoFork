local function mult_color (col,mult)
	local ret = {}
	for c, v in pairs(col) do 
		ret[c] = v*mult
	end
	return ret
end

local colors = {
"r" ,
"y" ,
"b" ,
"a" ,
"ry" ,
"rb" ,
"ra" ,
"yb" ,
"ya" ,
"ba" ,
"rya",
"ryb" ,
"rba" ,
"yba" ,
"ryba" }

for _, color in pairs(colors) do

data:extend({ 
			{
      type="sprite",
      name="RRR-"..color,
      filename = MOD_PATH.."/graphics/sprites/"..color..".png",
      priority = "extra-high",
      width = 1,
      height = 1,
	}})
	
end
	
	
data:extend({ 
	{
		type = "font",
		name = "RRR-small-bold",
		from = "default-bold",
		size = 9,
	},
	{
      type="sprite",
      name="RRR-black",
      filename = MOD_PATH.."/graphics/sprites/black.png",
      priority = "extra-high",
      width = 1,
      height = 1,
	},
	{
      type="sprite",
      name="RRR-black-background",
      filename = MOD_PATH.."/graphics/black192x101.png",
      priority = "extra-high",
      width = 192,
      height = 101,
	  flags = {"linear-magnification"},
	},
	{
      type="sprite",
      name="RRR-button-x",
      filename = MOD_PATH.."/graphics/sprites/button_x.png",
      priority = "extra-high",
      width = 64,
      height = 64,
	  flags = {"linear-minification","linear-magnification","no-crop"}
	},
	{
      type="sprite",
      name="RRR-button-graph",
      filename = MOD_PATH.."/graphics/sprites/button_graph.png",
      priority = "extra-high",
      width = 64,
      height = 64,
	},
	{
      type="sprite",
      name="RRR-button-graph-off",
      filename = MOD_PATH.."/graphics/sprites/button_graph_off.png",
      priority = "extra-high",
      width = 64,
      height = 64,
	},
	{
      type="sprite",
      name="RRR-button-signals",
      filename = MOD_PATH.."/graphics/sprites/button_signals.png",
      priority = "extra-high",
      width = 64,
      height = 64,
	},
	{
      type="sprite",
      name="RRR-button-signals-off",
      filename = MOD_PATH.."/graphics/sprites/button_signals_off.png",
      priority = "extra-high",
      width = 64,
      height = 64,
	},
	{
      type="sprite",
      name="RRR-button-progress",
      filename = MOD_PATH.."/graphics/sprites/button_progress.png",
      priority = "extra-high",
      width = 64,
      height = 64,
	},
	{
      type="sprite",
      name="RRR-button-progress-off",
      filename = MOD_PATH.."/graphics/sprites/button_progress_off.png",
      priority = "extra-high",
      width = 64,
      height = 64,
	},
{
      type="sprite",
      name="RRR-button-control",
      filename = MOD_PATH.."/graphics/sprites/button_control.png",
      priority = "extra-high",
      width = 64,
      height = 64,
	},
	{
      type="sprite",
      name="RRR-button-control-off",
      filename = MOD_PATH.."/graphics/sprites/button_control_off.png",
      priority = "extra-high",
      width = 64,
      height = 64,
	},		
	{
      type="sprite",
      name="RRR-bonuscell-sprite",
      filename = MOD_PATH.."/graphics/icons/bonuscell_sprite.png",
      priority = "extra-high",
      width = 32,
      height = 32,
	},
	{
      type="sprite",
      name="RRR-transparent-sprite",
      filename = MOD_PATH.."/graphics/transparent32.png",
      priority = "extra-high",
      width = 32,
      height = 32,
	},
	{
      type="sprite",
      name="RRR-mini-sprite",
      filename = "__core__/graphics/empty.png",
      priority = "high",
      width = 1,
      height = 1,
	},
	{
      type="sprite",
      name="RRR-selection_box",
      filename = MOD_PATH.."/graphics/sprites/box.png",
      priority = "high",
      width = 272,
      height = 340,
	  draw_as_glow = true,
	},
})

data.raw["gui-style"].default["RRR-button"] = {
	  name = "RRR-button",
      type = "button_style",
      parent = "image_tab_slot",
      scalable = false,
      width = 25,
      height = 25,
	  padding = 0,
      default_graphical_set = {

			filename = "__core__/graphics/gui.png",
			priority = "extra-high-no-scale",
			width = 36,
			height = 36,
			x = 111,
			y = 144,
			tint = {0.8,0.8,0.8}
	  },  
	  
      hovered_graphical_set =  {

			filename = "__core__/graphics/gui.png",
			priority = "extra-high-no-scale",
			width = 36,
			height = 36,
			x = 148,
			y = 144,
			tint = {0.8,0.8,0.8}
	  }	,
	  
      clicked_graphical_set = {

			filename = "__core__/graphics/gui.png",
			priority = "extra-high-no-scale",
			width = 36,
			height = 36,
			x = 111,
			y = 0,
			tint = {0.8,0.8,0.8}
	  }
    }
	
local red_tint = {r=1,g=0.9,b=0.9}
local blue_tint = {r=0.875,g=0.925,b=1}

local dark_mult = 0.75

local dark_red_tint =  mult_color(red_tint, dark_mult)
local dark_blue_tint = mult_color(blue_tint, dark_mult)

data.raw["gui-style"].default["RRR-button-red"] = table.deepcopy(data.raw["gui-style"].default["RRR-button"])
data.raw["gui-style"].default["RRR-button-red"].default_graphical_set.tint = dark_red_tint

data.raw["gui-style"].default["RRR-button-blue"] = table.deepcopy(data.raw["gui-style"].default["RRR-button"])
data.raw["gui-style"].default["RRR-button-blue"].default_graphical_set.tint = dark_blue_tint

data.raw["gui-style"].default["RRR-progressbar-red"] = {
	type = "progressbar_style",
	parent = "progressbar",
	bar_background =
      {
        base = {position = {296, 48}, corner_size = 8, tint = red_tint},
        shadow = default_dirt
      },
}
data.raw["gui-style"].default["RRR-progressbar-blue"] = {
	type = "progressbar_style",
	parent = "progressbar",
	bar_background =
      {
        base = {position = {296, 48}, corner_size = 8, tint = blue_tint},
        shadow = default_dirt
      },
}

data.raw["gui-style"].default["RRR-progressbar-void"] = {
	type = "progressbar_style",
	parent = "progressbar",
	bar_background =
      {
        base = {position = {0, 0}, corner_size = 1, tint = {0,0,0,0}},
        shadow = {position = {0, 0}, corner_size = 1, tint = {0,0,0,0}},
        glow = {position = {0, 0}, corner_size = 1, tint = {0,0,0,0}},
      },
	  bar =
      {
        base = {position = {313, 48}, corner_size = 8, 
				left = {position = {313+8, 48+8}, size = {1, 1}}, 
				right = {position = {313+8, 48+8}, size = {1, 1}},
				left_top  = {position = {313+8, 48}, size = {1, 8}},
				right_top  = {position = {313+8, 48}, size = {1, 8}},
				left_bottom  = {position = {313+8, 48+9}, size = {1, 8}},
				right_bottom  = {position = {313+8, 48+9}, size = {1, 8}},
		},
        shadow = {position = {0, 0}, corner_size = 1, tint = {0,0,0,0}},
        glow = {position = {0, 0}, corner_size = 1, tint = {0,0,0,0}},
      },
}

data.raw["gui-style"].default["RRR-slider"] = 
    {
      type = "slider_style",
      parent = "map_generator_notched_slider",
      notch =
      {
        base = {position = {138, 200}, size = {1, 1},tint = {r=0,g=0,b=0,a=0},},
        shadow ={}
      },
	  full_bar =
      {
        base = {position = {73, 72},size = {1, 1}, corner_size = 1,tint = {r=0,g=0,b=0,a=0}},
        shadow = {}
      },
      full_bar_disabled =
      {
        base = {position = {90, 72}, size = {1, 1},corner_size = 1,tint = {r=0,g=0,b=0,a=0}},
        shadow = {}
      },
      empty_bar =
      {
        base =
        {
          left = {position = {56, 72}, size = {1, 1},tint = {r=0,g=0,b=0,a=0}},
          right = {position = {65, 72}, size = {1, 1},tint = {r=0,g=0,b=0,a=0}},
          center = {position = {64, 72}, size = {1, 1},tint = {r=0,g=0,b=0,a=0}}
        },
        shadow = {}
      },
    }
data.raw["gui-style"].default["RRR-textbox"] =
    {
      type = "textbox_style",
      parent = "textbox",
      default_background =
      {
        type = "none",
        opacity = 0
      },
      font_color = gui_color.white,
      maximal_width = 500,
      minimal_width = 0,
      padding = 0,
      minimal_height = 0,
	  active_background =
      {
        type = "none",
        opacity = 0
      },
    }
	
	
data.raw["gui-style"].default["RRR-frame-blue"] =
    {
      type = "frame_style",
	  parent = "frame",
	  graphical_set =
      {
        base = {position = {0, 0}, corner_size = 8, tint = blue_tint},
        shadow = default_shadow
      },
    }
data.raw["gui-style"].default["RRR-frame-red"] =
    {
      type = "frame_style",
	  parent = "frame",
	  graphical_set =
      {
        base = {position = {0, 0}, corner_size = 8,tint = red_tint},
        shadow = default_shadow
      },
    }
data.raw["gui-style"].default["RRR-slot_button-blue"] =
    {
      type = "button_style",
	  parent = "slot_button",
	  default_graphical_set =
      {
        base = {border = 4, position = {0, 736}, size = 80, tint = {r=0.8,g=0.9,b=1}},
        shadow = offset_by_2_rounded_corners_glow(default_dirt_color)
      },
    }
data.raw["gui-style"].default["RRR-slot_button-blue"].default_graphical_set.base.tint = mult_color(blue_tint,0.95)
data.raw["gui-style"].default["RRR-slot_button-blue"].default_graphical_set.base.tint.a = 0.88

data.raw["gui-style"].default["RRR-shallow_slot_button-blue"] =
    {
      type = "button_style",
	  parent = "slot_button",
	  default_graphical_set =
      {
        base = {border = 4, position = {0, 736}, size = 80, tint = {r=0.8,g=0.9,b=1}},
        shadow = offset_by_2_rounded_corners_glow(default_dirt_color)
      },
    }
data.raw["gui-style"].default["RRR-shallow_slot_button-blue"].default_graphical_set.base.tint = mult_color(blue_tint,0.75)
data.raw["gui-style"].default["RRR-shallow_slot_button-blue"].default_graphical_set.base.tint.a = 0.81



data.raw["gui-style"].default["RRR-slot_button-red"] =
    {
      type = "button_style",
	  parent = "slot_button",
	  default_graphical_set =
      {
        base = {border = 4, position = {0, 736}, size = 80, tint = {r=1,g=0.85,b=0.85}},
        shadow = offset_by_2_rounded_corners_glow(default_dirt_color)
      },
    }
data.raw["gui-style"].default["RRR-slot_button-red"].default_graphical_set.base.tint = mult_color(red_tint,0.95)
data.raw["gui-style"].default["RRR-slot_button-red"].default_graphical_set.base.tint.a = 0.88

data.raw["gui-style"].default["RRR-shallow_slot_button-red"] =
    {
      type = "button_style",
	  parent = "slot_button",
	  default_graphical_set =
      {
        base = {border = 4, position = {0, 736}, size = 80, tint = {r=1,g=0.85,b=0.85}},
        shadow = offset_by_2_rounded_corners_glow(default_dirt_color)
      },
    }
data.raw["gui-style"].default["RRR-shallow_slot_button-red"].default_graphical_set.base.tint = mult_color(red_tint,0.75)
data.raw["gui-style"].default["RRR-shallow_slot_button-red"].default_graphical_set.base.tint.a = 0.81

-----------------
local darken_glow = 0.9
data.raw["gui-style"].default["RRR-slot_button-blue-start"] = table.deepcopy(data.raw["gui-style"].default["RRR-slot_button-blue"])
data.raw["gui-style"].default["RRR-slot_button-blue-start"].height = 32
data.raw["gui-style"].default["RRR-slot_button-blue-start"].width = 32
data.raw["gui-style"].default["RRR-slot_button-blue-start"].hovered_graphical_set = { base = {border = 4, position = {80, 736}, size = 80, tint = mult_color({r=0,g=1,b=0},darken_glow)}, glow = offset_by_2_rounded_corners_glow(green_slot_glow_color)}
data.raw["gui-style"].default["RRR-slot_button-blue-start"].clicked_graphical_set = { base = {border = 4, position = {80, 736}, size = 80, tint = mult_color({r=0.5,g=1,b=0.5,a=0.33},darken_glow)}, glow = offset_by_2_rounded_corners_glow(green_slot_glow_color)}
--hovered_graphical_set =
--      {
--        base = {border = 4, position = {320, 656}, size = 80},
--        shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
--        glow = offset_by_2_rounded_corners_glow(green_slot_glow_color)
--      }--green_slot_glow_color = {34, 255, 75, 128}
	  
data.raw["gui-style"].default["RRR-slot_button-red-start"] = table.deepcopy(data.raw["gui-style"].default["RRR-slot_button-red"])
data.raw["gui-style"].default["RRR-slot_button-red-start"].height = 32
data.raw["gui-style"].default["RRR-slot_button-red-start"].width = 32
data.raw["gui-style"].default["RRR-slot_button-red-start"].hovered_graphical_set = { base = {border = 4, position = {80, 736}, size = 80, tint = mult_color({r=0,g=1,b=0},darken_glow)}, glow = offset_by_2_rounded_corners_glow(green_slot_glow_color)}
data.raw["gui-style"].default["RRR-slot_button-red-start"].clicked_graphical_set = { base = {border = 4, position = {80, 736}, size = 80, tint = mult_color({r=0.5,g=1,b=0.5,a=0.33},darken_glow)}, glow = offset_by_2_rounded_corners_glow(green_slot_glow_color)}



--hovered_graphical_set =
--      {
--        base = {border = 4, position = {320, 656}, size = 80},
--        shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
--        glow = offset_by_2_rounded_corners_glow(green_slot_glow_color)
--      }--green_slot_glow_color = {34, 255, 75, 128}
--hovered_graphical_set = { base = {border = 4, position = {504, 216}, size = 80}},
--      clicked_graphical_set = { base = {border = 4, position = {504, 296}, size = 80}}
---------------------------------------------------------------------

data.raw["gui-style"].default["RRR-slot_button-blue-stop"] = table.deepcopy(data.raw["gui-style"].default["RRR-slot_button-blue"])
data.raw["gui-style"].default["RRR-slot_button-blue-stop"].height = 32
data.raw["gui-style"].default["RRR-slot_button-blue-stop"].width = 32
data.raw["gui-style"].default["RRR-slot_button-blue-stop"].hovered_graphical_set = { base = {border = 4, position = {80, 736}, size = 80, tint = mult_color({r=1,g=0.5,b=0},darken_glow)}, glow = offset_by_2_rounded_corners_glow(red_slot_glow_color)}
data.raw["gui-style"].default["RRR-slot_button-blue-stop"].clicked_graphical_set = { base = {border = 4, position = {80, 736}, size = 80, tint = mult_color({r=1,g=0.6,b=0.5,a=0.33},darken_glow)}, glow = offset_by_2_rounded_corners_glow(red_slot_glow_color)}
--data.raw["gui-style"].default["RRR-slot_button-blue-stop"].hovered_graphical_set =
--      {
--        base = {border = 4, position = {320, 656}, size = 80},
--        shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
--        glow = offset_by_2_rounded_corners_glow(red_slot_glow_color)
--      }--green_slot_glow_color = {34, 255, 75, 128}
	  
data.raw["gui-style"].default["RRR-slot_button-red-stop"] = table.deepcopy(data.raw["gui-style"].default["RRR-slot_button-red"])
data.raw["gui-style"].default["RRR-slot_button-red-stop"].height = 32
data.raw["gui-style"].default["RRR-slot_button-red-stop"].width = 32
data.raw["gui-style"].default["RRR-slot_button-red-stop"].hovered_graphical_set = { base = {border = 4, position = {80, 736}, size = 80, tint = mult_color({r=1,g=0.5,b=0},darken_glow)}, glow = offset_by_2_rounded_corners_glow(red_slot_glow_color)}
data.raw["gui-style"].default["RRR-slot_button-red-stop"].clicked_graphical_set = { base = {border = 4, position = {80, 736}, size = 80, tint = mult_color({r=1,g=0.6,b=0.5,a=0.33},darken_glow)}, glow = offset_by_2_rounded_corners_glow(red_slot_glow_color)}
--data.raw["gui-style"].default["RRR-slot_button-red-stop"].hovered_graphical_set =
--      {
--        base = {border = 4, position = {320, 656}, size = 80},
--        shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
--        glow = offset_by_2_rounded_corners_glow(red_slot_glow_color)
--      }--green_slot_glow_color = {34, 255, 75, 128}

---------------------------------------------------------------------

data.raw["gui-style"].default["RRR-slot_button-blue-nil"] = table.deepcopy(data.raw["gui-style"].default["RRR-slot_button-blue"])
data.raw["gui-style"].default["RRR-slot_button-blue-nil"].height = 32
data.raw["gui-style"].default["RRR-slot_button-blue-nil"].width = 32
data.raw["gui-style"].default["RRR-slot_button-blue-nil"].hovered_graphical_set = data.raw["gui-style"].default["RRR-slot_button-blue-nil"].default_graphical_set
data.raw["gui-style"].default["RRR-slot_button-blue-nil"].clicked_graphical_set = data.raw["gui-style"].default["RRR-slot_button-blue-nil"].default_graphical_set



data.raw["gui-style"].default["RRR-slot_button-red-nil"] = table.deepcopy(data.raw["gui-style"].default["RRR-slot_button-red"])
data.raw["gui-style"].default["RRR-slot_button-red-nil"].height = 32
data.raw["gui-style"].default["RRR-slot_button-red-nil"].width = 32
data.raw["gui-style"].default["RRR-slot_button-red-nil"].hovered_graphical_set = data.raw["gui-style"].default["RRR-slot_button-red-nil"].default_graphical_set
data.raw["gui-style"].default["RRR-slot_button-red-nil"].clicked_graphical_set = data.raw["gui-style"].default["RRR-slot_button-red-nil"].default_graphical_set