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
    iron = ic.find("Silo - Iron"),
    copper = ic.find("Silo - Copper"),
    gold = ic.find("Silo - Gold"),
    silicon = ic.find("Silo - Silicon"),
    coal = ic.find("Silo - Coal"),
    lead = ic.find("Silo - Lead"),
    nickel = ic.find("Silo - Nickel"),
    silver = ic.find("Silo - Silver"),
    cobalt = ic.find("Silo - Cobalt"),
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




----------------------------
-- Init du système
----------------------------

for _, id in pairs(siloId) do
    system.safe.writeId(id, LT.On, 1)
    system.safe.writeId(id, LT.Lock, 1)
end

--Encodage de chaque mots numerique dans la table operations
do
    for _, value in pairs(ores) do
        value.operation = encodeSorterOperation(1, value.hash)
    end
    for key, id in pairs(sorterId) do
        system.safe.writeId(id, LT.On, 1)
        system.safe.writeId(id, LT.Lock, 1)
        mem_clear_id(id)
        mem_put_id(id, 0, ores[key].operation)
    end
end



while true do
    yield()
end