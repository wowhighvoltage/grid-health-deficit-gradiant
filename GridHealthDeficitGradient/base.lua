-- Defines a global addon object and relvant Grid module objects


local statusModule = Grid:NewStatusModule("GridHealthDeficitGradient")
statusModule.menuName = "GridHealthDeficitGradient"
statusModule.options = false


GridHealthDeficitGradient = {
    utils = {},
    statusModule = statusModule,
}

