if mods["Krastorio2"] then
  local coal_filtration_recipe = data.raw["recipe"]["coal-filtration"]
  if (coal_filtration_recipe)
  then
    local input_heavy_oil_amount = coal_filtration_recipe.ingredients[1].amount
    coal_filtration_recipe.ingredients[1].amount = input_heavy_oil_amount *
    settings.startup["YourCheapMode-recipe-result-multiplier"].value
  end
end
