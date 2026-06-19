

local LT = ic.enums.LogicType


while true do

    local activate = ic.read(0, LT.Activate)
    if activate == 1 then
        ic.net.request("IC Housing (Compact) silo", "silo/ores_request", {
            {type = "iron", quantity = 1}
        },
            function(ok, payload, err, fromId, fromName)
                if not ok then
                    print("not ok : " .. tostring(ok))
                    return
                end
                print("Payload type = " .. tostring(type(payload)))
                print("Payload raw = " .. tostring(payload))
                if type(payload) ~= "table" then
                    print("Le programme " .. tostring(fromName) .. " n'a pas envoyer un payload de type table")
                    return
                end

                for key, value in pairs(payload) do
                    print("| " .. tostring(key) .. " | " .. tostring(value) .. " |")
                end
            end,
            10
        )
    end
    sleep(1)
end