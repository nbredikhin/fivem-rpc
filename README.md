# FiveM RPC library

## Description
This resource is a simple [RPC](https://en.wikipedia.org/wiki/Remote_procedure_call) library for [FiveM](https://fivem.net/). It allows you to call methods on remote side and receive return values.

## Installation
1. Copy this resource to your `resources` directory. Resource name should be `fivem-rpc`.
2. Include client_script `'@fivem-rpc/lib.lua'` in your `__resource.lua`.

## Example
```lua
-- server-side
RPC.Register("getGreetingMessage", function (params, ret, player)
    local message = "Hello, "..tostring(GetPlayerName(player)).."!"
    if type(params.text) == "string" then
        message = message.." "..params.text
    end
    return message
end)

-- client-side
RPC.Call("getGreetingMessage", { text = "Params passed by client" }, function (message)
    Citizen.Trace("Greeting message: "..tostring(message))
end)
```

You can also do asynchronous calls inside FiveM threads:
```lua
-- client-side
Citizen.CreateThread(function ()
    local message = RPC.CallAsync("getGreetingMessage", { text = "Params passed by client" })
    Citizen.Trace("Greeting message: "..tostring(message))
end)
```

You can find working example code in `fivem-rpc/example` folder.

## Usage

## RPC.Register(name, callback)
* `name<string>` - remote method name
* `callback<function>` - method function (see method callback)

Registers new method that can be called from remote side.

## Method callback
```lua
RPC.Register("doSomething", function (params, ret, player)
    return "Hello from server"
end)
```

* `params<table>` - params passed to method by remote caller
* `player<player>` - player who called this method (only for server-side)
* `ret<function>` - function for returning values asynchronously

`ret` function can be used to return values asynchronously:
```lua
RPC.Register("doSomething", function (params, player, ret)
    Citizen.SetTimeout(1000, function ()
        ret("Hello from server (but delayed)")
    end)
end)
```
If you return anything from method callback, `ret` will be ignored and return value will be passed to caller (see first callback example).

## RPC.Call(name, params, callback [, player])
* `name<string>` - method name
* `params<table>` - params passed to method
* `callback<function>` - callback called when results are received
* `player<player>` - optional player source to call method on (only for server-side)

Calls remote method.

## RPC.CallAsync(name, params [, player])
* `name<string>` - method name
* `params<table>` - params passed to method
* `player<player>` - optional player source to call method on (only for server-side)
* returns `result<any>` - any data returned by remote method

Calls remote method asynchronously. Can only be used inside `Citizen.CreateThread`.

## RPC.Notify(name, params [, player])
* `name<string>` - method name
* `params<table>` - params passed to method
* `player<player>` - optional player source to call method on (only for server-side)

Calls remote method without receiving return values.
