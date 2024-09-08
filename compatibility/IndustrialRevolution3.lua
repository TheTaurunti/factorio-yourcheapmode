if mods["IndustrialRevolution3"] then
	Excluded_Recipe_Names["charged-battery"] = true
	Excluded_Recipe_Names["charged-advanced-battery"] = true
	Excluded_Recipe_Names["charged-hydrogen-battery"] = true

	-- Barrel-Adjacents & module deprogramming
	Excluded_Recipe_Subgroups["ir-canisters"] = true

	-- Gas -> liquid -> gas exchange gains blocked by this
	Excluded_Recipe_Categories["cryogenics"] = true
	Excluded_Recipe_Categories["heating"] = true

	-- Prevents molten -> ingot -> molten resource gain
	Excluded_Recipe_Categories["melting"] = true
	Excluded_Recipe_Categories["ingot-casting"] = true

	-- Covers both programming and deprogramming modules
	Excluded_Recipe_Categories["module-loading"] = true

	table.insert(Ingredient_Equivalency_Groups, {
		"dirty-water",
		"dirty-steam"
	})


	-- I would rather disallow scrap results entirely than to figure out...
	-- ... what the appropriate costs or chances would be.
	local recipes = data.raw["recipe"]
	for _, recipe in pairs(recipes) do
		if (recipe.category == "scrapping")
		then
			Remove_Recipe_Results(recipe)
		end
	end

	-- old way of blocking module gains
	-- Excluded_Recipe_Subgroups["ir-module-reversed"] = true
	-- Need to correct some recipes.
	-- recipes["deprogram-speed-module"].ingredients[1][2] = RESULT_MULTIPLIER
	-- recipes["deprogram-speed-module-2"].ingredients[1][2] = RESULT_MULTIPLIER
	-- recipes["deprogram-speed-module-3"].ingredients[1][2] = RESULT_MULTIPLIER
	-- recipes["deprogram-effectivity-module"].ingredients[1][2] = RESULT_MULTIPLIER
	-- recipes["deprogram-effectivity-module-2"].ingredients[1][2] = RESULT_MULTIPLIER
	-- recipes["deprogram-effectivity-module-3"].ingredients[1][2] = RESULT_MULTIPLIER
	-- recipes["deprogram-productivity-module"].ingredients[1][2] = RESULT_MULTIPLIER
	-- recipes["deprogram-productivity-module-2"].ingredients[1][2] = RESULT_MULTIPLIER
	-- recipes["deprogram-productivity-module-3"].ingredients[1][2] = RESULT_MULTIPLIER
end
