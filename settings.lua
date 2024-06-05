data:extend({
  -- Core Mod Values
  {
    type = "int-setting",
    name = "YourCheapMode-recipe-result-multiplier",
    setting_type = "startup",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 5000
  },
  {
    type = "int-setting",
    name = "YourCheapMode-recipe-time-multiplier",
    setting_type = "startup",
    default_value = 5,
    minimum_value = 1,
    maximum_value = 360
  },

  {
    type = "string-setting",
    name = "YourCheapMode-user-excluded-names",
    setting_type = "startup",
    default_value = "",
    allow_blank = true,
    auto_trim = true
  }
})
