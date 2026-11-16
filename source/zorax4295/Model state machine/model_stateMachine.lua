-------------------------------
--MODEL ROOM LIGHT — STATE MACHINE
-------------------------------

-------------------------------
-- ARCHITECTURE LOGIQUE — GRAFCET
-------------------------------
--                    ┌───────────────┐
--                    │   ÉTAPE 0     │
--                    │     ARRET     │
--                    │               │
--                    │ Lumières = OFF│
--                    └───────┬───────┘
--                            │
--                            ├─────────────────────────────┐
--                            │                             │
--                  Sélecteur = AUTO              Sélecteur = MANU
--                            │                             │
--                            ▼                             ▼
--                    ┌───────────────┐             ┌───────┴───────┐
--                    │   ÉTAPE 1     │             │   ÉTAPE 2     │
--                    │     AUTO      │             │     MANU      │
--                    │               │             │               │
--                    │ Capteur pièce │             │ Interrupteur  │
--                    │      ↓        │             │      ↓        │
--                    │ Lumières      │             │ Lumières      │
--                    │ ON / OFF      │             │ ON / OFF      │
--                    └───────┬───────┘             └───────┬───────┘
--                            │                             │
--                            │                             │
--                            ├─────────────────────────────┘
--                            │
--                     Sélecteur = ARRET
--                            │
--                            ▼
--                    ┌───────────────┐
--                    │   ÉTAPE 0     │
--                    │     ARRET     │
--                    └───────────────┘

-- Fonctionnement :
--
-- 1. Les entrées sont lues par l'état actif.
-- 2. Le tick() de l'état analyse les entrées.
-- 3. Si une transition est nécessaire, l'état suivant est retourné.
-- 4. transition() gère le changement d'état :
--      → exit() de l'ancien état
--      → changement d'état
--      → enter() du nouvel état
-- 5. L'état actif commande les sorties.
-- 6. Le cycle recommence à chaque yield().



-------------------------------
-- Configuration
-------------------------------

--Librairie système
local system = require("system")

-- Entrées
local roomSensor = 0
local selecteurMode = 1
local switchLight = 2

-- Sortie
local lightHash = {
    wallLight = hash("StructureWallLight"),
    LightLong = hash("StructureLightLong"),
    LightLongAngled = hash("StructureLightLongAngled"),
    LightLongWide = hash("StructureLightLongWide"),
    LightRound = hash("StructureLightRound"),
    LightRoundSmall = hash("StructureLightRoundSmall"),
    LightRoundAngled = hash("StructureLightRoundAngled"),
}


local LT = ic.enums.LogicType



-------------------------------
-- Fonction utilisé dans la state machine
-------------------------------

local function setLight(state)
    for _, hash in pairs(lightHash) do
        ic.batch_write(hash, LT.On, state)
    end
end





-------------------------------
-- STATE MACHINE
-------------------------------

--Liste des differente étape
local stateName = {
    ARRET = "ARRET",
    AUTO = "AUTO",
    MANU = "MANU",
}
local stateCode = {
    [stateName.ARRET] = 0,
    [stateName.AUTO] = 1,
    [stateName.MANU] = 2,
}
--Décrit le comportement de chaque étape
local stateAction = {
    [stateName.ARRET] = {

        enter = function ()
            setLight(0)
        end,

        tick = function()
            local slecteurState = system.safe.read(selecteurMode, LT.Setting, "Selecteur")

            if slecteurState == 1 then
                return stateName.AUTO
            elseif slecteurState == 2 then
                return stateName.MANU
            end

        end,
    },

    [stateName.AUTO] = {

        tick = function ()
            local slecteurState = system.safe.read(selecteurMode, LT.Setting, "Selecteur")
            local sensorOnOffState = system.safe.read(roomSensor, LT.Activate, "sensor")

            if slecteurState == 0 then
                return stateName.ARRET
            elseif slecteurState == 2 then
                return stateName.MANU
            end

            if sensorOnOffState == 1 then
                setLight(1)
            else
                setLight(0)
            end

        end,

    },

    [stateName.MANU] = {
        enter = function()
            print("Entrée en mode MANU")
        end,

        tick = function ()
            local slecteurState = system.safe.read(selecteurMode, LT.Setting, "Selecteur")
            local switchOnOffState = system.safe.read(switchLight, LT.Setting, "Swithc ON/OFF")

            if slecteurState == 0 then
                return stateName.ARRET
            elseif slecteurState == 1 then
                return stateName.AUTO
            end

            if switchOnOffState == 1 then
                setLight(1)
            else
                setLight(0)
            end

        end,

        exit = function()
            print("Sortie du mode MANU")
        end,

    }
}

--Contient l'étape actuelle de la state machine
local currentState = stateName.ARRET

--Permet de changer la state machine d'étape
local function transition(newState)

    --Test si l'étape n'existe pas
    if not stateAction[newState] then
        print("ERREUR : état inexistant : " .. tostring(newState))
        return
    end


    -- EXIT de l'ancien état
    if stateAction[currentState].exit then --Test si la fonction exit existe si elle l'execute
        stateAction[currentState].exit()
    end

    -- Changement d'état
    currentState = newState

    -- ENTER du nouvel état
    if stateAction[currentState].enter then
        stateAction[currentState].enter()
    end


    print(system.log.time() .. "h " .. system.log.level("debug") .. " : ÉTAT actuel : " .. system.utils.color("Yellow", newState))
end


while true do

    local nextState = stateAction[currentState].tick()

    --En Lua, une condition est fausse uniquement si la valeur est nil ou false par consequent nextConduite est un string donc elle ne vaut pas nil donc la condition est vrai
    if nextState ~= nil then
        transition(nextState)
    end

    yield()
end