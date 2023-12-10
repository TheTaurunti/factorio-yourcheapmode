-- Globals for Compatibility
Mod_Excluded_Recipe_Names = {}
Mod_Excluded_Recipe_Categories = {}
Mod_Excluded_Recipe_Subgroups = {}

-- Compatibility
require("compatibility.data-final-fixes.FreightForwarding_final")
require("compatibility.data-final-fixes.IntermodalContainers_final")
require("compatibility.data-final-fixes.Krastorio2_final")

-- Mod Logic
require("prototypes.recipe.recipe")
