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

--local system = require("system")


----------------------------
-- Définition des appareil
----------------------------


----------------------------
-- Définition des donnés
----------------------------

local LT = ic.enums.LogicType

local ores = {
    iron = "iron",
    copper = "copper",
    gold = "gold",
    silicon = "silicon",
    coal = "coal",
    lead = "lead",
    nickel = "nickel",
    silver = "silver",
    cobalt = "cobalt",
}

--local devices = device_list()

--for i, dev in ipairs(devices) do
--    print(dev.display_name)
--end


--ic.net.send("Logic Mirror test reseaux", "test/reseau", true)


local sorterId = ic.find("Sorter test")
local cableHash = hash("ItemCableCoil")
local cableHeavyHash = hash("ItemCableCoilHeavy")
ic.write_id(sorterId, LT.On, 1)
ic.write_id(sorterId, LT.Mode, 1)


local cableOperation = bit_sll(cableHash, 8)
local ResolvedCableOperation = bit_or(cableOperation, 1)

local cableHeavyOperation = bit_sll(cableHeavyHash, 8)
local ResolvedCableHeavyOperation = bit_or(cableHeavyOperation, 1)

mem_clear_id(sorterId)
mem_put_id(sorterId, 0, ResolvedCableOperation)
mem_put_id(sorterId, 31, ResolvedCableHeavyOperation)