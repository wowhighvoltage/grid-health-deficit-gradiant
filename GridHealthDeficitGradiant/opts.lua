-- Configuration inputs and defaults


local module = GridHealthDeficitGradiant.statusModule


module.defaultDB = {
    deficit_plus = {
        enable = false,
        priority = 50,
        color_full_hp = { r = 0, g = 255, b = 0, a = 1 },
        color_threshold_hp = { r = 255, g = 0, b = 0, a = 1 },
        icon = nil,
        ignore_self = false,
        always_show = false,
        threshold_percentage = true,
    }
}


module._opts = {
    color = false,
    ignoreSelf = {
        type = "toggle", width = "double",
        name = "Ignore Self",
        desc = "Ignore heals cast by you.",
        get = function()
            return module.db.profile.deficit_plus.ignore_self
        end,
        set = function(_, v)
            module.db.profile.deficit_plus.ignore_self = v
            module:UpdateAllUnits()
        end,
    },
    alwaysDisplay = {
        type = "toggle", width = "double",
        name = "Always Display (requires UI reload)",
        desc = "Show status even when players are at full HP.",
        get = function()
            return module.db.profile.deficit_plus.always_show
        end,
        set = function(_, v)
            module.db.profile.deficit_plus.always_show = v
            module:UpdateAllUnits()
        end,
    },
    color1 = {
        order = 100,
        name = "Full health color",
        desc = "Use this color when a player is at full health.",
        type = "color",
        hasAlpha = true,
        get = function(t)
            local color = module.db.profile.deficit_plus.color_full_hp
            return color.r, color.g, color.b, color.a 
        end,
        set = function(t, r, g, b, a)
            local color = module.db.profile.deficit_plus.color_full_hp
            color.r, color.g, color.b, color.a = r, g, b, a 
        end,
    },
    color2 = {
        order = 101,
        name = "Threshold health color",
        desc = "Use this color when a player is at the health threshold.",
        type = "color",
        hasAlpha = true,
        get = function(t)
            local color = module.db.profile.deficit_plus.color_threshold_hp
            return color.r, color.g, color.b, color.a 
        end,
        set = function(t, r, g, b, a)
            local color = module.db.profile.deficit_plus.color_threshold_hp
            color.r, color.g, color.b, color.a = r, g, b, a 
        end,
    },
    threshold_abs = {
        order = 103,
        type = "toggle", width = "double",
        name = "Use Percentage Threshold",
        desc = "Use  a percetnage for the threshold",
        get = function()
            return module.db.profile.deficit_plus.percentage_threshold
        end,
        set = function(_, v)
            module.db.profile.deficit_plus.percetange_threshold = v
            module:UpdateAllUnits()
        end,
    },
    threshold = {
        order = 105,
        name = "Threshold",
        desc = "The threshold at which to change the indicators color.",
        type = "input",
        get = function(t)
            return module.db.profile.deficit_plus.threshold_health
        end
        set = function(t, v)
            module.db.profile.deficit_plus.threshold_health = tonumber(v)
        end
    }
}
