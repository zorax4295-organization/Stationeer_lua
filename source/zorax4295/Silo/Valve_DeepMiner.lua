

----------------------------
-- import de la librairie
----------------------------

local system = require("system")


----------------------------
-- Définition des appareil
----------------------------

local valveId = {
    iron = ic.find("Digital Valve - iron"),
    copper = ic.find("Digital Valve - copper"),
    gold = ic.find("Digital Valve - gold"),
    silicon = ic.find("Digital Valve - silicon"),
    coal = ic.find("Digital Valve - coal"),
    lead = ic.find("Digital Valve - lead"),
    nickel = ic.find("Digital Valve - nickel"),
    silver = ic.find("Digital Valve - silver"),
    cobalt = ic.find("Digital Valve - cobalt"),
}

----------------------------
-- Définition des donnés
----------------------------

local LT = ic.enums.LogicType
local oresQuantity = {}


----------------------------
-- Définition des functions
----------------------------


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

        if valveId[key] ~= nil then --Test si la key recus par le message existe dans la table valveId
            oresQuantity[key] = value
        else
            print(system.log.time() .. "h " .. system.log.level("warn") .. " : La key n'est pas valide")
        end
        ::nextKey::
    end
end
ic.net.subscribe("silo/ores_quantity", "handler") --Recupère les quantiter de minerais des silo



----------------------------
-- Init du système
----------------------------

--Démarage des valve
for oreType, id in pairs(valveId) do
    system.safe.writeId(id, LT.Lock, 1, "Digital Valve - " .. oreType)
    system.safe.writeId(id, LT.On, 1, "Digital Valve - " .. oreType)
    system.safe.writeId(id, LT.Open, 0, "Digital Valve - " .. oreType)
end




while true do
    yield()
end