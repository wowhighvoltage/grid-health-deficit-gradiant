-- Defines functions to help with color transitions


local CS = CreateFrame("ColorSelect")
local module = {}


local function ConvertColorRgbToHsv(color)
    -- Converts  a color from RGB to HSV
    CS:SetColorRGB(color.r, color.g, color.b)
    local h, s, v = CS:GetColorHSV()
    return {h=h, s=s, v=v, a=color.a}
end

     
local function ConvertColorHsvToRgb(color)
    -- Converts  a color from HSV to RGB
    CS:SetColorHSV(color.h, color.s, color.v)
    local r, g, b = CS:GetColorRGB()
    return {r=r, g=g, b=b, a=color.a}
end

     
function module:CalculateHSVColorAtPosition(color1, color2, position)
    -- Calculate the color on a color gradiant between color1 and color2
    -- at a given postion between color1 and color2. Position is between
    -- 0 and 1, with 0 being color1 and 1 being color2. Uses HSV values.
    local colorAtPos = {}
    if abs(color1.h - color2.h) > 180 then
        local angle = (360 - abs(color1.h - color2.h)) * position
        if color1.h < color2.h then
            colorAtPos.h = floor(color1.h - angle)
            if colorAtPos.h < 0 then
                colorAtPos.h = colorAtPos.h + 360
            end
        else
            colorAtPos.h = floor(color1.h + angle)
            if colorAtPos.h > 360 then
                colorAtPos.h = colorAtPos.h - 360
            end
        end
    else
        colorAtPos.h = floor(color1.h - (color1.h - color2.h) * position)
    end    

    colorAtPos.s = color1.s - (color1.s - color2.s) * position
    colorAtPos.v = color1.v - (color1.v - color2.v) * position

    colorAtPost.a = abs(color1.a - color2.a) * position

    return colorAtPos
end

     
function module:CalculateRGBColorAtPosition(color1, color2, position)
    -- Same as CalculateHSVColorAtPosition but uses RBG values
    local hsvColor1 = ConvertColorRgbToHsv(color1)
    local hsvColor2 = ConvertColorRgbToHsv(color2)
    local hsvColorAtPosition = self:CalculateHSVColorAtPosition(hsvColor1, hsvColor2, position)
    return ConvertColorHsvToRgb(hsvColorAtPosition)
end


GridHealthDeficitGradiant.utils.color = module
