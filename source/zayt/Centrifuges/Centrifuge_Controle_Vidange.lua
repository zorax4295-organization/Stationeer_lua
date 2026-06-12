
----------------------------
-- import de la librairie
----------------------------

local system = require("system")

----------------------------
-- Définition des données
----------------------------

local LT = ic.enums.LogicType
local LST = ic.enums.LogicSlotType



ic.net.listen("centrifuge/vidange", function(fromId, fromName, payload)
    if type(payload) ~= "table" then
        print(system.log.time() .. "h " .. system.log.level("warn") .. " : La puce " .. system.utils.color("Yellow", fromName) .. " a envoyer un payload qui n'est pas une table")
        return
    end
    local centrifugesId = payload.centrifugesId
    local key = payload.key
    local i = payload.i

    sleep(10)
end)

while true do
    yield()
end