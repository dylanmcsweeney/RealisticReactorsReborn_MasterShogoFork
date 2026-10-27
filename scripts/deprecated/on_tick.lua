--[[ -- could be used to steer heat transfer
-- replaces the reactor core entity with another one
function replace_reactor(reactor, new_reactor_entity_name)
	local temp = reactor.core.temperature
	--logging("Building reactor model: "..new_reactor_entity_name)
		
	-- get table entry index for reactor to be replaced
	local table_index
	for i,table_reactor in pairs(storage.reactors) do
		if table_reactor.id == reactor.id then
			table_index = i
		end
	end
	--logging("- old reactor ID: " .. reactor.id)
	--logging("- old reactor core ID: " .. reactor.core_id)
	
	-- create new reactor core
	new_reactor_core = reactor.core.surface.create_entity
	{
		name = new_reactor_entity_name,
		position = reactor.core.position,
		force = reactor.core.force, 
		create_build_effect_smoke = false		
	}
	--logging("- new reactor core ID: " .. new_reactor_core.unit_number)
	
	-- copy everything from old core to new core 
	new_reactor_core.copy_settings(reactor.core) --(what is this actually copying???)
	new_reactor_core.temperature = temp
	new_reactor_core.destructible = false
	--logging("-> updated temperature: " .. new_reactor_core.temperature)
	-- transfer burner heat and remaining fuel in burner

	--if reactor.state == 0 and not (storage.settings["RRR-scram-behaviour"] == "stop half-empty") then
	--	-- do nothing (don't transfer burner heat to a stopped or scramed reactor)
	--	if storage.settings["RRR-scram-behaviour"] == "consume additional cell" and reactor.displayer.burner.currently_burning then
	--		reactor.displayer.get_burnt_result_inventory().insert({name = reactor.displayer.burner.currently_burning.burnt_result.name, count = 1})
	--		reactor.displayer.burner.currently_burning = nil
	--	end
    --
	--	--logging("-> burner settings not transferred, state: stopped or scramed")
	--else
	--	-- transfer current burner settings
	--	--if reactor.core.burner.heat > 0 then --not reliable!
	--	if reactor.displayer.burner.remaining_burning_fuel > 0 then
			--new_reactor_core.burner.currently_burning = game.item_prototypes["uranium-fuel-cell"]
			--new_reactor_core.burner.currently_burning = reactor.displayer.burner.currently_burning
			new_reactor_core.burner.currently_burning = "rr-dummy-fuel-cell"
			new_reactor_core.burner.remaining_burning_fuel = 9223372035000000000
			new_reactor_core.burner.heat = reactor.displayer.burner.heat
			--logging("-> updated burner heat: " .. new_reactor_core.burner.heat)
			--new_reactor_core.burner.remaining_burning_fuel = reactor.displayer.burner.remaining_burning_fuel
			--logging("-> updated burner remaining_burning_fuel: " .. new_reactor_core.burner.remaining_burning_fuel)
	--	else
	--		--logging("-> burner settings not transferred, empty")
	--	end			
	--end
	
	new_reactor_core.minable = false -- core should be unminable in any case cause its removed via script

	--new_reactor_core.get_fuel_inventory().insert{name="RRR-dummy-fuel-cell", count = 50}
	
	

	-- destroy old core
	reactor.core.destroy()
	-- store new core
	reactor.core = new_reactor_core
	--update reactor core id with new core unit_number
	reactor.core_id = new_reactor_core.unit_number
	-- update table entry
	storage.reactors[table_index]=reactor
	
	--logging("-> reactor replaced")
	--logging("- new reactor ID: " .. reactor.id)
	--logging("- new reactor core ID: " .. reactor.core_id)
end
]]