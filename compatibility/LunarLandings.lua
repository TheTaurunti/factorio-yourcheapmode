if mods["LunarLandings"] then
	-- Packing rocket parts
	Excluded_Recipe_Names["ll-pack-rocket-control-unit"] = true
	Excluded_Recipe_Names["ll-pack-low-density-structure"] = true
	Excluded_Recipe_Names["ll-pack-heat-shielding"] = true
	Excluded_Recipe_Names["ll-unpack-rocket-control-unit"] = true
	Excluded_Recipe_Names["ll-unpack-low-density-structure"] = true
	Excluded_Recipe_Names["ll-unpack-heat-shielding"] = true
	Excluded_Recipe_Names["ll-used-rocket-part-recycling"] = true
	Excluded_Recipe_Names["rocket-part-down"] = true

	-- This both excludes the red mud recipe AND requires more of it.
	-- ... I wanted to keep it in, but make sure it wouldn't grant stupid resource quantities
	Input_Mult_Recipes["ll-red-mud-recovery"] = true
	Excluded_Recipe_Names["ll-red-mud-recovery"] = true

	-- Energy production
	Excluded_Recipe_Names["ll-rtg"] = true

	-- Steam recovery
	Excluded_Recipe_Names["ll-condense-steam"] = true

	-- Data Cards
	Excluded_Recipe_Names["ll-blank-data-card"] = true
	Excluded_Recipe_Names["ll-broken-data-card-recycling"] = true
	table.insert(Ingredient_Equivalency_Groups,
		{ "ll-blank-data-card", "ll-data-card", "ll-quantum-data-card", "ll-junk-data-card", "ll-broken-data-card" })

	-- Arcospheres
	table.insert(Ingredient_Equivalency_Groups,
		{ "ll-superposed-polariton", "ll-up-polariton", "ll-right-polariton", "ll-down-polariton", "ll-left-polariton" })
end
