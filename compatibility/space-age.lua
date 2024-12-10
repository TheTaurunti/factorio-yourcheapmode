if mods["space-age"] then
  Excluded_Recipe_Names["acid-neutralisation"] = true
  Excluded_Recipe_Names["space-platform-starter-pack"] = true

  -- Asteroid
  Excluded_Recipe_Categories["crushing"] = true

  Make_Equivalency_Group({ "ice" }, { { "water", 20 } })
  Make_Equivalency_Group({ "fluoroketone-hot", "fluoroketone-cold" })
end
