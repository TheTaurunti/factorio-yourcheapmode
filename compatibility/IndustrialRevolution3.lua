if mods["IndustrialRevolution3"] then
	Excluded_Recipe_Subgroups["ir-canisters"] = true
	Excluded_Recipe_Subgroups["ir-module-reversed"] = true

	Excluded_Recipe_Categories["cryogenics"] = true
	Excluded_Recipe_Categories["heating"] = true


	-- Need to correct some recipes.
	local recipes = data.raw["recipe"]

	recipes["deprogram-speed-module"].ingredients[1][2] = RESULT_MULTIPLIER
	recipes["deprogram-speed-module-2"].ingredients[1][2] = RESULT_MULTIPLIER
	recipes["deprogram-speed-module-3"].ingredients[1][2] = RESULT_MULTIPLIER
	recipes["deprogram-effectivity-module"].ingredients[1][2] = RESULT_MULTIPLIER
	recipes["deprogram-effectivity-module-2"].ingredients[1][2] = RESULT_MULTIPLIER
	recipes["deprogram-effectivity-module-3"].ingredients[1][2] = RESULT_MULTIPLIER
	recipes["deprogram-productivity-module"].ingredients[1][2] = RESULT_MULTIPLIER
	recipes["deprogram-productivity-module-2"].ingredients[1][2] = RESULT_MULTIPLIER
	recipes["deprogram-productivity-module-3"].ingredients[1][2] = RESULT_MULTIPLIER

	-- Simplest way to deal with scrapping / resource recovery: disallow it
	for _, recipe in pairs(recipes) do
		if (recipe.category == "scrapping")
		then
			Remove_Recipe_Results(recipe)
		end
	end
end
