

----------------------------
-- import de la librairie
----------------------------

local system = require("system")



----------------------------
-- Définition des appareil
----------------------------

local housingAccess = 0
local buttonDepartCycleId = ic.find("Start Cycle")
local accessCode = 2
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
local sensCycle = {
    pressurizing = 0,
    depressurizing = 1,
}
local actualSensCycle = sensCycle.depressurizing
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
    actualSensCycle = sensCycle.depressurizing
    print(system.log.time() .. system.log.level("info") .. " : Server Room Pressurizing Started" )
    system.safe.writeId(displayState, LT.Setting, displayStateValue.cycleInProgress, "Led Display State")
    ic.batch_write(flashLightHash, LT.On, 1)
    ic.batch_write(lightHash, LT.On, 0)
    system.safe.writeId(alarmId, LT.On, 1, "Alarm")
    yield()
    system.safe.writeId(ventInterId, LT.Mode, 0, "Vent Exterieur")
    system.safe.writeId(ventInterId, LT.On, 1, "Vent Exterieur")

    while system.safe.readId(gasSensorId, LT.Pressure, "Gas Sensor Interieur") <= system.safe.readId(gasSensorExterId, LT.Pressure, "Gas Sensor Exterieur") do
        yield()
    end

    system.safe.writeId(ventInterId, LT.On, 0, "Vent Exterieur")
    yield()
    system.safe.writeId(doorId, LT.Open, 1, "Blast Door") --Ouvert
    ic.batch_write(flashLightHash, LT.On, 0)
    ic.batch_write(lightHash, LT.On, 1)
    system.safe.writeId(alarmId, LT.On, 0, "Alarm")
    print(system.log.time() .. system.log.level("info") .. " : Server Room Pressurizing Finished" )
end
local function depressurizing()
    actualSensCycle = sensCycle.pressurizing
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
end


----------------------------
-- Init du system
----------------------------

system.safe.writeId(ventExterId, LT.On, 0, "Vent Exterieur")
system.safe.writeId(ventInterId, LT.On, 0, "Vent Interieur")
ic.batch_write(flashLightHash, LT.On, 0)
ic.batch_write(lightHash, LT.On, 1)
system.safe.writeId(alarmId, LT.Color , 4)
system.safe.writeId(displayState, LT.Mode, 10, "Led Display State") --Définition du led display en mode string
system.safe.writeId(displayPressure, LT.Mode, 14, "Led Display Pressure") --Définition du led display en mode pressure


function tick(dt) --S'execute a chaque tick du jeux
    refreshPressureDisplay()
end



while true do
    local actualAccessLevel = system.safe.read(housingAccess, LT.Setting, "card")
    local actualCode = system.safe.read(accessCode, LT.Setting, "keypad")
    local dcy = system.safe.readId(buttonDepartCycleId, LT.Activate, "Button Depart Cycle")
    system.safe.writeId(displayState, LT.Setting, displayStateValue.idle, "Led Display State")

    if actualCode == code and (actualAccessLevel == accessLevel.granted or actualAccessLevel == accessLevel.maintenance) and dcy == 1 then
        print(system.log.time() .. system.log.level("info") .. " : ServerDoor Access " .. system.utils.color("Green", "Granted"))
        if actualSensCycle == sensCycle.depressurizing then
            depressurizing()
        else
            pressurizing()
        end
    elseif dcy == 1 then
        print(system.log.time() .. system.log.level("info") .. " : ServerDoor Access " .. system.utils.color("Red","Denied"))
    end
    yield()
end