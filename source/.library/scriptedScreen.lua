--@module scriptedScreen
local system = require("system")

---@class RectElement
---@field x number
---@field y number
---@field w number
---@field h number
---@field style table
---@field top table
---@field right table
---@field bottom table
---@field left table
---@field set_props fun(self: RectElement, x:number?, y:number?, w:number?, h:number?)
---@field set_style fun(self: RectElement, color:string?, thickness:number?)

local scriptedScreen = {}
scriptedScreen.element = {}

-- Permet la création d'un carré ou d'un rectangle
---@param id string
---@param x number
---@param y number
---@param w number
---@param h number
---@param color string
---@param thickness number
---@return RectElement
function scriptedScreen.element.createRect(parent, id, x, y, w, h, color, thickness)
    thickness = thickness or 2
    color = color or "#000000"
    local rect = {
        x = x, y = y, w = w, h = h,
        style = {
            color = color,
            thickness = thickness
        }
    }

    local function apply_style(element)
        element:set_style({
            color = rect.style.color,
            thickness = rect.style.thickness
        })
    end

    rect.top = parent:element({
        id = id .. "_top",
        type = "line",
        props = { x1 = x, y1 = y, x2 = x + w, y2 = y },
        style = rect.style
    })

    rect.right = parent:element({
        id = id .. "_right",
        type = "line",
        props = { x1 = x + w, y1 = y, x2 = x + w, y2 = y + h },
        style = rect.style
    })

    rect.bottom = parent:element({
        id = id .. "_bottom",
        type = "line",
        props = { x1 = x, y1 = y + h, x2 = x + w, y2 = y + h },
        style = rect.style
    })

    rect.left = parent:element({
        id = id .. "_left",
        type = "line",
        props = { x1 = x, y1 = y, x2 = x, y2 = y + h },
        style = rect.style
    })

    -- fonction de mise à jour de props.
    -- utiliser nil pour ne pas mettre a jour un argument
    ---@param x number
    ---@param y number
    ---@param w number
    ---@param h number
    function rect:set_props(x, y, w, h)
        self.x = x or self.x
        self.y = y or self.y
        self.w = w or self.w
        self.h = h or self.h

        self.top:set_props({ x1=self.x, y1=self.y, x2=self.x+self.w, y2=self.y })
        self.right:set_props({ x1=self.x+self.w, y1=self.y, x2=self.x+self.w, y2=self.y+self.h })
        self.bottom:set_props({ x1=self.x, y1=self.y+self.h, x2=self.x+self.w, y2=self.y+self.h })
        self.left:set_props({ x1=self.x, y1=self.y, x2=self.x, y2=self.y+self.h })
    end

    -- fonction de mise à jour de style.
    -- utiliser nil pour ne pas mettre a jour un argument
    ---@param color string
    ---@param thickness number
    function rect:set_style(color, thickness)
        self.style.color = color or self.style.color
        self.style.thickness = thickness or self.style.thickness

        self.top:set_style(self.style)
        self.right:set_style(self.style)
        self.bottom:set_style(self.style)
        self.left:set_style(self.style)
    end

    return rect
end

--Permet de calculer divers parametre d'un label pour qu'il se redimensionne en fonction du texte et de l'ecran
---@param raw_font_size number
---@param text string
---@param isRetourLigne boolean
---@param max_width number
function scriptedScreen.calculateLabel(screenHauteur, raw_font_size, text, parent, isRetourLigne, max_width)
    do
        if type(raw_font_size) ~= "number" then
            print(system.log.time() .. "h " .. system.log.level("fatal") .. " : Fonction calculateLabel [raw_font_size] n'est pas de type number")
            error("Fonction calculateLabel [raw_font_size] n'est pas de type number")
        end
        if type(text) ~= "string" then
            print(system.log.time() .. "h " .. system.log.level("fatal") .. " : Fonction calculateLabel [text] n'est pas de type string")
            error("Fonction calculateLabel [text] n'est pas de type string")
        end
        if type(isRetourLigne) ~= "boolean" then
            print(system.log.time() .. "h " .. system.log.level("fatal") .. " : Fonction calculateLabel [isRetourLigne] n'est pas de type boolean")
            error("Fonction calculateLabel [isRetourLigne] n'est pas de type boolean")
        end
        if type(max_width) ~= "number" then
            print(system.log.time() .. "h " .. system.log.level("fatal") .. " : Fonction calculateLabel [max_width] n'est pas de type number")
            error("Fonction calculateLabel [max_width] n'est pas de type number")
        end
    end

    local REFERENCE_H = 584 --La taille d'ecran de referance avec lequel on a calibrer la fonction pour obtenir la taille du label en pourcentage
    local font_size = math.floor(raw_font_size * (screenHauteur / REFERENCE_H)) --Permet d'obtenir la taille de font size pour n'importe quelle ecran grace a une lois proportionel
    local size = parent:measure_text(text, max_width, font_size, isRetourLigne) --Permet de mesurer la taille du tecte en px

    return {
        font_size = font_size,
        w = size.w + font_size * 0.4, -- longueur en px
        h = size.h, -- hauteur en px
        text = text -- Contenue de texte du label
    }
end

return scriptedScreen