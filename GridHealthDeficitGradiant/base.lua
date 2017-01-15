-- Defines a global addon object and relvant Grid module objects


local statusModule = Grid:NewStatusModule("GridHealthDeficitGradiant")
statusModule.menuName = "GridHealthDeficitGradiant"
statusModule.options = false


GridHealthDeficitGradiant = {
    utils={},
    statusModule=statusModule,
}

