# lua-mdns

Multicast DNS (mDNS) service browser implemented in pure Lua. mDNS provides the ability to provide and find DNS names for local devices. For more information on mDNS and DNS Service discovery, see <http://www.dns-sd.org>.


## Installing

**Prerequisites**

* Lua 5.2 or later
* LuaSocket 2.1 or later (currently tested on 3.0rc1)

**Installation using LuaRocks package manager**

    $ luarocks make mdns-2.0-1.rockspec


## Example Usage

The code below queries all mDNS services available on the local network.

    local mdns = require('mdns')

    -- DNS service discovery (defaults: all services, 2 seconds timeout)
    local res = mdns.query()
    if (res) then
        for k,v in pairs(res) do
            -- output key name
            print(k)
            local function print_table(t, indent)
                for k,v in pairs(t) do
                    -- output service descriptor fields
                    if (type(v) == 'table') then
                        print(string.rep('  ',indent)..k..':')
                        print_table(v, indent + 1)
                    else
                        print(string.rep('  ',indent)..k..': '..v)
                    end
                end
            end
            print_table(v, 1)
        end
    else
        print('no result')
    end

If called without parameters, `mdns.query` returns all available services after the default timeout of 2 seconds. Additional examples can be found in the `examples` subdirectory.


## Reference

The module exports _mdns.query_, mdns.query_async, and _mdns.socket_


### mdns.query

**Usage**

    result = mdns.query([<service>, [<timeout>]])


**Parameters**

_mdns.query_ takes up to two parameters:

* **service**: mDNS service name (e.g. \_printers.\_tcp.local). The _.local_ suffix may be omitted. If this parameter is missing or if it evaluates to `nil`, _mdns.query_ queries all available mDNS services by using enumerating the *\_services.\_dns-sd.\_udp.local* service.

* **timeout**: Timeout in seconds waiting for mDNS responses. If this parameter is missing or if it evaluates to `nil`, _mdns.query_ uses the dafault timeout of 2 seconds.


**Return value**

If _mdns\.resolve_ succeeds, an associateve array of service descriptors is returned as a Lua table. Please note that the array may be empty if there is no mDNS service available on the local network. In case of error, the function either asserts, or it returns `nil`.

Service descriptors returned by _mdns.query_ may contain a combination of the following fields:

* **name**: mDNS service name (e.g. _HP Laserjet 4L @ server.example.com_)
* **service**: mDNS service type (e.g. _\_ipps.\_tcp.local_)
* **hostname**: hostname
* **port**: port number
* **ipv4**: IPv4 address
* **ipv6**: IPv6 address
* **text**: Table of text record(s)

_mdns\.resolve_ returns whatever information the mDNS daemons provide. The presence of certain fields doesn't imply that the system running _lua-mdns_ supports all features. For example, an IPv6 address may be returned even though the LuaSocket library installed on the system may not support IPv6. Resolving such potetial mismatches is beyond the scope of _lua-mdns_.

### mdns.query_async

Allows the use of platform appropriate timer options. Specifically, if available, an asynchronous timer.

**Usage**

    tick, finalise = mdns.query_async([<service>])

**Parameters**

_mdns.query_async_ takes up to one parameter:

* **service**: see _mdns.query_

**Return value**

_mdns.query_async_ returns two functions. These are indented to be called by a platform appropriate timer.

* **tick()**: This should be called frequently as possible until the user operation timeout.

* **finalise()**: Once the user operation has timed out, this function should be called.\
It will clean up and return a table of services.
**Return value**
    * **services**: Table of service descriptors or `nil`, see _mdns.query_

**Example**

The `timer` library here is given as an example, please use a platform appropriate library:

    local mdns = require('mdns')
    local ticker = require('timer')
    local timeout = require('timer')

    -- Query all MDNS services
    local mdns_tick, mdns_finalise = mdns.query_async()

    -- Setup ticker
    ticker.single_shot = false
    ticker.interval = 0.01
    ticker.handler = function()
        mdns_tick()
    end
    ticker:start()

    -- Setup timeout
    timeout.single_shot = true
    timeout.interval = 2.0
    timeout.handler = function()
        ticker:stop()

        local res = mdns_finalise()
        if (res) then
            for k,v in pairs(res) do
                <... use results>
            end
        end
    end
    timeout:start()

### mdns.socket

Allows the user to set custom socket operations.
e.g. Use IPv6, unicast IPv4, some other transport, or even a socket library other than LuaSocket.

**Members**

* **mdns.socket.PEER.IP**
    MDNS Query destination IP.
    Default: IPv4 multicast address '224.0.0.251'

* **mdns.socket.PEER.PORT**
    MDNS Query destination port.
    Default: 5353

* **mdns.socket:setup()**
    Setup the socket

* **mdns.socket:send()**
    Send datagram\
    **Parameters**
    * **datagram**: Datagram string to send to the peer

* **mdns.socket:recv()**
    Receive response datagram\
    **Return value**
    * **datagram**: Response datagram, or `nil`

* **mdns.socket:teardown()**
    Tear down the socket

**Example (IPv6)**

    local mdns = require('mdns')

    mdns.socket.PEER.IP = 'ff02::fb'
    mdns.socket.setup = function(self, timeout)
        local socket = require('socket')
        self.udp = socket.udp6()
        assert(self.udp:setoption('ipv6-add-membership', { multiaddr = self.PEER.IP }))
        assert(self.udp:settimeout(0.1))
    end
    mdns.socket.teardown = function(self)
        assert(self.udp:setoption("ipv6-drop-membership", { multiaddr = self.PEER.IP }))
        assert(self.udp:close())
        self.udp = nil
    end

    local res = mdns.resolve()


## License

_lua-mdns_ is released under the MIT license.


    Copyright (c) 2015 Frank Edelhaeuser

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
