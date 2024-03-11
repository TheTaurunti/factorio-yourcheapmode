-- =============
-- Load Settings
-- =============

local RESULT_MULTIPLIER = settings.startup["YourCheapMode-recipe-result-multiplier"].value
local CRAFTING_TIME_MULTIPLIER = settings.startup["YourCheapMode-recipe-time-multiplier"].value
local EXCLUDE_PLAYER_ITEMS = settings.startup["YourCheapMode-player-items-exclusion"].value


-- ==================================
-- Add Mod-Defined Recipe Exclusions
-- ==================================

local excluded_recipe_names = {}
for _, recipe_name in ipairs(Mod_Excluded_Recipe_Names) do
  excluded_recipe_names[recipe_name] = true
end

local excluded_recipe_categories = {}
for _, recipe_category in ipairs(Mod_Excluded_Recipe_Categories) do
  excluded_recipe_categories[recipe_category] = true
end

local excluded_recipe_subgroups = {
  ["fill-barrel"] = true,
  ["empty-barrel"] = true
}
for _, recipe_subgroup in ipairs(Mod_Excluded_Recipe_Subgroups) do
  excluded_recipe_subgroups[recipe_subgroup] = true
end


local ingredient_equivalency_groups = {}
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
for _, resource_group in ipairs(Mod_Ingredient_Equivalencies) do
  for _, resource in ipairs(resource_group) do
    -- Ensure table exists
    if (not ingredient_equivalency_groups[resource])
    then
      ingredient_equivalency_groups[resource] = {}
    end

    -- Construct equivalencies
    for _, other_resource in ipairs(resource_group) do
      if (not (resource == other_resource))
      then
        ingredient_equivalency_groups[resource][other_resource] = true
      end
    end
  end
end



-- =========================
-- Recipe Exclusion: Vanilla
-- =========================

-- Potentially-Gainful Recipe Loops (Nuclear Power)
excluded_recipe_names["uranium-fuel-cell"] = true
excluded_recipe_names["nuclear-fuel-reprocessing"] = true

-- Multiplying rocket parts in the silo does nothing. This prevents visual error.
-- >> If there is a mod that produces rocket parts OUTSIDE of silo, this would be fine to have not-excluded
excluded_recipe_names["rocket-part"] = true

-- Player Items Exclusion Setting Check
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

if (EXCLUDE_PLAYER_ITEMS)
then
  excluded_recipe_names["artillery-targeting-remote"] = true
  excluded_recipe_names["discharge-defense-remote"] = true
end


-- Excluding troublesome non-stacking items/recipes
local armors = data.raw["armor"]
local cars = data.raw["car"]
local spider_vehicles = data.raw["spider-vehicle"]
local spidertron_remotes = data.raw["spidertron-remote"]
local rocket_silos = data.raw["rocket-silo"]

local function recipe_disallowed__special(recipe_name)
  if (armors[recipe_name]) then return true end
  if (cars[recipe_name]) then return true end
  if (spider_vehicles[recipe_name]) then return true end
  if (spidertron_remotes[recipe_name]) then return true end
  if (rocket_silos[recipe_name]) then return true end

  return false
end



local function recipe_changes_allowed(recipe)
  if (recipe_disallowed__special(recipe.name)) then return false end
  if (EXCLUDE_PLAYER_ITEMS and recipe_disallowed__player_items(recipe.name))
  then
    return false
  end

  if (excluded_recipe_names[recipe.name]) then return false end
  if (excluded_recipe_categories[recipe.category]) then return false end
  if (excluded_recipe_subgroups[recipe.subgroup]) then return false end

  return true
end


-- =====================================
-- Helper Functions For Script Execution
-- =====================================

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
      if (ingredient_equivalency_groups[ingred] and ingredient_equivalency_groups[ingred][result_name])
      then
        input_catalyst_amount = input_catalyst_amount + count
      end
    end
  end

  return math.max(input_catalyst_amount, result_catalyst_quant)
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

-- ================
-- Script Execution
-- ================

local recipes = data.raw["recipe"]

for _, recipe in pairs(recipes) do
  if (recipe_changes_allowed(recipe))
  then
    apply_recipe_changes(recipe)
  end
end
