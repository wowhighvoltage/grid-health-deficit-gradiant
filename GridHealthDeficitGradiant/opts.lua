-- Configuration inputs and defaults


local module = GridHealthDeficitGradiant.statusModule


module.defaultDB = {
    deficit_gradiant = {
        enable = false,
        priority = 50,
        color_full_hp = { r = 0, g = 255, b = 0, a = 1 },
        color_threshold_hp = { r = 255, g = 0, b = 0, a = 1 },
        icon = nil,
        ignore_self = false,
        always_show = false,
        threshold_percentage = true,
        threshold = 0.5,
        threshold_percentage_value = 0.5,
        threshold_absolute_value = 10000,
    }
}


local function validateThreshold,


module._opts = {
    ignoreSelf = {
        name = "Ignore Self",
        desc = "Ignore heals cast by you.",
        type = "toggle", width = "double",
        order = 101,
        get = function()
            return module.db.profile.deficit_gradiant.ignore_self
        end,
        set = function(_, v)
            module.db.profile.deficit_gradiant.ignore_self = v
            module:UpdateAllUnits()
        end,
    },
    alwaysDisplay = {
        name = "Always Display (requires UI reload)",
        desc = "Show status even when players are at full HP.",
        type = "toggle", width = "double",
        order = 100,
        get = function()
            return module.db.profile.deficit_gradiant.always_show
        end,
        set = function(_, v)
            module.db.profile.deficit_gradiant.always_show = v
            module:UpdateAllUnits()
        end,
    },
    color1 = {
        name = "Full health color",
        desc = "Use this color when a player is at full health.",
        type = "color",
        order = 110,
        hasAlpha = true,
        get = function(t)
            local color = module.db.profile.deficit_gradiant.color_full_hp
            return color.r, color.g, color.b, color.a 
        end,
        set = function(t, r, g, b, a)
            local color = module.db.profile.deficit_gradiant.color_full_hp
            color.r, color.g, color.b, color.a = r, g, b, a 
        end,
    },
    color2 = {
        name = "Threshold health color",
        desc = "Use this color when a player is at the health threshold.",
        type = "color",
        order = 111,
        hasAlpha = true,
        get = function(t)
            local color = module.db.profile.deficit_gradiant.color_threshold_hp
            return color.r, color.g, color.b, color.a 
        end,
        set = function(t, r, g, b, a)
            local color = module.db.profile.deficit_gradiant.color_threshold_hp
            color.r, color.g, color.b, color.a = r, g, b, a 
        end,
    },
    threshold = {
        name = "Threshold",
        desc = "The threshold at which to change the indicators color.",
        type = "group",
        args = {
            is_percentage = {
                name = "Use Percentage Threshold",
                desc = "Use  a percetnage for the threshold",
                type = "toggle",
                width = "double",
                order = 1,
                get = function()
                    return module.db.profile.deficit_gradiant.threshold_percentage
                end,
                set = function(_, v)
                    module.db.profile.deficit_gradiant.threshold_percentage = v

                    local newThreshold
                    if v then
                        newThreshold = module.db.profile.deficit_gradiant.threshold_percentage_value
                    else
                        newThreshold = module.db.profile.deficit_gradiant.threshold_absolute_value
                    end

                    module.db.profile.deficit_gradiant.threshold_health = newThreshold
                end
            }
            abs = {
                name = "Absolute Value",
                type = "input",
                disabled = function()
                  return not module.db.profile.deficit_gradiant.threshold_percetange
                end
                order = 2,
                pattern = "^%s%d+%s*",
                get = function(t)
                  return module.db.profile.deficit_gradiant.threshold_absolute_value
                end,
                set = function(t, v)
                  local numericValue = tonumber(strmatch("^%s(%d+)%s*"))
                  module.db.profile.deficit_gradiant.threshold_health = numericValue
                  module.db.profile.deficit_gradiant.threshold_absolute_value = numericValue
                end
            },
            percentage = {
                name = "Percetage Value",
                type = "range",
                isPercent = true,
                max = 100,
                min = 0
                disabled = function()
                    return module.db.profile.deficit_gradiant.threshold_percetange
                end
                order = 4,
                get = function(t)
                    return module.db.profile.deficit_gradiant.threshold_percentage_value
                end,
                set = function(t, v)
                    module.db.profile.deficit_gradiant.threshold_absolute_value = v
                end
            }
        }
    }
}
