----------------------------
-- import de la librairie
----------------------------

local system = require("system")

----------------------------
-- Définition des appareil
----------------------------

local roomSensor = 0
local lightHash = {
    wallLight = hash("StructureWallLight"),
    LightLong = hash("StructureLightLong"),
    LightLongAngled = hash("StructureLightLongAngled"),
    LightLongWide = hash("StructureLightLongWide"),
    LightRound = hash("StructureLightRound"),
    LightRoundSmall = hash("StructureLightRoundSmall"),
    LightRoundAngled = hash("StructureLightRoundAngled"),
}


----------------------------
-- Définition des données
----------------------------

local LT = ic.enums.LogicType
local LBM = ic.enums.LogicBatchMethod

local toBolean = system.utils.toBolean


----------------------------
-- Init du system
----------------------------
for _, hash in pairs(lightHash) do
    ic.batch_write(hash, LT.Lock, 1)
end


while true do
    local sensorState = system.safe.read(roomSensor, LT.Activate, "Occupancy Sensor")

    for _, hash in pairs(lightHash) do
        ic.batch_write(hash, LT.On, sensorState)
    end

    sleep(4)
end