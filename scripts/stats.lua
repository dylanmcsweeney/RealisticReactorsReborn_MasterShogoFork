--copyright ownlyme, written for realistic reactors (free to use/distribute/edit/build upon as a module of this mod or other mods by ingoknieto)



COLUMN_COUNT = 75 -- reducing this requires a data wipe, increasing just closed windows
AQUA_EXTRA_DATA = 10
PIXEL_WIDTH = 2
FONT_SIZE = 12
GRAPH_HEIGHT = 101

function gui_init()
storage.worker_key = nil
storage.gui_count = 0
storage.stats = {}
storage.guis = {}
end


table.insert(on_tick_tasks,{ name = "iterate_overlays", performance_hit = 1.5, reactor_scaling = 1, ticks_per_update = 30, func = function(event)
	local mode = storage.settings["RRR-overlay-text-mode"]
	if mode ~= "never" and storage.settings["RRR-overlay-text"] ~= "reactor name" then
		if not storage.iterate_overlays or not storage.reactors[storage.iterate_overlays] then
			storage.iterate_overlays = next(storage.reactors)
		else
			storage.iterate_overlays = next(storage.reactors,storage.iterate_overlays)
		end
		if not storage.iterate_overlays then
			storage.iterate_overlays = next(storage.reactors)
		end
		if storage.iterate_overlays then
			local update_text = false
			if mode == "on hover" then
				for pid, rid in pairs(storage.player_selections) do
					if rid == storage.iterate_overlays then
						update_text = true
					end
				end
			elseif mode == "in alt overlay" then
				for pid, rid in pairs(storage.player_selections) do
					if rid == -1 then
						update_text = true
					end
				end
			else
				update_text = true
			end
			if update_text then
				
				local reactor = storage.reactors[storage.iterate_overlays]
				if reactor.state == 0 and mode ~= "on hover" then
					--reactor.name_render.text = ""
				else
					if storage.settings["RRR-overlay-text"] ==  "temperature + rod coloring" then
						if reactor.signals["core_temperature"].count >= 991+reactor.quality*10 then
							reactor.name_render.text = string.format("!!!! %.1f !!!!", reactor.signals["core_temperature"].count)
						else
							reactor.name_render.text = string.format("%.1f", reactor.signals["core_temperature"].count)
						end
						--reactor.name_render.color = {r=1,g=math.max(0,1-(reactor.control_current-1)/500),b=math.max(0,math.min(1,(reactor.control_current-500)/600))}
						if reactor.control_current >0 then
							reactor.name_render.color={r=1,g=math.max(0,1-1*(reactor.control_current)/50),b=math.max(0,math.min(1,(reactor.control_current-50)/60))}
						else
							if reactor.control_current < -50 then
								reactor.name_render.color={r=math.min(1,(-reactor.control_current-50)/50),g=1,b=math.min(1,(-reactor.control_current-50)/50)}
							else
								reactor.name_render.color={r=math.max(0,1+reactor.control_current/50),g=math.min(1,0.9-0.1*reactor.control_current/10),b=0}
							end
						end
					else
						reactor.name_render.text = string.format("%.1f", reactor.signals["core_temperature"].count)
						reactor.name_render.color={r=1,g=math.min(1,math.max(0,1-1*(reactor.signals["core_temperature"].count-800)/200)),b=math.max(0,math.min(1,(reactor.signals["core_temperature"].count-1000)/300))}
					end
					
				end
			end
		end
	end
end})

function stats_tick(event)
	if event.tick% (TICKS_PER_UPDATE*2) == 0 then
		--if not storage.stats[reactor_key] then storage.stats[reactor_key] = {efficiency = {},production = {},temperature = {}, aqua = {}} end
		for reactor_key, stats in pairs (storage.stats) do
			if not storage.reactors[reactor_key] then
				storage.stats[reactor_key]=nil
			else
				signals = storage.reactors[reactor_key].signals
				if storage.reactors[reactor_key].power_usage.interface >1 then
					stats.temperature[COLUMN_COUNT] = math.min(100,math.max(1,math.floor((signals["core_temperature"].count or 1)/10)))
					stats.efficiency[COLUMN_COUNT] = math.min(100,math.max(1,math.floor((signals["efficiency"].count or 1)/math.max(1,storage.reactors[reactor_key].max_efficiency)*100)))
					
					stats.production[COLUMN_COUNT] =(signals["power-output"].count or 1)		--math.min(100,math.max(1,
					stats.aqua[COLUMN_COUNT+AQUA_EXTRA_DATA] =	storage.reactors[reactor_key].cooling_history*60/TICKS_PER_UPDATE/2
					storage.reactors[reactor_key].cooling_history = 0
				else
					stats.efficiency[COLUMN_COUNT] = -1
					stats.production[COLUMN_COUNT] = -1
					stats.temperature[COLUMN_COUNT] =-1
					stats.aqua[COLUMN_COUNT] =-1
					
				end
				--local cooling = 0
				--for i=1,math.floor(1/(TICKS_PER_UPDATE/30)) do
				--	cooling = cooling + storage.reactors[reactor_key].cooling_history[i]
				--end
				--stats.aqua[COLUMN_COUNT] = math.floor(cooling / math.floor(1/(TICKS_PER_UPDATE/30))/2)
				
				--game.players[1].print(stats.aqua[COLUMN_COUNT])
				for k=1,COLUMN_COUNT-1 do
					stats.efficiency[k] = stats.efficiency[k+1]
					stats.production[k] = stats.production[k+1]
					stats.temperature[k] = stats.temperature[k+1]
					stats.aqua[k]=stats.aqua[k+1]
				end
				for k=COLUMN_COUNT-1, COLUMN_COUNT-1+AQUA_EXTRA_DATA do
					stats.aqua[k]=stats.aqua[k+1]
				end
				local maxpower = {tablemax(stats.production), tablemax_aqua(stats.aqua),storage.reactors[reactor_key].max_power}
				stats.max = math.max(90,tablemax(maxpower))
				
			end
		end
	end
	if event.tick % TICKS_PER_UPDATE == 0 then
		for key, tbl in pairs (storage.guis) do
			local gui = tbl.gui
			local player = game.players[gui.player_index]
			if player and player.valid and tbl.text then
				local pos = 0
				for _, elem in pairs(player.gui.left.children) do
					if elem.name:sub(1,7 ) == "rr_gui_" then
						pos = pos+1
						if elem ==gui then
							break
						end
					end
				end
				if tbl.text.text ~= tostring(pos) then
					tbl.text.text = tostring(pos)
				end
			end
			
			local reactor_key, playerid = splitty(key,"-")
	
			local reactor = storage.reactors[reactor_key]
	
			if reactor and reactor.furnace.valid and storage.stats[reactor_key] then
				local signals = reactor.signals
				local burner = to_burner(reactor.furnace)
				if gui.signals then
					local has_power = storage.reactors[reactor_key].power_usage.interface >1 or nil
					local temp_temperature = math.floor(signals["core_temperature"].count)
					if temp_temperature > 1000 then temp_temperature = -temp_temperature+1000 end
					gui.signals.temperature.number = has_power and temp_temperature or nil
					gui.signals.power.number = has_power and math.floor(signals["power-output"].count) or nil
					gui.signals.efficiency.number = has_power and math.floor(signals["efficiency"].count) or nil
					--if reactor.furnace.name == BREEDER_FURNACE_NAME then
						gui.signals.bonuscells.number = has_power and math.floor(signals["cell-bonus"].count)/100 or nil
						gui.signals.cooling.number = has_power and math.floor(signals["cooling"].count) or nil
					--end
					--gui.signals.coolant.number = has_power and signals["coolant-amount"].count or nil
					local style_affix = "-blue"
					if reactor.furnace.name == BREEDER_FURNACE_NAME then
						style_affix = "-red"
					end
					
					if signals["state_stopped"].count > 0 then
						gui.signals.status.number=nil
						gui.signals.status.sprite="virtual-signal/signal-state-stopped"
						gui.signals.status.style="RRR-slot_button"..style_affix.."-start"
						
					elseif signals["state_starting"].count > 0 then
						gui.signals.status.number=signals["state_starting"].count
						gui.signals.status.sprite="virtual-signal/signal-state-starting"
						gui.signals.status.style="RRR-slot_button"..style_affix.."-stop"
					elseif signals["state_running"].count > 0 then
						gui.signals.status.number=nil
						gui.signals.status.sprite="virtual-signal/signal-state-running"
						gui.signals.status.style="RRR-slot_button"..style_affix.."-stop"
					elseif signals["state_scramed"].count > 0 then
						gui.signals.status.number=signals["state_scramed"].count
						gui.signals.status.sprite="virtual-signal/signal-state-scramed"
						gui.signals.status.style="RRR-slot_button"..style_affix.."-nil"
					end
				end
				if gui.progress then
					if reactor.furnace.get_inventory(defines.inventory.crafter_input).is_empty() then
						gui.progress.cells.number = nil
						gui.progress.cells.sprite = "RRR-transparent-sprite"
						gui.progress.cells.elem_tooltip  = nil
					else
						local item = reactor.furnace.get_inventory(defines.inventory.crafter_input)[1]
						gui.progress.cells.number = item.count
						if gui.progress.cells.sprite ~= item.name.."-"..item.quality.name then
							gui.progress.cells.sprite = item.name.."-"..item.quality.name
							gui.progress.cells.elem_tooltip  = {type = "item-with-quality", name = item.name, quality = item.quality.name}
							gui.progress.cells.ignored_by_interaction = false
						end
						--game.print(222)
					end
					
					if reactor.furnace.get_output_inventory().is_empty() then
						gui.progress.used_cells.number = nil
						gui.progress.used_cells.sprite = "RRR-transparent-sprite"
						if gui.progress.used_cells2 then
							gui.progress.used_cells2.number = nil
							gui.progress.used_cells2.sprite = "RRR-transparent-sprite"
						end
					else
						local inv1 = reactor.furnace.get_output_inventory()[2] --second output slot
						gui.progress.used_cells.number =  inv1.valid_for_read and inv1.count or nil
						local new_sprite = inv1.valid_for_read and inv1.name.."-"..inv1.quality.name or "RRR-transparent-sprite"
						if gui.progress.used_cells.sprite ~= new_sprite then
							gui.progress.used_cells.sprite = new_sprite
							gui.progress.used_cells.elem_tooltip = new_sprite ~= "RRR-transparent-sprite" and {type = "item-with-quality", name = inv1.name, quality = inv1.quality.name} or nil
						end
						if gui.progress.used_cells2 then
							if next(reactor.hidden_output_inventory) then
								local highest_count = 0.9999999
								local highest_item = nil
								for id, count in pairs(reactor.hidden_output_inventory) do
									if count > highest_count then
										highest_count = count
										highest_item = id
									end
								end
								if highest_item then
									gui.progress.used_cells2.number =highest_count
									if gui.progress.used_cells2.sprite ~= highest_item then
										gui.progress.used_cells2.sprite = highest_item
										local item = highest_item:sub(1,highest_item:match(".*()%-")-1)
										local quality = highest_item:sub(highest_item:match(".*()%-")+1)
										if prototypes.item[item] then
											gui.progress.used_cells2.elem_tooltip = {type = "item-with-quality", name = item, quality = quality}
										end
									end
								else
									gui.progress.used_cells2.number = nil
									gui.progress.used_cells2.sprite = "RRR-transparent-sprite"
									gui.progress.used_cells2.elem_tooltip = nil
								end
							else
								gui.progress.used_cells2.number = nil
								gui.progress.used_cells2.sprite = "RRR-transparent-sprite"
								gui.progress.used_cells2.elem_tooltip = nil
							end
							
						end
					end
					
					if burner.currently_burning == nil then
						gui.progress.bars.progress.value=0
						--if reactor.displayer.name == "RRR-realistic-reactor-breeder" then
							gui.progress.bars.bonus_cells.value=0
						--end
					elseif burner.currently_burning.name.burnt_result then -- TODOOO
						local burnt_result = burner.currently_burning.name.burnt_result
						if burnt_result.name == "apm_fuel_cell_mox_used" then
							burnt_result.name = "apm_nuclear_breeder_uranium_inventory_enriched"
						end
						--gui.progress.cells.sprite = "item/"..burner.currently_burning.name
						--gui.progress.used_cells.sprite = "item/"..burnt_result.name
						gui.progress.bars.progress.value = burner.remaining_burning_fuel / math.max(1,burner.currently_burning.name.fuel_value)
						--if reactor.displayer.name == "RRR-realistic-reactor-breeder" then
						local result_quality = reactor.furnace.result_quality and reactor.furnace.result_quality.name or "normal"
						gui.progress.bars.bonus_cells.value = math.min(1,reactor.bonus_cells[burnt_result.name.."-"..result_quality] or 0)--burner.currently_burning.quality.name] or 0)
						--end
					end
				end
				if gui.control then
					gui.control.reactor_slider.slider_value = reactor.control_target
					--total width = 182, half = 91
					local width = math.ceil(math.max(1,math.abs(reactor.control_current)/100*91))
					gui.control.progress.style.width = width
					--gui.control.progress.value=1
					if reactor.control_current >0 then
						gui.control.progress.style.color={r=1,g=math.max(0,1-(reactor.control_current)/50),b=math.max(0,math.min(1,(reactor.control_current-50)/60))}
						gui.control.progress.style.left_margin=91
					else
						if reactor.control_current < -50 then
							gui.control.progress.style.color={r=math.min(1,(-reactor.control_current-50)/50),g=1,b=math.min(1,(-reactor.control_current-50)/50)}
						else
							gui.control.progress.style.color={r=math.max(0,1+reactor.control_current/50),g=math.min(1,0.9-0.1*reactor.control_current/10),b=0}
						end
						--game.print(math.max(0,1+reactor.control_current/100))
						if reactor.control_current == 0 then
							gui.control.progress.style.left_margin=91-width
						else
							gui.control.progress.style.left_margin=90-width
						end
					end
				
				end
			else
				storage.stats[reactor_key] = nil
				gui.destroy()
				if tbl.text then tbl.text.destroy() end
				if tbl.box then tbl.box.destroy() end
				storage.guis[reactor_key.."-"..playerid] = nil
				storage.gui_count = storage.gui_count - 1
			
			end
		end
	end
	
	
	
	--process graphs
	if event.tick % math.floor((TICKS_PER_UPDATE*2) / table_length(storage.guis)) ==0 then
		if not storage.guis[storage.worker_key] then storage.worker_key = nil end
		storage.worker_key = next(storage.guis, storage.worker_key)
		if storage.worker_key == nil then
			storage.worker_key = next(storage.guis, storage.worker_key)
		end
		local graphs_processed=0
		while storage.worker_key and graphs_processed<1 do
			local gui = storage.guis[storage.worker_key].gui
			if gui.graph then
				local reactor_key,playerid = splitty(storage.worker_key,"-")
				if not storage.reactors[reactor_key] or not storage.stats[reactor_key] then
					storage.stats[reactor_key] = nil
					if storage.guis[storage.worker_key].text then storage.guis[storage.worker_key].text.destroy() end
					if storage.guis[storage.worker_key].box then storage.guis[storage.worker_key].box.destroy() end
					gui.destroy()
					storage.guis[reactor_key.."-"..playerid] = nil
					storage.gui_count = storage.gui_count - 1
				else
					if gui.graph.valid then
						local stats=storage.stats[reactor_key]
						local aqua_stats = gaussian_smoothing_with_reflection(stats.aqua, 12, 4)
						local has_power = storage.reactors[reactor_key].power_usage.interface >1 or nil
						for k, temperature in pairs(stats.temperature) do
							local colors={}
							local production = math.min(100,math.max(1,math.floor(  stats.production[k] / stats.max * 100  )))
							local aqua = math.min(100,math.max(1,math.floor(  (aqua_stats[k+AQUA_EXTRA_DATA] or 0) / stats.max * 100  )))
							
							colors[production] = ""
							colors[stats.efficiency[k]] = ""
							colors[aqua] = ""
							colors[production+1] = ""
							colors[stats.efficiency[k]+1] = ""
							colors[aqua+1] = ""
							
							colors[stats.temperature[k]] = "r"
							colors[stats.temperature[k]+1] = "r"
							colors[production] = colors[production] .."y"
							colors[production+1] = colors[production+1] .."y"
							colors[stats.efficiency[k]] = colors[stats.efficiency[k]] .."b"
							colors[stats.efficiency[k]+1] = colors[stats.efficiency[k]+1] .."b"
							colors[aqua] = colors[aqua].."a"
							colors[aqua+1] = colors[aqua+1].."a"
							
							local height = 0
							local counter = 1
							local value,color = next(colors)
	
							while value do
								if has_power and value > 0 then
									if counter > 1 then
										gui.graph.table["col_".. k]["space_"..counter-1].style.minimal_height=math.max(0,value-height)
									end
	
									height=value+2
									if gui.graph.table["col_".. k]["dot_"..counter.."_1"].sprite~=string2sprite(color) then
										gui.graph.table["col_".. k]["dot_"..counter.."_1"].sprite=string2sprite(color)
									end
									if colors[value+1] then
										if gui.graph.table["col_".. k]["dot_"..counter.."_2"].sprite~=string2sprite(colors[value+1]) then
											gui.graph.table["col_".. k]["dot_"..counter.."_2"].sprite=string2sprite(colors[value+1])
										end
										value,color = next(colors,value)
									else
										if gui.graph.table["col_".. k]["dot_"..counter.."_2"].sprite~="RRR-black" then
											gui.graph.table["col_".. k]["dot_"..counter.."_2"].sprite="RRR-black"
										end
									end
									counter=counter+1
								end
								value,color = next(colors,value)
							end
							for i=counter,4 do
								if i~=1 then
									gui.graph.table["col_".. k]["space_"..i-1].style.minimal_height=0
								end
								if gui.graph.table["col_".. k]["dot_"..i.."_1"].sprite ~= "RRR-black" then
									gui.graph.table["col_".. k]["dot_"..i.."_1"].sprite = "RRR-black"
								end
								if gui.graph.table["col_".. k]["dot_"..i.."_2"].sprite ~= "RRR-black" then
									gui.graph.table["col_".. k]["dot_"..i.."_2"].sprite = "RRR-black"
								end
								height=height+2
								
							end
							gui.graph.table["col_".. k]["space_".. 4].style.minimal_height=math.max(0,103-height)
						end
						
						--text on the right side
						local temp_stats = {}
						local signals = storage.reactors[reactor_key].signals
						
						local production = math.min(100,math.max(1,math.floor(  stats.production[COLUMN_COUNT] / stats.max * 100  )))
						--local aqua = math.min(100,math.max(1,math.floor(  (aqua_stats[COLUMN_COUNT+AQUA_EXTRA_DATA] or 0) / stats.max * 100  )))
						local aqua = math.min(100,math.max(1,math.floor(  (signals.cooling.count or 0) / stats.max * 100  )))

						freespot = 0
						while temp_stats[math.min(100,production+math.floor(FONT_SIZE/2))+freespot] do
							freespot = freespot + 1
						end
						temp_stats[math.min(100,production+math.floor(FONT_SIZE/2))+freespot] = "y"
						--game.players[1].print(game.tick.." y = "..stats.production[COLUMN_COUNT])
						
						freespot = 0
						while temp_stats[math.min(100,stats.efficiency[COLUMN_COUNT]+math.floor(FONT_SIZE/2))+freespot] do
							freespot = freespot + 1
						end
						temp_stats[math.min(100,stats.efficiency[COLUMN_COUNT]+math.floor(FONT_SIZE/2))+freespot] = "b"
						--game.players[1].print(game.tick.." b = "..stats.efficiency[COLUMN_COUNT])
						
						freespot = 0
						while temp_stats[math.min(100,aqua+math.floor(FONT_SIZE/2))+freespot] do
							freespot = freespot + 1
						end
						temp_stats[math.min(100,aqua+math.floor(FONT_SIZE/2))+freespot] = "a"
						--game.players[1].print(game.tick.." a = "..stats.aqua[COLUMN_COUNT])
						
						freespot = 0
						while temp_stats[math.min(100,stats.temperature[COLUMN_COUNT]+math.floor(FONT_SIZE/2))+freespot] do
							freespot = freespot + 1
						end
						temp_stats[math.min(100,stats.temperature[COLUMN_COUNT]+math.floor(FONT_SIZE/2))+freespot] = "r"
						--game.players[1].print(game.tick.." r = "..stats.temperature[COLUMN_COUNT])
						
						--local checked_stats = {}
						local groups = {}
						local i = 1
						
						local currentvalue = next(temp_stats, nil)
						while currentvalue do
							groups[i] = {min_value = currentvalue, max_value = currentvalue, avg_value = currentvalue, count = 1, values = {}}
							groups[i].values[currentvalue] = temp_stats[currentvalue]
							local nextvalue = next(temp_stats,currentvalue)
							local values = 1
							--game.players[1].print(game.tick.." group "..i.." "..currentvalue.." = "..temp_stats[currentvalue])    --
							--if nextvalue then                                                  --
							--	game.players[1].print(game.tick..i.." next: "..nextvalue)      --
							--end                                                                --
							--game.players[1].print(i.." "..nextvalue - groups[i].min_value)
							--if nextvalue and nextvalue - groups[i].min_value < 10 * groups[i].count then
							--	game.players[1].print(game.tick.."GROUP: ")
							--end
							while nextvalue and nextvalue - groups[i].min_value < FONT_SIZE * groups[i].count do
								groups[i].count = groups[i].count + 1
								groups[i].values[nextvalue] = temp_stats[nextvalue]
								--game.players[1].print (game.tick.." "..groups[i].count..": "..nextvalue .." = "..temp_stats[nextvalue])
								local values_sum = 0
								for value, stat in pairs(groups[i].values) do
									values_sum = values_sum + value
								end
								
								groups[i].avg_value = values_sum / groups[i].count
								groups[i].min_value = values_sum / groups[i].count - math.floor(FONT_SIZE/2) * (groups[i].count-1)
								groups[i].max_value = values_sum / groups[i].count + math.floor(FONT_SIZE/2) * (groups[i].count-1)
								if groups[i].min_value < 1 then
									groups[i].max_value = groups[i].max_value + (1 - groups[i].min_value)
									groups[i].min_value = 1
								end
								if groups[i].max_value > 100 then
									groups[i].min_value = groups[i].min_value - (groups[i].max_value - 100)
									groups[i].max_value = 100
								end
								nextvalue = next(temp_stats,nextvalue)
							end
							
							if nextvalue then
								currentvalue = nextvalue
								i=i+1
							else
								currentvalue = nil
							end
						end
						
						local last_maximal = 0
						for key, group in pairs(groups) do
							if group.min_value < last_maximal+FONT_SIZE then
								group.min_value = group.min_value + last_maximal - group.min_value+FONT_SIZE
								group.max_value = group.max_value + last_maximal - group.min_value+FONT_SIZE
							end
							last_maximal = group.max_value
						end
						
						local last_minimal = 100+FONT_SIZE
						for key=i, 1, -1 do
							local group = groups[key]
							if group.max_value > last_minimal-FONT_SIZE then
								group.min_value = group.min_value - (group.max_value - (last_minimal-FONT_SIZE))
								group.max_value = group.max_value - (group.max_value - (last_minimal-FONT_SIZE))
							end
							last_minimal = group.min_value
						end
						
						local temp_stats2 = {}
						for key, group in pairs(groups) do
							i = 0
							for _, stat in pairs(group.values) do
								--if temp_stats2[math.floor(group.min_value + i*12)] then
								--	game.players[1].print(i.."occupied")
								--end
								table.insert(temp_stats2,{value = math.floor(group.min_value + i*FONT_SIZE), stat = stat})
								--game.players[1].print(game.tick.." ("..i..") "..math.floor(group.min_value + i*FONT_SIZE).." = "..stat)
								i = i+1
							end
						end
						local height = 100
						--for value,stat in pairs(temp_stats2) do
						for counter = 4, 1, -1 do
							local value = temp_stats2[counter].value
							local stat = temp_stats2[counter].stat
	
							gui.graph.table["col_".. COLUMN_COUNT+1]["space_"..counter].style.height=math.max(0,height-value-1)
	
							--game.players[1].print(game.tick.." spacer "..counter.." = "..gui.graph.table["col_".. COLUMN_COUNT+1]["space_"..counter].style.minimal_height.."px, value = "..value)
							height=height-math.max(0,height-value-1)-FONT_SIZE
							--game.players[1].print(game.tick .." height:"..height-16 .." value:"..value.." color:"..stat)
							if storage.reactors[reactor_key].power_usage.interface >1 then
								if stat=="r" then
									gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].caption = "  "..math.floor(signals["core_temperature"].count).."°"
								elseif stat=="y" then
									gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].caption = "  "..math.floor(signals["power-output"].count+0.5).."MW"
								elseif stat=="b" then
									gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].caption = "  "..signals["efficiency"].count.."%"
								else
									gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].caption = math.floor(aqua_stats[#aqua_stats] or 0)*-1 .."MW"
								end
								gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].style.font_color = string2color(stat)
							else
								gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].caption = ""
								gui.graph.table["col_".. COLUMN_COUNT+1]["text_"..counter].style.font_color = {r=0,g=0,b=0}
							end
						end
						--gui.graph.table["col_".. COLUMN_COUNT+1]["space_".. 5].style.height= 0 --height
						--game.players[1].print(game.tick.." spacer 5 = "..gui.graph.table["col_".. COLUMN_COUNT+1]["space_5"].style.minimal_height.."px")
						--game.players[1].print(100-height)
					end
				end
				graphs_processed=graphs_processed+1
			else				
				storage.worker_key = next(storage.guis, storage.worker_key)
			end
		end	
		
	end
end

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.players[event.player_index]
  if player.opened_gui_type ~= defines.gui_type.entity then return end
  local entity = player.opened
  if entity ~= nil and (entity.name == "RRR-realistic-reactor-interface" or entity.name == "RRR-realistic-breeder-interface") then
	local reactor_key
	for key, reactor in pairs(storage.reactors) do
		if reactor.interface == player.opened then
			reactor_key = key
		end
	end
    player.opened = nil
	if reactor_key then
		if player.gui.left["rr_gui_"..reactor_key] then
			if storage.guis[reactor_key.."-"..event.player_index].text then storage.guis[reactor_key.."-"..event.player_index].text.destroy() end
			if storage.guis[reactor_key.."-"..event.player_index].box then storage.guis[reactor_key.."-"..event.player_index].box.destroy() end
			player.gui.left["rr_gui_"..reactor_key].destroy()
			storage.guis[reactor_key.."-"..event.player_index]=nil
			storage.gui_count = storage.gui_count -1
		else
			create_gui(player,reactor_key)
		end
	end
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	
	if event.element.name == "RRR-migration-power-down-reactors" then
		event.element.parent.parent.destroy()
		for _, reactor in pairs(storage.reactors) do
			change_reactor_state(3, reactor, event)
			reactor.power_output_last_tick = math.min(reactor.power_output_last_tick,50)
			reactor.temperature_offset = 0
		end
		--game.tick_paused = false
		return
	elseif event.element.name == "RRR-migration-do-nothing" then
		event.element.parent.parent.destroy()
		--game.tick_paused = false
		return
	end
	
		
	
	if not element.parent or (element.parent.name ~="rr_buttons_flow" and element.parent.name ~="signals") then return end
	local reactor_key = tonumber(string.sub(element.parent.parent.name,8))
	
	if (not storage.reactors[reactor_key]) or element.name == "rr_button_exit" then
		if storage.guis[reactor_key.."-"..event.player_index].text then storage.guis[reactor_key.."-"..event.player_index].text.destroy() end
		if storage.guis[reactor_key.."-"..event.player_index].box then storage.guis[reactor_key.."-"..event.player_index].box.destroy() end
		storage.guis[reactor_key.."-"..event.player_index]=nil
		storage.gui_count = storage.gui_count -1
		element.parent.parent.destroy()
		return
	end
	local reactor = storage.reactors[reactor_key]
	local burner = to_burner(reactor.furnace)
	
	if element.name == "rr_button_signals" then
		if element.parent.parent.signals then
			element.parent.parent.signals.destroy()
			element.parent.rr_button_signals.sprite = "RRR-button-signals-off"
		else
			create_signals(element.parent.parent,reactor_key)
			element.parent.rr_button_signals.sprite = "RRR-button-signals"
		end
	
	elseif element.name == "rr_button_progress" then
		if element.parent.parent.progress then
			element.parent.parent.progress.destroy()
			element.parent.rr_button_progress.sprite = "RRR-button-progress-off"
		else
			create_progress(element.parent.parent,reactor_key)
			element.parent.rr_button_progress.sprite = "RRR-button-progress"
		end
	
	elseif element.name == "rr_button_graph" then
		if element.parent.parent.graph then
			element.parent.parent.graph.destroy()
			element.parent.rr_button_graph.sprite = "RRR-button-graph-off"
		else
			create_graph(element.parent.parent)
			element.parent.rr_button_graph.sprite = "RRR-button-graph"
		end
	elseif element.name == "rr_button_control" then
		if element.parent.parent.control then
			element.parent.parent.control.destroy()
			element.parent.rr_button_control.sprite = "RRR-button-control-off"
		else
			create_control(element.parent.parent,reactor_key)
			element.parent.rr_button_control.sprite = "RRR-button-control"
		end
	elseif element.name == "status" then
		
		local state_changed = false
		local signal_scram = false
		local green_network = reactor.control.get_circuit_network(defines.wire_type.green)
		if green_network then
			--logging("-> Found green circuit network. Network ID: " .. green_network.network_id)
			if green_network.get_signal(SIGNAL_CONTROL_SCRAM) > 0 then
				signal_scram = true
				--logging("--> found green SCRAM signal")
			end
	
		end
		local red_network = reactor.control.get_circuit_network(defines.wire_type.red)
		if red_network then
			--logging("-> Found red circuit network. Network ID: " .. red_network.network_id)
			if red_network.get_signal(SIGNAL_CONTROL_SCRAM) > 0 then
				signal_scram = true
				--logging("--> found red SCRAM signal")
			end
		end
		if reactor.furnace.get_inventory(defines.inventory.crafter_input).is_empty() and burner.remaining_burning_fuel == 0 then
			game.players[event.player_index].print("[RealisticReactors] Reactor can't start, because it has no fuel cell.")
		elseif reactor.power.energy < (POWER_USAGE_STARTING * TICKS_PER_UPDATE * 4 / 60* storage.settings["RRR-energy_consumption_multiplier"]) then
			if reactor.state == 0 then
				game.players[event.player_index].print("[RealisticReactors] Reactor can't start, because it doesn't have enough electricity.")
			else
				game.players[event.player_index].print("[RealisticReactors] Reactor can't scram, because it doesn't have enough electricity.")
			end
		elseif signal_scram then
			game.players[event.player_index].print("[RealisticReactors] Reactor can't start, because there's a scram control signal on its circuit interface.")
		else
			if reactor.state == 0 then
				state_changed = true
				change_reactor_state(1, reactor, event)
				update_reactor_states(reactor_key, event)
			elseif reactor.state == 1 or reactor.state == 2 then
				state_changed = true
				change_reactor_state(3, reactor, event)
				update_reactor_states(reactor_key, event)
			else
				game.players[event.player_index].print("[RealisticReactors] Reactor is already scramed.")
			end
		end

	end
end)
	
function create_gui(player, reactor_key)
	local reactor = storage.reactors[reactor_key]
	local style_affix = "-blue"
	if reactor.furnace.name == BREEDER_FURNACE_NAME then
		style_affix = "-red"
	end
	local gui = player.gui.left.add{type = "frame", name = "rr_gui_"..reactor_key, caption = "", direction = "vertical", style = "RRR-frame"..style_affix}
	gui.style.top_padding 		= 1
	gui.style.right_padding 	= 0
	gui.style.bottom_padding 	= 4
	gui.style.left_padding 		= 4
	--gui.style.scaleable 		= false
	
	if not storage.stats[reactor_key] then 
		storage.stats[reactor_key] = {}
		storage.stats[reactor_key].temperature = {}
		storage.stats[reactor_key].efficiency = {}
		storage.stats[reactor_key].production = {}
		storage.stats[reactor_key].aqua = {}
		storage.stats[reactor_key].max = 1
	end
	gui.add{type = "table", column_count = 6, name = "rr_buttons_flow", direction = "horizontal"}
	gui.rr_buttons_flow.style.top_padding 		= 0
	gui.rr_buttons_flow.style.right_padding 	= 0
	gui.rr_buttons_flow.style.bottom_margin 	= -1
	gui.rr_buttons_flow.style.bottom_padding 	= 0
	gui.rr_buttons_flow.style.left_padding 		= 0
	gui.rr_buttons_flow.style.horizontal_spacing= 1
	--gui.rr_buttons_flow.style.scaleable = false
	
		gui.rr_buttons_flow.add{type = "textfield",name = "rr_textbox", style = "RRR-textbox"}
		gui.rr_buttons_flow.rr_textbox.style.top_padding 	= 0
		gui.rr_buttons_flow.rr_textbox.style.right_padding 	= 1
		gui.rr_buttons_flow.rr_textbox.style.bottom_padding 	= 0
		gui.rr_buttons_flow.rr_textbox.style.left_padding 	= 0	
		gui.rr_buttons_flow.rr_textbox.style.height 	= 21
		gui.rr_buttons_flow.rr_textbox.style.right_margin 	= -1
		gui.rr_buttons_flow.rr_textbox.text = tostring(reactor.name)
		gui.rr_buttons_flow.rr_textbox.lose_focus_on_confirm = true
		if reactor.control_rods_tech == 0 then
			gui.rr_buttons_flow.rr_textbox.style.width 	= 71+21+1
		else
			gui.rr_buttons_flow.rr_textbox.style.width 	= 71
		end
		
		gui.rr_buttons_flow.add{type = "sprite-button",name = "rr_button_signals", sprite = "RRR-button-signals", style = "RRR-button"..style_affix}
		gui.rr_buttons_flow.rr_button_signals.style.top_padding 	= 1
		gui.rr_buttons_flow.rr_button_signals.style.right_padding 	= 1
		gui.rr_buttons_flow.rr_button_signals.style.bottom_padding 	= 1
		gui.rr_buttons_flow.rr_button_signals.style.left_padding 	= 1	
		gui.rr_buttons_flow.rr_button_signals.style.height 	= 21
		gui.rr_buttons_flow.rr_button_signals.style.width 	= 21
		--gui.rr_buttons_flow.rr_button_signals.style.scaleable = false
		if reactor.control_rods_tech > 0 then
			gui.rr_buttons_flow.add{type = "sprite-button",name = "rr_button_control", sprite = "RRR-button-control", style = "RRR-button"..style_affix}
			gui.rr_buttons_flow.rr_button_control.style.top_padding 		= 1
			gui.rr_buttons_flow.rr_button_control.style.right_padding 	= 1
			gui.rr_buttons_flow.rr_button_control.style.bottom_padding 	= 1
			gui.rr_buttons_flow.rr_button_control.style.left_padding 		= 1	
			gui.rr_buttons_flow.rr_button_control.style.height 		= 21
			gui.rr_buttons_flow.rr_button_control.style.width 		= 21
		end
		
		gui.rr_buttons_flow.add{type = "sprite-button",name = "rr_button_progress", sprite = "RRR-button-progress", style = "RRR-button"..style_affix}
		gui.rr_buttons_flow.rr_button_progress.style.top_padding 		= 1
		gui.rr_buttons_flow.rr_button_progress.style.right_padding 		= 1
		gui.rr_buttons_flow.rr_button_progress.style.bottom_padding 	= 1
		gui.rr_buttons_flow.rr_button_progress.style.left_padding 		= 1	
		gui.rr_buttons_flow.rr_button_progress.style.height 	= 21
		gui.rr_buttons_flow.rr_button_progress.style.width 		= 21
		--gui.rr_buttons_flow.rr_button_progress.style.scaleable = false
		
		gui.rr_buttons_flow.add{type = "sprite-button",name = "rr_button_graph", sprite = "RRR-button-graph-off", style = "RRR-button"..style_affix}
		gui.rr_buttons_flow.rr_button_graph.style.top_padding 		= 1
		gui.rr_buttons_flow.rr_button_graph.style.right_padding 	= 1
		gui.rr_buttons_flow.rr_button_graph.style.bottom_padding 	= 1
		gui.rr_buttons_flow.rr_button_graph.style.left_padding 		= 1	
		gui.rr_buttons_flow.rr_button_graph.style.height 		= 21
		gui.rr_buttons_flow.rr_button_graph.style.width 		= 21
		gui.rr_buttons_flow.rr_button_graph.style.right_margin = 4
		--gui.rr_buttons_flow.rr_button_graph.style.scaleable = false
		
		--gui.rr_buttons_flow.rr_button_control.style.scaleable = false
		
		--gui.rr_buttons_flow.add{type = "flow", name = "titlebar_spacer", direction = "horizontal"}
		--gui.rr_buttons_flow.titlebar_spacer.style.width=2
		--gui.rr_buttons_flow.titlebar_spacer.style.height=1
		--gui.rr_buttons_flow.titlebar_spacer.style.scaleable = false
		
		
		gui.rr_buttons_flow.add{type = "sprite-button",name = "rr_button_exit", sprite = "RRR-button-x", style = "RRR-button"..style_affix}
		gui.rr_buttons_flow.rr_button_exit.style.top_padding 		= 0
		gui.rr_buttons_flow.rr_button_exit.style.right_padding 		= 0
		gui.rr_buttons_flow.rr_button_exit.style.bottom_padding 	= 0
		gui.rr_buttons_flow.rr_button_exit.style.left_padding 		= 0	
		gui.rr_buttons_flow.rr_button_exit.style.height 	= 21
		gui.rr_buttons_flow.rr_button_exit.style.width 		= 21
		--gui.rr_buttons_flow.rr_button_exit.style.scaleable = false
	create_signals(gui,reactor_key)
	if reactor.control_rods_tech > 0 then
		create_control(gui,reactor_key)
	end
	create_progress(gui,reactor_key)
	local pos = 0
	for _, elem in pairs(player.gui.left.children) do
		if elem.name:sub(1,7 ) == "rr_gui_" then
			pos = pos+1
			if elem ==gui then
				break
			end
		end
	end
	local tint = {r=0.65,g=0.75,b=1, a = 2}
	if style_affix == "-red" then
		tint = {r=1,g=0.64,b=0.68, a = 1.55}
	end
	tint = mult_color(tint, 1)
	local text_render = rendering.draw_text{text = tostring(pos), scale = 2, alignment = "left", surface = reactor.furnace.surface, target = {x=reactor.furnace.position.x+1.2, y=reactor.furnace.position.y+1.6}, only_in_alt_mode = true, color = mult_color(tint,1.2), players = {player}}
	local box = rendering.draw_sprite{sprite = "RRR-selection_box", x_scale = 0.33, y_scale = 0.33, surface = reactor.furnace.surface, target = {x=reactor.furnace.position.x, y=reactor.furnace.position.y}, only_in_alt_mode = true, tint = tint, players = {player}}

	storage.guis[reactor_key.."-"..player.index] = {gui = gui, text = text_render, box = box}
	
end


function create_graph(gui)

	gui.add{type = "sprite", name = "graph", sprite="RRR-black-background", direction = "vertical"}
	gui.graph.style.width=math.floor(80*PIXEL_WIDTH)+22
	gui.graph.style.height=GRAPH_HEIGHT
	gui.graph.style.stretch_image_to_widget_size =true
	--gui.graph.style.scaleable = false
	gui.graph.add{type = "table", column_count=COLUMN_COUNT+1, name = "table", direction = "vertical"}
	gui.graph.table.style.horizontal_spacing=0
	gui.graph.table.style.vertical_spacing=0
	--gui.graph.table.style.scaleable = false
	
	for x=1,COLUMN_COUNT+1 do
		gui.graph.table.add{type = "table", column_count=1, name = "col_"..x, direction = "vertical"}
		gui.graph.table["col_"..x].style.horizontal_spacing=0
		gui.graph.table["col_"..x].style.vertical_spacing=0
		gui.graph.table["col_"..x].style.minimal_height=GRAPH_HEIGHT
		gui.graph.table["col_"..x].style.maximal_height=GRAPH_HEIGHT
		--gui.graph.table["col_"..x].style.scaleable = false
		if x>COLUMN_COUNT then
		gui.graph.table["col_"..x].style.left_padding = 3
		end
		--gui.graph.table["col_"..x].add{type = "flow", name = "space_5", direction = "vertical"}
		--gui.graph.table["col_"..x]["space_5"].style.maximal_height=100
		--gui.graph.table["col_"..x]["space_5"].style.minimal_height=1
		--gui.graph.table["col_"..x]["space_5"].style.maximal_width=PIXEL_WIDTH
		--gui.graph.table["col_"..x]["space_5"].style.minimal_width=PIXEL_WIDTH
		--gui.graph.table["col_"..x]["space_5"].style.scaleable = false
		
	end
	for x=1,COLUMN_COUNT+1 do
		for y=4,1,-1 do
			gui.graph.table["col_"..x].add{type = "flow", name = "space_"..y, direction = "vertical"}
			gui.graph.table["col_"..x]["space_"..y].style.maximal_height=100
			gui.graph.table["col_"..x]["space_"..y].style.minimal_height=1
			gui.graph.table["col_"..x]["space_"..y].style.maximal_width=PIXEL_WIDTH
			gui.graph.table["col_"..x]["space_"..y].style.minimal_width=PIXEL_WIDTH
			--gui.graph.table["col_"..x]["space_"..y].style.scaleable = false
			if x <=COLUMN_COUNT then
				gui.graph.table["col_"..x].add{type = "sprite", name = "dot_"..y.."_2", direction = "vertical"}
				gui.graph.table["col_"..x]["dot_"..y.."_2"].style.maximal_height=1
				gui.graph.table["col_"..x]["dot_"..y.."_2"].style.maximal_width=PIXEL_WIDTH
				gui.graph.table["col_"..x]["dot_"..y.."_2"].style.minimal_width=PIXEL_WIDTH
				gui.graph.table["col_"..x]["dot_"..y.."_2"].sprite="RRR-black"
				--gui.graph.table["col_"..x]["dot_"..y.."_2"]=1
				--gui.graph.table["col_"..x]["dot_"..y.."_2"].style.color={r=0,g=0,b=0}
				--gui.graph.table["col_"..x]["dot_"..y.."_2"].style.scaleable = false
				
				gui.graph.table["col_"..x].add{type = "sprite", name = "dot_"..y.."_1", direction = "vertical"}
				gui.graph.table["col_"..x]["dot_"..y.."_1"].style.maximal_height=1
				gui.graph.table["col_"..x]["dot_"..y.."_1"].style.maximal_width=PIXEL_WIDTH
				gui.graph.table["col_"..x]["dot_"..y.."_1"].style.minimal_width=PIXEL_WIDTH
				gui.graph.table["col_"..x]["dot_"..y.."_1"].sprite="RRR-black"
				--gui.graph.table["col_"..x]["dot_"..y.."_1"]=1
				--gui.graph.table["col_"..x]["dot_"..y.."_1"].style.color={r=0,g=0,b=0}
				--gui.graph.table["col_"..x]["dot_"..y.."_1"].style.scaleable = false
			else
				gui.graph.table["col_"..x].add{type = "label", name = "text_"..y, direction = "vertical"}
				gui.graph.table["col_"..x]["text_"..y].caption = ""
				gui.graph.table["col_"..x]["text_"..y].style.height = FONT_SIZE
				--gui.graph.table["col_"..x]["text_"..y].style.vertical_align = "top"
				--gui.graph.table["col_"..x]["text_"..y].style.single_line =false
				--gui.graph.table["col_"..x]["text_"..y].style.want_ellipsis  =false
				gui.graph.table["col_"..x]["text_"..y].style.font = "RRR-small-bold"
				gui.graph.table["col_"..x]["text_"..y].style.top_padding 		= 0
				gui.graph.table["col_"..x]["text_"..y].style.right_padding 	= 0
				gui.graph.table["col_"..x]["text_"..y].style.bottom_padding 	= 0
				gui.graph.table["col_"..x]["text_"..y].style.left_padding 	= 0	
				--gui.graph.table["col_"..x]["text_"..y].style.scaleable = false
				
			end
		end
	end
end
function create_signals (gui,reactor_key)
	local reactor = storage.reactors[reactor_key]
	local style_affix = "-blue"
	if reactor.furnace.name == BREEDER_FURNACE_NAME then
		style_affix = "-red"
	end
	gui.add{type = "table", column_count = 6, name = "signals", direction = "horizontal"}
	gui.signals.style.top_padding 		= 0
	gui.signals.style.right_padding 	= 0
	gui.signals.style.bottom_padding 	= 0
	gui.signals.style.left_padding 	= 0
	gui.signals.style.horizontal_spacing= 0
	gui.signals.style.vertical_spacing=0
	--gui.signals.style.scaleable = false
	local button_size = 30
		gui.signals.add{type = "sprite-button", name = "temperature", sprite="virtual-signal/signal-reactor-core-temp", direction = "vertical", style = "RRR-shallow_slot_button"..style_affix}
		--gui.signals.temperature.number=0
		gui.signals.temperature.style.height = 	button_size
		gui.signals.temperature.style.width = 	button_size
		gui.signals.temperature.style.top_padding 	= 0
		gui.signals.temperature.style.right_padding 	= 0
		gui.signals.temperature.style.bottom_padding 	= 0
		gui.signals.temperature.style.left_padding 	= 0
		--gui.signals.temperature.style.scaleable = false
		gui.signals.temperature.ignored_by_interaction =true
		
		gui.signals.add{type = "sprite-button", name = "power", sprite="virtual-signal/signal-reactor-power-output", direction = "vertical", style = "RRR-shallow_slot_button"..style_affix}
		--gui.signals.power.number=0
		gui.signals.power.style.height = 	button_size
		gui.signals.power.style.width = 	button_size
		gui.signals.power.style.top_padding 	= 0
		gui.signals.power.style.right_padding 	= 0
		gui.signals.power.style.bottom_padding 	= 0
		gui.signals.power.style.left_padding 	= 0
		--gui.signals.power.style.scaleable = false
		gui.signals.power.ignored_by_interaction =true
		
		gui.signals.add{type = "sprite-button", name = "cooling", sprite="virtual-signal/signal-cooling", direction = "vertical", style = "RRR-shallow_slot_button"..style_affix}
			--gui.signals.bonuscells.number=0
			gui.signals.cooling.style.height = 	button_size
			gui.signals.cooling.style.width = 	button_size
			gui.signals.cooling.style.top_padding 	= 0
			gui.signals.cooling.style.right_padding 	= 0
			gui.signals.cooling.style.bottom_padding 	= 0
			gui.signals.cooling.style.left_padding 	= 0
			--gui.signals.cooling.style.scaleable = false
			gui.signals.cooling.ignored_by_interaction =true
		
		gui.signals.add{type = "sprite-button", name = "efficiency", sprite="virtual-signal/signal-reactor-efficiency", direction = "vertical", style = "RRR-shallow_slot_button"..style_affix}
		--gui.signals.efficiency.number=0
		gui.signals.efficiency.style.height = 	button_size
		gui.signals.efficiency.style.width = 	button_size
		gui.signals.efficiency.style.top_padding 	= 0
		gui.signals.efficiency.style.right_padding 	= 0
		gui.signals.efficiency.style.bottom_padding = 0
		gui.signals.efficiency.style.left_padding 	= 0
		--gui.signals.efficiency.style.scaleable = false
		gui.signals.efficiency.ignored_by_interaction =true
		
		--if storage.reactors[reactor_key].displayer.name=="RRR-realistic-reactor-breeder" then
			gui.signals.add{type = "sprite-button", name = "bonuscells", sprite="virtual-signal/signal-reactor-cell-bonus", direction = "vertical", style = "RRR-shallow_slot_button"..style_affix}
			--gui.signals.bonuscells.number=0
			gui.signals.bonuscells.style.height = 	button_size
			gui.signals.bonuscells.style.width = 	button_size
			gui.signals.bonuscells.style.top_padding 	= 0
			gui.signals.bonuscells.style.right_padding 	= 0
			gui.signals.bonuscells.style.bottom_padding 	= 0
			gui.signals.bonuscells.style.left_padding 	= 0
			gui.signals.bonuscells.style.right_margin = 3
			--gui.signals.bonuscells.style.scaleable = false
			gui.signals.bonuscells.show_percent_for_small_numbers =true
			gui.signals.bonuscells.ignored_by_interaction =true
		--end
		
		
		
		--gui.signals.add{type = "sprite-button", name = "coolant", sprite="virtual-signal/signal-coolant-amount", direction = "vertical", style = "slot_button"}
		--gui.signals.coolant.number=0
		--gui.signals.coolant.style.height = 	32
		--gui.signals.coolant.style.width = 	32
		--gui.signals.coolant.style.top_padding 	= 0
		--gui.signals.coolant.style.right_padding 	= 0
		--gui.signals.coolant.style.bottom_padding 	= 0
		--gui.signals.coolant.style.left_padding 	= 0
		----gui.signals.coolant.style.scaleable = false
		--gui.signals.coolant.ignored_by_interaction =true
		
		gui.signals.add{type = "sprite-button", name = "status", sprite="virtual-signal/signal-state-stopped", direction = "vertical", style = "RRR-slot_button"..style_affix}
		--gui.signals.status.number=0
		gui.signals.status.style.height = 	button_size
		gui.signals.status.style.width = 	button_size
		gui.signals.status.style.top_padding 	= 0
		gui.signals.status.style.right_padding 	= 0
		gui.signals.status.style.bottom_padding 	= 0
		gui.signals.status.style.left_padding 	= 0
		--gui.signals.status.style.scaleable = false
		gui.signals.status.ignored_by_interaction =false

end

function create_control (gui,reactor_key)
	local reactor = storage.reactors[reactor_key]
	local style_affix = "-blue"
	if reactor.furnace.name == BREEDER_FURNACE_NAME then
		style_affix = "-red"
	end
	gui.add{type = "flow", name = "control", direction = "vertical"}
	gui.control.style.top_padding 		= 0
	gui.control.style.right_padding 	= 0
	gui.control.style.bottom_padding 	= 0
	gui.control.style.left_padding 	= 0
	gui.control.style.top_margin 	= -3
	--gui.control.style.horizontal_spacing= 0
	--gui.control.style.vertical_spacing=0
	--gui.control.style.scaleable = false
	
	gui.control.add{type = "progressbar", name = "progress_background", direction = "vertical", style = "RRR-progressbar"..style_affix}
			gui.control.progress_background.style.height=15
			gui.control.progress_background.style.width=182
			gui.control.progress_background.style.top_padding 	= 0
			gui.control.progress_background.style.bottom_margin 	= 0
			gui.control.progress_background.style.right_padding 	= 0
			gui.control.progress_background.style.bottom_padding	= 0
			gui.control.progress_background.style.bottom_margin	= -19
			gui.control.progress_background.style.left_padding 	= 0
			gui.control.progress_background.value=0--(reactor.control_current-1)/999
			gui.control.progress_background.style.bar_width =15
			gui.control.progress_background.style.color={r=1,g=math.max(0,0.9-0.9*(reactor.control_current-1)/500),b=math.max(0,math.min(1,(reactor.control_current-500)/600))}
		gui.control.add{type = "progressbar", name = "progress", direction = "vertical", style = "RRR-progressbar-void"}
			gui.control.progress.style.height=14
			gui.control.progress.style.width=1 --x/182
			gui.control.progress.style.top_padding 	= 0
			gui.control.progress.style.bottom_margin 	= 0
			gui.control.progress.style.right_padding 	= 0
			gui.control.progress.style.bottom_padding	= 0
			gui.control.progress.style.left_padding 	= 0
			gui.control.progress.style.left_margin 	= 182/2--182/4
			gui.control.progress.value=1--(reactor.control_current-1)/999
			gui.control.progress.style.bar_width =14
			gui.control.progress.style.bottom_margin =-18
			gui.control.progress.style.color={r=1,g=math.max(0,0.9-0.9*(reactor.control_current-1)/500),b=math.max(0,math.min(1,(reactor.control_current-500)/600))}
			
		gui.control.add{type = "sprite", name = "middle", direction = "vertical"}
		gui.control.middle.style.height=14
		gui.control.middle.style.width=1
		gui.control.middle.sprite="RRR-black"
		--gui.control.middle.style.top_margin 	= -14
		gui.control.middle.style.top_padding 	= 0
		gui.control.middle.style.bottom_margin 	= 5
		gui.control.middle.style.right_padding 	= 0
		gui.control.middle.style.bottom_padding	= 0
		gui.control.middle.style.left_padding 	= 0
		gui.control.middle.style.left_margin 	= 90
		gui.control.middle.style.stretch_image_to_widget_size	= true

	-- map_generator_13_notch_slider
	-- map_generator_notched_slider_wide
	
	gui.control.add{type = "slider", name = "reactor_slider", direction = "vertical", style = "RRR-slider"}
			gui.control.reactor_slider.style.height=1
			gui.control.reactor_slider.style.width=194
			gui.control.reactor_slider.style.right_margin 	= -5
			gui.control.reactor_slider.style.left_margin 	= -6.5
			gui.control.reactor_slider.style.top_margin 	= 0
			gui.control.reactor_slider.style.bottom_margin 	= -2
			gui.control.reactor_slider.style.top_padding 	= 0
			gui.control.reactor_slider.style.right_padding 	= 0
			gui.control.reactor_slider.style.bottom_padding	= 0
			gui.control.reactor_slider.style.left_padding 	= 0
			gui.control.reactor_slider.set_slider_value_step(1)
			gui.control.reactor_slider.set_slider_minimum_maximum(-100,100)
			gui.control.reactor_slider.slider_value  = -1
			--gui.control.reactor_slider.value=0
			--gui.control.reactor_slider.style.color={r=1,g=0,b=0}
	
	

end

function create_progress (gui,reactor_key)
	local reactor = storage.reactors[reactor_key]
	local style_affix = "-blue"
	if reactor.furnace.name == BREEDER_FURNACE_NAME then
		style_affix = "-red"
	end
	local cols = 4 --3
	--if #reactor.furnace.get_output_inventory() > 1 then
	--	cols = 4
	--end
	gui.add{type = "table", column_count = cols, name = "progress", direction = "horizontal"}
	gui.progress.style.top_padding 		= 0
	gui.progress.style.right_padding 	= 0
	gui.progress.style.bottom_padding 	= 0
	gui.progress.style.left_padding 	= 0
	gui.progress.style.horizontal_spacing= 1
	gui.progress.style.vertical_spacing=1
	--gui.progress.style.scaleable = false

	
		gui.progress.add{type = "sprite-button", name = "cells", sprite="RRR-mini-sprite", direction = "vertical", style = "RRR-button"..style_affix}
		gui.progress.cells.style.maximal_height = 	25
		gui.progress.cells.style.maximal_width = 	25
		gui.progress.cells.style.top_padding 	= 0
		gui.progress.cells.style.right_padding 	= 0
		gui.progress.cells.style.bottom_padding 	= 0
		gui.progress.cells.style.left_padding 	= 0
		--gui.progress.cells.style.scaleable = false
		--gui.progress.cells.ignored_by_interaction =true
	
		
		gui.progress.add{type = "table", column_count = 1, name = "bars", direction = "vertical"}
		gui.progress.bars.style.maximal_height = 28
		gui.progress.bars.style.maximal_width = 140
		gui.progress.bars.style.horizontal_spacing=0
		gui.progress.bars.style.vertical_spacing=0
		gui.progress.bars.style.top_padding 	= 0
		gui.progress.bars.style.right_padding 	= 0
		gui.progress.bars.style.bottom_padding 	= 0
		gui.progress.bars.style.left_padding 	= 0
		--gui.progress.bars.style.scaleable = false
	
		
			gui.progress.bars.add{type = "progressbar", name = "progress", direction = "vertical", style = "RRR-progressbar"..style_affix}
			gui.progress.bars.progress.style.height=12
			gui.progress.bars.progress.style.width=105
			gui.progress.bars.progress.style.top_padding 	= 0
			gui.progress.bars.progress.style.right_padding 	= 0
			gui.progress.bars.progress.style.bottom_padding	= 0
			gui.progress.bars.progress.style.left_padding 	= 0
			gui.progress.bars.progress.value=0
			gui.progress.bars.progress.style.color={r=1,g=0,b=0}
			--gui.progress.bars.progress.style.scaleable = false
		
			--if storage.reactors[reactor_key].furnace.name==BREEDER_FURNACE_NAME then
				gui.progress.bars.add{type = "progressbar", name = "bonus_cells", direction = "vertical", style = "RRR-progressbar"..style_affix}
				gui.progress.bars.bonus_cells.style.height=12
				gui.progress.bars.bonus_cells.style.width=105
				gui.progress.bars.bonus_cells.style.top_padding 	= 0
				gui.progress.bars.bonus_cells.style.right_padding 	= 0
				gui.progress.bars.bonus_cells.style.bottom_padding 	= 0
				gui.progress.bars.bonus_cells.style.left_padding 	= 0
				gui.progress.bars.bonus_cells.value=0
				gui.progress.bars.bonus_cells.style.color={r=0.8,g=0,b=0.8}
				--gui.progress.bars.bonus_cells.style.scaleable = false
			--else
			--	gui.progress.bars.style.top_padding 	= 2
			--end
	
		
		gui.progress.add{type = "sprite-button", name = "used_cells", sprite="RRR-transparent-sprite", direction = "vertical", style = "RRR-button"..style_affix}
		gui.progress.used_cells.style.height = 25
		gui.progress.used_cells.style.width 	= 25
		gui.progress.used_cells.style.top_padding 	= 0
		gui.progress.used_cells.style.right_padding 	= 0
		gui.progress.used_cells.style.bottom_padding = 0
		gui.progress.used_cells.style.left_padding 	= 0
		--gui.progress.used_cells.style.scaleable = false
		--gui.progress.used_cells.ignored_by_interaction =true
		--if #reactor.furnace.get_output_inventory() > 1 then
			gui.progress.add{type = "sprite-button", name = "used_cells2", sprite="RRR-transparent-sprite", direction = "vertical", style = "RRR-button"..style_affix}
			gui.progress.used_cells2.style.height = 25
			gui.progress.used_cells2.style.width 	= 25
			gui.progress.used_cells2.style.top_padding 	= 0
			gui.progress.used_cells2.style.right_padding 	= 0
			gui.progress.used_cells2.style.bottom_padding = 0
			gui.progress.used_cells2.style.left_padding 	= 0
			--gui.progress.used_cells.style.scaleable = false
			--gui.progress.used_cells2.ignored_by_interaction =true
			--gui.progress.bars.progress.style.width=115
			--if gui.progress.bars.bonus_cells then
			--	gui.progress.bars.bonus_cells.style.width = 115
			--end
		--end
		
end


script.on_event(defines.events.on_gui_text_changed , function(event)
	if event.element.name ~= "rr_textbox" then return end
	local reactor_key = tonumber(string.sub(event.element.parent.parent.name,8))
	if not storage.reactors[reactor_key] or not storage.reactors[reactor_key].name_render or not storage.reactors[reactor_key].name_render.valid then return end
	storage.reactors[reactor_key].name_render.text = event.element.text
	storage.reactors[reactor_key].name = event.element.text

end)

script.on_event(defines.events.on_gui_value_changed, function(event)
	
	if event.element.name ~= "reactor_slider" or not event.element.parent or  event.element.parent.name ~="control" then return end
	local reactor_key = tonumber(string.sub(event.element.parent.parent.name,8))
	if not storage.reactors[reactor_key] then return end
	storage.reactors[reactor_key].control_target = event.element.slider_value
	storage.reactors[reactor_key].manual_control_tick = event.tick

end)


script.on_event("RRR-change_reactor_state", function(event)

	local player = game.players[event.player_index]
	local entity = player.selected
	if entity then
		local entity_name = entity.name
		if entity_name == INTERFACE_ENTITY_NAME or entity_name == BREEDER_INTERFACE_ENTITY_NAME then
			local reactor = storage.reactors[entity.unit_number]
			if not reactor then --blueprint where reactor wasn't placed yet
				return
			end
			local signal_scram = false
			local green_network = reactor.control.get_circuit_network(defines.wire_type.green)
			if green_network then
				if green_network.get_signal(SIGNAL_CONTROL_SCRAM) > 0 then
					signal_scram = true
				end
		
			end
			local red_network = reactor.control.get_circuit_network(defines.wire_type.red)
			if red_network then
				if red_network.get_signal(SIGNAL_CONTROL_SCRAM) > 0 then
					signal_scram = true
				end
			end
			local burner = to_burner(reactor.furnace)
			if reactor.furnace.get_inventory(defines.inventory.crafter_input).is_empty() and burner.remaining_burning_fuel == 0 then
				game.players[event.player_index].print("[RealisticReactors] Reactor can't start, because it has no fuel cell.")
			elseif reactor.power.energy < (POWER_USAGE_STARTING * TICKS_PER_UPDATE * 4 / 60* storage.settings["RRR-energy_consumption_multiplier"]) then
				if reactor.state == 0 then
					game.players[event.player_index].print("[RealisticReactors] Reactor can't start, because it doesn't have enough electricity.")
				else
					game.players[event.player_index].print("[RealisticReactors] Reactor can't scram, because it doesn't have enough electricity.")
				end
			elseif signal_scram then
				game.players[event.player_index].print("[RealisticReactors] Reactor can't start, because there's a scram control signal on its circuit interface.")
			else
				if reactor.state == 0 then
					state_changed = true
					change_reactor_state(1, reactor, event)
					update_reactor_states(reactor.id, event)
				elseif reactor.state == 1 or reactor.state == 2 then
					state_changed = true
					change_reactor_state(3, reactor, event)
					update_reactor_states(reactor.id, event)
				else
					game.players[event.player_index].print("[RealisticReactors] Reactor is already scramed.")
				end
			end
		end
	end
end)

script.on_event(defines.events.on_player_toggled_alt_mode, function(event)
	
	if storage.settings["RRR-overlay-text-mode"] == "in alt overlay" then
		if event.alt_mode then
			storage.player_selections[event.player_index] = -1
		else
			storage.player_selections[event.player_index] = nil
		end
	end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
	if storage.settings["RRR-overlay-text-mode"] == "in alt overlay" then
		storage.player_selections[event.player_index] = -1
	end
end)

script.on_event(defines.events.on_player_left_game , function(event)
	storage.player_selections[event.player_index] = nil
end)



script.on_event(defines.events.on_selected_entity_changed, function(event)
	if storage.settings["RRR-overlay-text-mode"] == "on hover" then
		local selected = game.players[event.player_index].selected
		if selected then
			local selected_name = selected.name
			if selected_name:sub(0,4) == "RRR-" then
				local new_selected_reactor
				if selected_name == REACTOR_FURNACE_NAME or selected_name == BREEDER_FURNACE_NAME then
					new_selected_reactor = find_compound_entity(selected, "furnace")
				elseif selected_name:sub(1,#ECCS_L_NAME) == ECCS_L_NAME then
					new_selected_reactor = find_compound_entity(selected, "eccs_L")
				elseif selected_name:sub(1,#ECCS_R_NAME) == ECCS_R_NAME then
					new_selected_reactor = find_compound_entity(selected, "eccs_R")
				elseif selected_name == INTERFACE_ENTITY_NAME or selected_name == BREEDER_INTERFACE_ENTITY_NAME then
					new_selected_reactor = find_compound_entity(selected, "interface")
				end
				if new_selected_reactor == nil then
					--- DUBLICATE CODE
					if storage.player_selections[event.player_index] and storage.player_selections[event.player_index] ~= -1 then
						local other_watching = false
						for pid, rid in pairs(storage.player_selections) do
							if pid ~= event.player_index and rid == storage.player_selections[event.player_index] then
								other_watching = true
							end
						end
						if not other_watching and storage.reactors[storage.player_selections[event.player_index]] then
							storage.reactors[storage.player_selections[event.player_index]].name_render.text = ""
						end
						storage.player_selections[event.player_index] = -1
					end
					--- DUBLICATE CODE
				else
					storage.player_selections[event.player_index] = new_selected_reactor
					local reactor = storage.reactors[new_selected_reactor]
					if storage.settings["RRR-overlay-text"] == "reactor name" then
						reactor.name_render.text = reactor.name
					else
						if reactor.signals["core_temperature"].count >= 991+reactor.quality*10 then
							reactor.name_render.text = string.format("!!!!! %.1f !!!!!", reactor.signals["core_temperature"].count)
						else
							reactor.name_render.text = string.format("%.1f", reactor.signals["core_temperature"].count)
						end
						if storage.settings["RRR-overlay-text"] ==  "temperature + rod coloring" then
							reactor.name_render.color = {r=1,g=math.max(0,1-(reactor.control_current-1)/500),b=math.max(0,math.min(1,(reactor.control_current-500)/600))}
						end
					end
				end
			--- DUBLICATE CODE
			elseif storage.player_selections[event.player_index] and storage.player_selections[event.player_index] ~= -1 then
				local other_watching = false
				for pid, rid in pairs(storage.player_selections) do
					if pid ~= event.player_index and rid == storage.player_selections[event.player_index] then
						other_watching = true
					end
				end
				if not other_watching and storage.reactors[storage.player_selections[event.player_index]] then
					storage.reactors[storage.player_selections[event.player_index]].name_render.text = ""
				end
				storage.player_selections[event.player_index] = -1
			end
			--- DUBLICATE CODE
		else
			--- DUBLICATE CODE
			if storage.player_selections[event.player_index] and storage.player_selections[event.player_index] ~= -1 then
				local other_watching = false
				for pid, rid in pairs(storage.player_selections) do
					if pid ~= event.player_index and rid == storage.player_selections[event.player_index] then
						other_watching = true
					end
				end
				if not other_watching and storage.reactors[storage.player_selections[event.player_index]] then
					storage.reactors[storage.player_selections[event.player_index]].name_render.text = ""
				end
				storage.player_selections[event.player_index] = -1
			end
			--- DUBLICATE CODE
		end
	end
end)