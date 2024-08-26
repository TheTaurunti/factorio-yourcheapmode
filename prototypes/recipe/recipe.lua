-- ==================================
-- Add User-Defined Recipe Exclusions
-- ==================================

-- Thank you, https://stackoverflow.com/questions/1426954/split-string-in-lua
local USER_DEFINED_EXCLUDED_RECIPES = settings.startup["YourCheapMode-user-excluded-names"].value
for split_string in string.gmatch(USER_DEFINED_EXCLUDED_RECIPES, "([^" .. "," .. "]+)") do
	Excluded_Recipe_Names[split_string] = true
end


local ingredient_equivalency_matricies = {}
-- Equivalency groups take a little more work
-- Input of {"water", "steam"} becomes:
-- {
--   ["water"] = { ["steam"] = true },
--   ["steam"] = { ["water"] = true }
-- },

-- Input of {"water", "steam", "crude-oil"} becomes:
-- {
--   ["water"] = { ["steam"] = true, ["crude-oil"] = true },
--   ["steam"] = { ["water"] = true, ["crude-oil"] = true },
--   ["crude-oil"] = { ["water"] = true, ["steam"] = true }
-- }
for _, resource_group in ipairs(Ingredient_Equivalency_Groups) do
	for _, resource in ipairs(resource_group) do
		-- Ensure table exists
		if (not ingredient_equivalency_matricies[resource])
		then
			ingredient_equivalency_matricies[resource] = {}
		end

		-- Construct equivalencies
		for _, other_resource in ipairs(resource_group) do
			if (not (resource == other_resource))
			then
				ingredient_equivalency_matricies[resource][other_resource] = true
			end
		end
	end
end


-- ======================================
-- Excluding Player Items & Un-Stackables
-- ======================================

-- Player Items
local guns = data.raw["gun"]
local solar_equipments = data.raw["solar-panel-equipment"]
local generator_equipments = data.raw["generator-equipment"]
local battery_equipments = data.raw["battery-equipment"]
local belt_immunity_equipments = data.raw["belt-immunity-equipment"]
local exoskeleton_equipments = data.raw["movement-bonus-equipment"]
local roboport_equipments = data.raw["roboport-equipment"]
local nightvision_equipments = data.raw["night-vision-equipment"]
local energy_shield_equipments = data.raw["energy-shield-equipment"]
local active_defense_equipments = data.raw["active-defense-equipment"]

local function recipe_disallowed__player_items(recipe_name)
	if (guns[recipe_name]) then return true end
	if (solar_equipments[recipe_name]) then return true end
	if (generator_equipments[recipe_name]) then return true end
	if (battery_equipments[recipe_name]) then return true end
	if (belt_immunity_equipments[recipe_name]) then return true end
	if (exoskeleton_equipments[recipe_name]) then return true end
	if (roboport_equipments[recipe_name]) then return true end
	if (nightvision_equipments[recipe_name]) then return true end
	if (energy_shield_equipments[recipe_name]) then return true end
	if (active_defense_equipments[recipe_name]) then return true end

	return false
end


-- Un-Stackables
local armors = data.raw["armor"]
local cars = data.raw["car"]
local spider_vehicles = data.raw["spider-vehicle"]
local spidertron_remotes = data.raw["spidertron-remote"]
local rocket_silos = data.raw["rocket-silo"]

local function recipe_disallowed_for_stacking_issues(recipe_name)
	if (armors[recipe_name]) then return true end
	if (cars[recipe_name]) then return true end
	if (spider_vehicles[recipe_name]) then return true end
	if (spidertron_remotes[recipe_name]) then return true end
	if (rocket_silos[recipe_name]) then return true end

	return false
end


local function can_recipe_be_changed(recipe)
	if (Excluded_Recipe_Names[recipe.name]) then return false end
	if (Excluded_Recipe_Categories[recipe.category]) then return false end
	if (Excluded_Recipe_Subgroups[recipe.subgroup]) then return false end

	if (recipe_disallowed_for_stacking_issues(recipe.name)) then return false end
	if (recipe_disallowed__player_items(recipe.name)) then return false end

	return true
end

-- ==========================================================
-- Recipe Adjustment Functions (Lots of important stuff here)
-- ==========================================================

-- Functions
local function get_adjusted_recipe_result(catalyst_amount, result_amount)
	local result_net_gain = result_amount - catalyst_amount
	if (result_net_gain <= 0)
	then
		return result_amount
	end

	return catalyst_amount + (result_net_gain * RESULT_MULTIPLIER)
end

local function get_ingredients_simplified(recipe)
	local ret = {
		count = 0,
		table = {}
	}

	for _, ingredient in ipairs(recipe.ingredients) do
		local ingredient_name = ingredient.name or ingredient[1]
		local ingredient_amount = ingredient.amount or ingredient[2]

		ret.table[ingredient_name] = ingredient_amount
		ret.count = ret.count + 1
	end

	return ret
end


local function get_catalyst_quantity(ingredients, result_name, result_catalyst_quant)
	-- Exact resource match is obviously best. If there isn't one, then check the
	-- ... other ingredients for an "equivalent" that can be noted as a catalyst input
	local input_catalyst_amount = ingredients[result_name] or 0

	if (input_catalyst_amount == 0)
	then
		for ingred, count in pairs(ingredients) do
			if (ingredient_equivalency_matricies[ingred] and ingredient_equivalency_matricies[ingred][result_name])
			then
				input_catalyst_amount = input_catalyst_amount + count
			end
		end
	end

	return math.max(input_catalyst_amount, result_catalyst_quant)
end


local function get_recipe_result(recipe)
	local recipe_standard = recipe.normal or recipe
	local results = recipe_standard.results

	if (not results) then return recipe_standard.result end
	if (#results > 1) then return nil end

	if (results[1])
	then
		return results[1].name or results[1][1]
	end

	return nil
end

local function apply_recipe_changes(recipe)
	local recipe_standard = recipe.normal or recipe

	local simple_ingredients = get_ingredients_simplified(recipe_standard)
	if (simple_ingredients.count == 0) then return end
	local ingredients = simple_ingredients.table

	-- Edge Case - Single-Output Form
	-- Turns out that the single-output form is actually the exception.
	-- >> Most new things seem to use the products array (which is good)
	if (not recipe_standard.results)
	then
		local catalyst_amount = get_catalyst_quantity(ingredients, recipe_standard.result, 0)
		recipe_standard.result_count = get_adjusted_recipe_result(catalyst_amount, recipe_standard.result_count or 1)

		if (recipe_standard.result_count > catalyst_amount)
		then
			recipe_standard.energy_required = (recipe_standard.energy_required or 0.5) * CRAFTING_TIME_MULTIPLIER
		end

		return
	end

	-- Normal Case - Array-Output Form
	local one_or_more_results_multiplied = false
	for _, result in ipairs(recipe_standard.results) do
		local catalyst_quant = get_catalyst_quantity(
			ingredients,
			(result.name or result[1]),
			result.catalyst_amount or 0
		)

		if (result.amount_max)
		then
			if (result.amount_min and result.amount_min > 0)
			then
				result.amount_min = get_adjusted_recipe_result(catalyst_quant, result.amount_min)
			end

			result.amount_max = get_adjusted_recipe_result(catalyst_quant, result.amount_max)

			if (result.amount_max > catalyst_quant)
			then
				one_or_more_results_multiplied = true
			end
		else
			local result_amount = result.amount or result[2]

			if (result.amount)
			then
				result.amount = get_adjusted_recipe_result(catalyst_quant, result_amount)
			else
				result[2] = get_adjusted_recipe_result(catalyst_quant, result_amount)
			end

			if (result_amount > catalyst_quant)
			then
				one_or_more_results_multiplied = true
			end
		end
	end

	if (one_or_more_results_multiplied) then
		recipe_standard.energy_required = (recipe_standard.energy_required or 0.5) * CRAFTING_TIME_MULTIPLIER
	end
end

-- ===========================
-- Recipe Exclusion: Buildings
-- ===========================

local placeable_item_check_groups = {
	"item",
	"item-with-entity-data"
}

-- Find building item-names
local item_buildings_to_skip = {}
for _, group in ipairs(placeable_item_check_groups) do
	for _, thing in pairs(data.raw[group]) do
		if (thing.place_result)
		then
			item_buildings_to_skip[thing.name] = true
		end
	end
end


-- ================
-- Script Execution
-- ================

local recipes = data.raw["recipe"]

for _, recipe in pairs(recipes) do
	-- Check so we can skip buildings
	local result = get_recipe_result(recipe)
	if (result and item_buildings_to_skip[result])
	then
		Excluded_Recipe_Names[recipe.name] = true
	end

	--
	if (can_recipe_be_changed(recipe))
	then
		apply_recipe_changes(recipe)
	end
end
