----------------------------
-- Définition des constantes
----------------------------

local oresMaxInSilo = 570 --Quantité de minerais max accepter dans les silo avant que les valve se ferme


----------------------------
-- import de la librairie
----------------------------

local system = require("system")


----------------------------
-- Définition des appareil
----------------------------

local valve = {
    iron = {id = ic.find("Digital Valve - iron"), lastState = 0},
    copper = {id = ic.find("Digital Valve - copper"), lastState = 0},
    gold = {id = ic.find("Digital Valve - gold"), lastState = 0},
    silicon = {id = ic.find("Digital Valve - silicon"), lastState = 0},
    coal = {id = ic.find("Digital Valve - coal"), lastState = 0},
    lead = {id = ic.find("Digital Valve - lead"), lastState = 0},
    nickel = {id = ic.find("Digital Valve - nickel"), lastState = 0},
    silver = {id = ic.find("Digital Valve - silver"), lastState = 0},
    cobalt = {id = ic.find("Digital Valve - cobalt"), lastState = 0},
}

----------------------------
-- Définition des donnés
----------------------------

local LT = ic.enums.LogicType
local oresQuantity = {}



----------------------------
-- Définition des functions réseaux
----------------------------

local function handler(sujet, payload, fromId, fromName, isRetained)
    if type(payload) ~= "table" then
        print(system.log.time() .. "h " .. system.log.level("fatal") .. " : Le payload du message réseaux [" .. system.utils.color("Yellow", sujet) .. "] n'est pas de type table")
        error("type(payload) != table")
    end

    for key, value in pairs(payload) do
        do
            if type(value) ~= "number" then
                print(system.log.time() .. "h " .. system.log.level("warn") .. " : La value a la key [" .. system.utils.color("Yellow", key) .. "] n'est pas de type number")
                goto nextKey
            end
            if value % 1 ~= 0 then
                print(system.log.time() .. "h " .. system.log.level("warn") .. " : La value a la key [" .. system.utils.color("Yellow", key) .. "] n'est pas un nombre entier")
                goto nextKey
            end
        end

        if valve[key] ~= nil then --Test si la key recus par le message existe dans la table valve
            oresQuantity[key] = value
        else
            print(system.log.time() .. "h " .. system.log.level("warn") .. " : La key " .. tostring(key) .. " n'est pas valide")
        end
        ::nextKey::
    end
end
ic.net.subscribe("silo/ores_quantity", "handler") --Recupère les quantiter de minerais des silo



----------------------------
-- Init du système
----------------------------

--Démarage des valve
for oreType, _ in pairs(valve) do
    system.safe.writeId(valve[oreType].id, LT.Lock, 1, "Digital Valve - " .. oreType)
    system.safe.writeId(valve[oreType].id, LT.On, 1, "Digital Valve - " .. oreType)
    system.safe.writeId(valve[oreType].id, LT.Open, 0, "Digital Valve - " .. oreType)
    system.safe.writeId(valve[oreType].id, LT.Setting, 0, "Digital Valve - " .. oreType)
end




while true do

    for oreType, quantity in pairs(oresQuantity) do
        if quantity < oresMaxInSilo then
            if valve[oreType].lastState == 0 then
                system.safe.writeId(valve[oreType].id, LT.Open, 1, "Digital Valve - " .. oreType)
                valve[oreType].lastState = 1
            end
        else
            if valve[oreType].lastState == 1 then
                system.safe.writeId(valve[oreType].id, LT.Open, 0, "Digital Valve - " .. oreType)
                valve[oreType].lastState = 0
            end
        end
    end

    yield()
end