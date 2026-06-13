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

local sensorsIds = {
    A = 0,
    B = 0,
    C = 0,
    D = 0,
    E = 0,
}
local lightHash = hash("StructureLightLongWide")
local lightName = {
    A = hash("Wall Light Room A"),
    B = hash("Wall Light Room B"),
    C = hash("Wall Light Room C"),
    D = hash("Wall Light Room D"),
    E = hash("Wall Light Room E"),
}

----------------------------
-- Définition des données
----------------------------

local LT = ic.enums.LogicType
local LST = ic.enums.LogicSlotType

local occupationState = {
    A = false,
    B = false,
    C = false,
    D = false,
    E = false,
}
local debug = {
    getSensorId = false,
    getLightHash = false,
}

----------------------------
-- Définition des functions
----------------------------

local function getSensorId()
    for key, value in pairs(sensorsIds) do --Itere sur chaque ranger
        local id = ic.find("Occupancy Sensor " .. key)
        if id == nil then
            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Occupancy Sensor " .. system.utils.color("Yellow", key ) .. " manquante.")
            goto continue
        end

        sensorsIds[key] = id
        if debug.getSensorId then
            print(system.log.time().. "h " .. system.log.level("debug") .. " : Occupancy Sensor " .. system.utils.color("Red", key) .. " : "  .. " id = " .. tostring(id))
        end
        ::continue::
    end
end

local function getOccupationState()
    for key, value in pairs(sensorsIds) do
        if sensorsIds[key] == nil or sensorsIds[key] == 0 then
            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Impossible de lire le sensorsIds : sensorsIds " .. system.utils.color("Yellow", key) .. " manquante.")
            return
        end

        local isOccupationState = system.utils.toBolean(system.safe.readId(sensorsIds[key], LT.Activate, "Occupancy Sensor " .. key))
        if type(isOccupationState) == "boolean" then
            occupationState[key] = isOccupationState
        end
    end
end

local function setOccupationStateToLight()
    for key, value in pairs(occupationState) do
        if value == true then
            ic.batch_write_name(lightHash, lightName[key], LT.On, 1)
            sleep(3)
        else
            ic.batch_write_name(lightHash, lightName[key], LT.On, 0)
        end
    end
end


----------------------------
-- Init du system
----------------------------

getSensorId()

while true do
    getOccupationState()
    setOccupationStateToLight()
    yield()
end