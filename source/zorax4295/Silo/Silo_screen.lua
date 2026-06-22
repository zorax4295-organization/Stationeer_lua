----------------------------------Explication du programme--------------------------------------
-- Se système est conçus pour s'afficher sur cette écran : Console Monitor
-- La taille de l'écran est de : w=460px | h=460px
-- Cette écran à été dimmensionné avec : https://www.figma.com
---------------------------------------Objectif-------------------------------------------------

------------------------------------------------------------------------------------------------



-----------------------------------------------------
-- import de la librairie
-----------------------------------------------------

local system = require("system")


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

-----------------------------------------------------
-- Création des écran
-----------------------------------------------------

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

-----------------------------------------------------
-- Initialisation des ecran
-----------------------------------------------------

ui.oresQuantity.clear()
ui.oresQuantity.set()

-----------------------------------------------------
-- Déffinition des données
-----------------------------------------------------



-----------------------------------------------------
-- Construction des ui
-----------------------------------------------------

