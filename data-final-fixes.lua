-- Globals for Compatibility
Mod_Excluded_Recipe_Names = {}
Mod_Excluded_Recipe_Categories = {}
Mod_Excluded_Recipe_Subgroups = {}
Mod_Ingredient_Equivalencies = {}

table.insert(Mod_Ingredient_Equivalencies, { "water", "steam" })

-- Utils
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

-- Compatibility
require("compatibility.data-final-fixes.FreightForwarding")
require("compatibility.data-final-fixes.IntermodalContainers")
require("compatibility.data-final-fixes.Krastorio2")
require("compatibility.data-final-fixes.SpaceExploration")

-- Mod Logic
require("prototypes.recipe.recipe")
