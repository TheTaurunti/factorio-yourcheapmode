-------------------- Prep --------------------
RESULT_MULTIPLIER = settings.startup["YourCheapMode-recipe-result-multiplier"].value
CRAFTING_TIME_MULTIPLIER = settings.startup["YourCheapMode-recipe-time-multiplier"].value

Excluded_Recipe_Names = {}
Excluded_Recipe_Categories = {}
Excluded_Recipe_Subgroups = {}

Ingredient_Equivalency_Groups = {}

Input_Mult_Recipes = {}
Output_Prob_Division_Recipes = {}

-- Prep utils
require("utils")

-- Making list of placeable items. Needed earlier in script so Quality mod can reference.
Item_Buildings_To_Skip = {}
local placeable_item_check_groups = { "item", "item-with-entity-data" }
for _, group in ipairs(placeable_item_check_groups) do
  for _, thing in pairs(data.raw[group]) do
    if (thing.place_result)
    then
      Item_Buildings_To_Skip[thing.name] = true
    end
  end
end

-- Vanilla
require("compatibility.base")
require("compatibility.space-age")
require("compatibility.quality")

-- Compatibility
require("compatibility.electric-trains")
require("compatibility.FreightForwarding")
require("compatibility.IndustrialRevolution3")
require("compatibility.IntermodalContainers")
require("compatibility.kj_fuel")
require("compatibility.Krastorio2")
require("compatibility.LunarLandings")
require("compatibility.Mining_Drones")
require("compatibility.space-exploration")

-------------------- Main --------------------



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
-- Input of {{"water", 1}, {"steam", 10}} becomes:
-- {
--   ["water"] = { ["steam"] = 10 },
--   ["steam"] = { ["water"] = 0.1 }
-- },

-- Input of {{"water", 1}, {"steam", 10}, {"crude-oil", 5}} becomes:
-- {
--   ["water"] = { ["steam"] = 10, ["crude-oil"] = 5 },
--   ["steam"] = { ["water"] = 0.1, ["crude-oil"] = 0.5 },
--   ["crude-oil"] = { ["water"] = 0.2, ["steam"] = 2 }
-- }
for _, resource_group in ipairs(Ingredient_Equivalency_Groups) do
  for _, name_weight_pair in ipairs(resource_group) do
    local resource_name = name_weight_pair[1]

    -- Ensure table exists
    if (not ingredient_equivalency_matricies[resource_name])
    then
      ingredient_equivalency_matricies[resource_name] = {}
    end

    -- Construct equivalencies
    for _, other_pair in ipairs(resource_group) do
      if (not (resource_name == other_pair[1]))
      then
        ingredient_equivalency_matricies[resource_name][other_pair[1]] = (other_pair[2] / name_weight_pair[2])
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
local function calculate_adjusted_recipe_result(catalyst_amount, result_amount)
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

  if (recipe.ingredients)
  then
    for _, ingredient in ipairs(recipe.ingredients) do
      local ingredient_name = ingredient.name
      local ingredient_amount = ingredient.amount

      ret.table[ingredient_name] = ingredient_amount
      ret.count = ret.count + 1
    end
  end

  return ret
end


local function get_catalyst_quantity(ingredient_name_amounts_table, result_name, result_catalyst_quant)
  local input_catalyst_amount = ingredient_name_amounts_table[result_name] or 0

  if (input_catalyst_amount == 0)
  then
    for ingred, count in pairs(ingredient_name_amounts_table) do
      local entry = ingredient_equivalency_matricies[ingred]
      if (entry and entry[result_name])
      then
        input_catalyst_amount = input_catalyst_amount + math.floor((count * entry[result_name]) + 0.5)
      end
    end
  end

  return math.max(input_catalyst_amount, result_catalyst_quant)
end


local function apply_recipe_changes(recipe)
  local simple_ingredients = get_ingredients_simplified(recipe)
  if (simple_ingredients.count == 0) then return end


  -- Normal Case - Array-Output Form
  local one_or_more_results_multiplied = false
  for _, result in ipairs(recipe.results) do
    local catalyst_quant = get_catalyst_quantity(
      simple_ingredients.table,
      result.name,
      result.catalyst_amount or 0
    )

    if (result.amount_max)
    then
      if (result.amount_min and result.amount_min > 0)
      then
        result.amount_min = calculate_adjusted_recipe_result(catalyst_quant, result.amount_min)
      end

      result.amount_max = calculate_adjusted_recipe_result(catalyst_quant, result.amount_max)

      if (result.amount_max > catalyst_quant)
      then
        one_or_more_results_multiplied = true
      end
    else
      result.amount = calculate_adjusted_recipe_result(catalyst_quant, result.amount)

      if (result.amount > catalyst_quant)
      then
        one_or_more_results_multiplied = true
      end
    end
  end

  if (one_or_more_results_multiplied) then
    recipe.energy_required = (recipe.energy_required or 0.5) * CRAFTING_TIME_MULTIPLIER
  end
end




-- ================
-- Script Execution
-- ================

local recipes = data.raw["recipe"]

for _, recipe in pairs(recipes) do
  -- Skip buildings
  local result_name = Get_Recipe_Result_Name(recipe)
  if (result_name and Item_Buildings_To_Skip[result_name])
  then
    Excluded_Recipe_Names[recipe.name] = true
  end


  -- Things in "input_mult" and "output_division" tables will always be altered.
  if (Input_Mult_Recipes[recipe.name])
  then
    for _, ingred in ipairs(recipe.ingredients) do
      ingred.amount = ingred.amount * RESULT_MULTIPLIER
    end
  end

  -- Same end result as above, but intended for recyclers which might get stuck waiting for a second item.
  if (Output_Prob_Division_Recipes[recipe.name])
  then
    -- Sort of hacking an implicit meaning here, to allow for just changing
    -- ... one output's probability, instead of all of them always.
    local restrictions = Output_Prob_Division_Recipes[recipe.name]
    if (restrictions == true) then restrictions = nil end

    for _, result in ipairs(recipe.results) do
      if (not restrictions or (restrictions and restrictions[result.name])) then
        result.probability = (result.probability or 1.0) / RESULT_MULTIPLIER
      end
    end
  end


  if (can_recipe_be_changed(recipe))
  then
    apply_recipe_changes(recipe)
  end
end

-- ===============
