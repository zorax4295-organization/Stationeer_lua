
----------------------------
-- import de la librairie
----------------------------

local system = require("system")

----------------------------
-- Définition des appareil
----------------------------

local daylightSensor = 0
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

--alias de toBolean dans system
local toBolean = system.utils.toBolean



while true do
    local isSunPresent = toBolean(system.safe.read(daylightSensor, LT.Activate, "Daylight Sensor"))

    if isSunPresent then
        for key, value in pairs(lightHash) do
            system.safe.batch_write(value, LT.On, 0, LBM.Maximum, key)
        end
    else
        for key, value in pairs(lightHash) do
            system.safe.batch_write(value, LT.On, 1, LBM.Maximum, key)
        end
    end
    sleep(4)
end