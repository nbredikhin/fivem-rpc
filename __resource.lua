resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

client_script "shared/rpc.lua"
client_script "lib.lua"

server_script "shared/rpc.lua"
server_script "lib.lua"

-- Example scripts
-- client_script "example/client.lua"
-- server_script "example/server.lua"

export "CallRemoteMethod"
export "RegisterMethod"

server_export "CallRemoteMethod"
server_export "RegisterMethod"
