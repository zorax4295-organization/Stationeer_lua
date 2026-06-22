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

local REFERENCE_H = 584 --La taille d'ecran de referance avec lequel on été fait les test pour obtenir la taille du label en pourcentage
--Permet de calculer divers parametre d'un label pour qu'il se redimensionne en fonction du texte et de l'ecran
---@param raw_font_size number
---@param text string
---@param isRetourLigne boolean
---@param max_width number
local function calculateLabel(raw_font_size, text, parent, isRetourLigne, max_width)
    local font_size = math.floor(raw_font_size * (h / REFERENCE_H)) --Permet d'obtenir la taille de font size pour n'importe quelle ecran grace a une lois proportionel
    local size = parent:measure_text(text, max_width, font_size, isRetourLigne) --Permet de mesurer la taille du tecte en px

    return {
        font_size = font_size,
        w = size.w + font_size * 0.4, -- longueur en px
        h = size.h, -- hauteur en px
        text = text -- Contenue de texte du label
    }
end


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
    do
        local label = calculateLabel(50, "Bonjour je suis un technicien hautement qualifier", ui.oresQuantity.surface, true, 500)
        local weightPourcent = label.w / w * 100 --taille du labelle en pourcentage par rapport a l'écran
        local heightPourcent = label.h / h * 100 --taille du labelle en pourcentage par rapport a l'écran
        pages.oresQuantity.title = ui.oresQuantity.surface:element({
            id = "id", type = "label",
            rect = {
                unit = "%",
                x = 50 - weightPourcent/2,
                y = 0,
                w = weightPourcent,
                h = heightPourcent },
            props = {
                text = label.text,
                z_index = 2,
            },
            style = {
                font_size = label.font_size,
                color = "#FFFFFF",
                align = "center",
            },
        })
    end
end
