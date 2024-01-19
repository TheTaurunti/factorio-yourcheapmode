if mods["FreightForwarding"] then
  table.insert(Mod_Excluded_Recipe_Names, "ff-charge-battery")
  table.insert(Mod_Excluded_Recipe_Names, "ff-charge-battery-pack")

  table.insert(Mod_Excluded_Recipe_Names, "ff-titansteel-heating")

  -- As of 1.0.7, these two should be fine to remove. Just need to test if that is the case.
  table.insert(Mod_Excluded_Recipe_Names, "ff-titansteel-cooling")
  table.insert(Mod_Excluded_Recipe_Names, "ff-water-condensing")
end
