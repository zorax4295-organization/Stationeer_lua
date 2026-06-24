----------------------Explication LogicSorter-------------------------
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
-----------------------Model request ores RPC-------------------------
---{
---    {type = "iron", quantity = 50},
---    {type = "copper", quantity = 100},
---}
---Sujet : "silo/ores_request"
----------------------------------------------------------------------
---Nom de la puce lua : Housing silo OS
----------------------------------------------------------------------




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
local silo = {
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
local sorterOresId = ic.find("Logic Sorter ores")
local sorterBeltsId = ic.find("Logic Sorter belts")
local loaderId = ic.find("Loader unfiltred mining belt")
local unloaderId = ic.find("Unloader mining belt")


----------------------------
-- Définition des donnés
----------------------------

local LT = ic.enums.LogicType
local LST = ic.enums.LogicSlotType

local ores = {
    iron = {hash = hash("ItemIronOre"), operationEqual = 0, operationNotEqual = 0},
    copper = {hash = hash("ItemCopperOre"), operationEqual = 0, operationNotEqual = 0},
    gold = {hash = hash("ItemGoldOre"), operationEqual = 0, operationNotEqual = 0},
    silicon = {hash = hash("ItemSiliconOre"), operationEqual = 0, operationNotEqual = 0},
    coal = {hash = hash("ItemCoalOre"), operationEqual = 0, operationNotEqual = 0},
    lead = {hash = hash("ItemLeadOre"), operationEqual = 0, operationNotEqual = 0},
    nickel = {hash = hash("ItemNickelOre"), operationEqual = 0, operationNotEqual = 0},
    silver = {hash = hash("ItemSilverOre"), operationEqual = 0, operationNotEqual = 0},
    cobalt = {hash = hash("ItemCobaltOre"), operationEqual = 0, operationNotEqual = 0},
}
local belts = {
    miningBelt = {hash = hash("ItemMiningBeltMKII"), operationEqual = 0},
    miningBeltMk2 = {hash = hash("ItemMiningBelt"), operationEqual = 0},
    hardMiningBackPack = {hash = hash("ItemHardMiningBackPack"), operationEqual = 0},
}
local adress = 0


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
    for key, value in pairs(silo) do
        local quantity = system.safe.readId(value.id, LT.Quantity, "Silo - " .. key)
        value.quantity = quantity
    end
end
--Permet de lire le loader et de faire sortire la mining belts
local function checkLoader()
    local isPayloadOccupied = system.utils.toBolean(system.safe.readSlotId(loaderId, 0, LST.Occupied, "Loader"))
    local isRecipientOccupied = system.utils.toBolean(system.safe.readSlotId(loaderId, 1, LST.Occupied, "Loader"))
    local isExportOccupied = system.utils.toBolean(system.safe.readSlotId(loaderId, 2, LST.Occupied, "Loader"))

    if isExportOccupied then
        system.safe.writeId(unloaderId, LT.On, 0, "Unloader")
    else
        system.safe.writeId(unloaderId, LT.On, 1, "Unloader")
    end

    sleep(1)
    if isRecipientOccupied and not isPayloadOccupied then
        system.safe.writeId(loaderId, LT.Open, 1, "Loader")
        yield()
        system.safe.writeId(loaderId, LT.Open, 0, "Loader")
    end
end



----------------------------
-- Définition des functions réseaux
----------------------------

--Permet de recevoir des requete de minerais
---@class OreRequest
---@field type string
---@field quantity integer
---@param payload OreRequest[]
ic.net.register("silo/ores_request", function(payload, fromId, fromName)
    local retour = {}
    if type(payload) ~= "table" then
        print(system.log.time() .. "h " .. system.log.level("warn") .. " : Le programme " .. system.utils.color("Yellow", fromName) .. " n'a pas envoyer un payload de type " .. system.utils.color("Yellow", "table"))
        return nil
    end
    print(system.log.time() .. "h " .. system.log.level("debug") .. " : ores request reçue.")
    for index, value in ipairs(payload) do
        print(system.log.time() .. "h " .. system.log.level("debug") .. " : oresType = " .. value.type)
        print(system.log.time() .. "h " .. system.log.level("debug") .. " : quantity = " .. value.quantity)
    end

    for index, value in ipairs(payload) do
        do --Test si le model de donné dans payload est correct
            if type(value.type) ~= "string" then
                print(system.log.time() .. "h " .. system.log.level("warn") .. " : Le type de minerais n'est pas un string a l'index " .. system.utils.color("Yellow", tostring(index)))
                retour[value.type] = false
                goto nextIndex
            elseif ores[value.type] == nil then -- test si le type de minerais est valide en se basant sur les clé de la table ores
                print(system.log.time() .. "h " .. system.log.level("warn") .. " : Le type de minerais n'est pas valide a l'index " .. system.utils.color("Yellow", tostring(index)) .. " valeur actuel : " .. system.utils.color("Yellow", value.type))
                retour[value.type] = false
                goto nextIndex
            end

            if type(value.quantity) ~= "number" then
                print(system.log.time() .. "h " .. system.log.level("warn") .. " : La quantiter de minerais n'est pas un nombre a l'index " .. system.utils.color("Yellow", tostring(index)))
                retour[value.type] = false
                goto nextIndex
            elseif value.quantity % 1 ~= 0 then -- Test si la quantity est bien un nombre entier
                print(system.log.time() .. "h " .. system.log.level("warn") .. " : La quantiter de minerais n'est pas un nombre entier a l'index " .. system.utils.color("Yellow", tostring(index) .. "le type attentu est un nombre entier"))
                retour[value.type] = false
                goto nextIndex
            elseif value.quantity <= 0 then
                print(system.log.time() .. "h " .. system.log.level("warn") .. " : La quantiter de minerais est <= 0 a l'index " .. system.utils.color("Yellow", tostring(index)) .. "valeur attendu > 0")
                retour[value.type] = false
                goto nextIndex
            end
        end


        local quantity = silo[value.type].quantity
        local valveSiloOutId = valveSiloOut[value.type]

        if quantity < value.quantity then
            print(system.log.time() .. "h " .. system.log.level("warn") .. " : Quantity de minerais de " .. system.utils.color("Yellow", value.type) .. " insuffisante")
            retour[value.type] = false
            goto nextIndex
        end
        retour[value.type] = true

        system.safe.writeId(valveSiloOutId, LT.Setting, value.quantity, "Chute Valve Left - " .. system.utils.color("Yellow", value.type))
        system.safe.writeId(valveSiloOutId, LT.Open, quantity, "Chute Valve Left - " .. system.utils.color("Yellow", value.type))

        ::nextIndex::
    end
    return retour
end)


----------------------------
-- Init du système
----------------------------

system.safe.writeId(loaderId, LT.Mode, 1, "Loader")
system.safe.writeId(loaderId, LT.On, 1, "Loader")

for key, value in pairs(silo) do
    system.safe.writeId(value.id, LT.On, 1, "Silo - " .. key)
    system.safe.writeId(value.id, LT.Lock, 1, "Silo - " .. key)
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

do
    --Encodage de chaque mots numerique
    do
        for _, value in pairs(ores) do
            value.operationEqual = encodeSorterOperation(1, value.hash)
            value.operationNotEqual = encodeSorterOperation(2, value.hash)
        end
        for _, value in pairs(belts) do
            value.operationEqual = encodeSorterOperation(1, value.hash)
        end
    end
    --Ecriture de chaque mots numerique dans les sorter des silo
    for key, id in pairs(sorterId) do
        system.safe.writeId(id, LT.On, 1, "Sorter - " .. key)
        system.safe.writeId(id, LT.Lock, 1, "Sorter - " .. key)
        mem_clear_id(id)
        mem_put_id(id, 0, ores[key].operationEqual)
    end


    --Ecriture des mots numerique de chaque minerais dans le sorter ores pres de l'unloader
    system.safe.writeId(sorterOresId, LT.On, 1, "Logic Sorter ores")
    system.safe.writeId(sorterOresId, LT.Lock, 1, "Logic Sorter ores")
    mem_clear_id(sorterOresId)
    for _, value in pairs(ores) do
        mem_put_id(sorterOresId, adress, value.operationNotEqual)
        adress = adress + 1
    end

    --Ecriture des mots numerique de chaque belts dans le sorter belts pres de l'unloader
    system.safe.writeId(sorterBeltsId, LT.On, 1, "Logic Sorter ores")
    system.safe.writeId(sorterBeltsId, LT.Lock, 1, "Logic Sorter ores")
    system.safe.writeId(sorterBeltsId, LT.Mode, 1, "Logic Sorter ores")
    mem_clear_id(sorterBeltsId)
    adress = 0
    for _, value in pairs(belts) do
        mem_put_id(sorterBeltsId, adress, value.operationEqual)
        adress = adress + 1
    end
end



while true do
    refreshQuantitySilo()
    checkLoader()
    do --Publie les quantity de minerais
        ic.net.publish("silo/ores_quantity", {
            iron = silo.iron.quantity,
            copper = silo.copper.quantity,
            gold = silo.gold.quantity,
            silicon = silo.silicon.quantity,
            coal = silo.coal.quantity,
            lead = silo.lead.quantity,
            nickel = silo.nickel.quantity,
            silver = silo.silver.quantity,
            cobalt = silo.cobalt.quantity,
        }, {
            retain = true, --Mémorise le dernier message publié pour ce sujet. Tout nouvel abonné recevra immédiatement cette valeur même si elle a été publiée avant son abonnement.
            ttl = 20, --Temps de conservation du message retenu, en secondes. Après expiration, le message n'est plus distribué aux nouveaux abonnés.
        })
    end
    yield()
end