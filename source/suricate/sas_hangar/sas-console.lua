----------------------------------Explication du programme--------------------------------------
-- Se système est conçus pour s'afficher sur cette écran : Console Monitor
-- La taille de l'écran est de : w=460px | h=460px
-- Cette écran à été dimmensionné avec : https://www.figma.com
---------------------------------------Objectif-------------------------------------------------

------------------------------------------------------------------------------------------------



-- Déffinition des parametre de chaque écran
local function createScreen(name)
    local surface = ss.ui.surface(name)
    return {
        -- Rend accessible la surface pour utilisation ulterieur
        surface=surface,
        -- Affiche l'écran
        set = function()
            ss.ui.activate(name)
        end,
        -- Retire tout les élément afficher a l'écran
        clear = function ()
            surface:clear()            
        end,
    }
end

------------------------
-- Création des écran
------------------------

---Liste toute les surface 
local ui = {
    accueil = createScreen("accueil"),
}

------------------------
-- Déffinition d'une résolution virtuelle
------------------------

ui.accueil.surface:get_resolution(1254, 1254)
local size = ui.accueil.surface:size()

-- Déffinition de la taille de l'écran virtuelle
local w = size.w
local h = size.h


ui.accueil.clear()
ui.accueil.set()

--Liste tout les elements créer dans chaque écran
local container = {
    accueil = {
        menu = ui.accueil.surface:element({
            id = "container_menu_auto", type = "panel",
            rect = { unit = "px", x = 0, y = 0, w = 540, h = 40 },
            style = { bg = "#00000000" }
        }),
    },
}
local elements = {
    accueil = {
        label = ui.accueil.surface:element({
            id = "title", type = "label",
            rect = { unit = "px", x = 20, y = 10, w = 200, h = 30 },
            props = { text = "Hello World" },
            style = { font_size = 18, color = "#FFFFFF", align = "left" }
        }),
    },
}