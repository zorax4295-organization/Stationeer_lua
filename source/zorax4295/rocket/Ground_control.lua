-----------------------------------------------------------------------------
--- Sur les umbilical le LT.Maxium = se que passe au maximum l'appareil le débit en L/tick pour un gas ou le requiredPower pour l'electrique
-----------------------------------------------------------------------------
---------------------------------Objectif------------------------------------
--- Préparer la fusée (electriquement, carburant, vidange cargo)
--- lors du décolage préparer le launch mout au lancement
--- Faire interagir le pupitre de commande et les ihm avec le programme
-----------------------------------------------------------------------------


----------------------------
-- import de la librairie
----------------------------

local system = require("system")
local toBolean = system.utils.toBolean

----------------------------
-- Définition des donnés
----------------------------

local LT = ic.enums.LogicType
local LBM = ic.enums.LogicBatchMethod

local housingAccessId = ic.find("")

local pumpFuelId = ic.find("Turbo Pump Fuel")
local didodePumpStateId = ic.find("Diode state pump")
local gaugePressureTankId = ic.find("Gauge Pressure tank")
local sensorFuelId = ic.find("Pipe Analyzer Fuel")
local upLinkId = ic.find("Uplink")
local bridgeHash = hash("StructureAccessBridge")
local umbilicalHash = {
    gas = hash("StructureGasUmbilicalMale"),
    power = hash("StructurePowerUmbilicalMale"),
    chute = hash("StructureChuteUmbilicalMale"),
}
local display = {
    directionPumpId = ic.find("Display direction pump"),
    umbilicalFuelId = ic.find("Display State Umbilical FUEL"),
    umbilicalPowerId = ic.find("Display State Umbilical Power"),
    umbilicalCargoId = ic.find("Display State Umbilical Cargo"),
    cargoQuantityId = ic.find("Display Stockage n reagent"),
    rocketStateId = ic.find("Display state rocket"),
    displayDirectionPumpFuel = {
        id = ic.find("Display direction pump"),
        remplissage = pack_ascii6("<---"), --Renvoie <---
        vidange = pack_ascii6("--->"), -- Renvoie --->
    },
}


----------------------------
-- Définition des function
----------------------------

local function updateDisplayPumpFuel()
    local directionPump = system.safe.readId(pumpFuelId, LT.Mode, "Turbo Pump Fuel")
    local IsPumpFuelOn = toBolean(system.safe.readId(pumpFuelId, LT.On, "Turbo Pump Fuel"))
end



while true do
    yield()
end