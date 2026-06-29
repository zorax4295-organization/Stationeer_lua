---@meta -- permet d'avoir l'autocompletion sans que le fichier ai besoin d'etre ouvert


--Appellé automatiquement par le jeu lors d'une sauvegarde ou d'un power-off. Doit retourner une string ou nil.
---@return string | nil
function serialize() end

--Appellé automatiquement par le jeu après le chargement. Reçoit la string retournée par serialize(). S'exécute après le premier tour du while true.
---@param blob string
function deserialize(blob) end



ic = {}
ic.persist = {}

---@class NaN
---@class json

ic.enums = {
    LogicType = {
        On = {},
        Lock = {},
        Activate = {},
        Mode = {},
        RequiredPower = {},
        PrefabHash = {},
        ReferenceId = {},
        NameHash = {},
        Open = {},
        Error = {},
        PressureExternal = {},
        PressureInternal = {},
        Setting = {},
        Maximum = {},
        Ratio = {},
        PressureOutput = {},
        TemperatureOutput = {},
        RatioOxygenOutput = {},
        RatioCarbonDioxideOutput = {},
        RatioNitrogenOutput = {},
        RatioPollutantOutput = {},
        RatioMethaneOutput = {},
        RatioWaterOutput = {},
        RatioNitrousOxideOutput = {},
        TotalMolesOutput = {},
        CombustionOutput = {},
        RatioHydrogenOutput = {},
        RatioLiquidHydrogenOutput = {},
        RatioPollutedWaterOutput = {},
        RatioHydrazineOutput = {},
        RatioLiquidHydrazineOutput = {},
        RatioLiquidAlcoholOutput = {},
        RatioHeliumOutput = {},
        RatioLiquidSodiumChlorideOutput = {},
        RatioSilanolOutput = {},
        RatioLiquidSilanolOutput = {},
        RatioHydrochloricAcidOutput = {},
        RatioLiquidOzoneOutput = {},
        Pressure = {},
        Temperature = {},
        Combustion = {},
        TotalMoles = {},
        VolumeOfLiquid = {},
        RatioOxygen = {},
        RatioCarbonDioxide = {},
        RatioNitrogen = {},
        RatioPollutant = {},
        RatioMethane = {},
        RatioWater = {},
        RatioNitrousOxide = {},
        RatioLiquidNitrogen = {},
        RatioLiquidOxygen = {},
        RatioLiquidMethane = {},
        RatioSteam = {},
        RatioLiquidCarbonDioxide = {},
        RatioLiquidPollutant = {},
        RatioLiquidNitrousOxide = {},
        RatioHydrogen = {},
        RatioLiquidHydrogen = {},
        RatioPollutedWater = {},
        RatioHydrazine = {},
        RatioLiquidHydrazine = {},
        RatioLiquidAlcohol = {},
        RatioHelium = {},
        RatioLiquidSodiumChloride = {},
        RatioSilanol = {},
        RatioLiquidSilanol = {},
        RatioHydrochloricAcid = {},
        RatioLiquidHydrochloricAcid = {},
        RatioOzone = {},
        RatioLiquidOzone = {},
        Horizontal = {},
        Vertical = {},
        SolarAngle = {},
        SolarIrradiance = {},
        Quantity = {},
        StackSize = {},
        WorkingGasEfficiency = {},
        Weight = {},
        WattsReachingContact = {},
        Volume = {},
        VerticalRatio = {},
        VelocityZ = {},
        VelocityY = {},
        VelocityX = {},
        VelocityRelativeZ = {},
        VelocityRelativeY = {},
        VelocityRelativeX = {},
        VelocityMagnitude = {},
        TrueAnomaly = {},
        TotalQuantity = {},
        TotalMolesOutput2 = {},
        TotalMolesInput = {},
        TotalMolesInput2 = {},
        TimeToDestination = {},
        Time = {},
        ThrustToWeight = {},
        Thrust = {},
        Throttle = {},
        TemperatureSetting = {},
        TemperatureOutput2 = {},
        TemperatureInput = {},
        TemperatureInput2 = {},
        TemperatureExternal = {},
        TemperatureDifferentialEfficiency = {},
        TargetZ = {},
        TargetY = {},
        TargetX = {},
        TargetSlotIndex = {},
        TargetPrefabHash = {},
        TargetPadIndex = {},
        Survey = {},
        Stress = {},
        SoundAlert = {},
        SizeZ = {},
        SizeY = {},
        SizeX = {},
        Size = {},
        Sites = {},
        SignalStrength = {},
        SignalID = {},
        SettingOutput = {},
        SettingInput = {},
        Setpoint = {},
        SemiMajorAxis = {},
        Rpm = {},
        Richness = {},
        ReturnFuelCost = {},
        Reset = {},
        RequestHash = {},
        RecipeHash = {},
        Reagents = {},
        ReEntryAltitude = {},
    },
    LogicBatchMethod = {
        Maximum = {},
        Minimum = {},
        Average = {},
        Sum = {},
    },
    LogicSlotType = {
        Occupied = {},
        OccupantHash = {},
        Quantity = {},
        Dammage = {},
        Class = {},
        MaxQuantity = {},
        PrefabHash = {},
        SortingClass = {},
        ReferenceId = {},
        FreeSlots = {},
        TotalSlots = {},
    },
    LogicReagentMode = {},
}

--Stocke une string. Retourne true en cas de succès. Les clés commençant par __ sont réservées
---@param key string -- max 128 characters
---@param value string | number | boolean | table | nil -- max 8192 characters
---@return boolean
function ic.persist.set(key, value) end
--Retourne la string ou nil si absente
---@param key string
---@return string | nil
function ic.persist.get(key) end
--Retourne true si la clé existe
---@param key string
---@return boolean
function ic.persist.has(key) end
--Supprime une clé. Retourne true si elle existait.
---@param key string
---@return boolean
function ic.persist.delete(key) end
--Supprime toutes les clés de cette puce (y compris l’ancien blob serialize). Retourne true si quelque chose était stocké.
---@return boolean
function ic.persist.clear() end


--Permet d'écrire sur un périphériques
---@param device integer
---@param logicType LogicType
---@param value number
---@param network integer | nil
---@return nil
function ic.write(device, logicType, value, network) end
--Permet d'écrire sur un périphériques a partir de son id
---@param id integer
---@param logicType LogicType
---@param value number
---@param network integer | nil
---@return nil
function ic.write_id(id, logicType, value, network) end
--Permet d'écrire sur slot d'un périphériques
---@param device integer
---@param slot integer
---@param slotType LogicSlotType
---@param value number
---@param network integer | nil
---@return nil
function ic.write_slot(device, slot, slotType, value, network) end
--Permet d'écrire sur slot d'un périphériques a partir de son id
---@param id integer
---@param slot integer
---@param slotType LogicSlotType
---@param value number
---@param network integer | nil
---@return nil
function ic.write_slot_id(id, slot, slotType, value, network) end
--Permet d'écrire sur un logicType de plusieurs périphériques en même temps
---@param hash integer
---@param logicType LogicType
---@param value number
---@param network integer | nil
---@return nil
function ic.batch_write(hash, logicType, value, network) end
--Permet d'écrire sur un logicType de plusieurs périphériques en même temps a partir d'un nom
---@param hash integer
---@param nameHash integer
---@param logicType LogicType
---@param value number
---@param network integer | nil
---@return nil
function ic.batch_write_name(hash, nameHash, logicType, value, network) end
--Permet d'écrire sur un slot de plusieurs périphériques en même temps
---@param hash integer
---@param slot integer
---@param slotType LogicSlotType
---@param value number
---@param network integer | nil
---@return nil
function ic.batch_write_slot(hash, slot, slotType, value, network) end
--Permet d'écrire sur un slot de plusieurs périphériques en même temps
---@param hash integer
---@param nameHash integer
---@param slot integer
---@param slotType LogicSlotType
---@param value number
---@param network integer | nil
---@return nil
function ic.batch_write_slot_name(hash, nameHash, slot, slotType, value, network) end



--Permet de lire un logicType d'un périphérique
---@param device integer
---@param logicType LogicType
---@param network integer | nil
---@return number | nil
function ic.read(device, logicType, network) end
--Permet de lire un logicType sur un périphérique a partir de son id
---@param id integer
---@param logicType LogicType
---@param network integer | nil
---@return number | nil
function ic.read_id(id, logicType, network) end
--Permet de lire un logicSlotType d'un périphérique
---@param device integer
---@param slot integer
---@param slotType LogicSlotType
---@param network integer | nil
---@return number | nil
function ic.read_slot(device, slot, slotType, network) end
--Permet de lire un logicSlotType d'un périphérique a partir de son id
---@param id integer
---@param slot integer
---@param slotType LogicSlotType
---@param network integer | nil
---@return number | nil
function ic.read_slot_id(id, slot, slotType, network) end
--Permet de lire des logicType de plusieurs périphériques
---@param hash integer
---@param logicType LogicType
---@param network integer | nil
---@return number | NaN
function ic.batch_read(hash, logicType, method, network) end
--Permet de lire des logicType de plusieurs périphériques a partir d'un nom
---@param hash integer
---@param nameHash integer
---@param logicType LogicType
---@param network integer | nil
---@return number | NaN
function ic.batch_read_name(hash, nameHash, logicType, method, network) end
--Permet de lire des logicSlotType de plusieurs périphériques
---@param hash integer
---@param slot integer
---@param slotType LogicSlotType
---@param network integer | nil
---@return number | NaN
function ic.batch_read_slot(hash, slot, slotType, method, network) end
--Permet de lire des logicSlotType de plusieurs périphériques a partir d'un nom
---@param hash integer
---@param nameHash integer
---@param slot integer
---@param slotType LogicSlotType
---@param network integer | nil
---@return number | NaN
function ic.batch_read_slot_name(hash, nameHash, slot, slotType, method, network) end



--Arrête la puce et prend feu
function ic.hcf() end
--Récupére l'id d'un périphériques a partir de son nom
---@param name string
---@return integer
function ic.find(name) end
--Liste tous les périphériques d'un réseau
---@param network integer
---@return nil
function ic.device_list(network) end




--Permet de lire une adresse de la mémoire interne de la puce lua
---@param adress integer
---@return number
function mem_read(adress) end
--Permet d'écrire sur une adresse de la mémoire interne de la puce lua
---@param adress integer
---@param value number
---@return nil
function mem_write(adress, value) end
--Permet de lire une adresse de la mémoire interne d'une autre puce lua
---@param device integer
---@param adress integer
---@param network integer | nil
---@return number
function mem_get(device, adress, network) end
--Permet de lire une adresse de la mémoire interne d'une autre puce lua a partire de son id
---@param id integer
---@param adress integer
---@param network integer | nil
---@return number
function mem_get_id(id, adress, network) end
--Permet d'écrire sur une adresse de la mémoire interne d'une autre puce lua
---@param device integer
---@param adress integer
---@param value number
---@param network integer | nil
---@return nil
function mem_put(device, adress, value, network) end
--Permet d'écrire sur une adresse de la mémoire interne d'une autre puce lua a partire de son id
---@param id integer
---@param adress integer
---@param value number
---@param network integer | nil
---@return nil
function mem_put_id(id, adress, value, network) end
--Permet d'éffacer toute la mémoire interne de la puce lua
---@return nil
function mem_clear() end
--Permet d'éffacer toute la mémoire interne d'une autre puce lua
---@param device integer
---@param network integer | nil
---@return nil
function mem_clear_device(device, network) end
--Permet d'éffacer toute la mémoire interne d'une autre puce lua a partire de son id
---@param id integer
---@param network integer | nil
---@return nil
function mem_clear_id(id, network) end



--Permet de hasher un string
---@param nameHash string
---@return number
function hash(nameHash) end
--Permet de retrouver le hash a partire d'un string
---@param hash integer
---@return string | nil
function prefab_name(hash) end

--Permet d'encoder une chaine de caractère en ascii6 utile pour afficher du texte sur un led display
---@param str string
---@return number
function pack_ascii6(str) end
--Permet de décoder un number en une chaine de caractère
---@param num number
---@return string
function unpack_ascii6(num) end

--Permet de faire patienter le programme pendant 1 tick soit 0.5s
function yield() end
--Permet de faire patienter le programme pendant n seconde ou 0.5 = 1 tick
---@param time number
function sleep(time) end

--S'éxecute a chaque tick du jeux
function tick(dt) end

-- Décale les bits de la valeur A de N positions vers la gauche.
---@param a number
---@param n number
---@return number
function bit_sll(a, n) end

--bit_or(a, b) compare les bits de A et B un par un.
--Pour chaque position de bit :
--si A = 1 OU B = 1 → résultat = 1
--sinon → résultat = 0
-- | Example
--A =  0101
--B =  0011
--OR = 0111
---@param a number
---@param b number
---@return number
function bit_or(a, b) end

--bit_and(a, b) compare les bits de A et B un par un.
--Pour chaque position de bit :
--si A = 1 ET B = 1 → résultat = 1
--sinon → résultat = 0
-- | Example
--A =  0101
--B =  0011
--AND = 0001
---@param a number
---@param b number
---@return number
function bit_and(a, b) end

--bit_xor(a, b) compare les bits de A et B un par un.
--Pour chaque position de bit :
--Le résultat est 1 uniquement si les deux valeurs sont différentes
--sinon → résultat = 0
-- | Example
--A =  0101
--B =  0011
--XOR = 0110
---@param a number
---@param b number
---@return number
function bit_xor(a, b) end

--bit_nor(a, b) compare les bits de A et B un par un.
--Pour chaque position de bit :
--Le résultat est 1 uniquement si les deux valeurs sont égal a 0
--sinon → résultat = 0
-- | Example
--A =  0101
--B =  0011
--NOR = 1000
---@param a number
---@param b number
---@return number
function bit_nor(a, b) end

--bit_not(a, b) compare les bits de A et B un par un.
--Pour chaque position de bit :
--Renoie l'inverse donc si a=1 alors 0 si a=0 alors 1
--sinon → résultat = 0
-- | Example
--A =  01
--NOT = 10
---@param a number
---@return number
function bit_not(a) end

--Extrait la valeur d'un mot binaire a partir d'une plage de bit
---@param value number
---@param startPos integer
---@param finalPos integer
---@return number
function bit_ext(value, startPos, finalPos) end







ic.net = {}

--Obtenir son propre id
---@return integer
function ic.net.id() end
--Liste tous les id de puce Lua sur le réseau
---@return table
function ic.net.peers() end
--Enovie un message a une cible précise soit par id soit par nom
---@param target integer | string
---@param sujet string
---@param payload number | string | boolean | table | nil
---@return nil
function ic.net.send(target, sujet, payload) end
--Enovie un message a tout le monde sur le réseau et renvoie le nombre de puce aillent reçus le message
---@param sujet string
---@param payload number | string | boolean | table | nil
---@return integer
function ic.net.broadcast(sujet, payload) end
--Reçois un message envoyer par send ou broadcast
---@param sujet string
---@param handler string | fun(fromId:integer, fromName:string, payload:number | string | boolean | table | nil) --Execute la function lors de la reception d'une message
---@return nil
function ic.net.listen(sujet, handler) end

--Publie un sujet a qui bont voudra l'écouter
---@param sujet string
---@param payload number | string | boolean | table | nil
---@param options table | nil
---@return number
function ic.net.publish(sujet, payload , options) end
--S'inscrit pour écouter un sujet publier par publish
---@param sujet string
---@param handler string | fun(sujet:string, payload:number | string | boolean | table | nil, fromId:integer, fromName:string, isRetained:boolean) --Execute la function lors de la reception d'une message
---@return nil
function ic.net.subscribe(sujet, handler) end
--Se désincrit d'un sujet
---@param sujet string
---@return nil
function ic.net.unsubscribe(sujet) end

--Permet d'enregistrer une requete RPC sur le server
---@param sujet string
---@param handler function --fonction anonyme retournant une valeur
function ic.net.register(sujet, handler) end
--Permet de se désenregistrer d'une requete RPC
---@param sujet string
function ic.net.unregister(sujet) end
--Permet d'envoyer une requete RPC a une cible et de recevoir la reponse
---@param target string
---@param sujet string
---@param payload number | string | boolean | table | nil
---@param response function
---@param timeout number --En seconde par defaut 10s max 120s
function ic.net.request(target, sujet, payload, response , timeout) end




util = {}
util.json = {}

-- Permet d'encoder des donné en json pour les sauvgarder
---@param data table | boolean | string | number | nil
---@return json
function util.json.encode (data) end



--- commentaire pour comprendre la nouvelle serialisation des donné et les problème de l'ancienne :
--- avec serialize et deserialize on a un problème deserialize s'execute a la toute fin du script donc dans se code
--- local currentState

--- function deserialize(blob)
---     currentState = ... -- restauré ici
--- end

-- FAUX : s'exécute à l'étape 3, avant deserialize (étape 4)
-- currentState est encore nil ici
--- if currentState == states.idle then ... end

--- while true do
    -- CORRECT : après le premier yield(), les prochains tours
    -- voient currentState restauré
---     if currentState == states.idle then ... end
---     yield()
--- end

--- Pour palier a sa un nouvelle ordre de chargement :
--- KV hydraté — ic.persist est chargé en mémoire
--- Compilation du source
--- Init — le code module-level s'exécute, y compris le premier tour du while true
--- deserialize(blob) — s'exécute après l'init comme avant
--- Boucle tick — reprend normalement
--- 
--- Voici les syntaxe des nouvelle fonction disponible :
--- ic.persist.set("key", "maValeur")   -- sauvegarder des donné de la même maniere qu'avec serilize
--- ic.persist.get("key")               -- lire
--- ic.persist.has("key")               -- vérifier si la clé existe
--- ic.persist.delete("key")            -- supprimer une clé
--- ic.persist.clear()                    -- supprimer tout
--- 
--- 
--- ATTENTION : serialize est apeler lors de la sauvgarde du monde se n'est pas le cas de ic.persist.set il est donc fortement recommender de la mettre dans la fonction tick(dt)