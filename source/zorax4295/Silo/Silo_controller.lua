-----------------Explication LogicSorter-------------------
--Le sorter Dispose de plusieur instruction par exemple le HashEquals
--Sa valeur que on lui envoie se décompose en 3 partie
--Du byte 0-7 ses reserver a l'OP_CODE
--Du byte 8-39 ses réserver au PREFAB_HASH
--Du byte 40-63 se n'est pas utiliser d'apres le stationpedia
--On va d'abors encoder la valeur la plus a gauche dans le mot binaire donc celui a la plage de byte la plus elever en locurance le PREFAB_HASH
--On utilise   bit_sll(cableHash, 8)   se que sa fait sa prend le hash du cable :
--Sa le convertie en binaire donc sa resemble a sa : [Unused] 00000000100110100111001101001101  10010110
--Puis a le deplace de 8 bit vers la gauche : [Unused] 10011010011100110100110110010110   00000000
--On a le hash d'encoder maintenant il faut encoder l'op_code ilfaut le mettre pour dire au sorter tien utilise cette instruction en locurance la equal donc op_code = 1
--On fait donc  bit_or(cableHeavyOperation, 1)   Sa test sur chaque bit si ses a 1 ou pas donc sa permet de ne pas detruire le hash comme le ferait un AND
--Donc en binaire sur 8 byte 1 est égal à 00000001 donc on va avoir : [Unused] [PREFAB_HASH]   00000001
--Et voila notre instruction est encoder en binaire
--Maintenant on l'insere dans le sorter avec
--mem_put_id(sorterId, 0, ResolvedCableOperation)
--Chaque adress mémoire peut contenir une instruction on peut avoir 32 adress au maximum donc 32 instruction allant de l'adress 0-31
-----------------------------------------------------------




----------------------------
-- import de la librairie
----------------------------

local system = require("system")


----------------------------
-- Définition des appareil
----------------------------

local sorterId = {
    iron = ic.find("Sorter - Iron"),
    copper = ic.find("Sorter - Copper"),
    gold = ic.find("Sorter - Gold"),
    silicon = ic.find("Sorter - Silicon"),
    coal = ic.find("Sorter - Coal"),
    lead = ic.find("Sorter - Lead"),
    nickel = ic.find("Sorter - Nickel"),
    silver = ic.find("Sorter - Silver"),
    cobalt = ic.find("Sorter - Cobalt"),
}
local siloId = {
    iron = {id = ic.find("Silo - Iron"), quantity = 0},
    copper = {id = ic.find("Silo - Copper"), quantity = 0},
    gold = {id = ic.find("Silo - Gold"), quantity = 0},
    silicon = {id = ic.find("Silo - Silicon"), quantity = 0},
    coal = {id = ic.find("Silo - Coal"), quantity = 0},
    lead = {id = ic.find("Silo - Lead"), quantity = 0},
    nickel = {id = ic.find("Silo - Nickel"), quantity = 0},
    silver = {id = ic.find("Silo - Silver"), quantity = 0},
    cobalt = {id = ic.find("Silo - Cobalt"), quantity = 0},
}
local stackerId = {
    iron = ic.find("Stacker - Iron"),
    copper = ic.find("Stacker - Copper"),
    gold = ic.find("Stacker - Gold"),
    silicon = ic.find("Stacker - Silicon"),
    coal = ic.find("Stacker - Coal"),
    lead = ic.find("Stacker - Lead"),
    nickel = ic.find("Stacker - Nickel"),
    silver = ic.find("Stacker - Silver"),
    cobalt = ic.find("Stacker - Cobalt"),
}
local valveSiloOut = {
    iron = ic.find("Chute Valve Left - Iron"),
    copper = ic.find("Chute Valve Left - Copper"),
    gold = ic.find("Chute Valve Left - Gold"),
    silicon = ic.find("Chute Valve Left - Silicon"),
    coal = ic.find("Chute Valve Left - Coal"),
    lead = ic.find("Chute Valve Left - Lead"),
    nickel = ic.find("Chute Valve Left - Nickel"),
    silver = ic.find("Chute Valve Left - Silver"),
    cobalt = ic.find("Chute Valve Left - Cobalt"),
}


----------------------------
-- Définition des donnés
----------------------------

local LT = ic.enums.LogicType

local ores = {
    iron = {hash = hash("ItemIronOre"), operation = 0},
    copper = {hash = hash("ItemCopperOre"), operation = 0},
    gold = {hash = hash("ItemGoldOre"), operation = 0},
    silicon = {hash = hash("ItemSiliconOre"), operation = 0},
    coal = {hash = hash("ItemCoalOre"), operation = 0},
    lead = {hash = hash("ItemLeadOre"), operation = 0},
    nickel = {hash = hash("ItemNickelOre"), operation = 0},
    silver = {hash = hash("ItemSilverOre"), operation = 0},
    cobalt = {hash = hash("ItemCobaltOre"), operation = 0},
}

----------------------------
-- Définition des functions
----------------------------

--Permet d'encoder un hash en une valeur numerique unique pour les instruction
---@param op_code 1 | 2
---@param hash number
local function encodeSorterOperation(op_code, hash)
    local operationHash = bit_sll(hash, 8)
    local resolvedOperation = bit_or(operationHash, op_code)
    return resolvedOperation
end

local function refreshQuantitySilo()
    for key, value in pairs(siloId) do
        local quantity = system.safe.readId(value.id, LT.Quantity, "Silo - " .. key)
        value.quantity = quantity
    end
end




----------------------------
-- Init du système
----------------------------

for key, silo in pairs(siloId) do
    system.safe.writeId(silo.icfind, LT.On, 1, "Silo - " .. key)
    system.safe.writeId(silo.icfind, LT.Lock, 0, "Silo - " .. key)
end
for key, id in pairs(stackerId) do
    system.safe.writeId(id, LT.On, 1, "Stacker - " .. key)
    system.safe.writeId(id, LT.Lock, 1, "Stacker - " .. key)
    system.safe.writeId(id, LT.Setting, 500, "Stacker - " .. key)
end
for key, id in pairs(valveSiloOut) do
    system.safe.writeId(id, LT.On, 1, "Valve Silo Out - " .. key)
    system.safe.writeId(id, LT.Lock, 0, "Valve Silo Out - " .. key)
    system.safe.writeId(id, LT.Setting, 0, "Valve Silo Out - " .. key)
end

--Encodage de chaque mots numerique dans la table operations
do
    for _, value in pairs(ores) do
        value.operation = encodeSorterOperation(1, value.hash)
    end
    for key, id in pairs(sorterId) do
        system.safe.writeId(id, LT.On, 1, "Sorter - " .. key)
        system.safe.writeId(id, LT.Lock, 1, "Sorter - " .. key)
        mem_clear_id(id)
        mem_put_id(id, 0, ores[key].operation)
    end
end



while true do
    refreshQuantitySilo()
    yield()
end