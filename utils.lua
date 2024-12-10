function Remove_Recipe_Result(recipe, result_name_to_remove)
  local new_results = {}
  local removed_result = nil

  for _, result in ipairs(recipe.results) do
    local name = result.name or result[1]

    if (name == result_name_to_remove)
    then
      removed_result = result
    else
      table.insert(new_results, result)
    end
  end

  recipe.results = new_results
  return removed_result
end

function Get_Recipe_Result_Name(recipe)
  return (recipe.results and #recipe.results == 1 and recipe.results[1].name) or nil
end

function Make_Equivalency_Group(names_singles, _names_with_vals)
  local all_equivs = {
    -- { "water", 1  },
    -- { "steam", 10 }
  }

  for _, name in ipairs(names_singles) do
    table.insert(all_equivs, { name, 1 })
  end

  _names_with_vals = _names_with_vals or {}
  for _, name_val_pair in ipairs(_names_with_vals) do
    table.insert(all_equivs, { name_val_pair[1], name_val_pair[2] })
  end

  table.insert(Ingredient_Equivalency_Groups, all_equivs)
end
