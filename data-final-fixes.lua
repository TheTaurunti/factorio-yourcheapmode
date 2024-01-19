-- Globals for Compatibility
Mod_Excluded_Recipe_Names = {}
Mod_Excluded_Recipe_Categories = {}
Mod_Excluded_Recipe_Subgroups = {}
Mod_Ingredient_Equivalencies = {}

table.insert(Mod_Ingredient_Equivalencies, { "water", "steam" })

-- Compatibility
require("compatibility.data-final-fixes.FreightForwarding")
require("compatibility.data-final-fixes.IntermodalContainers")
require("compatibility.data-final-fixes.Krastorio2")
require("compatibility.data-final-fixes.SpaceExploration")

-- Mod Logic
require("prototypes.recipe.recipe")
