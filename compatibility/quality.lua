if mods["quality"] then
  Excluded_Recipe_Categories["recycling"] = true

  -- Recycling recipes will have outputs reduced according to multiplier
  local recipes = data.raw["recipe"]
  for recipe_name, recipe in pairs(recipes) do
    local recipe_result_item_name = Get_Recipe_Result_Name(recipe)
    if (recipe.category == "recycling" and not Item_Buildings_To_Skip[recipe_result_item_name])
    then
      Output_Prob_Division_Recipes[recipe_name] = true
    end
  end
end
