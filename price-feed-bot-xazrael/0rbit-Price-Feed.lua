-- PID XXXXXXXXXXXXXXXX

local json = require("json")

_ORBIT = "ogh_-4jDyj5U4qUWnNopsx-pmYrwRZNLAKxDfA72BbY"

function handleError(msg, errorMessage)
    ao.send({
        Target = msg.From,
        Tags = {
            Action = "Error",
            ["Message-Id"] = msg.Id,
            Error = errorMessage
        }
    })
end

Handlers.add("Xazrael",
    Handlers.utils.hasMatchingTag("Action", "Sponsored-Get-Request"),
    function(msg)
        local token = msg.Tags.Token
        if not token then
            handleError(msg, "Token not provided")
            return
        end
        
        local url = "https://api.coingecko.com/api/v3/simple/price?ids=" .. token .. "&vs_currencies=usd"
        ao.send({
            Target = _ORBIT,
            Action = "Get-Real-Data",
            Url = url
        })
        print("Pricefetch request sent for " .. token)
    end
)

Handlers.add("ReceiveData",
    Handlers.utils.hasMatchingTag("Action", "Receive-Response"),
    function(msg)
        print("Received data: " .. msg.Data)
        local res = json.decode(msg.Data)
        local token = msg.Tags.Token
        if res[token] and res[token].usd then
            ao.send({
                Target = msg.From,
                Tags = {
                    Action = "Price-Response",
                    ["Message-Id"] = msg.Id,
                    Price = res[token].usd
                }
            })
            print("Price of " .. token .. " is " .. res[token].usd)
        else
            handleError(msg, "Failed to fetch price")
        end
    end
)
