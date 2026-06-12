

local LT = ic.enums.LogicType


while true do
    
    local activate = ic.read(0, LT.Activate)
    if activate == 1 then
        ic.net.request("IC Housing (Compact) silo", "silo/ores_request", {
            {type = "iron", quantity = 1}
        },
            function(ok, payload, err, fromId, fromName)
                if not ok then
                    print("Ok = " .. tostring(ok) .. " Error : " .. tostring(err))
                    return
                end
                print("Ok = " .. tostring(ok))
                print("TYPE payload =", type(payload))
                print("RAW payload =", tostring(payload))
                if type(payload) ~= "table" then
                    print("Le programme " .. tostring(fromName) .. " n'a pas envoyer un payload de type table")
                    return
                end
                for key, value in pairs(payload) do
                    print("| " .. tostring(key) .. " | " .. tostring(value) .. " |")
                end
                print("callback executer")
            end,
            10
        )
    end
    sleep(1)
end 