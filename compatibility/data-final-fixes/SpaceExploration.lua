if mods["space-exploration"] then
  -- "Packing" and recipes like ingots, which are used to more densely transfer items in cargo ships
  table.insert(Mod_Excluded_Recipe_Names, "se-cargo-rocket-section-pack")
  table.insert(Mod_Excluded_Recipe_Names, "se-cargo-rocket-section-unpack")

  -- Ice <-> Fluid Conversion Recipes
  table.insert(Mod_Excluded_Recipe_Names, "se-cryonite-to-water-ice")
  table.insert(Mod_Excluded_Recipe_Names, "se-melting-water-ice")
  table.insert(Mod_Excluded_Recipe_Names, "se-cryonite-to-methane-ice")
  table.insert(Mod_Excluded_Recipe_Names, "se-melting-methane-ice")

  -- Life Support (avoid duplicating containers)
  table.insert(Mod_Excluded_Recipe_Names, "se-lifesupport-canister-fish")
  table.insert(Mod_Excluded_Recipe_Names, "se-lifesupport-canister-coal")
  table.insert(Mod_Excluded_Recipe_Names, "se-lifesupport-canister-specimen")
  table.insert(Mod_Excluded_Recipe_Names, "se-used-lifesupport-canister-cleaning")

  -- Refurbishment / "Fixing an item" recipes
  table.insert(Mod_Excluded_Recipe_Names, "se-space-capsule-refurbish")

  -- Recycling Facility
  table.insert(Mod_Excluded_Recipe_Categories, "hand-hard-recycling")
  table.insert(Mod_Excluded_Recipe_Categories, "hard-recycling")

  -- Decontamination Facility
  table.insert(Mod_Excluded_Recipe_Names, "se-bio-sludge-decontamination")
  table.insert(Mod_Excluded_Recipe_Names, "se-space-water-decontamination")
  table.insert(Mod_Excluded_Recipe_Names, "se-scrap-decontamination")
  table.insert(Mod_Excluded_Recipe_Names, "se-used-lifesupport-canister-cleaning-space")



  -- Steam <-> Water Conversion Recipes
  -- >> Might not be needed once ingredient equivalencies are working correctly.
  --table.insert(Mod_Excluded_Recipe_Names, "se-pyroflux-steam")
  --table.insert(Mod_Excluded_Recipe_Names, "se-steam-to-water")
  --table.insert(Mod_Excluded_Recipe_Categories, "condenser-turbine")
  --table.insert(Mod_Excluded_Recipe_Categories, "se-electric-boiling")

  -- Thermofluid
  table.insert(Mod_Ingredient_Equivalencies, {
    "se-space-coolant-hot",
    "se-space-coolant-warm",
    "se-space-coolant-cold",
    "se-space-coolant-supercooled"
  })

  -- Some data cards
  table.insert(Mod_Ingredient_Equivalencies, {
    "se-junk-data",
    "se-empty-data",
    "se-broken-data"
  })
end
