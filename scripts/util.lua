function reset_reactor(reactor) -- pre 2.0.11 compatible -- TODO: modules (currently only used in v11 migration anyway)
	local state = reactor.state
	local temperature = reactor.core.temperature
	local surface = reactor.furnace.surface
	local name = reactor.furnace.name
	local position = reactor.furnace.position
	local force = reactor.furnace.force
	local quality = reactor.furnace.quality
	local input = reactor.furnace.get_inventory(defines.inventory.crafter_input)
	local output = reactor.furnace.get_output_inventory()
	local module_inventory = reactor.furnace.get_module_inventory()
	local input1 = nil
	if input[1] and input[1].valid_for_read then
		input1 = {name = input[1].name, count = input[1].count, quality = input[1].quality}
	end
	local output1 = nil
	local output2 = nil
	if output[1] and output[1].valid_for_read then
		output1 = {name = output[1].name, count = output[1].count, quality = output[1].quality}
	end
	if output[2] and output[2].valid_for_read then
		output2 = {name = output[2].name, count = output[2].count, quality = output[2].quality}
	end
	----------------------------------
	local index = nil
	for i, r in pairs(storage.reactors) do
		if r.furnace == reactor.furnace then
			index = i
			break
		end
	end
	reactor.eccs_L.destroy() -- remove eccs
	reactor.eccs_R.destroy() -- remove eccs
	reactor.power.destroy() -- remove power entity
	if reactor.displayer.valid then reactor.displayer.destroy() end
	if reactor.core.valid then reactor.core.destroy() end
	if reactor.lamp.valid then reactor.lamp.destroy() end
	if reactor.light.valid then reactor.light.destroy() end
	if reactor.interface_warning and reactor.interface_warning.valid then reactor.interface_warning.destroy() end
	if reactor.cooling_warning and reactor.cooling_warning.valid then reactor.cooling_warning.destroy() end
	reactor.furnace.destroy() --only destroy when there should not remain a ghost
	local interface = reactor.interface
	storage.reactors[index] = nil
	local furnace = surface.create_entity{name = name, position = position, force = force, quality = quality}
	furnace.disabled_by_script = true
	add_reactor(furnace,interface)
	reactor = storage.reactors[interface.unit_number]
	reactor.core.temperature = temperature
	if input1 then
		furnace.get_inventory(defines.inventory.crafter_input).insert(input1)
	end
	if output1 then
		furnace.get_output_inventory().insert(output1)
	end
	if output2 then
		furnace.get_output_inventory().insert(output2)
	end
	change_reactor_state(state, reactor, {tick = game.tick})
	
end	





function to_burner(entity)
	local recipe, quality =entity.get_recipe()
	local fuel_cell_prototype = nil
	if recipe then
		local fuel_cell_name = recipe.ingredients[1].name
		fuel_cell_prototype = prototypes.item[fuel_cell_name]
		local fuel_value = fuel_cell_prototype.fuel_value
		
		return {
			heat = 1,
			fuel_value = fuel_value,
			remaining_burning_fuel = fuel_value * (1-entity.crafting_progress),
			currently_burning = {
				name = fuel_cell_prototype,
				quality = quality,
			}
		}
		
	else
		return {
			heat = 0,
			remaining_burning_fuel = 0,
			currently_burning = nil,
		}
	end
end

function respawn_furnace(reactor)
	local surface = reactor.furnace.surface
	local name = reactor.furnace.name
	local position = reactor.furnace.position
	local force = reactor.furnace.force
	local quality = reactor.furnace.quality
	local input = reactor.furnace.get_inventory(defines.inventory.crafter_input)
	local output = reactor.furnace.get_output_inventory()
	local module_inventory = reactor.furnace.get_module_inventory()
	local input1 = nil
	if input[1] and input[1].valid_for_read then
		input1 = {name = input[1].name, count = input[1].count, quality = input[1].quality}
	end
	local output1 = nil
	local output2 = nil
	if output[1] and output[1].valid_for_read then
		output1 = {name = output[1].name, count = output[1].count, quality = output[1].quality}
	end
	if output[2] and output[2].valid_for_read then
		output2 = {name = output[2].name, count = output[2].count, quality = output[2].quality}
	end
	local modules = {}
	for i=1, #module_inventory do
		if module_inventory[i] and module_inventory[i].valid_for_read then
			table.insert(modules, {name = module_inventory[i].name, quality = module_inventory[i].quality})
		end
	end
	local fp = reactor.furnace.position
	local module_requests = nil
	local module_removals = nil
	local nearby = reactor.furnace.surface.find_entities_filtered{area = {{fp.x-0.5,fp.y},{fp.x+0.5,fp.y+1}}}
	for a,b in pairs(nearby) do
		if b.name == "item-request-proxy" and b.proxy_target == reactor.furnace then
			module_requests = b.insert_plan
			module_removals = b.removal_plan
		end
	end
	reactor.furnace.destroy()
	reactor.furnace = surface.create_entity{name = name, position = position, force = force, quality = quality}
	reactor.furnace.disabled_by_script = true
	for _, itemstack in pairs(modules) do
		reactor.furnace.get_module_inventory().insert(itemstack)
	end
	
	if module_requests then
		-- Preserve Factorio's request-plan structure, including qualities and slots.
		surface.create_entity {name="item-request-proxy", position=position,
			target=reactor.furnace, force=force, modules=module_requests,
			removal_plan=module_removals}
	end
	if input1 then
		reactor.furnace.get_inventory(defines.inventory.crafter_input).insert(input1)
	end
	if output1 then
		reactor.furnace.get_output_inventory().insert(output1)
	end
	if output2 then
		reactor.furnace.get_output_inventory().insert(output2)
	end
end

function dbg (str)
	if not storage.dbg then storage.dbg = 1 end
		if type(str) ~= "number" and type(str) ~= "string" then
		if str == true then 
			str = "true" 
		elseif str == false then 
			str = "false" 
		else
			str = type(str)
		end
	end
	game.players[1].print(storage.dbg.."/"..game.tick..": "..str)
	storage.dbg = storage.dbg+1
end

function msg(s)
	game.print(s)
	--for _, player in pairs(game.players) do
	--	if player.connected then
	--		player.print(s)
	--	end
	--end
end

-- function logging(message)
	-- game.write_file("RealisticReactors.log","\r\n[" .. game.tick .. "] " .. message,true)
-- end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function compare_tables(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or compare_tables(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function table_length(t)
	local i=0
	for _ in pairs(t) do
		i=i+1
	end
	return i
end

function find_compound_entity(entity, field)
	for rid, reactor in pairs(storage.reactors) do
		if reactor[field] == entity then
			return rid
		end
	end
end

function count_active_reactors()
	local i = 0
	for _, reactor in pairs(storage.reactors) do
		if reactor.state ~=0 then
			i=i+1
		end
	end
	return i
end
function next_active_reactor(current_index)
	if current_index and not storage.reactors[current_index] then
	end
end



---------------------------------------------------------------------------------- 
-- stats.lua:


function mult_color (col,mult)
	local ret = {}
	for c, v in pairs(col) do 
		ret[c] = math.min(1,v*mult)
	end
	return ret
end

function splitty(s,delimiter) 
    result = {} 
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do 
        table.insert(result, match) 
    end 
    return tonumber(result[1]), tonumber(result[2])
end

function string2sprite(ryba)
	if ryba == "" then
		return "RRR-black"
	else
		return "RRR-"..ryba
	end
end

function string2color(ryba)
	local color = {r=0,g=0,b=0}
	if ryba == "r" then
		color.r=1
	end	
	if ryba == "y" then
		color.r=1
		color.g=1
	end
	if ryba == "b" then
		color.b=1
	end	
	if ryba == "a" then
		color.r=0.4
		color.g=0.75
		color.b=1
	end
	return color
end

function tablemax(tbl)
	local ret = 1 --actually 0 or nil, but for this usecase i need at least 1
	for _, val in pairs(tbl) do
		if val > ret then
			ret = val
		end
	end
	return ret
end

function tablemax_aqua(tbl)
	local ret = 1 --actually 0 or nil, but for this usecase i need at least 1
	for i=1+AQUA_EXTRA_DATA, #tbl  do
		
		if (tbl[i] or 0) > ret then
			ret = tbl[i]
		end
	end
	return ret
end

-- Gaussian-Gewichte für ein Fenster erstellen
function gaussian_weights(window_size, sigma)
    local weights = {}
    local sum = 0
    local half_window = math.floor(window_size / 2)

    for i = -half_window, half_window do
        local weight = math.exp(- (i * i) / (2 * sigma * sigma))
        table.insert(weights, weight)
        sum = sum + weight
    end

    -- Normiere die Gewichte
    for i = 1, #weights do
        weights[i] = weights[i] / sum
    end

    return weights
end

-- Gaussian-Glättung mit Randspiegelung
function gaussian_smoothing_with_reflection(data, window_size, sigma)
    local smoothed_data = {}
    local half_window = math.floor(window_size / 2)
    local weights = gaussian_weights(window_size, sigma)

    local function reflect_index(i, data_length)
        if i < 1 then
            return 1 - i  -- Spiegelung am Anfang
        elseif i > data_length then
            return 2 * data_length - i  -- Spiegelung am Ende
        else
            return i
        end
    end

    for i = 1, #data do
			local sum = 0
	
			for j = -half_window, half_window do
				local idx = reflect_index(i + j, #data)
				sum = sum + (data[idx] or 0) * weights[j + half_window + 1]
			end
	
			smoothed_data[#smoothed_data + 1] = sum
    end

    return smoothed_data
end
