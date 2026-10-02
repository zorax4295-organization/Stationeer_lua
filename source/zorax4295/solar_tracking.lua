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
local panel1X5Hash = hash("")
local dualPanel1X5Hash = hash("")
local panelHeavyHash = hash("StructureSolarPanelReinforced")
local dualPanelHeavyHash = hash("StructureSolarPanelDualReinforced")
local panelHeavy1X5Hash = hash("")
local dualPanelHeavy1X5Hash = hash("")

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
local targetRatio = 0.8
local autoTuningIsDone = false


----------------------------
-- Définition des functions
----------------------------

---@param key string
---@param value table | string | number | boolean
local function saveData(key, value)
    local isOk, valueOrError = pcall(util.json.encode, value)
    if isOk then
        ic.persist.set(key, valueOrError)
    else
        print(system.log.time() .. "h " .. system.log.level("fatal") .. " : Echec de la sauvgarde des données")
        error(valueOrError)
    end
end

---@param key string
---@return nil | string | number | boolean | table
local function loadData(key)
    if not ic.persist.has(key) then
        print(system.log.time() .. "h " .. system.log.level("warn") .. " : Echec du chargement des donnés, la key n'existe pas")
        return nil
    end

    local rawData = ic.persist.get(key)
    if type(rawData) ~= "string" then
        print(system.log.time() .. "h " .. system.log.level("warn") .. " : Echec du chargement des donnés, les données obtenue ne sont pas de type string")
        return nil
    end

    local isOk, data = pcall(util.json.decode, rawData)

    if isOk then
        return data
    end
    print(system.log.time() .. "h " .. system.log.level("warn") .. " : Echec du chargement des donnés, erreur : " .. system.utils.color("Yellow", data))
    return nil
end

--Patiente que les panneaux solaire est atteint leur consigne d'angle avec une petite marge
local function sleepAngleTarget(consigne, marge)
    while -- attent que les panneaux solaire est atteint leur consigne d'angle
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(panelHash, LT.Horizontal, LBM.Average)) and
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(dualPanelHash, LT.Horizontal, LBM.Average)) and
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(panelHeavyHash, LT.Horizontal, LBM.Average)) and
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(dualPanelHeavyHash, LT.Horizontal, LBM.Average)) and
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(panel1X5Hash, LT.Horizontal, LBM.Average)) and
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(dualPanel1X5Hash, LT.Horizontal, LBM.Average)) and
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(panelHeavy1X5Hash, LT.Horizontal, LBM.Average)) and
        not system.utils.inRangeAngle(consigne, marge, ic.batch_read(dualPanelHeavy1X5Hash, LT.Horizontal, LBM.Average))
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
    ic.batch_write(panel1X5Hash, LT.Horizontal, consigneH)
    ic.batch_write(dualPanel1X5Hash, LT.Horizontal, consigneH)
    ic.batch_write(panelHeavy1X5Hash, LT.Horizontal, consigneH)
    ic.batch_write(dualPanelHeavy1X5Hash, LT.Horizontal, consigneH)

    ic.batch_write(panelHash, LT.Vertical, consigneV)
    ic.batch_write(dualPanelHash, LT.Vertical, consigneV)
    ic.batch_write(panelHeavyHash, LT.Vertical, consigneV)
    ic.batch_write(dualPanelHeavyHash, LT.Vertical, consigneV)
    ic.batch_write(panel1X5Hash, LT.Vertical, consigneV)
    ic.batch_write(dualPanel1X5Hash, LT.Vertical, consigneV)
    ic.batch_write(panelHeavy1X5Hash, LT.Vertical, consigneV)
    ic.batch_write(dualPanelHeavy1X5Hash, LT.Vertical, consigneV)
end

local function autoTuning()
    while true do
        updateSolarPanel()
        sleepAngleTarget(consigneH, 1)
        local ratioPanel = ic.batch_read(panelHash, LT.Ratio, LBM.Average)
        local ratioDualPanel = ic.batch_read(dualPanelHash, LT.Ratio, LBM.Average)
        local ratioPanelHeavy = ic.batch_read(panelHeavyHash, LT.Ratio, LBM.Average)
        local ratioDualPanelHeavy = ic.batch_read(dualPanelHeavyHash, LT.Ratio, LBM.Average)
        local ratioPanel1X5 = ic.batch_read(panel1X5Hash, LT.Ratio, LBM.Average)
        local ratioDualPanel1X5 = ic.batch_read(dualPanel1X5Hash, LT.Ratio, LBM.Average)
        local ratioPanelHeavy1X5 = ic.batch_read(panelHeavy1X5Hash, LT.Ratio, LBM.Average)
        local ratioDualPanelHeavy1X5 = ic.batch_read(dualPanelHeavy1X5Hash, LT.Ratio, LBM.Average)


        if ratioPanel < targetRatio
            or ratioDualPanel < targetRatio
            or ratioPanelHeavy < targetRatio
            or ratioDualPanelHeavy < targetRatio
            or ratioPanel1X5 < targetRatio
            or ratioDualPanel1X5 < targetRatio
            or ratioPanelHeavy1X5 < targetRatio
            or ratioDualPanelHeavy1X5 < targetRatio
        then -- si un panneaux est absent ses pas grave comme NaN<0.95 = false
            angleCorrectionHorizontal = (angleCorrectionHorizontal + 90) % 360 --Le % est le reste d'une division sa permet de garder l'angle entre 0 et 360
            consigneH = h + angleCorrectionHorizontal

            ic.batch_write(panelHash, LT.Horizontal, consigneH)
            ic.batch_write(dualPanelHash, LT.Horizontal, consigneH)
            ic.batch_write(panelHeavyHash, LT.Horizontal, consigneH)
            ic.batch_write(dualPanelHeavyHash, LT.Horizontal, consigneH)
            ic.batch_write(panel1X5Hash, LT.Horizontal, consigneH)
            ic.batch_write(dualPanel1X5Hash, LT.Horizontal, consigneH)
            ic.batch_write(panelHeavy1X5Hash, LT.Horizontal, consigneH)
            ic.batch_write(dualPanelHeavy1X5Hash, LT.Horizontal, consigneH)

            sleepAngleTarget(consigneH, 1)
        else
            print(system.log.time() .. "h " .. system.log.level("info") .. " : AutoTuning terminé angle Horizontal selectionné : " .. system.utils.color("Yellow", tostring(angleCorrectionHorizontal)))
            autoTuningIsDone = true
            saveData("autoTuning/data", {autoTuningIsDone = autoTuningIsDone, angleCorrectionHorizontal = angleCorrectionHorizontal})
            return
        end
        yield()
    end
end

----------------------------
-- Init du système
----------------------------
local saved = loadData("autoTuning/data")
if saved ~= nil then
    angleCorrectionHorizontal = saved.angleCorrectionHorizontal
    autoTuningIsDone = saved.autoTuningIsDone
end
if not autoTuningIsDone then
    autoTuning()
end


while true do
    updateSolarPanel()
    yield()
end
