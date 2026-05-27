----------------------------
-- import de la librairie
----------------------------

local system = require("system")


----------------------------
-- Définition des appareil
----------------------------

local sensor = 0
local panelHash = hash("StructureSolarPanel")
local dualPanelHash = hash("StructureSolarPanelDual")
local panelHeavyHash = hash("StructureSolarPanelReinforced")
local dualPanelHeavyHash = hash("StructureSolarPanelDualReinforced")

----------------------------
-- Définition des donnés
----------------------------

local LT = ic.enums.LogicType
local LBM = ic.enums.LogicBatchMethod
local angleCorrectionHorizontal = 0
local angleCorrectionVertical = 90
local h = 0
local v = 0
local consigneH = 0
local consigneV = 0


----------------------------
-- Définition des functions
----------------------------

--Patiente que les panneaux solaire est atteint leur consigne d'angle avec une petite marge
local function sleepAngleTarget(consigne, marge)
    while -- attent que les panneaux solaire est atteint leur consigne d'angle
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(panelHash, LT.Horizontal, LBM.Average)) and
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(dualPanelHash, LT.Horizontal, LBM.Average)) and
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(panelHeavyHash, LT.Horizontal, LBM.Average)) and
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(dualPanelHeavyHash, LT.Horizontal, LBM.Average))
    do
        yield()
    end
end
local function updateSolarPanel()
    h = system.safe.read(sensor , LT.Horizontal, "Daylight Sensor")
    v = system.safe.read(sensor , LT.Vertical, "Daylight Sensor")
    consigneH = h + angleCorrectionHorizontal
    consigneV = v + angleCorrectionVertical

    ic.batch_write(panelHash, LT.Horizontal, consigneH)
    ic.batch_write(dualPanelHash, LT.Horizontal, consigneH)
    ic.batch_write(panelHeavyHash, LT.Horizontal, consigneH)
    ic.batch_write(dualPanelHeavyHash, LT.Horizontal, consigneH)

    ic.batch_write(panelHash, LT.Vertical, consigneV)
    ic.batch_write(dualPanelHash, LT.Vertical, consigneV)
    ic.batch_write(panelHeavyHash, LT.Vertical, consigneV)
    ic.batch_write(dualPanelHeavyHash, LT.Vertical, consigneV)
end

local function autoTuning()
    while true do
        updateSolarPanel()
        sleepAngleTarget(consigneH, 1)
        local ratioPanel = ic.batch_read(panelHash, LT.Ratio, LBM.Average)
        local ratioDualPanel = ic.batch_read(dualPanelHash, LT.Ratio, LBM.Average)
        local ratioPanelHeavy = ic.batch_read(panelHeavyHash, LT.Ratio, LBM.Average)
        local ratioDualPanelHeavy = ic.batch_read(dualPanelHeavyHash, LT.Ratio, LBM.Average)


        if ratioPanel<0.95 or ratioDualPanel<0.95 or ratioPanelHeavy<0.95 or ratioDualPanelHeavy<0.95 then -- si un panneaux est absent ses pas grave comme NaN<0.95 = false
            angleCorrectionHorizontal = (angleCorrectionHorizontal + 90) % 360 --Le % est le reste d'une division sa permet de garder l'angle entre 0 et 360
            consigneH = h + angleCorrectionHorizontal

            ic.batch_write(panelHash, LT.Horizontal, consigneH)
            ic.batch_write(dualPanelHash, LT.Horizontal, consigneH)
            ic.batch_write(panelHeavyHash, LT.Horizontal, consigneH)
            ic.batch_write(dualPanelHeavyHash, LT.Horizontal, consigneH)

            sleepAngleTarget(consigneH, 1)
        else
            print(system.log.time() .. "h " .. system.log.level("info") .. " : AutoTuning terminé angle Horizontal selectionné : " .. system.utils.color("Yellow", tostring(angleCorrectionHorizontal)))
            return
        end
        yield()
    end
end

----------------------------
-- Init du système
----------------------------

autoTuning()


while true do
    updateSolarPanel()
    yield()
end
