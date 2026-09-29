----------------------------
-- import de la librairie
----------------------------

local system = require("system")

----------------------------
-- Définition des appareil
----------------------------

local transmiter_A = 0
local transmiter_B = 1

----------------------------
-- Définition des données
----------------------------

local LT = ic.enums.LogicType
local LBM = ic.enums.LogicBatchMethod
local toBolean = system.utils.toBolean
local pos = {
    A = {},
    B = {},
}
local nameLogTransmiteurA = "transmetteur de puissance A"
local nameLogTransmiteurB = "transmetteur de puissance B"


----------------------------
-- Init du system
----------------------------

system.safe.write(transmiter_A, LT.On, 1, "transmetteur de puissance A")
system.safe.write(transmiter_B, LT.On, 1, "transmetteur de puissance B")
pos.A.x = system.safe.read(transmiter_A, LT.PositionX, nameLogTransmiteurA)
pos.A.y = system.safe.read(transmiter_A, LT.PositionY, nameLogTransmiteurA)
pos.A.z = system.safe.read(transmiter_A, LT.PositionZ, nameLogTransmiteurA)
pos.B.x = system.safe.read(transmiter_B, LT.PositionX, nameLogTransmiteurB)
pos.B.y = system.safe.read(transmiter_B, LT.PositionY, nameLogTransmiteurB)
pos.B.z = system.safe.read(transmiter_B, LT.PositionZ, nameLogTransmiteurB)

--Calcule d'angle pour le transmeteur A
do
    local dX = pos.B.x - pos.A.x
    local dY = pos.B.y - pos.A.y
    local dZ = pos.B.z - pos.A.z

    --Distance horizontale
    local Dh = math.sqrt(dX^2 + dZ^2)
    --Distance total
    local D = math.sqrt(dX^2 + dY^2 + dZ^2)

    local angleV = math.atan(dY / Dh) + 90
    print(system.log.time() .. "h " .. system.log.level("debug") .. " : angle vertical A : " .. angleV)
    system.safe.write(transmiter_A, LT.Vertical, angleV, nameLogTransmiteurA)



    local angleH = math.deg(math.atan2(dX, dZ))
    if angleH < 0 then
        angleH = angleH + 360
    end
    print(system.log.time() .. "h " .. system.log.level("debug") .. " : angle horizontale A : " .. angleH)
    system.safe.write(transmiter_A, LT.Horizontal, angleH, nameLogTransmiteurA)
end

print("------------------------------------------------------------------------------")

--Calcule d'angle pour le transmeteur B
do
    local dX = pos.A.x - pos.B.x
    local dY = pos.A.y - pos.B.y
    local dZ = pos.A.z - pos.B.z

    --Distance horizontale
    local Dh = math.sqrt(dX^2 + dZ^2)
    --Distance total
    local D = math.sqrt(dX^2 + dY^2 + dZ^2)

    local angleV = math.atan(dY / Dh) + 90

    print(system.log.time() .. "h " .. system.log.level("debug") .. " : angle vertical B : " .. angleV)
    system.safe.write(transmiter_B, LT.Vertical, angleV, nameLogTransmiteurB)



    local angleH = math.deg(math.atan2(dX, dZ))
    if angleH < 0 then
        angleH = angleH + 360
    end
    print(system.log.time() .. "h " .. system.log.level("debug") .. " : angle horizontale B : " .. angleH)
    system.safe.write(transmiter_B, LT.Horizontal, angleH + 180, nameLogTransmiteurB)
end