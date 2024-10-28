if mods["electric-trains"] then
	table.insert(Ingredient_Equivalency_Groups,
		{
			"electric-train-battery-pack",
			"electric-train-discharged-battery-pack",
			"electric-train-destroyed-battery-pack"
		}
	)

	table.insert(Ingredient_Equivalency_Groups,
		{
			"space-train-battery-pack",
			"space-train-discharged-battery-pack",
			"space-train-destroyed-battery-pack"
		}
	)

	table.insert(Ingredient_Equivalency_Groups,
		{ "acceleration-battery-pack", "discharged-acceleration-battery-pack" })

	table.insert(Ingredient_Equivalency_Groups,
		{ "efficiency-battery-pack", "discharged-efficiency-battery-pack" })

	table.insert(Ingredient_Equivalency_Groups,
		{ "speed-battery-pack", "discharged-speed-battery-pack" })
end
