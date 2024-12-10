if mods["Krastorio2"] then
  -- Coal filtration is a problem recipe for this mod - needs direct changes
  Excluded_Recipe_Names["coal-filtration"] = true
  local coal_filtration_recipe = data.raw["recipe"]["coal-filtration"]
  if (coal_filtration_recipe)
  then
    Input_Mult_Recipes[coal_filtration_recipe.name] = true
  end

  -- Exclusion as normal
  Excluded_Recipe_Names["kr-air-cleaning"] = true
  Excluded_Recipe_Names["kr-air-cleaning-2"] = true
  Excluded_Recipe_Names["restore-used-pollution-filter"] = true
  Excluded_Recipe_Names["restore-used-improved-pollution-filter"] = true

  Excluded_Recipe_Names["kr-water"] = true
  Excluded_Recipe_Names["kr-water-separation"] = true

  Excluded_Recipe_Names["dirty-water-filtration-1"] = true
  Excluded_Recipe_Names["dirty-water-filtration-2"] = true
  Excluded_Recipe_Names["dirty-water-filtration-3"] = true

  Excluded_Recipe_Names["dt-fuel"] = true
  Excluded_Recipe_Names["kr-fusion"] = true

  Excluded_Recipe_Names["charge-stabilizer"] = true
  Excluded_Recipe_Names["charged-antimatter-fuel-cell"] = true

  Excluded_Recipe_Names["kr-intergalactic-transceiver"] = true

  Excluded_Recipe_Categories["crushing"] = true

  Excluded_Recipe_Subgroups["matter-conversion"] = true
  Excluded_Recipe_Subgroups["matter-deconversion"] = true
end
