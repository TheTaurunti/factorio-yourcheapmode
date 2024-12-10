if mods["electric-trains"] then
  Make_Equivalency_Group({
    "electric-train-battery-pack",
    "electric-train-discharged-battery-pack",
    "electric-train-destroyed-battery-pack"
  })
  Make_Equivalency_Group({
    "space-train-battery-pack",
    "space-train-discharged-battery-pack",
    "space-train-destroyed-battery-pack"
  })

  Make_Equivalency_Group({
    "acceleration-battery-pack",
    "discharged-acceleration-battery-pack"
  })
  Make_Equivalency_Group({
    "efficiency-battery-pack",
    "discharged-efficiency-battery-pack"
  })
  Make_Equivalency_Group({
    "speed-battery-pack",
    "discharged-speed-battery-pack"
  })
end
