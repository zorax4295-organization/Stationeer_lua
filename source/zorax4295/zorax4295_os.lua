--Utilisation sur un programmable visor


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
    setting = createScreen("setting"),
}


local size = ui.setting.surface:size()

local w, h = size.w , size.h
print(system.log.time() .. "h " .. system.log.level("debug") .. " : w=" .. w .. " | h=" .. h)


-----------------------------------------------------
-- Initialisation des ecran
-----------------------------------------------------

ui.setting.clear()
ui.setting.set()


----------------------------
-- Définition des appareil
----------------------------


----------------------------
-- Définition des donnés
----------------------------

local LT = ic.enums.LogicType



----------------------------
-- Dessin de l'interface
----------------------------

while true do
    yield()
end
