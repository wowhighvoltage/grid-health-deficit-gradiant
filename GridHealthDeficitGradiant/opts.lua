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
            local color = module.db.profile.deficit_plus.color_full_hp,
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



function module:PostInitialize()
    settings = module.db.profile.deficit_plus
    self:RegisterStatus("deficit_gradiant", "Health Deficit Color Gradiant", opts, true)
end


function module:OnStatusEnable(status)
    self:Debug("OnStatusEnable", status)
    self:RegisterEvent("UNIT_HEALTH", "UpdateUnit")
    self:RegisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
    self:RegisterEvent("UNIT_HEAL_PREDICTION", "UpdateUnit")
    if settings.always_show then 
        self:RegisterEvent("UNIT_HEAL_PREDICTION", "UpdateUnit")
    end
    self:UpdateAllUnits()
end


function module:OnStatusDisable(status)
    self:Debug("OnStatusDisable", status)
    self:UnregisterEvent("UNIT_HEALTH")
    self:UnregisterEvent("UNIT_MAXHEALTH")
    self:UnregisterEvent("UNIT_HEAL_PREDICTION")
    if settings.always_show then 
        self:UnregisterEvent("UNIT_HEAL_PREDICTION")
    end
    self.core:SendStatusLostAllUnits(status)
end


function module:PostReset()
    settings = module.db.profile.deficit_plus
end


function module:UpdateAllUnits()
    for guid, unit in GridRoster:IterateRoster() do
        self:UpdateUnit("UpdateAllUnits", unit)
    end
end


function module:UpdateUnit(event, unit)
    if not unit then return end

    local guid = UnitGUID(unit)
    if not GridRoster:IsGUIDInRaid(guid) then return end

    if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
        local incoming = UnitGetIncomingHeals(unit) or 0
        local unitCurrentHealth = UnitHealth(unit)
        local unitMaxHealth = UnitHealthMax(unit)
        
        if (unitCurrentHealth < unitMaxHealth) or settings.always_show then
            self:Debug("UpdateUnit", unit, incoming, UnitGetIncomingHeals(unit, "player") or 0, format("%.2f%%", incoming / UnitHealthMax(unit) * 100))
            
            if settings.ignore_self then
                incoming = incoming - (UnitGetIncomingHeals(unit, "player") or 0)
            end
            self:SendIncomingHealsStatus(guid, incoming, unitCurrentHealth, unitMaxHealth)
            return
        end
    end
    self.core:SendStatusLost(guid, "deficit_gradiant")
end


function module:SendIncomingHealsStatus(guid, incoming, currentHealth, maxHealth)
    local effectiveDeficit = min(maxHealth, incoming + currentHealth - maxHealth)
    local threshold = settings.threshold
    local thresholdPercentage = settings.threshold_abs
    local smudgePosition
    local processedText = ""

    if (
        (not thresholdPercentage and effectiveDeficit > threshold) or
        (thresholdPercentage and (effectiveDeficit / maxHealth) > threshold)
    ) then
        smudgePosition = effectiveDeficit / threshold
    else
        smudgePosition = 1
    end

    local colorMode = GetSmudgeColor(
        settings.full_health_color,
        settings.threshold_health_color,
        smudgePosition
    )

    if math.abs(healthFromMax) > 9999 then
        processedText = format("%.0fk", healthFromMax / 1000)
    elseif math.abs(healthFromMax) > 999 then
        processedText = format("%.1fk", healthFromMax / 1000)
    else
        processedText = healthFromMax
    end
    
    if (healthFromMax > 0) then
        processedText =  "+" .. processedText
    end
    
    if (processedText == 0) then 
        processedText = "0"
    end
        
    self.core:SendStatusGained(guid, "deficit_gradiant",
        settings.priority,
        settings.range,
        colorMode,
        processedText,
        nil, 
        maxHealth,
        settings.icon
    )
end
