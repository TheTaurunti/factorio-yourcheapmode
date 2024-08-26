-- Globals for Compatibility
Excluded_Recipe_Names = {}
Excluded_Recipe_Categories = {}
Excluded_Recipe_Subgroups = {}

Ingredient_Equivalency_Groups = {}

-- Load Settings
RESULT_MULTIPLIER = settings.startup["YourCheapMode-recipe-result-multiplier"].value
CRAFTING_TIME_MULTIPLIER = settings.startup["YourCheapMode-recipe-time-multiplier"].value

-- Prep utils
require("utils")

-- Vanilla
require("compatibility.base")

-- Compatibility
require("compatibility.FreightForwarding")
require("compatibility.IndustrialRevolution3")
require("compatibility.IntermodalContainers")
require("compatibility.Krastorio2")
require("compatibility.Mining_Drones")
require("compatibility.space-exploration")

-- Main
require("prototypes.recipe.recipe")
