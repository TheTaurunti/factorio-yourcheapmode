function Remove_Recipe_Result(recipe, result_name_to_remove)
	local recipe_standard = recipe.normal or recipe
	if (not recipe_standard.results) then return end

	local new_results = {}
	local removed_result = nil

	for _, result in ipairs(recipe_standard.results) do
		local name = result.name or result[1]

		if (name == result_name_to_remove)
		then
			removed_result = result
		else
			table.insert(new_results, result)
		end
	end

	recipe_standard.results = new_results
	return removed_result
end

function Add_Recipe_Result(recipe, result_to_add)
	local recipe_standard = recipe.normal or recipe
	if (not recipe_standard.results) then return end

	table.insert(recipe.results, result_to_add)
end

function Set_Recipe_Time(recipe, time)
	local recipe_standard = recipe.normal or recipe

	recipe_standard.energy_required = time
end

function Remove_Recipe_Results(recipe)
	local recipe_standard = recipe.normal or recipe

	if (recipe_standard.results)
	then
		recipe_standard.results = {}
	else
		recipe_standard.result = nil
		recipe_standard.result_count = 0
	end
end
