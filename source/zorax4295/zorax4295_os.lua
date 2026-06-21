--Utilisation sur un programmable visor
--Ma taille d'ecran physique : w=2226 | h=932




----------------------------
-- import de la librairie
----------------------------

local system = require("system")



-----------------------------------------------------
-- Création des écran
-----------------------------------------------------

local currentUi = "setting"
-- Déffinition des parametre de chaque écran
local function createScreen(name)
    local surface = ss.hud.surface(name)
    return {
        -- Rend accessible la surface pour utilisation ulterieur
        surface = surface,
        -- Affiche l'écran
        set = function()
            -- Retourne l'id de la page acctuel
            currentUi = name
            ss.hud.activate(name)
        end,
        -- Retire tout les élément afficher a l'écran
        clear = function ()
            surface:clear()            
        end,
    }
end

--Liste toute les page 
local ui = {
    settings = createScreen("setting"),
}


local size = ui.settings.surface:size()

local w, h = size.w , size.h
print(system.log.time() .. "h " .. system.log.level("debug") .. " : w=" .. w .. " | h=" .. h)


----------------------------
-- Initialisation des ecran
----------------------------

ui.settings.clear()
ui.settings.set()


----------------------------
-- Définition des appareil
----------------------------


----------------------------
-- Définition des donnés
----------------------------

local LT = ic.enums.LogicType


----------------------------
-- Déffinition des callbacks
----------------------------

----------------------------
-- Dessin de l'interface
----------------------------

local container = {}
local subContainer = {}
local elements = {
    settings = {
        background = ui.settings.surface:element({
            id = "background", type = "panel",
            rect = { unit = "px", x = (w/2) - 300, y = (h/2) - 250, w = 600, h = 500 },
            props = { z_index = 0 },
            style = {
                bg = "#1b1b1b",
            },
        }),
    }
}


----------------------------
-- Déffinition des functions
----------------------------

while true do
    yield()
end
