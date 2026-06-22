----------------------------------Explication du programme--------------------------------------
-- Se système est conçus pour s'afficher sur cette écran : Console Monitor
-- La taille de l'écran est de : w=862px | h=584px
-- Cette écran à été dimmensionné avec : https://www.figma.com
---------------------------------------Objectif-------------------------------------------------

------------------------------------------------------------------------------------------------



-----------------------------------------------------
-- import de la librairie
-----------------------------------------------------

local system = require("system")
local scriptedScreen = require("scriptedScreen")


-----------------------------------------------------
-- Création des écran
-----------------------------------------------------

local currentUi = "auto"
-- Déffinition des parametre de chaque écran
---@param name string
local function createScreen(name)
    if type(name) ~= "string" then
        print(system.log.time() .. "h " .. system.log.level("fatal") .. " : La création d'un écran a échoué son id n'est pas de type string : " .. system.utils.color("Yellow", tostring(name)))
        error("La création d'un écran a échoué son id n'est pas de type string : " .. system.utils.color("Yellow", tostring(name)))
    end

    local surface = ss.ui.surface(name)
    return {
        -- Rend accessible la surface pour utilisation ulterieur
        surface = surface,
        -- Renvoie l'id d e l'écran
        id = name,
        -- Affiche l'écran
        set = function()
            -- Retourne l'id de la page acctuel
            currentUi = name
            ss.ui.activate(name)
        end,
        -- Retire tout les élément afficher a l'écran
        clear = function ()
            surface:clear()            
        end,
    }
end


--Liste toute les page 
local ui = {
    oresQuantity = createScreen("oresQuantity"),
}


-----------------------------------------------------
-- Déffinition d'une résolution
-----------------------------------------------------

local size = ui.oresQuantity.surface:size()

-- Déffinition de la taille de l'écran virtuelle
local w, h = size.w, size.h
print(system.log.time() .. "h " .. system.log.level("debug") .. " : w=" .. w .. " | h=" .. h)


-----------------------------------------------------
-- Initialisation des ecran
-----------------------------------------------------

ui.oresQuantity.clear()
ui.oresQuantity.set()

-----------------------------------------------------
-- Déffinition des données
-----------------------------------------------------

local reference_w = 862 --Ecran de réference pour le calibrage du programme pour convertire en pourcentage
local reference_h = 584 --Ecran de réference pour le calibrage du programme pour convertire en pourcentage



-----------------------------------------------------
-- Déffinition des callbacks et des fonction pour le dessin
-----------------------------------------------------



-----------------------------------------------------
-- Construction des ui
-----------------------------------------------------

local pages = {}

pages.oresQuantity = {}
do
    pages.oresQuantity.background = ui.oresQuantity.surface:element({
        id = "oresQuantity_background", type = "panel",
        rect = { unit = "%", x = 0, y = 0, w = 100, h = 100 },
        props = { z_index = 0 },
        style = {
            bg = "#0F172A",
        },
    })

    do --Menu
        pages.oresQuantity.menu = {}
        local menuBackgroundPos = { x = 5, y = 5} --En PX
        local menuBackgroundSize = { w = 145, h = 574} --En PX
        local menuBackgroundPosPourcentage = scriptedScreen.convertPixelToPourcentage(menuBackgroundPos.x, menuBackgroundPos.y, reference_w, reference_h)
        local menuBackgroundSizePourcentage = scriptedScreen.convertPixelToPourcentage(menuBackgroundSize.w, menuBackgroundSize.h, reference_w, reference_h)
        pages.oresQuantity.menu.background = ui.oresQuantity.surface:element({
            id = "menu_background", type = "panel",
            rect = {
                unit = "%",
                x = menuBackgroundPosPourcentage.x,
                y = menuBackgroundPosPourcentage.y,
                w = menuBackgroundSizePourcentage.x,
                h = menuBackgroundSizePourcentage.y,
            },
            props = { z_index = 0 },
            style = {
                bg = "#1F2940",
            },
        })


        do --Menu title
            local pos = { x = 0, y = 23,} --Position en pixel
            local size = { w = menuBackgroundSize.w, h = 23,} --Taille en pixel
            local labelData = scriptedScreen.calculateLabel(h, 20, "MENU", ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, menuBackgroundSize.w, menuBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, menuBackgroundSize.w, menuBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.menu.title = pages.oresQuantity.menu.background:element({
                id = "menu_title", type = "label",
                rect = {
                    unit = "%",
                    x = labelPosPourcentage.x,
                    y = labelPosPourcentage.y,
                    w = labelSizePourcentage.x,
                    h = labelSizePourcentage.y,
                },
                props = {
                    text = labelData.text,
                    z_index = 0,
                },
                style = {
                    font_size = labelData.font_size,
                    color = "#FFFFFF",
                    align = "center",
                },
            })
        end
        do --Button menu ores quantity
            local pos = { x = 0, y = 57,} --Position en pixel
            local size = { w = menuBackgroundSize.w, h = 72,} --Taille en pixel
            local buttonData = scriptedScreen.calculateLabel(h, 18, "quantité de minerais", ui.oresQuantity.surface, false, 0)
            local buttonPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, menuBackgroundSize.w, menuBackgroundSize.h) --Position en pourcentage par rapport au parent
            local buttonSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, menuBackgroundSize.w, menuBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.menu.button_ores_Quantity = pages.oresQuantity.menu.background:element({
                id = "menu_button_ores_quantity", type = "button",
                rect = {
                    unit = "%",
                    x = buttonPosPourcentage.x,
                    y = buttonPosPourcentage.y,
                    w = buttonSizePourcentage.x,
                    h = buttonSizePourcentage.y,
                },
                props = {
                    text = buttonData.text,
                    z_index = 0
                },
                style = { bg = "#7C3AED", text = "#FFFFFF", font_size = buttonData.font_size },
                on_click = function(playerName)
                    ui.oresQuantity.set()
                end
            })
            print("font size : " .. buttonData.font_size)
        end
    end

    do --Contenue
        pages.oresQuantity.contenue = {}
        local contenueBackgroundPos = { x = 155, y = 5} --En PX
        local contenueBackgroundSize = { w = 702, h = 574} --En PX
        local contenueBackgroundPosPourcentage = scriptedScreen.convertPixelToPourcentage(contenueBackgroundPos.x, contenueBackgroundPos.y, reference_w, reference_h)
        local contenueBackgroundSizePourcentage = scriptedScreen.convertPixelToPourcentage(contenueBackgroundSize.w, contenueBackgroundSize.h, reference_w, reference_h)
        pages.oresQuantity.contenue.background = ui.oresQuantity.surface:element({
            id = "contenue_background", type = "panel",
            rect = {
                unit = "%",
                x = contenueBackgroundPosPourcentage.x,
                y = contenueBackgroundPosPourcentage.y,
                w = contenueBackgroundSizePourcentage.x,
                h = contenueBackgroundSizePourcentage.y,
            },
            props = { z_index = 0 },
            style = {
                bg = "#1F2940",
            },
        })

        do --Contenue title
            local pos = { x = 0, y = 23,} --Position en pixel
            local size = { w = contenueBackgroundSize.w, h = 23,} --Taille en pixel
            local labelData = scriptedScreen.calculateLabel(h, 30, "Silo OS", ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueBackgroundSize.w, contenueBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueBackgroundSize.w, contenueBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.contenue.title = pages.oresQuantity.contenue.background:element({
                id = "contenue_title", type = "label",
                rect = {
                    unit = "%",
                    x = labelPosPourcentage.x,
                    y = labelPosPourcentage.y,
                    w = labelSizePourcentage.x,
                    h = labelSizePourcentage.y,
                },
                props = {
                    text = labelData.text,
                    z_index = 0,
                },
                style = {
                    font_size = labelData.font_size,
                    color = "#FFFFFF",
                    align = "center",
                },
            })
        end
        do --Contenue version
            local pos = { x = 652, y = 556,} --Position en pixel
            local size = { w = 50, h = 16,} --Taille en pixel
            local labelData = scriptedScreen.calculateLabel(h, 14, "v0.1", ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueBackgroundSize.w, contenueBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueBackgroundSize.w, contenueBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.contenue.version = pages.oresQuantity.contenue.background:element({
                id = "contenue_version", type = "label",
                rect = {
                    unit = "%",
                    x = labelPosPourcentage.x,
                    y = labelPosPourcentage.y,
                    w = labelSizePourcentage.x,
                    h = labelSizePourcentage.y,
                },
                props = {
                    text = labelData.text,
                    z_index = 0,
                },
                style = {
                    font_size = labelData.font_size,
                    color = "#FFFFFF",
                    align = "center",
                },
            })
        end
    end
end
