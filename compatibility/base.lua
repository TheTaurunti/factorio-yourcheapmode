-- Potentially-Gainful Recipe Loops (Nuclear Power)
Excluded_Recipe_Names["uranium-fuel-cell"] = true
Excluded_Recipe_Names["nuclear-fuel-reprocessing"] = true

-- Player items that aren't skipped automatically
Excluded_Recipe_Names["artillery-targeting-remote"] = true
Excluded_Recipe_Names["discharge-defense-remote"] = true

-- Rocket launches aren't affected by recipe output mult
Excluded_Recipe_Names["rocket-part"] = true

-- Of course, barreling
Excluded_Recipe_Subgroups["fill-barrel"] = true
Excluded_Recipe_Subgroups["empty-barrel"] = true

-- Retexturing concrete should not multiply it.
Excluded_Recipe_Names["hazard-concrete"] = true
Excluded_Recipe_Names["refined-hazard-concrete"] = true

-- Lots of mods like to convert between these two
Make_Equivalency_Group({ "water" }, { { "steam", 10 } })
