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


module._opts = {
    color = false,
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
    colors = {
        name = "Color at...",
        type = "group",
        inline = true,
        order = 110,
        args = {
            color1 = {
                name = "full health",
                type = "color",
                order = 1,
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
                name = "threshold health",
                type = "color",
                order = 2,
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
        },
    },
    threshold = {
        name = "Deficit threshold",
        type = "group",
        inline = true,
        order = 120,
        args = {
            is_percentage = {
                name = "Use percentage",
                desc = "Use  a percentage for the threshold",
                type = "toggle",
                width = "double",
                order = 1,
                get = function()
                    return module.db.profile.deficit_gradiant.threshold_percentage
                end,
                set = function(_, v)
                    module.db.profile.deficit_gradiant.threshold_percentage = v

                    local newThreshold
                    local inputFields = module._opts.threshold.args
                    if v then
                        newThreshold = module.db.profile.deficit_gradiant.threshold_percentage_value
                    else
                        newThreshold = module.db.profile.deficit_gradiant.threshold_absolute_value
                    end

                    module.db.profile.deficit_gradiant.threshold_health = newThreshold
                end
            },
            abs = {
                name = "",
                type = "range",
                min = 0,
                max = 1000000000,
                softMax = 30000,
                step = 100,
                disabled = function()
                    return module.db.profile.deficit_gradiant.threshold_percentage
                end,
                order = 5,
                get = function(t)
                    return module.db.profile.deficit_gradiant.threshold_absolute_value
                end,
                set = function(t, v)
                    module.db.profile.deficit_gradiant.threshold_absolute_value = v
                    if not module.db.profile.deficit_gradiant.threshold_percentage then
                        module.db.profile.deficit_gradiant.threshold_health = v
                    end
                end
            },
            percentage = {
                name = "",
                type = "range",
                order = 3,
                isPercent = true,
                min = 0,
                max = 1,
                disabled = function()
                    return not module.db.profile.deficit_gradiant.threshold_percentage
                end,
                get = function(t)
                    return module.db.profile.deficit_gradiant.threshold_percentage_value
                end,
                set = function(t, v)
                    module.db.profile.deficit_gradiant.threshold_percentage_value = v
                    if module.db.profile.deficit_gradiant.threshold_percentage then
                        module.db.profile.deficit_gradiant.threshold_health = v
                    end
                end
            }
        }
    }
}
