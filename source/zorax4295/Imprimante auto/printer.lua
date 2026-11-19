-------------------------------
-- Configuration
-------------------------------

local system = require("system")

--- Entrées

local bpStart = ic.find("Button start Autolathe")
local bpStop = ic.find("Button stop Autolathe")

--- Sortie

--Liste les different Led display
local displayId = {
    state = ic.find("Display state Autolathe"),
    quantity = ic.find("Display quantity Autolathe"),
    progress = ic.find("Display progress Autolathe")
}
local printerName = "Autolathe"
local printer = ic.find(printerName)
local stacker = ic.find("Stacker Autolathe")

----------------------------
-- Définition des données
----------------------------

local LT = ic.enums.LogicType
local nextState
local isDebugMode = true
--List les different état du système
local state = {
    stop = "STOP",
    run = "RUN",
    done = "DONE",
    empty = "EMPTY",
}

-------------------------------
-- STATE MACHINE
-------------------------------

local currentState = state.stop

local stateMachine = {
    [state.stop] = {
        enter = function ()
            system.safe.writeId(displayId.state, LT.Setting, pack_ascii6(state.stop), "Display state " .. printerName)
            system.safe.writeId(displayId.state, LT.Color, 4, "Display state " .. printerName)
            system.safe.writeId(printer, LT.Activate, 0, "printer " .. printerName)
        end,

        tick = function ()
        end,

        exit = function ()
        end,
    }
}

--Permet de changer la state machine d'étape
local function transition(newState)

    --Test si l'étape n'existe pas
    if not stateMachine[newState] then
        print("ERREUR : état inexistant : " .. tostring(newState))
        return
    end


    -- EXIT de l'ancien état
    if stateMachine[currentState].exit then --Test si la fonction exit existe si elle l'execute
        stateMachine[currentState].exit()
    end

    -- Changement d'état
    currentState = newState

    -- ENTER du nouvel état
    if stateMachine[currentState].enter then
        stateMachine[currentState].enter()
    end

    if isDebugMode then
        print(system.log.time() .. "h " .. system.log.level("debug") .. " : New State --> " .. system.utils.color("Yellow", newState))
    end
end

----------------------------
-- Définition des functions
----------------------------


----------------------------
-- Init du système
----------------------------

system.safe.writeId(displayId.state, LT.Mode, 10, "Display state Autolathe")
system.safe.writeId(displayId.progress, LT.Mode, 1, "Display progress Autolathe")
--Execute une première fois la fonction enter de l'étape initial
if stateMachine[currentState].enter then
    stateMachine[currentState].enter()
else
    print(system.log.time() .. "h " .. system.log.level("warn") .. " : la fonction " ..
        system.utils.color("Yellow", "enter") ..
        "de la state" ..
        currentState ..
        "n'existe pas !"
    )
end

while true do
    --Permet d'executer la fonction tick de l'état actuel a chaque tick du jeux
    if stateMachine[currentState].tick then
        nextState = stateMachine[currentState].tick()
    else
        print(system.log.time() .. "h " .. system.log.level("warn") .. " : La fonction tick dans la state : " ..
            system.utils.color("Yellow", currentState) ..
            " n'existe pas !"
        )
    end

    --En Lua, une condition est fausse uniquement si la valeur est nil ou false par consequent nextConduite est un string donc elle ne vaut pas nil donc la condition est vrai
    if nextState ~= nil then
        transition(nextState)
    end

    yield()
end