if mods["space-exploration"] then
  -- "Packing" and recipes like ingots, which are used to more densely transfer items in cargo ships
  Excluded_Recipe_Names["se-cargo-rocket-section-pack"] = true
  Excluded_Recipe_Names["se-cargo-rocket-section-unpack"] = true

  Excluded_Recipe_Names["se-plasma-canister"] = true
  Excluded_Recipe_Names["se-plasma-canister-empty"] = true
  Excluded_Recipe_Names["se-ion-canister"] = true
  Excluded_Recipe_Names["se-ion-canister-empty"] = true
  Excluded_Recipe_Names["se-antimatter-canister"] = true
  Excluded_Recipe_Names["se-empty-antimatter-canister"] = true -- why not named consistently?

  -- Ice <-> Fluid Conversion Recipes
  Excluded_Recipe_Names["se-cryonite-to-water-ice"] = true
  Excluded_Recipe_Names["se-melting-water-ice"] = true
  Excluded_Recipe_Names["se-cryonite-to-methane-ice"] = true
  Excluded_Recipe_Names["se-melting-methane-ice"] = true

  -- Special case exclusions (win-con doesn't need a time extension)
  Excluded_Recipe_Names["se-distortion-drive"] = true

  -- Refurbishment / "Fixing an item" recipes
  Excluded_Recipe_Names["se-space-capsule-refurbish"] = true

  -- Recycling Facility
  Excluded_Recipe_Categories["hand-hard-recycling"] = true
  Excluded_Recipe_Categories["hard-recycling"] = true

  -- Other troublesome areas
  Excluded_Recipe_Categories["delivery-cannon"] = true
  Excluded_Recipe_Categories["core-fragment-processing"] = true

  -- Thermofluid
  table.insert(Ingredient_Equivalency_Groups, {
    "se-space-coolant-hot",
    "se-space-coolant-warm",
    "se-space-coolant-cold",
    "se-space-coolant-supercooled"
  })

  -- Similar to barreling, but for the particle streams
  table.insert(Ingredient_Equivalency_Groups, {
    "se-magnetic-canister",

    "se-plasma-canister",
    "se-ion-canister",
    "se-antimatter-canister",
  })

  -- Life Support (avoid duplicating containers)
  table.insert(Ingredient_Equivalency_Groups, {
    "se-lifesupport-canister",
    "se-used-lifesupport-canister",
    "se-empty-lifesupport-canister"
  })

  -- Decontamination
  table.insert(Ingredient_Equivalency_Groups, {
    "se-scrap",
    "se-contaminated-scrap"
  })
  table.insert(Ingredient_Equivalency_Groups, {
    "se-space-water",
    "se-contaminated-space-water"
  })
  table.insert(Ingredient_Equivalency_Groups, {
    "se-bio-sludge",
    "se-contaminated-bio-sludge"
  })


  -- ==================================
  -- Data Cards Are Ruining My Life !!!
  -- ==================================


  -- Having no prod in space is cool. Keeps you from just doing everything in space.
  -- The prevalence of data cards and the fact that they are recycled throws a major wrench in this mod
  -- ... since it introduces resource loops all over the place.
  -- >> The solution I've decided to go with is to remove data card recycling. Junk cards can get reformatted into
  -- ... scrap cards still, and to make the further tiers of reformatting worthwhile I've altered
  -- ... the time it takes for those recipes as well.
  local recipes = data.raw["recipe"]

  local formatting_1 = recipes["se-formatting-1"]
  local formatting_2 = recipes["se-formatting-2"]
  local formatting_3 = recipes["se-formatting-3"]
  local formatting_4 = recipes["se-formatting-4"]

  Excluded_Recipe_Names["se-formatting-1"] = true
  Excluded_Recipe_Names["se-formatting-2"] = true
  Excluded_Recipe_Names["se-formatting-3"] = true
  Excluded_Recipe_Names["se-formatting-4"] = true

  formatting_1.energy_required = 60
  formatting_1.results = {
    { type = "item",  name = "se-broken-data",       amount = 1, probability = 0.1 },
    { type = "item",  name = "se-scrap",             amount = 1, probability = 0.9 },
    { type = "fluid", name = "se-space-coolant-hot", amount = 1 },
  }

  formatting_2.energy_required = 30
  formatting_2.results = {
    { type = "item",  name = "se-broken-data",       amount = 1, probability = 0.2 },
    { type = "item",  name = "se-scrap",             amount = 1, probability = 0.8 },
    { type = "fluid", name = "se-space-coolant-hot", amount = 1 },
  }

  formatting_3.energy_required = 15
  formatting_3.results = {
    { type = "item",  name = "se-broken-data",       amount = 1, probability = 0.4 },
    { type = "item",  name = "se-scrap",             amount = 1, probability = 0.6 },
    { type = "fluid", name = "se-space-coolant-hot", amount = 1 },
  }

  formatting_4.energy_required = 5
  formatting_4.results = {
    { type = "item",  name = "se-broken-data",       amount = 1, probability = 0.8 },
    { type = "item",  name = "se-scrap",             amount = 1, probability = 0.2 },
    { type = "item",  name = "se-cryonite-rod",      amount = 1, probability = 0.9 },
    { type = "fluid", name = "se-space-coolant-hot", amount = 1 },
  }

  Remove_Recipe_Result(recipes["se-forcefield-data"], "se-empty-data")
  Remove_Recipe_Result(recipes["se-timespace-anomaly-data"], "se-empty-data")
  Remove_Recipe_Result(recipes["se-dark-energy-data"], "se-empty-data")
  --Remove_Recipe_Result(recipes[], "se-empty-data")

  local data_card_output_recipes = {
    -- All the simulation->Significant insight recipes
    "se-simulation-a",
    "se-simulation-s",
    "se-simulation-b",
    "se-simulation-m",

    "se-simulation-as",
    "se-simulation-ab",
    "se-simulation-am",
    "se-simulation-sb",
    "se-simulation-sm",
    "se-simulation-bm",

    "se-simulation-asb",
    "se-simulation-asm",
    "se-simulation-abm",
    "se-simulation-sbm",

    "se-simulation-asbm",

    -- Tier-1 Insight
    "se-astronomic-insight-1",
    "se-energy-insight-1",
    "se-material-insight-1",
    "se-biological-insight-1",

    -- etc
    "se-distortion-drive"
  }

  for _, v in ipairs(data_card_output_recipes) do
    local recipe = recipes[v]

    local removed = Remove_Recipe_Result(recipe, "se-empty-data")
    removed.name = "se-junk-data"
    Add_Recipe_Result(recipe, removed)
  end
end
