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
        pages.oresQuantity.menu.background = ui.oresQuantity.surface:element({
            id = "menu_background", type = "panel",
            rect = { unit = "px", x = 0, y = 0, w = 150, h = h },
            props = { z_index = 0 },
            style = {
                bg = "#1F2940",
            },
        })

        do
            local labelData = scriptedScreen.calculateLabel(h, 20, "MENU", ui.oresQuantity.surface, false, 0)
            pages.oresQuantity.menu.title = pages.oresQuantity.menu.background:element({
                id = "menu_title", type = "label",
                rect = {
                    unit = "px",
                    x = 0,
                    y = 8,
                    w = 150,
                    h = 23,
                },
                props = {
                    text = labelData.text,
                    z_index = 4,
                },
                style = {
                    font_size = labelData.font_size,
                    color = "#FFFFFF",
                    align = "center",
                },
            })
        end

        pages.oresQuantity.menu.button_ores_Quantity = pages.oresQuantity.menu.background:element({
            id = "menu_button_ores_quantity", type = "button",
            rect = { unit = "px", x = 0, y = 57, w = 150, h = 72 },
            props = { text = "quanité de minerais", z_index = 0 },
            style = { bg = "#0334155F172A", text = "#FFFFFF", font_size = 14 },
            on_click = function(playerName)
            end
        })
    end


    do -- label title
        local label = scriptedScreen.calculateLabel(h, 50, "quantité de minerais", ui.oresQuantity.surface, true, 500)
        local weightPourcent = label.w / w * 100 --taille du labelle en pourcentage par rapport a l'écran
        local heightPourcent = label.h / h * 100 --taille du labelle en pourcentage par rapport a l'écran
        pages.oresQuantity.title = ui.oresQuantity.surface:element({
            id = "temp", type = "label",
            rect = {
                unit = "%",
                x = 50 - weightPourcent/2,
                y = 0,
                w = weightPourcent,
                h = heightPourcent },
            props = {
                text = label.text,
                z_index = 0,
            },
            style = {
                font_size = label.font_size,
                color = "#FFFFFF",
                align = "center",
            },
        })
    end
end