--@module conv

----------------------------
-- import de la librairie
----------------------------

local system = require("system")

local conv = {}


--Convertion de pression
---@param value number
---@param from "Pa"|"kPa"|"MPa"
---@param to "Pa"|"kPa"|"MPa"
---@return number | nil
function conv.pressure(value, from, to)
    local toPa = {
        Pa  = 1,
        kPa = 1e3,
        MPa = 1e6
    }

    -- Gestion erreur
    if not toPa[from] then
        print(system.log.time() .. "h " .. system.log.level("fatal") .. system.log.moduleName("unitConvert") .. "Unité source invalide: " .. tostring(from))
        return
    elseif not toPa[to] then
        print(system.log.time() .. "h " .. system.log.level("fatal") .. system.log.moduleName("unitConvert") .. "Unité cible invalide: " .. tostring(to))
        return
    end

    -- Conversion
    local valueInPa = value * toPa[from]
    return valueInPa / toPa[to]
end



--Convertion de Kelvin en degrès celsius
---@param valueInCelsius number | string
---@return number | nil
function conv.cToK(valueInCelsius)

    --Traitement des erreur de type de donnée
    if type(valueInCelsius) ~= "number" then
        print(
            system.log.time() .. "h " .. system.log.level("warn") ..
            " : La fonction " .. system.utils.color("Yellow", "cTok()") .. " attend un nombre, type reçu : " .. system.utils.color("Yellow", tostring(type(valueInCelsius)))
        )

        if type(valueInCelsius) == "string" then
            print(system.log.time() .. "h " .. system.log.level("info") .. " : Tentative de convertion de string en number")
            local convertedValue = tonumber(valueInCelsius)

            if type(convertedValue) ~= "number" then
                print(system.log.time() .. "h " .. system.log.level("warn") .. " : " .. system.utils.color("Red", "Echec") .. " de la Tentative de convertion")
                return nil
            end
            if type(convertedValue) == "number" then
                print(system.log.time() .. "h " .. system.log.level("info") .. " : Tentative de convertion " .. system.utils.color("Green", "réussis"))
                valueInCelsius = convertedValue
            end
        else
            return nil
        end
    end

    --Convertion
    return valueInCelsius + 273.15
end
--Convertion de degrès celsius en Kelvin
---@param valueInKelvin number | string
---@return number | nil
function conv.kToC(valueInKelvin)

    --Traitement des erreur de type de donnée
    if type(valueInKelvin) ~= "number" then
        print(
            system.log.time() .. "h " .. system.log.level("warn") ..
            " : La fonction " .. system.utils.color("Yellow", "kToC()") .. " attend un nombre, type reçu : " .. system.utils.color("Yellow", tostring(type(valueInKelvin)))
        )

        if type(valueInKelvin) == "string" then
            print(system.log.time() .. "h " .. system.log.level("info") .. " : Tentative de convertion de string en number")
            local convertedValue = tonumber(valueInKelvin)

            if type(convertedValue) ~= "number" then
                print(system.log.time() .. "h " .. system.log.level("warn") .. " : " .. system.utils.color("Red", "Echec") .. " de la Tentative de convertion")
                return nil
            end
            if type(convertedValue) == "number" then
                print(system.log.time() .. "h " .. system.log.level("info") .. " : Tentative de convertion " .. system.utils.color("Green", "réussis"))
                valueInKelvin = convertedValue
            end
        else
            return nil
        end
    end

    --Convertion
    return valueInKelvin - 273.15
end

return conv