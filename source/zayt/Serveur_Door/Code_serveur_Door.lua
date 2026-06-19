

----------------------------
-- import de la librairie
----------------------------

local system = require("system")



----------------------------
-- Définition des appareil
----------------------------

local housingAccess = 0
local buttonDepartCycleId = ic.find("Start Cycle")
local doorId = ic.find("Blast Door")
local gasSensorId = ic.find("Gas Sensor Int")
local gasSensorExterId = ic.find("Gas Sensor Ext")
local ventInterId = ic.find("Powered Vent inter")
local ventExterId = ic.find("Powered Vent exter")
local alarmId = ic.find("Logic Alarm")
local numPadId = ic.find("Logic Num Pad")
local displayState = ic.find("Display state")
local displayPressure = ic.find("Display pressure")
local flashLightHash = hash("StructureFlashingLight")
local lightHash = hash("StructureLightLongWide")


----------------------------
-- Définition des données
----------------------------

local LT = ic.enums.LogicType
local code = 1234
local accessLevel = {
    denied = 0,
    granted = 1,
    maintenance = 2,
}
local state = {
    idle = 0,
    cycleRunning = 1,
}
local currentState = state.idle
local sensCycle = {
    pressurizing = 0,
    depressurizing = 1,
}
local currentSensCycle = sensCycle.depressurizing
local displayStateValue = {
    cycleInProgress = pack_ascii6("Cycle"),
    idle = pack_ascii6("Idle"),
}


----------------------------
-- Définition des functions
----------------------------

local function refreshPressureDisplay()
    --Pression en kPa
    local pressureRoom = system.safe.readId(gasSensorId, LT.Pressure, "Gas Sensor Interieur") * 1000 -- lit et convertie de kPa en Pa
    system.safe.writeId(displayPressure, LT.Setting, pressureRoom, "Led Display Pressure")
    if pressureRoom >= 240000 then
        system.safe.writeId(displayPressure, LT.Color, 4) --Rouge
    elseif pressureRoom >= 150000 then
        system.safe.writeId(displayPressure, LT.Color, 3) --Orange
    else
        system.safe.writeId(displayPressure, LT.Color, 2) --Vert
    end
end
local function pressurizing()
    print(system.log.time() .. system.log.level("info") .. " : Server Room Pressurizing Started" )
    system.safe.writeId(displayState, LT.Setting, displayStateValue.cycleInProgress, "Led Display State")
    ic.batch_write(flashLightHash, LT.On, 1)
    ic.batch_write(lightHash, LT.On, 0)
    system.safe.writeId(alarmId, LT.On, 1, "Alarm")
    yield()
    system.safe.writeId(ventInterId, LT.Mode, 0, "Vent Exterieur")
    system.safe.writeId(ventInterId, LT.On, 1, "Vent Exterieur")

    while not system.utils.inRangeMarge(system.safe.readId(gasSensorExterId, LT.Pressure, "Gas Sensor Exterieur"), 0.5, system.safe.readId(gasSensorId, LT.Pressure, "Gas Sensor Interieur")) do
        yield()
    end

    system.safe.writeId(ventInterId, LT.On, 0, "Vent Exterieur")
    yield()
    system.safe.writeId(doorId, LT.Open, 1, "Blast Door") --Ouvert
    ic.batch_write(flashLightHash, LT.On, 0)
    ic.batch_write(lightHash, LT.On, 1)
    system.safe.writeId(alarmId, LT.On, 0, "Alarm")
    print(system.log.time() .. system.log.level("info") .. " : Server Room Pressurizing Finished" )
    currentSensCycle = sensCycle.depressurizing
end
local function depressurizing()
    print(system.log.time() .. system.log.level("info") .. " : Server Room depressurizing Started" )
    system.safe.writeId(displayState, LT.Setting, displayStateValue.cycleInProgress, "Led Display State")
    system.safe.writeId(doorId, LT.Open, 0, "Blast Door") --fermé
    ic.batch_write(flashLightHash, LT.On, 1)
    ic.batch_write(lightHash, LT.On, 0)
    system.safe.writeId(alarmId, LT.On, 1, "Alarm")
    yield()
    system.safe.writeId(ventExterId, LT.Mode, 1, "Vent Exterieur")
    system.safe.writeId(ventExterId, LT.On, 1, "Vent Exterieur")

    while system.safe.readId(gasSensorId, LT.Pressure, "Gas Sensor Interieur") ~= 0 do
        yield()
    end

    sleep(2)
    system.safe.writeId(ventExterId, LT.On, 0, "Vent Exterieur")
    ic.batch_write(flashLightHash, LT.On, 0)
    ic.batch_write(lightHash, LT.On, 1)
    system.safe.writeId(alarmId, LT.On, 0, "Alarm")
    print(system.log.time() .. system.log.level("info") .. " : Server Room depressurizing Finished" )
    currentSensCycle = sensCycle.pressurizing
end
local function saveData()
    local data = {
        currentState = currentState,
        currentSensCycle = currentSensCycle,
    }
    ic.persist.set("programSave", util.json.encode(data))
end
local function loadData(key)
    if not ic.persist.has(key) then return nil end
    local brut = ic.persist.get(key)
    if type(brut) ~= "string" then return nil end
    local ok, data = pcall(util.json.decode, brut)

    if ok and type(data) == "table" then
        currentState = data.currentState
        currentSensCycle = data.currentSensCycle
    else
        print(system.log.time() .. "h " .. system.log.level("info") .. " : Echec de la Reconstruction des donnés data n'est pas de type table")
    end
end

----------------------------
-- Init du system
----------------------------
do
    system.safe.writeId(ventExterId, LT.On, 0, "Vent Exterieur")
    system.safe.writeId(ventInterId, LT.On, 0, "Vent Interieur")
    ic.batch_write(flashLightHash, LT.On, 0)
    ic.batch_write(lightHash, LT.On, 1)
    system.safe.writeId(alarmId, LT.Color , 4)
    system.safe.writeId(displayState, LT.Mode, 10, "Led Display State") --Définition du led display en mode string
    system.safe.writeId(displayPressure, LT.Mode, 14, "Led Display Pressure") --Définition du led display en mode pressure

    loadData("programSave")

    if currentState == state.cycleRunning then
        if currentSensCycle == sensCycle.depressurizing then
            depressurizing()
        else
            pressurizing()
        end
    end
end

function tick(dt) --S'execute a chaque tick du jeux
    saveData()
    refreshPressureDisplay()
end



while true do
    local actualAccessLevel = system.safe.read(housingAccess, LT.Setting, "card")
    local actualCode = system.safe.readId(numPadId, LT.Setting, "keypad")
    local dcy = system.safe.readId(buttonDepartCycleId, LT.Activate, "Button Depart Cycle")
    system.safe.writeId(displayState, LT.Setting, displayStateValue.idle, "Led Display State")

    if actualCode == code
        and (actualAccessLevel == accessLevel.granted or actualAccessLevel == accessLevel.maintenance)
        and dcy == 1
    then
        currentState = state.cycleRunning
        print(system.log.time() .. system.log.level("info") .. " : ServerDoor Access " .. system.utils.color("Green", "Granted"))
        if currentSensCycle == sensCycle.depressurizing then
            depressurizing()
        else
            pressurizing()
        end
        currentState = state.idle
    elseif dcy == 1 then
        print(system.log.time() .. system.log.level("info") .. " : ServerDoor Access " .. system.utils.color("Red","Denied"))
    end
    yield()
end