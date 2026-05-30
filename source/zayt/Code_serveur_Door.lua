

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
local display1Id = ic.find("Display 1")
local display2Id = ic.find("Display 2")
local flashLightId = hash("StructureFlashingLight")
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

----------------------------
-- Définition des functions
----------------------------

local function pressurizing()
    actualSensCycle = sensCycle.depressurizing
    print(system.log.time() .. system.log.level("info") .. " : ServerDoor pressurizing" )
    system.safe.writeId(flashLightId, LT.On, 1, "Flash Light")
    ic.batch_write(lightHash, LT.On, 0)
    system.safe.writeId(alarmId, LT.On, 1, "Alarm")
    system.safe.writeId(ventInterId, LT.Mode, 0, "Vent Interieur")
    system.safe.writeId(ventInterId, LT.On, 1, "Vent Interieur")

    while not system.safe.readId(gasSensorId, LT.Pressure, "Gas Sensor Interieur") >= system.safe.readId(gasSensorExterId, LT.Pressure, "Gas Sensor Exterieur") do
        yield()
    end

    system.safe.writeId(ventInterId, LT.On, 0, "Vent Interieur")
    system.safe.writeId(flashLightId, LT.On, 0, "Flash Light")
    ic.batch_write(lightHash, LT.On, 1)
    system.safe.writeId(alarmId, LT.On, 0, "Alarm")
    yield()
    system.safe.writeId(doorId, LT.Open, 1, "Blast Door") --ouverte
end
local function depressurizing()
    actualSensCycle = sensCycle.pressurizing
    print(system.log.time() .. system.log.level("info") .. " : ServerDoor depressurizing" )
    system.safe.writeId(doorId, LT.Open, 0, "Blast Door") --fermé
    system.safe.writeId(flashLightId, LT.On, 1, "Flash Light")
    ic.batch_write(lightHash, LT.On, 0)
    system.safe.writeId(alarmId, LT.On, 1, "Alarm")
    yield()
    system.safe.writeId(ventExterId, LT.Mode, 1, "Vent Exterieur")
    system.safe.writeId(ventExterId, LT.On, 1, "Vent Exterieur")

    while not system.safe.readId(gasSensorId, LT.Pressure, "Gas Sensor Interieur") == 0 do
        yield()
    end

    system.safe.writeId(ventExterId, LT.On, 0, "Vent Exterieur")
    system.safe.writeId(flashLightId, LT.On, 0, "Flash Light")
    ic.batch_write(lightHash, LT.On, 1)
    system.safe.writeId(alarmId, LT.On, 0, "Alarm")
end


----------------------------
-- Init du system
----------------------------
while true do
    local actualAccessLevel = system.safe.readId(housingAccess, LT.Setting, "card")
    local actualCode = system.safe.readId(accessCode, LT.Setting, "keypad")
    print(ic.read_id(buttonDepartCycleId, LT.Activate))
    local dcy = system.safe.readId(buttonDepartCycleId, LT.Activate, "Button Depart Cycle")
    yield()
    if actualCode == code and (actualAccessLevel == accessLevel.granted or actualAccessLevel == accessLevel.maintenance) and dcy == 1 then
        print(system.log.time() .. system.log.level("info") .. " : ServerDoor Access " .. system.utils.color("Green", "Granted"))
        if actualSensCycle == sensCycle.depressurizing then
            depressurizing()
        end
    elseif dcy == 1 then
        print(system.log.time() .. system.log.level("info") .. " : ServerDoor Access " .. system.utils.color("Red","Denied"))
    end
end