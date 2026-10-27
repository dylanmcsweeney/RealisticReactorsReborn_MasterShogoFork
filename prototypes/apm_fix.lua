if mods["apm_nuclear"] then
	--data.raw.reactor["RRR-realistic-reactor-breeder"].energy_source.burnt_inventory_size = 2
	data.raw.item["RRR-realistic-reactor"].group = data.raw.item["apm_nuclear_breeder"].group
	data.raw.item["RRR-realistic-reactor"].subgroup = data.raw.item["apm_nuclear_breeder"].subgroup
	data.raw.item["RRR-breeder-reactor"].group = data.raw.item["apm_nuclear_breeder"].group
	data.raw.item["RRR-breeder-reactor"].subgroup = data.raw.item["apm_nuclear_breeder"].subgroup
end