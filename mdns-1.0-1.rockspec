package = "mdns"
version = "1.0-1"
source = {
    url = "git://github.com/mrpace2/lua-mdns",
    tag = "1.0"
}
description = {
    summary = "Multicast DNS browser implemented in pure Lua",
    homepage = "https://github.com/mrpace2/lua-mdns",
    license = "MIT"
}
dependencies = {
    "lua >= 5.1",
    "luasocket >= 2.0.2"
}
build = {
    type = "builtin",
    modules = {
        mdns = "mdns.lua"
    },
    copy_directories = { 
        "examples"
    }
}
