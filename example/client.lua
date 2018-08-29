-- 1. Callback example
RPC.Call("doSomethingRemote", { text = "World", delay = 1000 }, function (result)
    Citizen.Trace("[RPC][Example] Callback result: "..tostring(result))
end)

-- 2. Async example
Citizen.CreateThread(function ()
    -- Some params passed to server-side method
    local result = RPC.CallAsync("doSomethingRemote", {
        text = "World",
        delay = 2000
    })
    Citizen.Trace("[RPC][Example] Async result: "..tostring(result))
end)
