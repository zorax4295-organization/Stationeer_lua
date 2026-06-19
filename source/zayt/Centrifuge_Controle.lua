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
    powerOff = 4,
    powerOn = 2,
    error = 3,
}

local state = {
    manu = 1,
    auto = 2,
    debug = 3,
}
local currentState = state.manu




----------------------------
-- Définition des données
----------------------------


----------------------------
-- Définition des functions
----------------------------

local function collectCentrifugeIds()
    for key, _ in pairs(centrifugesId) do --Itere sur les rangé
        for i = 1, nCentrifugeuseMax do -- itere sur chaque centrifuges
            local id = ic.find("Centrifuge " .. key .. i) -- récupère l'Id de la centrifuge
            centrifugesId[key][i] = id -- écrit l'Id dans la table centrifuge Id
        end
    end

    if currentState == state.debug then
        for key, _ in pairs(centrifugesId) do
            for i = 1, nCentrifugeuseMax do
                print(system.log.time() .. system.log.level("debug") .. " : Centrifuge " .. system.utils.color("Red", key) .. " : " .. i .. " id = " .. tostring(centrifugesId[key][i]))
            end
        end
    end
end

local function collectLightIds()
    for key, _ in pairs(centriLightId) do
        for i = 1, nCentrifugeuseMax do
            local id = ic.find("Light State Centrifuge " .. key .. i)
            centriLightId[key][i] = id
        end
    end

    if currentState == state.debug then
        for key, _ in pairs(centriLightId) do
            for i = 1, nCentrifugeuseMax do
            print(system.log.time() .. system.log.level("debug") .. " : Light State Centrifuge " .. system.utils.color("Red", key) .. " : " .. i .. " id = " .. tostring(centriLightId[key][i]))
            end
        end
    end
end

----------------------------
-- Init du system
----------------------------

collectCentrifugeIds()
collectLightIds()