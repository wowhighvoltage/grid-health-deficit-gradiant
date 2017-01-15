-- Grid module hooks


local GridRoster = Grid:GetModule("GridRoster")
local module = GridHealthDeficitGradiant.statusModule


function module:PostInitialize()
    self:RegisterStatus("deficit_gradiant", "Health Deficit Color Gradiant", module._opts, true)
end


function module:OnStatusEnable(status)
    self:Debug("OnStatusEnable", status)
    self:RegisterEvent("UNIT_HEALTH", "UpdateUnit")
    self:RegisterEvent("UNIT_MAXHEALTH", "UpdateUnit")
    self:RegisterEvent("UNIT_HEAL_PREDICTION", "UpdateUnit")
    if module.db.profile.deficit_gradiant.always_show then 
        self:RegisterEvent("UNIT_HEAL_PREDICTION", "UpdateUnit")
    end
    self:UpdateAllUnits()
end


function module:OnStatusDisable(status)
    self:Debug("OnStatusDisable", status)
    self:UnregisterEvent("UNIT_HEALTH")
    self:UnregisterEvent("UNIT_MAXHEALTH")
    self:UnregisterEvent("UNIT_HEAL_PREDICTION")
    if module.db.profile.deficit_gradiant.always_show then 
        self:UnregisterEvent("UNIT_HEAL_PREDICTION")
    end
    self.core:SendStatusLostAllUnits(status)
end


function module:UpdateAllUnits()
    for guid, unit in GridRoster:IterateRoster() do
        self:UpdateUnit("UpdateAllUnits", unit)
    end
end


function module:UpdateUnit(event, unit)
    if not unit then
        return
    end

    local guid = UnitGUID(unit)

    if not GridRoster:IsGUIDInRaid(guid) then
        return
    end

    if UnitIsVisible(unit) and not UnitIsDeadOrGhost(unit) then
        local settings = module.db.profile.deficit_gradiant
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
    local settings = module.db.profile.deficit_gradiant
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

    local colorMode =  GridHealthDeficitGradiant.utils.color.CalculateRGBColorAtPosition(
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
