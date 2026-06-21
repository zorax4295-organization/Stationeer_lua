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

local hud = createScreen("hud")


local size = hud.surface:size()
local w, h = size.w , size.h
print(system.log.time() .. "h " .. system.log.level("debug") .. " : w=" .. w .. " | h=" .. h)


----------------------------
-- Initialisation des ecran
----------------------------

hud.clear()
hud.set()


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

local pages = {}


pages.settings = {}
do
    pages.settings.background = hud.surface:element({
        id = "settings_background", type = "panel",
        rect = { unit = "px", x = (w/2) - 300, y = (h/2) - 250, w = 600, h = 500 },
        props = {
            z_index = 0, --Niveau de couche de dessins (un peux comme un calque)
            draggable = true, --Permet de rendre le panel deplacable a la souris
            drag_bounds = "screen", --Empeche de sortire le panel de l'ecran (ses toujour screen j'amais autre chose si ses pour se limiter a la surface de l'ecran)
            drag_group = "auto", --Permet de faire deplacer tout ses elements avec le panel (il faut mettre les ids des elements separer de virgule si il y en a plusieurs)
        },
        style = {
            bg = "#1b1b1b",
        },
    })
    do --Entête
        pages.settings.entete = {}
        pages.settings.entete.ancre = pages.settings.background:element({
            id = "setting_entete", type = "panel",
            rect = { unit = "px", x = 0, y = 0, w = 600, h = 60 },
            props = {
                z_index = 0,
            },
            style = {
                bg = "#00000000",
            },
        })
        pages.settings.entete.background = pages.settings.entete.ancre:element({
            id = "setting_entete_background", type = "panel",
            rect = { unit = "px", x = 10, y = 10, w = 580, h = 40 },
            props = {
                z_index = 0,
            },
            style = {
                bg = "#0F172A",
            },
        })
    end
end

local PANEL_W, PANEL_H = 600, 500
local BASE_X, BASE_Y = (w/2) - (PANEL_W/2), (h/2) - (PANEL_H/2)
local function rebuild()
    local off = hud.surface:drag_offset("settings_background")
    hud.clear()
    hud.surface:layout({
        id = "settings_background", type = "panel",
        rect = { unit = "px", x = BASE_X + off.dx, y = BASE_Y + off.dy, w = PANEL_W, h = PANEL_H },
        props = {
            z_index = 0,
            draggable = true, --Permet de rendre le panel deplacable a la souris
            drag_bounds = "screen", --Empeche de sortire le panel de l'ecran (ses toujour screen j'amais autre chose si ses pour se limiter a la surface de l'ecran)
            drag_group = "auto", --Permet de faire deplacer tout ses elements avec le panel (il faut mettre les ids des elements separer de virgule si il y en a plusieurs)
        },
        style = {
            bg = "#1b1b1b",
        },
        children = { --[[ your widgets ]] },
    })
    hud.surface:commit()
end

hud.surface:on_drag(rebuild)
ss.hud.on_overlay_change(rebuild)
rebuild()

----------------------------
-- Déffinition des functions
----------------------------

while true do
    yield()
end
