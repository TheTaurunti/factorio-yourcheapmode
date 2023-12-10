-- =======================
-- Variable Initialization
-- =======================

local RESULT_MULTIPLIER = settings.startup["YourCheapMode-recipe-result-multiplier"].value
local CRAFTING_TIME_MULTIPLIER = settings.startup["YourCheapMode-recipe-time-multiplier"].value
local EXCLUDE_PLAYER_ITEMS = settings.startup["YourCheapMode-player-items-exclusion"].value

local excluded_recipe_names = {}
local excluded_recipe_categories = {}
local excluded_recipe_subgroups = {
  ["fill-barrel"] = true,
  ["empty-barrel"] = true
}



-- ==================================
-- Add User-Defined Recipe Exclusions
-- ==================================

local function add_user_defined_exclusions(target_table, user_input)
  -- Thank you, https://stackoverflow.com/questions/1426954/split-string-in-lua
  for split_string in string.gmatch(user_input, "([^" .. "," .. "]+)") do
    target_table[split_string] = true
    -- table.insert(target_table, split_string)
  end
end

add_user_defined_exclusions(excluded_recipe_names, settings.startup["YourCheapMode-user-excluded-names"].value)
add_user_defined_exclusions(excluded_recipe_categories, settings.startup["YourCheapMode-user-excluded-categories"].value)
add_user_defined_exclusions(excluded_recipe_subgroups, settings.startup["YourCheapMode-user-excluded-subgroups"].value)



-- ==================================
-- Add Mod-Defined Recipe Exclusions
-- ==================================

for _, recipe_name in ipairs(Mod_Excluded_Recipe_Names) do
  excluded_recipe_names[recipe_name] = true
  -- table.insert(excluded_recipe_names, recipe_name)
end

for _, recipe_category in ipairs(Mod_Excluded_Recipe_Categories) do
  excluded_recipe_categories[recipe_category] = true
  -- table.insert(excluded_recipe_categories, recipe_name)
end

for _, recipe_subgroup in ipairs(Mod_Excluded_Recipe_Subgroups) do
  excluded_recipe_subgroups[recipe_subgroup] = true
  -- table.insert(excluded_recipe_subgroups, recipe_name)
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
  -- If items similar to these are added by another mod...
  -- ... they should be excluded as well for consistency.
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



-- =====================================
-- Helper Functions For Script Execution
-- =====================================

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


local function get_adjusted_recipe_result(catalyst_amount, result_amount)
  local result_net_gain = result_amount - catalyst_amount
  if (result_net_gain <= 0)
  then
    return result_amount
  end

  return catalyst_amount + (result_net_gain * RESULT_MULTIPLIER)
end


local function apply_recipe_changes(recipe)
  local recipe_standard = recipe.normal or recipe

  -- Extra logic with ingredients to avoid multiplying catalyst resources
  local ingredients_count = 0
  local ingredients = {}
  for _, ingredient in pairs(recipe_standard.ingredients) do
    local ingredient_name = ingredient.name and ingredient.name or ingredient[1]
    local ingredient_amount = ingredient.amount and ingredient.amount or ingredient[2]

    ingredients[ingredient_name] = ingredient_amount
    ingredients_count = ingredients_count + 1
  end

  -- 0-Cost recipes can be skipped
  if (ingredients_count == 0) then return end

  -- Set Output Mult
  local output_modified = false
  if (recipe_standard.results)
  then
    for _, result in ipairs(recipe_standard.results) do
      local result_name = result.name or result[1]

      local input_catalyst_amount = ingredients[result_name] and ingredients[result_name] or 0
      local output_catalyst_amount = result.catalyst_amount or 0
      local greater_catalyst_amount = math.max(input_catalyst_amount, output_catalyst_amount)


      -- here is where check and logic split for amount_min amount_max happens
      if (result.amount_max)
      then
        if (result.amount_min and result.amount_min > 0)
        then
          result.amount_min = get_adjusted_recipe_result(greater_catalyst_amount, result.amount_min)
        end

        result.amount_max = get_adjusted_recipe_result(greater_catalyst_amount, result.amount_max)


        if (result.amount_max > greater_catalyst_amount)
        then
          output_modified = true
        end
      else
        local result_amount = result.amount or result[2]
        local adjusted_result_amount = get_adjusted_recipe_result(greater_catalyst_amount, result_amount)

        if (result.amount)
        then
          result.amount = adjusted_result_amount
        else
          result[2] = adjusted_result_amount
        end

        if (result_amount > greater_catalyst_amount)
        then
          output_modified = true
        end
      end
    end
  else
    -- Turns out that the single-output form is actually the relic.
    -- >> Most new things seem to use the products array (which is good)
    local input_catalyst_amount = ingredients[recipe_standard.result] and ingredients[recipe_standard.result] or 0
    recipe_standard.result_count = get_adjusted_recipe_result(input_catalyst_amount, recipe_standard.result_count or 1)
    output_modified = true
  end

  -- Checking for if an output was modified covers cases where catalyst item output was not changed.
  if (output_modified)
  then
    -- Set Time Mult
    local base_recipe_time = recipe_standard.energy_required or 0.5
    recipe_standard.energy_required = base_recipe_time * CRAFTING_TIME_MULTIPLIER
  end
end



-- ========================
-- Script / Logic Execution
-- ========================

local recipes = data.raw["recipe"]

for _, recipe in pairs(recipes) do
  if (recipe_changes_allowed(recipe))
  then
    apply_recipe_changes(recipe)
  end
end
