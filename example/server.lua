-- Register server-side method that can be called remotely
RPC.Method("doSomethingRemote", function (params, ret, client)
    if not params.delay then return end
    Citizen.SetTimeout(params.delay, function ()
        ret("Hello "..tostring(params.text)..", "..GetPlayerName(client))
    end)
end)
