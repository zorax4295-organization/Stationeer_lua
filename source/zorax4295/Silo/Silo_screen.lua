----------------------------------Explication du programme--------------------------------------
-- Se système est conçus pour s'afficher sur cette écran : Console Monitor
-- La taille de l'écran est de : w=862px | h=584px
-- Cette écran à été dimmensionné avec : https://www.figma.com
---------------------------------------Objectif-------------------------------------------------

--------------------------------------Constante-------------------------------------------------
local versionProgramme = "v0.3"


-----------------------------------------------------
-- import de la librairie
-----------------------------------------------------

local system = require("system")
local scriptedScreen = require("scriptedScreen")


-----------------------------------------------------
-- Création des écran
-----------------------------------------------------

local currentUi = ""
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
    oresRequest = createScreen("oresRequest")
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
ui.oresRequest.clear()
ui.oresRequest.set()

-----------------------------------------------------
-- Déffinition des données
-----------------------------------------------------

local reference_w = 862 --Ecran de réference pour le calibrage du programme pour convertire en pourcentage
local reference_h = 584 --Ecran de réference pour le calibrage du programme pour convertire en pourcentage
local oresQuantity = {
    iron = 0,
    copper = 0,
    gold = 0,
    silicon = 0,
    coal = 0,
    lead = 0,
    nickel = 0,
    silver = 0,
    cobalt = 0,
}
local oresRequest = {
    oreType = "", --Minerais actuellement selectionner dans la requete ores
    quantity = 0, --Quantité de minerais actuellement selectionner dans la requete ores
}
local colorMenuButton = {
    enable = "#4C1D95",
    disable = "#7C3AED",
}

local openPopupCommandeOres
local closePopupCommandeOres


-----------------------------------------------------
-- Déffinition des fonctions pour la création UI
-----------------------------------------------------

local function createMenu(parent, page)
    local screenId = parent.id
    page.menu = {}
    local menuBackgroundPos = { x = 5, y = 5} --En PX
    local menuBackgroundSize = { w = 145, h = 574} --En PX
    local menuBackgroundPosPourcentage = scriptedScreen.convertPixelToPourcentage(menuBackgroundPos.x, menuBackgroundPos.y, reference_w, reference_h)
    local menuBackgroundSizePourcentage = scriptedScreen.convertPixelToPourcentage(menuBackgroundSize.w, menuBackgroundSize.h, reference_w, reference_h)
    page.menu.background = parent.surface:element({
        id = screenId .. "_menu_background", type = "panel",
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
        local labelData = scriptedScreen.calculateLabel(h, 20, "MENU", parent.surface, false, 0)
        local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, menuBackgroundSize.w, menuBackgroundSize.h) --Position en pourcentage par rapport au parent
        local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, menuBackgroundSize.w, menuBackgroundSize.h) --Taille en pourcentage par rapport au parent
        page.menu.title = page.menu.background:element({
            id = screenId .. "_menu_title", type = "label",
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
        local buttonData = scriptedScreen.calculateLabel(h, 18, "quantité de minerais", parent.surface, false, 0)
        local buttonPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, menuBackgroundSize.w, menuBackgroundSize.h) --Position en pourcentage par rapport au parent
        local buttonSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, menuBackgroundSize.w, menuBackgroundSize.h) --Taille en pourcentage par rapport au parent
        page.menu.button_oresQuantity = page.menu.background:element({
            id = screenId .. "_menu_button_oresQuantity", type = "button",
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
            style = { bg = colorMenuButton.enable, text = "#FFFFFF", font_size = buttonData.font_size },
            on_click = function(playerName)
                ui.oresQuantity.set()
            end
        })
    end
    do --Button menu ores request
        local pos = { x = 0, y = 134,} --Position en pixel
        local size = { w = 145, h = 72,} --Taille en pixel
        local buttonData = scriptedScreen.calculateLabel(h, 18, "Commande de minerais", parent.surface, false, 0)
        local buttonPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, menuBackgroundSize.w, menuBackgroundSize.h) --Position en pourcentage par rapport au parent
        local buttonSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, menuBackgroundSize.w, menuBackgroundSize.h) --Taille en pourcentage par rapport au parent
        page.menu.button_oresRequest = page.menu.background:element({
            id = screenId .. "_menu_button_oresRequest", type = "button",
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
            style = { bg = colorMenuButton.disable, text = "#FFFFFF", font_size = buttonData.font_size },
            on_click = function(playerName)
                ui.oresRequest.set()
            end
        })
    end
    return page.menu
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

    pages.oresQuantity.menu = createMenu(ui.oresQuantity, pages.oresQuantity)

    do --Contenue
        pages.oresQuantity.contenue = {}
        local contenueBackgroundPos = { x = 155, y = 5} --En PX
        local contenueBackgroundSize = { w = 702, h = 574} --En PX
        local contenueBackgroundPosPourcentage = scriptedScreen.convertPixelToPourcentage(contenueBackgroundPos.x, contenueBackgroundPos.y, reference_w, reference_h)
        local contenueBackgroundSizePourcentage = scriptedScreen.convertPixelToPourcentage(contenueBackgroundSize.w, contenueBackgroundSize.h, reference_w, reference_h)
        pages.oresQuantity.contenue.background = ui.oresQuantity.surface:element({
            id = "oresQuantity_contenue_background", type = "panel",
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
                id = "oresQuantity_contenue_title", type = "label",
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
            local labelData = scriptedScreen.calculateLabel(h, 14, versionProgramme, ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueBackgroundSize.w, contenueBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueBackgroundSize.w, contenueBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.contenue.version = pages.oresQuantity.contenue.background:element({
                id = "oresQuantity_contenue_version", type = "label",
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

        do --Contenue Ores tile
            local backgroundPos = { x = 186, y = 101} --En PX
            local backgroundSize = { w = 640, h = 410} --En PX w=120 par tile et h=200 par tile
            local backgroundPosPourcentage = scriptedScreen.convertPixelToPourcentage(backgroundPos.x, backgroundPos.y, reference_w, reference_h) --Convertion de la position en pourcentage
            local backgroundSizePourcentage = scriptedScreen.convertPixelToPourcentage(backgroundSize.w, backgroundSize.h, reference_w, reference_h) --Convertion de la taille en pourcentage
            local backgroundPosPixel = { --Reconvertion en pixel par rapport au pourcentage parceque visiblement sa bug si j'utilise des pourcentage
                x = backgroundPosPourcentage.x / 100 * w,
                y = backgroundPosPourcentage.y / 100 * h 
            }
            local backgroundSizePixel = { --Reconvertion en pixel par rapport au pourcentage parceque visiblement sa bug si j'utilise des pourcentage
                w = backgroundSizePourcentage.x / 100 * w,
                h = backgroundSizePourcentage.y / 100 * h
            }


            local lineH = 200
            local lineHPourcent = scriptedScreen.convertPixelToPourcentage(0, lineH, 0, reference_h)
            local lineHPixel = lineHPourcent.y / 100 * h

            pages.oresQuantity.contenue.oresTiles = {}
            ---@type { contenue_tile_iron_background: any, contenue_tile_copper_background: any, contenue_tile_gold_background: any, contenue_tile_silicon_background: any, contenue_tile_coal_background: any, contenue_tile_lead_background: any, contenue_tile_nickel_background: any, contenue_tile_silver_background: any, contenue_tile_cobalt_background: any, }
            pages.oresQuantity.contenue.oresTiles.background = ui.oresQuantity.surface:layout({
                layout = "grid",
                rect = { unit = "px", x = backgroundPosPixel.x, y = backgroundPosPixel.y, w = backgroundSizePixel.w, h = backgroundSizePixel.h },
                cols = 5,
                row_height = lineHPixel, -- hauteur fixe de chaque ligne en px
                gap = 10, -- espace entre chaque colonne en px
                padding = 0, -- espace entre le bord du conteneur et les cellules en px
                children = {
                    { id = "contenue_tile_iron_background", type = "panel", style = { bg = "#5F85D9" } },
                    { id = "contenue_tile_copper_background", type = "panel", style = { bg = "#5F85D9" } },
                    { id = "contenue_tile_gold_background", type = "panel", style = { bg = "#5F85D9" } },
                    { id = "contenue_tile_silicon_background", type = "panel", style = { bg = "#5F85D9" } },
                    { id = "contenue_tile_coal_background", type = "panel", style = { bg = "#5F85D9" } },
                    { id = "contenue_tile_lead_background", type = "panel", style = { bg = "#5F85D9" } },
                    { id = "contenue_tile_nickel_background", type = "panel", style = { bg = "#5F85D9" } },
                    { id = "contenue_tile_silver_background", type = "panel", style = { bg = "#5F85D9" } },
                    { id = "contenue_tile_cobalt_background", type = "panel", style = { bg = "#5F85D9" } },
                }
            })
            for oreType, quantity in pairs(oresQuantity) do
                pages.oresQuantity.contenue.oresTiles[oreType] = {}
                local tileSize = { w = 120, h = 200 } -- taille d'une tuile individuelle
                do --Icon
                    local pos = { x = 5, y = 5} --En PX
                    local size = { w = 110, h = 110} --En PX
                    local posPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, tileSize.w, tileSize.h)
                    local sizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, tileSize.w, tileSize.h)
                    pages.oresQuantity.contenue.oresTiles[oreType].icon = pages.oresQuantity.contenue.oresTiles.background["contenue_tile_" .. oreType .. "_background"]:element({
                        id = "contenue_tile_" .. oreType .. "_icon", type = "icon",
                        rect = {
                            unit = "%",
                            x = posPourcentage.x,
                            y = posPourcentage.y,
                            w = sizePourcentage.x,
                            h = sizePourcentage.y,
                        },
                        props = {
                            icon_type = "prefab",
                            name = "Item" .. oreType:sub(1,1):upper() .. oreType:sub(2) .. "Ore", --Transforme la première lettre du minerais en majuscule
                            z_index = 0
                        },
                        style = { tint = "#FFFFFF"},
                    })
                end
                do --Label quantity
                    local pos = { x = 0, y = 138,} --Position en pixel
                    local size = { w = tileSize.w, h = 14,} --Taille en pixel
                    local labelText = oreType:sub(1,1):upper() .. oreType:sub(2) .. " : " .. quantity
                    local labelData = scriptedScreen.calculateLabel(h, 14, labelText, ui.oresQuantity.surface, false, 0)
                    local posPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, tileSize.w, tileSize.h) --Position en pourcentage par rapport au parent
                    local sizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, tileSize.w, tileSize.h) --Taille en pourcentage par rapport au parent
                    pages.oresQuantity.contenue.oresTiles[oreType].label = pages.oresQuantity.contenue.oresTiles.background["contenue_tile_" .. oreType .. "_background"]:element({
                        id = "contenue_tile_" .. oreType .. "_quantity", type = "label",
                        rect = {
                            unit = "%",
                            x = posPourcentage.x,
                            y = posPourcentage.y,
                            w = sizePourcentage.x,
                            h = sizePourcentage.y,
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
                do --Button commander
                    local pos = { x = 5, y = 165,} --Position en pixel
                    local size = { w = 110, h = 20,} --Taille en pixel
                    local labelData = scriptedScreen.calculateLabel(h, 14, "Commander", ui.oresQuantity.surface, false, 0)
                    local posPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, tileSize.w, tileSize.h) --Position en pourcentage par rapport au parent
                    local sizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, tileSize.w, tileSize.h) --Taille en pourcentage par rapport au parent
                    pages.oresQuantity.contenue.oresTiles[oreType].button = pages.oresQuantity.contenue.oresTiles.background["contenue_tile_" .. oreType .. "_background"]:element({
                        id = "contenue_tile_" .. oreType .. "_button", type = "button",
                        rect = {
                            unit = "%",
                            x = posPourcentage.x,
                            y = posPourcentage.y,
                            w = sizePourcentage.x,
                            h = sizePourcentage.y
                        },
                        props = {
                            text = labelData.text,
                            z_index = 0,
                        },
                        style = {
                            bg = "#2037B3",
                            text = "#FFFFFF",
                            font_size = labelData.font_size
                        },
                        on_click = function(playerName)
                            openPopupCommandeOres(oreType)
                        end
                    })
                end
            end
        end
    end


    do --Popup
        pages.oresQuantity.popup = {}
        local popupBackgroundSombrePos = { x = 0, y = 0} --En PX
        local popupBackgroundSombreSize = { w = 862, h = 584} --En PX
        local popupBackgroundSombrePosPourcentage = scriptedScreen.convertPixelToPourcentage(popupBackgroundSombrePos.x, popupBackgroundSombrePos.y, reference_w, reference_h)
        local popupBackgroundSombreSizePourcentage = scriptedScreen.convertPixelToPourcentage(popupBackgroundSombreSize.w, popupBackgroundSombreSize.h, reference_w, reference_h)

        pages.oresQuantity.popup.backgroundSombre = ui.oresQuantity.surface:element({
            id = "popup_backgroundSombre", type = "panel",
            rect = {
                unit = "%",
                x = popupBackgroundSombrePosPourcentage.x,
                y = popupBackgroundSombrePosPourcentage.y,
                w = popupBackgroundSombreSizePourcentage.x,
                h = popupBackgroundSombreSizePourcentage.y,
            },
            props = {
                z_index = 10,
                visible = false,
            },
            style = {
                bg = "#000000E6",
            },
        })

        local popupBackgroundPos = { x = 146, y = 120} --En PX
        local popupBackgroundSize = { w = 570, h = 344} --En PX
        local popupBackgroundPosPourcentage = scriptedScreen.convertPixelToPourcentage(popupBackgroundPos.x, popupBackgroundPos.y, popupBackgroundSombreSize.w, popupBackgroundSombreSize.h)
        local popupBackgroundSizePourcentage = scriptedScreen.convertPixelToPourcentage(popupBackgroundSize.w, popupBackgroundSize.h, popupBackgroundSombreSize.w, popupBackgroundSombreSize.h)
        pages.oresQuantity.popup.background = pages.oresQuantity.popup.backgroundSombre:element({
            id = "popup_background", type = "panel",
            rect = {
                unit = "%",
                x = popupBackgroundPosPourcentage.x,
                y = popupBackgroundPosPourcentage.y,
                w = popupBackgroundSizePourcentage.x,
                h = popupBackgroundSizePourcentage.y,
            },
            props = {
                z_index = 11,
                visible = false
            },
            style = {
                bg = "#1F2940",
            },
        })

        do --Popup title
            local pos = { x = 141, y = 15,} --Position en pixel
            local size = { w = 289, h = 35,} --Taille en pixel
            local labelData = scriptedScreen.calculateLabel(h, 25, "Commande de minerais", ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, popupBackgroundSize.w, popupBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, popupBackgroundSize.w, popupBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.popup.title = pages.oresQuantity.popup.background:element({
                id = "popup_title", type = "label",
                rect = {
                    unit = "%",
                    x = labelPosPourcentage.x,
                    y = labelPosPourcentage.y,
                    w = labelSizePourcentage.x,
                    h = labelSizePourcentage.y,
                },
                props = {
                    text = labelData.text,
                    z_index = 11,
                    visible = false,
                },
                style = {
                    font_size = labelData.font_size,
                    color = "#FFFFFF",
                    align = "center",
                },
            })
        end
        do --Popup quantity input
            local pos = { x = 146, y = 149,} --Position en pixel
            local size = { w = 279, h = 46,} --Taille en pixel
            local labelData = scriptedScreen.calculateLabel(h, 20, "Entré la quantité de minerais shouaité", ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, popupBackgroundSize.w, popupBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, popupBackgroundSize.w, popupBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.popup.inputQuantity = pages.oresQuantity.popup.background:element({
                id = "popup_quantityInput", type = "textinput",
                rect = {
                    unit = "%",
                    x = labelPosPourcentage.x,
                    y = labelPosPourcentage.y,
                    w = labelSizePourcentage.x,
                    h = labelSizePourcentage.y,
                },
                props = {
                    value = "",
                    placeholder = labelData.text,
                    title = "Name",
                    z_index = 11,
                    visible = false,
                },
                style = {
                    bg = "#FFFFFF",
                    text = "#000000",
                    placeholder_color = "#475569",
                    font_size = labelData.font_size,
                },
                on_change = function(rawValue, player)
                    if rawValue == "" then
                        print(system.log.time() .. "h " .. system.log.level("warn") .. " : Value du [popup_quantityInput] est vide")
                        popup.oresRequest.quantity = 0
                        return
                    end
                    local value = tonumber(rawValue)
                    if type(value) ~= "number" then
                        print(system.log.time() .. "h " .. system.log.level("warn") .. " : Value du [popup_quantityInput] n'est pas de type number")
                        pages.oresQuantity.popup.inputQuantity:set_props({ value = 0 })
                        return
                    end
                    if value % 1 ~= 0 then -- Test si la quantity est bien un nombre entier
                        print(system.log.time() .. "h " .. system.log.level("warn") .. " : Value du [popup_quantityInput] n'est pas un nombre entier")
                        return
                    end
                    if value < 0 then -- Test si la quantity est bien un nombre entier
                        print(system.log.time() .. "h " .. system.log.level("warn") .. " : Value du [popup_quantityInput] n'est pas un nombre superieur ou égal à 0")
                        pages.oresQuantity.popup.inputQuantity:set_props({ value = 0 })
                        return
                    end

                    popup.oresRequest.quantity = value
                    pages.oresQuantity.popup.inputQuantity:set_props({ value = value })
                end
            })
        end
        do --Button retirer 10
            local pos = { x = 175, y = 205,} --Position en pixel
            local size = { w = 50, h = 30,} --Taille en pixel
            local labelData = scriptedScreen.calculateLabel(h, 12, "Retirer 10", ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, popupBackgroundSize.w, popupBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, popupBackgroundSize.w, popupBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.popup.buttonRetirer10 = pages.oresQuantity.popup.background:element({
                id = "popup_buttonRetirer10", type = "button",
                rect = {
                    unit = "%",
                    x = labelPosPourcentage.x,
                    y = labelPosPourcentage.y,
                    w = labelSizePourcentage.x,
                    h = labelSizePourcentage.y
                },
                props = {
                    text = labelData.text,
                    z_index = 11,
                    visible = false,
                },
                style = {
                    bg = "#AB0000",
                    text = "#FFFFFF",
                    font_size = labelData.font_size,
                },
                on_click = function(playerName)
                    if popup.oresRequest.quantity <= 9 then
                        return
                    end
                    local quantity = popup.oresRequest.quantity - 10
                    popup.oresRequest.quantity = quantity
                    pages.oresQuantity.popup.inputQuantity:set_props({ value = tostring(quantity) })
                end
            })
        end
        do --Button retirer 1
            local pos = { x = 230, y = 205,} --Position en pixel
            local size = { w = 50, h = 30,} --Taille en pixel
            local labelData = scriptedScreen.calculateLabel(h, 12, "Retirer 1", ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, popupBackgroundSize.w, popupBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, popupBackgroundSize.w, popupBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.popup.buttonRetirer1 = pages.oresQuantity.popup.background:element({
                id = "popup_buttonRetirer1", type = "button",
                rect = {
                    unit = "%",
                    x = labelPosPourcentage.x,
                    y = labelPosPourcentage.y,
                    w = labelSizePourcentage.x,
                    h = labelSizePourcentage.y
                },
                props = {
                    text = labelData.text,
                    z_index = 11,
                    visible = false,
                },
                style = {
                    bg = "#AB0000",
                    text = "#FFFFFF",
                    font_size = labelData.font_size,
                },
                on_click = function(playerName)
                    if popup.oresRequest.quantity <= 0 then
                        return
                    end
                    local quantity = popup.oresRequest.quantity - 1
                    popup.oresRequest.quantity = quantity
                    pages.oresQuantity.popup.inputQuantity:set_props({ value = tostring(quantity) })
                end
            })
        end
        do --Button ajouter 1
            local pos = { x = 290, y = 205,} --Position en pixel
            local size = { w = 50, h = 30,} --Taille en pixel
            local labelData = scriptedScreen.calculateLabel(h, 12, "Ajouter 1", ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, popupBackgroundSize.w, popupBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, popupBackgroundSize.w, popupBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.popup.buttonAjouter1 = pages.oresQuantity.popup.background:element({
                id = "popup_buttonAjouter1", type = "button",
                rect = {
                    unit = "%",
                    x = labelPosPourcentage.x,
                    y = labelPosPourcentage.y,
                    w = labelSizePourcentage.x,
                    h = labelSizePourcentage.y
                },
                props = {
                    text = labelData.text,
                    z_index = 11,
                    visible = false,
                },
                style = {
                    bg = "#00AB0F",
                    text = "#FFFFFF",
                    font_size = labelData.font_size,
                },
                on_click = function(playerName)
                    local quantity = popup.oresRequest.quantity + 1
                    popup.oresRequest.quantity = quantity
                    pages.oresQuantity.popup.inputQuantity:set_props({ value = tostring(quantity) })
                end
            })
        end
        do --Button ajouter 10
            local pos = { x = 345, y = 205,} --Position en pixel
            local size = { w = 50, h = 30,} --Taille en pixel
            local labelData = scriptedScreen.calculateLabel(h, 12, "Ajouter 10", ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, popupBackgroundSize.w, popupBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, popupBackgroundSize.w, popupBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.popup.buttonAjouter10 = pages.oresQuantity.popup.background:element({
                id = "popup_buttonAjouter10", type = "button",
                rect = {
                    unit = "%",
                    x = labelPosPourcentage.x,
                    y = labelPosPourcentage.y,
                    w = labelSizePourcentage.x,
                    h = labelSizePourcentage.y
                },
                props = {
                    text = labelData.text,
                    z_index = 11,
                    visible = false,
                },
                style = {
                    bg = "#00AB0F",
                    text = "#FFFFFF",
                    font_size = labelData.font_size,
                },
                on_click = function(playerName)
                    local quantity = popup.oresRequest.quantity + 10
                    popup.oresRequest.quantity = quantity
                    pages.oresQuantity.popup.inputQuantity:set_props({ value = tostring(quantity) })
                end
            })
        end
        do --Button valider
            local pos = { x = 210, y = 261,} --Position en pixel
            local size = { w = 150, h = 30,} --Taille en pixel
            local labelData = scriptedScreen.calculateLabel(h, 20, "Valider", ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, popupBackgroundSize.w, popupBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, popupBackgroundSize.w, popupBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.popup.buttonValider = pages.oresQuantity.popup.background:element({
                id = "popup_buttonValider", type = "button",
                rect = {
                    unit = "%",
                    x = labelPosPourcentage.x,
                    y = labelPosPourcentage.y,
                    w = labelSizePourcentage.x,
                    h = labelSizePourcentage.y
                },
                props = {
                    text = labelData.text,
                    z_index = 11,
                    visible = false,
                },
                style = {
                    bg = "#FFFFFF",
                    text = "#000000",
                    font_size = labelData.font_size,
                },
                on_click = function(playerName)
                    closePopupCommandeOres()
                    print(system.log.time() .. "h " .. system.log.level("debug") .. " : oresType = " .. popup.oresRequest.oreType)
                    print(system.log.time() .. "h " .. system.log.level("debug") .. " : quantity = " .. popup.oresRequest.quantity)
                    ic.net.request("Housing silo OS", "silo/ores_request", {{type = popup.oresRequest.oreType, quantity = popup.oresRequest.quantity}},
                        function(payload, fromId, fromName)
                        end,
                        10
                    )
                end
            })
        end
        do --Button fermer
            local pos = { x = 473, y = 14,} --Position en pixel
            local size = { w = 79, h = 28,} --Taille en pixel
            local labelData = scriptedScreen.calculateLabel(h, 20, "Fermer", ui.oresQuantity.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, popupBackgroundSize.w, popupBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, popupBackgroundSize.w, popupBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresQuantity.popup.buttonFermer = pages.oresQuantity.popup.background:element({
                id = "popup_buttonFermer", type = "button",
                rect = {
                    unit = "%",
                    x = labelPosPourcentage.x,
                    y = labelPosPourcentage.y,
                    w = labelSizePourcentage.x,
                    h = labelSizePourcentage.y
                },
                props = {
                    text = labelData.text,
                    z_index = 11,
                    visible = false,
                },
                style = {
                    bg = "#FFFFFF",
                    text = "#000000",
                    font_size = labelData.font_size,
                },
                on_click = function(playerName)
                    closePopupCommandeOres()
                end
            })
        end
    end
end
pages.oresRequest = {}
do
    pages.oresRequest.background = ui.oresRequest.surface:element({
        id = "oresRequest_background", type = "panel",
        rect = { unit = "%", x = 0, y = 0, w = 100, h = 100 },
        props = { z_index = 0 },
        style = {
            bg = "#0F172A",
        },
    })

    pages.oresRequest.menu = createMenu(ui.oresRequest, pages.oresRequest)

    do --Contenue
        pages.oresRequest.contenue = {}
        local contenueBackgroundPos = { x = 155, y = 5} --En PX
        local contenueBackgroundSize = { w = 702, h = 574} --En PX
        local contenueBackgroundPosPourcentage = scriptedScreen.convertPixelToPourcentage(contenueBackgroundPos.x, contenueBackgroundPos.y, reference_w, reference_h)
        local contenueBackgroundSizePourcentage = scriptedScreen.convertPixelToPourcentage(contenueBackgroundSize.w, contenueBackgroundSize.h, reference_w, reference_h)
        pages.oresRequest.contenue.background = ui.oresRequest.surface:element({
            id = "oresRequest_contenue_background", type = "panel",
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
            local labelData = scriptedScreen.calculateLabel(h, 30, "Silo OS", ui.oresRequest.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueBackgroundSize.w, contenueBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueBackgroundSize.w, contenueBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresRequest.contenue.title = pages.oresRequest.contenue.background:element({
                id = "oresRequest_contenue_title", type = "label",
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
            local labelData = scriptedScreen.calculateLabel(h, 14, versionProgramme, ui.oresRequest.surface, false, 0)
            local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueBackgroundSize.w, contenueBackgroundSize.h) --Position en pourcentage par rapport au parent
            local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueBackgroundSize.w, contenueBackgroundSize.h) --Taille en pourcentage par rapport au parent
            pages.oresRequest.contenue.version = pages.oresRequest.contenue.background:element({
                id = "oresRequest_contenue_version", type = "label",
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

        do --Commande
            pages.oresRequest.contenue.commande = {}
            local contenueCommandeBackgroundPos = { x = 28, y = 79} --En PX
            local contenueCommandeBackgroundSize = { w = 267, h = 285} --En PX
            local contenueCommandeBackgroundPosPourcentage = scriptedScreen.convertPixelToPourcentage(contenueCommandeBackgroundPos.x, contenueCommandeBackgroundPos.y, contenueBackgroundSize.w, contenueBackgroundSize.h)
            local contenueCommandeBackgroundSizePourcentage = scriptedScreen.convertPixelToPourcentage(contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h, contenueBackgroundSize.w, contenueBackgroundSize.h)
            pages.oresRequest.contenue.commande.background = pages.oresRequest.contenue.background:element({
                id = "oresRequest_contenue_commande_background", type = "panel",
                rect = {
                    unit = "%",
                    x = contenueCommandeBackgroundPosPourcentage.x,
                    y = contenueCommandeBackgroundPosPourcentage.y,
                    w = contenueCommandeBackgroundSizePourcentage.x,
                    h = contenueCommandeBackgroundSizePourcentage.y,
                },
                props = { z_index = 0 },
                style = {
                    bg = "#141224",
                },
            })

            do --Commande label choisir un minerais
                local pos = { x = 5, y = 5,} --Position en pixel
                local size = { w = 230, h = 26,} --Taille en pixel
                local labelData = scriptedScreen.calculateLabel(h, 16, "1. CHOISIR UN MINERAIS", ui.oresRequest.surface, false, 0)
                local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Position en pourcentage par rapport au parent
                local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Taille en pourcentage par rapport au parent
                pages.oresRequest.contenue.commande.labelChoisirMinerais = pages.oresRequest.contenue.commande.background:element({
                    id = "oresRequest_contenue_commande_1", type = "label",
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
                        color = "#7A48C9",
                        align = "left",
                    },
                })
            end
            do --Liste deroulante selection minerais
                local contenueBackgroundPos = { x = 5, y = 41} --En PX
                local contenueBackgroundSize = { w = 257, h = 38} --En PX
                local contenueBackgroundPosPourcentage = scriptedScreen.convertPixelToPourcentage(contenueBackgroundPos.x, contenueBackgroundPos.y, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h)
                local contenueBackgroundSizePourcentage = scriptedScreen.convertPixelToPourcentage(contenueBackgroundSize.w, contenueBackgroundSize.h, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h)
                pages.oresRequest.contenue.commande.selectOre = pages.oresRequest.contenue.commande.background:element({
                    id = "oresRequest_contenue_commande_selectOre", type = "select",
                    rect = {
                        unit = "%",
                        x = contenueBackgroundPosPourcentage.x,
                        y = contenueBackgroundPosPourcentage.y,
                        w = contenueBackgroundSizePourcentage.x,
                        h = contenueBackgroundSizePourcentage.y,
                    },
                    props = {
                        options = {
                            "Iron",
                            "Copper",
                            "Gold",
                            "Silicon",
                            "Coal",
                            "Lead",
                            "Nickel",
                            "Silver",
                            "Cobalt",
                        },
                        selected = "0",
                    },
                    style = {
                        bg = "#2A1F47",
                        text = "#E2E8F0",
                        font_size = 14
                    },
                    on_change = function(value, player)
                        pages.oresRequest.contenue.commande.selectOre:set_props({ selected = value })
                    end,
                })
            end

            do --Commande label quantité
                local pos = { x = 5, y = 89,} --Position en pixel
                local size = { w = 120, h = 26,} --Taille en pixel
                local labelData = scriptedScreen.calculateLabel(h, 16, "2. QUANTITÉ", ui.oresRequest.surface, false, 0)
                local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Position en pourcentage par rapport au parent
                local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Taille en pourcentage par rapport au parent
                pages.oresRequest.contenue.commande.labelQuantite = pages.oresRequest.contenue.commande.background:element({
                    id = "oresRequest_contenue_commande_2", type = "label",
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
                        color = "#7A48C9",
                        align = "left",
                    },
                })
            end

            do --Button retirer 10
                local pos = { x = 10, y = 125,} --Position en pixel
                local size = { w = 40, h = 30,} --Taille en pixel
                local labelData = scriptedScreen.calculateLabel(h, 16, "-10", ui.oresRequest.surface, false, 0)
                local buttonPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Position en pourcentage par rapport au parent
                local buttonSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Taille en pourcentage par rapport au parent
                pages.oresRequest.contenue.commande.buttonRetirer10 = pages.oresRequest.contenue.commande.background:element({
                    id = "oresRequest_contenue_commande_buttonRetirer10", type = "button",
                    rect = {
                        unit = "%",
                        x = buttonPosPourcentage.x,
                        y = buttonPosPourcentage.y,
                        w = buttonSizePourcentage.x,
                        h = buttonSizePourcentage.y
                    },
                    props = {
                        text = labelData.text,
                        z_index = 0,
                        visible = true,
                    },
                    style = {
                        bg = "#2A1F47",
                        text = "#FFFFFF",
                        font_size = labelData.font_size,
                    },
                    on_click = function(playerName)
                        if oresRequest.quantity <= 9 then
                            local quantity = 0
                            oresRequest.quantity = quantity
                            pages.oresRequest.contenue.commande.inputQuantity:set_props({ value = tostring(quantity) })
                            return
                        end
                        local quantity = oresRequest.quantity - 10
                        oresRequest.quantity = quantity
                        pages.oresRequest.contenue.commande.inputQuantity:set_props({ value = tostring(quantity) })
                    end
                })
            end
            do --Button retirer 1
                local pos = { x = 55, y = 125,} --Position en pixel
                local size = { w = 40, h = 30,} --Taille en pixel
                local labelData = scriptedScreen.calculateLabel(h, 16, "-1", ui.oresRequest.surface, false, 0)
                local buttonPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Position en pourcentage par rapport au parent
                local buttonSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Taille en pourcentage par rapport au parent
                pages.oresRequest.contenue.commande.buttonRetirer1 = pages.oresRequest.contenue.commande.background:element({
                    id = "oresRequest_contenue_commande_buttonRetirer1", type = "button",
                    rect = {
                        unit = "%",
                        x = buttonPosPourcentage.x,
                        y = buttonPosPourcentage.y,
                        w = buttonSizePourcentage.x,
                        h = buttonSizePourcentage.y
                    },
                    props = {
                        text = labelData.text,
                        z_index = 0,
                        visible = true,
                    },
                    style = {
                        bg = "#2A1F47",
                        text = "#FFFFFF",
                        font_size = labelData.font_size,
                    },
                    on_click = function(playerName)
                        if oresRequest.quantity <= 0 then
                            return
                        end
                        local quantity = oresRequest.quantity - 1
                        oresRequest.quantity = quantity
                        pages.oresRequest.contenue.commande.inputQuantity:set_props({ value = tostring(quantity) })
                    end
                })
            end
            do --Button mettre a 0
                local pos = { x = 100, y = 125,} --Position en pixel
                local size = { w = 67, h = 30,} --Taille en pixel
                local labelData = scriptedScreen.calculateLabel(h, 16, "0", ui.oresRequest.surface, false, 0)
                local buttonPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Position en pourcentage par rapport au parent
                local buttonSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Taille en pourcentage par rapport au parent
                pages.oresRequest.contenue.commande.buttonMettreA0 = pages.oresRequest.contenue.commande.background:element({
                    id = "oresRequest_contenue_commande_buttonMettreA0", type = "button",
                    rect = {
                        unit = "%",
                        x = buttonPosPourcentage.x,
                        y = buttonPosPourcentage.y,
                        w = buttonSizePourcentage.x,
                        h = buttonSizePourcentage.y
                    },
                    props = {
                        text = labelData.text,
                        z_index = 0,
                        visible = true,
                    },
                    style = {
                        bg = "#0D0E1B",
                        text = "#FFFFFF",
                        font_size = labelData.font_size,
                    },
                    on_click = function(playerName)
                        local quantity = 0
                        oresRequest.quantity = quantity
                        pages.oresRequest.contenue.commande.inputQuantity:set_props({ value = tostring(quantity) })
                    end
                })
            end
            do --Button ajouter 1
                local pos = { x = 172, y = 125,} --Position en pixel
                local size = { w = 40, h = 30,} --Taille en pixel
                local labelData = scriptedScreen.calculateLabel(h, 16, "+1", ui.oresRequest.surface, false, 0)
                local buttonPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Position en pourcentage par rapport au parent
                local buttonSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Taille en pourcentage par rapport au parent
                pages.oresRequest.contenue.commande.buttonAjouter1 = pages.oresRequest.contenue.commande.background:element({
                    id = "oresRequest_contenue_commande_buttonAjouter1", type = "button",
                    rect = {
                        unit = "%",
                        x = buttonPosPourcentage.x,
                        y = buttonPosPourcentage.y,
                        w = buttonSizePourcentage.x,
                        h = buttonSizePourcentage.y
                    },
                    props = {
                        text = labelData.text,
                        z_index = 0,
                        visible = true,
                    },
                    style = {
                        bg = "#2A1F47",
                        text = "#FFFFFF",
                        font_size = labelData.font_size,
                    },
                    on_click = function(playerName)
                        local quantity = oresRequest.quantity + 1
                        oresRequest.quantity = quantity
                        pages.oresRequest.contenue.commande.inputQuantity:set_props({ value = tostring(quantity) })
                    end
                })
            end
            do --Button ajouter 10
                local pos = { x = 217, y = 125,} --Position en pixel
                local size = { w = 40, h = 30,} --Taille en pixel
                local labelData = scriptedScreen.calculateLabel(h, 16, "+10", ui.oresRequest.surface, false, 0)
                local buttonPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Position en pourcentage par rapport au parent
                local buttonSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Taille en pourcentage par rapport au parent
                pages.oresRequest.contenue.commande.buttonAjouter10 = pages.oresRequest.contenue.commande.background:element({
                    id = "oresRequest_contenue_commande_buttonAjouter10", type = "button",
                    rect = {
                        unit = "%",
                        x = buttonPosPourcentage.x,
                        y = buttonPosPourcentage.y,
                        w = buttonSizePourcentage.x,
                        h = buttonSizePourcentage.y
                    },
                    props = {
                        text = labelData.text,
                        z_index = 0,
                        visible = true,
                    },
                    style = {
                        bg = "#2A1F47",
                        text = "#FFFFFF",
                        font_size = labelData.font_size,
                    },
                    on_click = function(playerName)
                        local quantity = oresRequest.quantity + 10
                        oresRequest.quantity = quantity
                        pages.oresRequest.contenue.commande.inputQuantity:set_props({ value = tostring(quantity) })
                    end
                })
            end

            do --Commande label ou saisir directement
                local pos = { x = 5, y = 159,} --Position en pixel
                local size = { w = 199, h = 26,} --Taille en pixel
                local labelData = scriptedScreen.calculateLabel(h, 16, "OU SAISIR DIRECTEMENT", ui.oresRequest.surface, false, 0)
                local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Position en pourcentage par rapport au parent
                local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Taille en pourcentage par rapport au parent
                pages.oresRequest.contenue.commande.labelSaisirDirectement = pages.oresRequest.contenue.commande.background:element({
                    id = "oresRequest_contenue_commande_saisirDirectement", type = "label",
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
                        color = "#7A48C9",
                        align = "left",
                    },
                })
            end

            do --Popup quantity input
                local pos = { x = 5, y = 187,} --Position en pixel
                local size = { w = 257, h = 38,} --Taille en pixel
                local labelData = scriptedScreen.calculateLabel(h, 16, "Entrez la quantité", ui.oresRequest.surface, false, 0)
                local labelPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Position en pourcentage par rapport au parent
                local labelSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Taille en pourcentage par rapport au parent
                pages.oresRequest.contenue.commande.inputQuantity = pages.oresRequest.contenue.commande.background:element({
                    id = "oresRequest_contenue_commande_quantityInput", type = "textinput",
                    rect = {
                        unit = "%",
                        x = labelPosPourcentage.x,
                        y = labelPosPourcentage.y,
                        w = labelSizePourcentage.x,
                        h = labelSizePourcentage.y,
                    },
                    props = {
                        value = "",
                        placeholder = labelData.text,
                        title = "Name",
                        z_index = 0,
                        visible = true,
                    },
                    style = {
                        bg = "#FFFFFF",
                        text = "#000000",
                        placeholder_color = "#475569",
                        font_size = labelData.font_size,
                    },
                    on_change = function(rawValue, player)
                        if rawValue == "" then
                            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Value du [popup_quantityInput] est vide")
                            oresRequest.quantity = 0
                            return
                        end
                        local value = tonumber(rawValue)
                        if type(value) ~= "number" then
                            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Value du [popup_quantityInput] n'est pas de type number")
                            pages.oresRequest.contenue.commande.inputQuantity:set_props({ value = 0 })
                            return
                        end
                        if value % 1 ~= 0 then -- Test si la quantity est bien un nombre entier
                            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Value du [popup_quantityInput] n'est pas un nombre entier")
                            return
                        end
                        if value < 0 then -- Test si la quantity est bien un nombre entier
                            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Value du [popup_quantityInput] n'est pas un nombre superieur ou égal à 0")
                            pages.oresRequest.contenue.commande.inputQuantity:set_props({ value = 0 })
                            return
                        end

                        oresRequest.quantity = value
                        pages.oresRequest.contenue.commande.inputQuantity:set_props({ value = value })
                    end
                })
            end

            do --Button ajouter au panier
                local pos = { x = 5, y = 237,} --Position en pixel
                local size = { w = 257, h = 38,} --Taille en pixel
                local labelData = scriptedScreen.calculateLabel(h, 16, "+ AJOUTER A LA COMMANDE", ui.oresRequest.surface, false, 0)
                local buttonPosPourcentage = scriptedScreen.convertPixelToPourcentage(pos.x, pos.y, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Position en pourcentage par rapport au parent
                local buttonSizePourcentage = scriptedScreen.convertPixelToPourcentage(size.w, size.h, contenueCommandeBackgroundSize.w, contenueCommandeBackgroundSize.h) --Taille en pourcentage par rapport au parent
                pages.oresRequest.contenue.commande.buttonAjouterAuPanier = pages.oresRequest.contenue.commande.background:element({
                    id = "oresRequest_contenue_commande_buttonAjouterAuPanier", type = "button",
                    rect = {
                        unit = "%",
                        x = buttonPosPourcentage.x,
                        y = buttonPosPourcentage.y,
                        w = buttonSizePourcentage.x,
                        h = buttonSizePourcentage.y
                    },
                    props = {
                        text = labelData.text,
                        z_index = 0,
                        visible = true,
                    },
                    style = {
                        bg = "#2A1F47",
                        text = "#FFFFFF",
                        font_size = labelData.font_size,
                    },
                    on_click = function(playerName)
                    end
                })
            end
        end
    end
end

-----------------------------------------------------
-- Déffinition des fonctions
-----------------------------------------------------

local function refreshOresQuantity()
    for oreType, quantity in pairs(oresQuantity) do
        pages.oresQuantity.contenue.oresTiles[oreType].label:set_props({ text = oreType:sub(1,1):upper() .. oreType:sub(2) .. " : " .. quantity * 50 })
    end
end
openPopupCommandeOres = function(oreType)
    popup.oresRequest.oreType = oreType
    pages.oresQuantity.popup.backgroundSombre:set_props({ visible = true })
    pages.oresQuantity.popup.background:set_props({ visible = true })
    pages.oresQuantity.popup.title:set_props({ visible = true })
    pages.oresQuantity.popup.inputQuantity:set_props({ visible = true })
    pages.oresQuantity.popup.buttonValider:set_props({ visible = true })
    pages.oresQuantity.popup.buttonFermer:set_props({ visible = true })
    pages.oresQuantity.popup.buttonAjouter10:set_props({ visible = true })
    pages.oresQuantity.popup.buttonAjouter1:set_props({ visible = true })
    pages.oresQuantity.popup.buttonRetirer10:set_props({ visible = true })
    pages.oresQuantity.popup.buttonRetirer1:set_props({ visible = true })
end
closePopupCommandeOres = function()
    pages.oresQuantity.popup.inputQuantity:set_props({ value = "" })
    pages.oresQuantity.popup.backgroundSombre:set_props({ visible = false })
    pages.oresQuantity.popup.background:set_props({ visible = false })
    pages.oresQuantity.popup.title:set_props({ visible = false })
    pages.oresQuantity.popup.inputQuantity:set_props({ visible = false })
    pages.oresQuantity.popup.buttonValider:set_props({ visible = false })
    pages.oresQuantity.popup.buttonFermer:set_props({ visible = false })
    pages.oresQuantity.popup.buttonAjouter10:set_props({ visible = false })
    pages.oresQuantity.popup.buttonAjouter1:set_props({ visible = false })
    pages.oresQuantity.popup.buttonRetirer10:set_props({ visible = false })
    pages.oresQuantity.popup.buttonRetirer1:set_props({ visible = false })
end
local function setColorMenuButton()
    do --Ecran oresQuantity
        pages.oresQuantity.menu.button_oresQuantity:set_style({ bg = colorMenuButton.enable })
        pages.oresQuantity.menu.button_oresRequest:set_style({ bg = colorMenuButton.disable })
    end

    do --Ecran oresRequest
        pages.oresRequest.menu.button_oresQuantity:set_style({ bg = colorMenuButton.disable })
        pages.oresRequest.menu.button_oresRequest:set_style({ bg = colorMenuButton.enable })
    end
end

-----------------------------------------------------
-- Définition des functions réseaux
-----------------------------------------------------

ic.net.subscribe("silo/ores_quantity", function (sujet, payload, fromId, fromName, isRetained)
    if type(payload) ~= "table" then
        print(system.log.time() .. "h " .. system.log.level("warn") .. " : Le payload du message réseaux [" .. system.utils.color("Yellow", sujet) .. "] n'est pas de type table")
        return
    end
    for oresType, quantity in pairs(payload) do
        oresQuantity[oresType] = quantity
    end
end)


-----------------------------------------------------
-- Init du système
-----------------------------------------------------

setColorMenuButton()


while true do
    refreshOresQuantity()
    yield()
end