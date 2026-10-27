function register_update_connected_reactors_event()
	storage.tick_update_connected_reactors = game.tick + storage.settings["RRR-neighbour-check-delay"]
end

script.on_event( defines.events.on_console_chat, function(event)
	if event.message and event.message == "connect reactors" and (not event.player_index or not game.players[event.player_index] or game.players[event.player_index].admin) then
		storage.tick_update_connected_reactors = game.tick + 1
	end
end)

function add_heat_pipe(entity, reactor_id)
	local unit_number = entity.unit_number
	local struct = {
		entity=entity,
		neighbours = {}
	}
	if entity.type == "heat-pipe" then
		local surroundings = entity.surface.find_entities_filtered{area = {{entity.position.x-1,entity.position.y},{entity.position.x+1,entity.position.y}}, type={'heat-interface','heat-pipe'}}
		local surroundings2 = entity.surface.find_entities_filtered{area = {{entity.position.x,entity.position.y-1},{entity.position.x,entity.position.y+1}}, type={'heat-interface','heat-pipe'}}

		for _, ent in pairs (surroundings) do
			local neighbour_number = ent.unit_number
			if unit_number ~= neighbour_number and storage.all_heat_pipes[neighbour_number] then
				storage.all_heat_pipes[neighbour_number].neighbours[unit_number] = true
				struct.neighbours[neighbour_number] = true
				table.insert(storage.heatnet_changelog, neighbour_number)
			end
		end
		for _, ent in pairs (surroundings2) do
			local neighbour_number = ent.unit_number
			if unit_number ~= neighbour_number and storage.all_heat_pipes[neighbour_number] then
				storage.all_heat_pipes[neighbour_number].neighbours[unit_number] = true
				struct.neighbours[neighbour_number] = true
				table.insert(storage.heatnet_changelog, neighbour_number)
			end
		end
	elseif reactor_id then
		struct.reactor = reactor_id
		local hp_neighbour_entities_ew = entity.surface.find_entities_filtered{area = {{entity.position.x-2,entity.position.y-1},{entity.position.x+2,entity.position.y}},  type={'heat-interface','heat-pipe'}} --east and west
		local hp_neighbour_entities_n = entity.surface.find_entities_filtered{area = {{entity.position.x-1,entity.position.y-2},{entity.position.x+1,entity.position.y}},   type={'heat-interface','heat-pipe'}} -- north
		for _, ent in pairs (hp_neighbour_entities_ew) do
			local neighbour_number = ent.unit_number
			if unit_number ~= neighbour_number and storage.all_heat_pipes[neighbour_number] then
				storage.all_heat_pipes[neighbour_number].neighbours[unit_number] = true
				struct.neighbours[neighbour_number] = true
				table.insert(storage.heatnet_changelog, neighbour_number)
			end
		end
		for _, ent in pairs (hp_neighbour_entities_n) do
			local neighbour_number = ent.unit_number
			if unit_number ~= neighbour_number and storage.all_heat_pipes[neighbour_number] then
				storage.all_heat_pipes[neighbour_number].neighbours[unit_number] = true
				struct.neighbours[neighbour_number] = true
				table.insert(storage.heatnet_changelog, neighbour_number)
			end
		end
	else
		error(entity.name)
	end
	storage.all_heat_pipes[unit_number] = struct
	if table_length(struct.neighbours) > 1 then
		table.insert(storage.heatnet_changelog, unit_number)
		register_update_connected_reactors_event()
	end
end


function remove_heat_pipe(unit_number)
	if not storage.all_heat_pipes[unit_number] then return end
	if storage.all_heat_pipes[unit_number] then
		for neighbour_number in pairs(storage.all_heat_pipes[unit_number].neighbours) do
			if unit_number ~= neighbour_number and storage.all_heat_pipes[neighbour_number] then
				storage.all_heat_pipes[neighbour_number].neighbours[unit_number] = nil
				table.insert(storage.heatnet_changelog, neighbour_number)
			end
		end
	end
	if table_length(storage.all_heat_pipes[unit_number].neighbours) > 1 then
		table.insert(storage.heatnet_changelog, unit_number)
		register_update_connected_reactors_event()
	end
	storage.all_heat_pipes[unit_number] = nil
end

function init_heat_pipes()
	storage.all_heat_pipes = {}
	storage.heatnet_changelog = {}
	for _, surface in pairs(game.surfaces) do
		hps = surface.find_entities_filtered{type = "heat-pipe"}
		for _,hp in pairs(hps) do
			add_heat_pipe(hp)
		end
	end
	for _, reactor in pairs(storage.reactors) do
		add_heat_pipe(reactor.core, reactor.id)
	end
end

function update_heatnet()
	local checked_pipes = {}
	for _, changelog_unit_number in pairs(storage.heatnet_changelog) do
		if not checked_pipes[changelog_unit_number] and storage.all_heat_pipes[changelog_unit_number] and storage.all_heat_pipes[changelog_unit_number].entity.valid then
			local subnet = {}
			local subnet_reactors = {}
			local todo = {changelog_unit_number}
			for _, unit_number in pairs(todo) do
				if not checked_pipes[unit_number] and storage.all_heat_pipes[unit_number] and storage.all_heat_pipes[unit_number].entity.valid then
					subnet[unit_number] = true
					checked_pipes[unit_number] = true
					if storage.all_heat_pipes[unit_number].reactor then
						table.insert(subnet_reactors, storage.all_heat_pipes[unit_number].reactor)
					end
					for neighbour_number in pairs(storage.all_heat_pipes[unit_number].neighbours) do
						table.insert(todo, neighbour_number)
					end
				end
			end
			for _,reactor_number in pairs(subnet_reactors) do
				storage.reactors[reactor_number].connected_neighbours_IDs = subnet_reactors
			end
		end
	end
	storage.heatnet_changelog = {}
end
