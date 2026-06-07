-------------Objectif----------------
---transposer les états des centrifuges sur des diodes *
---ON/OFF général
---Couper l'arriver du MIX
---Ouverture des centrifuge quand elles sont pleines
-------------------------------------


----------------------------
-- Définition des constantes
----------------------------

local nCentrifugeuseMax = 20

----------------------------
-- import de la librairie
----------------------------

local system = require("system")

----------------------------
-- Définition des appareil
----------------------------


local centrifugesId = {
    A = {},
    B = {},
    C = {},
    D = {},
}
-- Light qui affiche l'état de la centrifuge
local centriLightId = {
    A = {},
    B = {},
    C = {},
    D = {},
}

----------------------------
-- Définition des données
----------------------------

local LT = ic.enums.LogicType

print(system.log.time() .. "h " .. system.log.level("debug") .. " : fonction colorLed = " .. tostring(system.utils.colorLed))
local lightState = {
    powerOff = 4, -- Rouge
    powerOn = 2, -- Vert
    error = 5, -- Jaune
}

local state = {
    manu = 1,
    auto = 2,
    debug = 3,
}
local currentState = state.debug
debug = {
    getCentrifugeIds = false,
    getLightIds = false,
}

local centrifugesError = {
    A = {},
    B = {},
    C = {},
    D = {},
}
local centrifugesPowerState = {
    A = {},
    B = {},
    C = {},
    D = {},
}
local lightLastOn = {
    A = {},
    B = {},
    C = {},
    D = {},
}




----------------------------
-- Définition des functions
----------------------------

--Permet d'iterer sur le nombre de centrifuge actuel
---@param action function
local function forNCentrifuge(action)
    for key, _ in pairs(centrifugesId) do --Itere sur les rangé
        for i = 1, nCentrifugeuseMax do -- itere sur chaque centrifuges
            action(key, i)
        end
    end
end

local function getCentrifugeIds()
    forNCentrifuge(function(key, i)
        local id = ic.find("Centrifuge " .. key .. i) -- récupère l'Id de la centrifuge
        if id == nil then
            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Centrifuge " .. system.utils.color("Yellow", key .. i) .. " manquante.")
            return
        end

        centrifugesId[key][i] = id -- écrit l'Id dans la table centrifuge Id
        if currentState == state.debug and debug.getCentrifugeIds == true then
            print(system.log.time() .. "h " .. system.log.level("debug") .. " : Centrifuge " .. system.utils.color("Yellow", key .. i) .. " id = " .. tostring(centrifugesId[key][i]))
        end
    end)
end

local function getLightIds()
    forNCentrifuge(function(key, i)
        local id = ic.find("Light State Centrifuge " .. key .. i)
        if id == nil then
            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Light State Centrifuge " .. system.utils.color("Yellow", key .. i) .. " manquante.")
            return
        end

        centriLightId[key][i] = id
        if currentState == state.debug and debug.getLightIds == true then
            print(system.log.time().. "h " .. system.log.level("debug") .. " : Light State Centrifuge " .. system.utils.color("Red", key) .. " : " .. i .. " id = " .. tostring(centriLightId[key][i]))
        end
    end)
end
--obtien la variable error des centrifuges
local function getErrorCentrifuges()
    forNCentrifuge(function(key, i)
        if centrifugesId[key][i] == nil then
            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Impossible de lire le LogicType Error : Centrifuge " .. system.utils.color("Yellow", key .. i) .. " manquante.")
            return
        end

        local isCentrifugesError = system.utils.toBolean(system.safe.readId(centrifugesId[key][i], LT.Error, "Centrifuge " .. key .. i))
        centrifugesError[key][i] = isCentrifugesError
    end)
end
local function getPowerStateCentrifuges()
    forNCentrifuge(function(key, i)
        if centrifugesId[key][i] == nil then
            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Impossible de lire le LogicType On : Centrifuge " .. system.utils.color("Yellow", key .. i) .. " manquante.")
            return
        end

        local isCentrifugeOn = system.utils.toBolean(system.safe.readId(centrifugesId[key][i], LT.On, "Centrifuge " .. key .. i))
        centrifugesPowerState[key][i] = isCentrifugeOn
    end)
end
local function actualiseLight()
    forNCentrifuge(function(key, i)
        local lightId = centriLightId[key][i]
        local isCentrifugesError = centrifugesError[key][i]
        local isCentrifugeOn = centrifugesPowerState[key][i]
        local isLightLastOn = lightLastOn[key][i]

        if lightId == nil then
            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Impossible de lire le LogicType On : Light " .. system.utils.color("Yellow", key .. i) .. " manquante.")
            return
        end
        if isCentrifugesError == nil or isCentrifugeOn == nil then
            if isLightLastOn ~= system.safe.readId(lightId, LT.On, "Light State Centrifuge " .. key .. i) then
                system.safe.writeId(lightId, LT.Color, 1, "Light State Centrifuge " .. key .. i) -- Gris
                system.safe.writeId(lightId, LT.On, 0, "Light State Centrifuge " .. key .. i)
                lightLastOn[key][i] = system.utils.toBolean(system.safe.read(lightId, LT.On , "Light State Centrifuge " .. key .. i))
            end
            return
        end

        
        system.safe.writeId(lightId, LT.On, 1, "Light State Centrifuge " .. key .. i)
        if isCentrifugesError then
            system.safe.writeId(lightId, LT.Color, 5, "Light State Centrifuge " .. key .. i) -- Jaune
        else
            if isCentrifugeOn then
                system.safe.writeId(lightId, LT.Color, 2, "Light State Centrifuge " .. key .. i) -- Vert
            else
                system.safe.writeId(lightId, LT.Color, 4, "Light State Centrifuge " .. key .. i) -- Rouge
            end
        end
    end)
end


----------------------------
-- Init du system
----------------------------

getCentrifugeIds()
getLightIds()


while true do
    getErrorCentrifuges()
    getPowerStateCentrifuges()
    actualiseLight()
    yield()
end