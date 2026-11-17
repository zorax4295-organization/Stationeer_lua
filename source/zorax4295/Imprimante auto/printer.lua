----------------------------
-- import de la librairie
----------------------------

local system = require("system")

----------------------------
-- Définition des appareil
----------------------------

local displayId = {
    state = ic.find("Display state Autolathe"),
    quantity = ic.find("Display quantity Autolathe"),
    progress = ic.find("Display progress Autolathe")
}

----------------------------
-- Définition des données
----------------------------

local LT = ic.enums.LogicType
local stateName = {
    stop = "STOP",
    run = "RUN",
    done = "DONE",
    empty = "EMPTY",
}

----------------------------
-- Définition des functions
----------------------------


----------------------------
-- Init du système
----------------------------

system.safe.writeId(displayId.state, LT.Mode, 10, "Display state Autolathe")
system.safe.writeId(displayId.progress, LT.Mode, 1, "Display progress Autolathe")

while true do
    yield()
end