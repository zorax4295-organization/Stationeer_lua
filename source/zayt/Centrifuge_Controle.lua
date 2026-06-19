-------------Objectif----------------
---transposer les états des centrifuges sur des diodes
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

local lightState = {
    powerOff = system.utils.colorLed("Red"),
    powerOn = system.utils.colorLed("Green"),
    error = system.utils.colorLed("Yellow"),
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


----------------------------
-- Init du system
----------------------------

getCentrifugeIds()
getLightIds()


while true do
    getErrorCentrifuges()
    yield()
end