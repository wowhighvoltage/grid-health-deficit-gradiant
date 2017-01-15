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

    local hue1 = color1.h % 360
    local hue2 = color2.h % 360

    local direction = hue1 < hue2 and 1 or -1
    local hueDiff = abs(hue1 - hue2)

    if hueDiff > 180 then
        hueDiff = 360 - diff
        direction = -1 * direction
    end

    colorAtPos.h = hue1 + direction * floor(hueDiff * position)

    for _, v in pairs({'s', 'v', 'a'}) do
        colorAtPos[k] = color1[k] - (color1[k] - color2[k]) * position
    end

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
