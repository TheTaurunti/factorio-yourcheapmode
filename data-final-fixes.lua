-- Globals for Compatibility
Excluded_Recipe_Names = {}
Excluded_Recipe_Categories = {}
Excluded_Recipe_Subgroups = {}

Ingredient_Equivalency_Groups = {}

require("utils")

-- Vanilla
require("compatibility.base")

-- Compatibility
require("compatibility.FreightForwarding")
require("compatibility.IntermodalContainers")
require("compatibility.Krastorio2")
require("compatibility.Mining_Drones")
require("compatibility.SpaceExploration")

-- Main
require("prototypes.recipe.recipe")
