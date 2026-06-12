-------------Objectif----------------
---Quand on ferme la porte ca eteint les lumieres
---Quand on ouvre la porte ca allument les lumieres
-------------------------------------


----------------------------
-- import de la librairie
----------------------------

local system = require("system")

----------------------------
-- Définition des appareil
----------------------------

local device = {
    A = {sensorIds = 0, lightHash = 0},
    B = {sensorIds = 0, lightHash = 0},
    C = {sensorIds = 0, lightHash = 0},
    D = {sensorIds = 0, lightHash = 0},
    E = {sensorIds = 0, lightHash = 0},
}


----------------------------
-- Définition des données
----------------------------

local LT = ic.enums.LogicType
local LST = ic.enums.LogicSlotType

local occupationState = {
    A = {},
    B = {},
    C = {},
    D = {},
    E = {},
}
local debug = {
    getSensorId = false,
    getLightHash = false,
}

----------------------------
-- Définition des functions
----------------------------

local function getSensorId()
    for key, value in pairs(device) do --Itere sur chaque ranger
        local id = ic.find("Occupancy Sensor " .. key)
        if id == nil then
            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Occupancy Sensor " .. system.utils.color("Yellow", key ) .. " manquante.")
            goto continue
        end

        device[key].sensorIds = id
        if debug.getSensorId then
            print(system.log.time().. "h " .. system.log.level("debug") .. " : Occupancy Sensor " .. system.utils.color("Red", key) .. " : "  .. " id = " .. tostring(id))
        end
        ::continue::
    end
end

local function getLightHash()
    
end