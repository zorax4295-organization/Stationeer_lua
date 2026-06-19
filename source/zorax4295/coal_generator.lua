----------------------------
-- import de la librairie
----------------------------

local system = require("system")

----------------------------
-- Définition des appareil
----------------------------


local generatorHash = hash("StructureSolidFuelGenerator")
local smallBatterieHash = hash("StructureBattery")
local largeBatterieHash = hash("StructureBatteryLarge")
local siloId = ic.find("SDB Silo coal")
local consoleId = {
    coalQuantity = ic.find("Display coal quantity"),
    chargeBattery = ic.find("Display batterie charge"),
}



----------------------------
-- Définition des donnés
----------------------------

local LT = ic.enums.LogicType
local LBM = ic.enums.LogicBatchMethod

local coalQuantity
local ratioBattery

----------------------------
-- Définition des functions
----------------------------

local function refreshCoalQuantity()
    coalQuantity = system.safe.readId(siloId, LT.Quantity, "Silo - Coal")
    system.safe.writeId(consoleId.coalQuantity, LT.Setting, coalQuantity, "Display coal quantity")

    if coalQuantity <= 20 then
        system.safe.writeId(consoleId.coalQuantity, LT.Color, 4, "Display coal quantity") --Rouge
    elseif coalQuantity <= 100 then
        system.safe.writeId(consoleId.coalQuantity, LT.Color, 3, "Display coal quantity") --Orange
    elseif coalQuantity <= 150 then
        system.safe.writeId(consoleId.coalQuantity, LT.Color, 5, "Display coal quantity") --Jaune
    else
        system.safe.writeId(consoleId.coalQuantity, LT.Color, 2, "Display coal quantity") --Vert
    end
end
local function refreshBatteryPourcentage()
    local ratioSmallBattery = ic.batch_read(smallBatterieHash, LT.Ratio, LBM.Average)
    local ratioLargeBattery = ic.batch_read(largeBatterieHash, LT.Ratio, LBM.Average)
    if (ratioSmallBattery ~= ratioSmallBattery) and (ratioLargeBattery ~= ratioLargeBattery) then
        print(system.log.time() .. "h " .. system.log.level("fatal") .. " : Aucune batterie n'est présente sur le réseau")
        error("Aucune batterie n'est présente sur le réseau")
    end

    if ratioSmallBattery ~= ratioSmallBattery then --Si ratioSmallBattery est un NaN alors ...
        ratioBattery = ratioLargeBattery
    elseif ratioLargeBattery ~= ratioLargeBattery then --Si ratioLargeBattery est un NaN alors ...
        ratioBattery = ratioSmallBattery
    else
        ratioBattery = (ratioSmallBattery + ratioLargeBattery) / 2
    end

    system.safe.writeId(consoleId.chargeBattery, LT.Setting, ratioBattery, "Display batterie charge") --L'erreur est régler mais lua considere encore une erreur alors quelle est traité au dessus
    if ratioBattery <= 0.25 then
        system.safe.writeId(consoleId.chargeBattery, LT.Color, 4, "Display batterie charge") --Rouge
    elseif ratioBattery <= 0.5 then
        system.safe.writeId(consoleId.chargeBattery, LT.Color, 3, "Display batterie charge") --Orange
    elseif ratioBattery <= 0.75 then
        system.safe.writeId(consoleId.chargeBattery, LT.Color, 5, "Display batterie charge") --Jaune
    else
        system.safe.writeId(consoleId.chargeBattery, LT.Color, 2, "Display batterie charge") --Vert
    end
end



----------------------------
-- Init du système
----------------------------

system.safe.writeId(consoleId.coalQuantity, LT.Mode, 0, "Display coal quantity")
system.safe.writeId(consoleId.coalQuantity, LT.On, 1, "Display coal quantity")
system.safe.writeId(consoleId.chargeBattery, LT.Mode, 1, "Display batterie charge")
ic.batch_write(generatorHash, LT.Lock, 1)




function tick(dt)

end


while true do
    refreshCoalQuantity()
    refreshBatteryPourcentage()

    if ratioBattery < 0.10 then
        while ratioBattery < 0.8 do
            ic.batch_write(generatorHash, LT.On, 1)
            refreshCoalQuantity()
            refreshBatteryPourcentage()
            yield()
        end
        ic.batch_write(generatorHash, LT.On, 0)
    end
    yield()
end