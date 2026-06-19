-------------Objectif----------------
---transposer les états des centrifuges sur des diodes
---ON/OFF général
---Couper l'arriver du MIX
---Ouverture des centrifuge quand elles sont pleines
-------------------------------------


----------------------------
-- import de la librairie
----------------------------

local system = require("system")

----------------------------
-- Définition des appareil
----------------------------


local centrifuges = {
    A = {},
    B = {},
    C = {},
    D = {},
}
-- Light qui affiche l'état de la centrifuge
local centriLight = {
    A = {},
    B = {},
    C = {},
    D = {},
}

----------------------------
-- Définition des données
----------------------------

local nCentrifugeuseMax = 20




----------------------------
-- Définition des données
----------------------------


----------------------------
-- Définition des functions
----------------------------

local function collectCentrifugeIds()
    for key, _ in pairs(centrifuges) do --Itere sur les rangé
        for i = 1, nCentrifugeuseMax do -- itere sur chaque centrifuges
            local id = ic.find("Centrifuge " .. key .. i)
            centrifuges[key][i] = id
        end
    end

    for i = 1, 20 do
        print(system.log.time() .. system.log.level("debug") .. " : Centrifuge" .. system.utils.color("Red", "A") .. " : " .. i .. " id = " .. tostring(centrifuges.A[i]))
    end
    for i = 1, 20 do
        print(system.log.time() .. system.log.level("debug") .. " : Centrifuge" .. system.utils.color("Orange", "B") .. " : " .. i .. " id = " .. tostring(centrifuges.B[i]))
    end
    for i = 1, 20 do
        print(system.log.time() .. system.log.level("debug") .. " : Centrifuge" .. system.utils.color("Yellow", "C") .. " : " .. i .. " id = " .. tostring(centrifuges.C[i]))
    end
    for i = 1, 20 do
        print(system.log.time() .. system.log.level("debug") .. " : Centrifuge" .. system.utils.color("Green", "D") .. " : " .. i .. " id = " .. tostring(centrifuges.D[i]))
    end
end

----------------------------
-- Init du system
----------------------------

collectCentrifugeIds()