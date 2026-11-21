--@module scriptedScreen

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

--Permet de récupérer la taille de l'écran shouaiter
---@param consoleType "Console Monitor"
---@param path table
---@return number w --Largeur de l'écran en PX
---@return number h --Longueur de l'écran en PX
function scriptedScreen.getScreenSize(path, consoleType)
    local console = {}
    if consoleType == "Console Monitor" then
        console.w = 460
        console.h = 460
    end

    path:get_resolution(console.w, console.w)
    local size = path:size()

    -- Renvoi de la taille de l'écran virtuelle
    return size.w, size.h
end

--Déffinition des paramètre de chaque écran
---@param name string --Nom de la page
---@param currentUi string --La page initial a définire avant la fonction
---@return table
function scriptedScreen.createScreen(name, currentUi)
    local surface = ss.ui.surface(name)
    return {
        -- Rend accessible la surface pour utilisation ulterieur
        surface = surface,
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

return scriptedScreen