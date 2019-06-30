-- Callback waiting for remote result
local pendingCallbacks = {}
-- Counter for unique callback id
local callbackId = 0
-- Remote methods table
local registeredMethods = {}

if IsDuplicityVersion() then
    RegisterServerEvent("rpc:call")
    RegisterServerEvent("rpc:response")
else
    RegisterNetEvent("rpc:call")
    RegisterNetEvent("rpc:response")
end

---------------------
-- Local functions --
---------------------

local function GetNextId()
    callbackId = callbackId + 1
    return callbackId
end

local function TriggerRemoteEvent(eventName, source, ...)
    if IsDuplicityVersion() then
        TriggerClientEvent(eventName, source or -1, ...)
    else
        TriggerServerEvent(eventName, ...)
    end
end

local function GetResponseFunction(id)
    if not id then
        return function () end
    end
    return function(...)
        TriggerRemoteEvent("rpc:response", source, id, ...)
    end
end

----------------------
-- Global functions --
----------------------

function CallRemoteMethod(name, params, callback, source)
    assert(type(name) == "string", "[RPC] CallRemoteMethod: Invalid method name. Expected string, got "..type(name))
    assert(type(params) == "table", "[RPC] CallRemoteMethod: Invalid params. Expected table, got "..type(params))

    local id = false
    if callback then
        id = GetNextId()
        pendingCallbacks[id] = callback
    end

    return TriggerRemoteEvent("rpc:call", source, id, name, params)
end

function RegisterMethod(name, callback)
    assert(type(name) == "string", "[RPC] RegisterMethod: Invalid method name. Expected string, got "..type(name))
    assert(callback, "[RPC] RegisterMethod: Invalid callback. Expected callback, got "..type(callback))

    registeredMethods[name] = callback
    return true
end

--------------------
-- Event handling --
--------------------

AddEventHandler("rpc:call", function (id, name, params)
    if type(name) ~= "string" then return end
    if not registeredMethods[name] then return end

    local returnValues = {registeredMethods[name](params, source, GetResponseFunction(id))}
    if #returnValues > 0 and id then
        TriggerRemoteEvent("rpc:response", source, id, table.unpack(returnValues))
    end
end)

AddEventHandler("rpc:response", function (id, ...)
    if not id then return end
    if not pendingCallbacks[id] then return end
    pendingCallbacks[id](...)
    pendingCallbacks[id] = nil
end)
