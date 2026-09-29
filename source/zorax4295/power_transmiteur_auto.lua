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
local horizontale_A
local vertical_A
local vertical_B
local horizontale_B


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

    vertical_A = math.atan(dY / Dh) + 90
    print(system.log.time() .. "h " .. system.log.level("debug") .. " : angle vertical A : " .. vertical_A)
    system.safe.write(transmiter_A, LT.Vertical, vertical_A, nameLogTransmiteurA)



    horizontale_A = math.deg(math.atan2(dX, dZ))
    if horizontale_A < 0 then
        horizontale_A = horizontale_A + 360
    end
    print(system.log.time() .. "h " .. system.log.level("debug") .. " : angle horizontale A : " .. horizontale_A)
    system.safe.write(transmiter_A, LT.Horizontal, horizontale_A, nameLogTransmiteurA)
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

    vertical_B = math.atan(dY / Dh) + 90

    print(system.log.time() .. "h " .. system.log.level("debug") .. " : angle vertical B : " .. vertical_B)
    system.safe.write(transmiter_B, LT.Vertical, vertical_B, nameLogTransmiteurB)



    horizontale_B = math.deg(math.atan2(dX, dZ))
    if horizontale_B < 0 then
        horizontale_B = horizontale_B + 360
    end
    print(system.log.time() .. "h " .. system.log.level("debug") .. " : angle horizontale B : " .. horizontale_B)
    system.safe.write(transmiter_B, LT.Horizontal, horizontale_B, nameLogTransmiteurB)
end

local function autoTuningHorizontal()

    -- On sauvegarde les angles calculés initialement
    local angleInitialA = horizontale_A
    local angleInitialB = horizontale_B

    print(system.log.time() .. "h " .. system.log.level("info") .. " : Début de la recherche automatique")

    for angleA = 0, 270, 90 do

        -- Angle A = angle initial + déplacement
        local testA = (angleInitialA + angleA) % 360

        horizontale_A = testA

        system.safe.write(
            transmiter_A,
            LT.Horizontal,
            horizontale_A,
            nameLogTransmiteurA
        )

        print(system.log.time() .. "h " .. system.log.level("debug") .. " : Test A = " .. testA .. "°")

        -- Pour chaque nouvelle position de A,
        -- on recommence B à son angle initial
        for angleB = 0, 270, 90 do

            local testB = (angleInitialB + angleB) % 360

            horizontale_B = testB

            system.safe.write(
                transmiter_B,
                LT.Horizontal,
                horizontale_B,
                nameLogTransmiteurB
            )

            print(
                system.log.time() ..
                "h " ..
                system.log.level("debug") ..
                " : Test combinaison A = " ..
                testA ..
                "° | B = " ..
                testB ..
                "°"
            )

            -- Attente avant le test
            sleep(15)

            -- Test de la liaison
            local isAligned = toBolean(
                system.safe.read(
                    transmiter_A,
                    LT.Mode,
                    nameLogTransmiteurA
                )
            )

            if isAligned then

                print(
                    system.log.time() ..
                    "h " ..
                    system.log.level("info") ..
                    " : Liaison établie avec " ..
                    system.utils.color("Green", "succès") ..
                    " | A = " ..
                    testA ..
                    "° | B = " ..
                    testB ..
                    "°"
                )

                return
            end
        end
    end

    print(
        system.log.time() ..
        "h " ..
        system.log.level("warn") ..
        " : Aucune combinaison trouvée"
    )
end

sleep(30)
autoTuningHorizontal()