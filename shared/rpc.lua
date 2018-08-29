-- Callback waiting for remote result
local pendingCallbacks = {}
-- Counter for unique callback id
local callbackId = 0
-- Remote methods table
local registeredMethods = {}

if IsDuplicityVersion() then
    RegisterServerEvent("rpc:call")
    RegisterServerEvent("rpc:result")
else
    RegisterNetEvent("rpc:call")
    RegisterNetEvent("rpc:result")
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
    return function(result)
        TriggerRemoteEvent("rpc:result", source, id, result)
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

    local result = registeredMethods[name](params, GetResponseFunction(id), source)
    if result ~= nil and id then
        TriggerRemoteEvent("rpc:result", source, id, result)
    end
end)

AddEventHandler("rpc:result", function (id, result)
    if not id then return end
    if not pendingCallbacks[id] then return end
    pendingCallbacks[id](result)
    pendingCallbacks[id] = nil
end)
