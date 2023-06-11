--[[

    Copyright (c) 2015 Frank Edelhaeuser

    This file is part of lua-mdns.

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

]]--
local mdns = require('../mdns')

-- Query all MDNS printers
local res = mdns.query('_printer._tcp')
if (res) then
    for k,v in pairs(res) do
        print(k)
        local function print_table(t, indent) 
            for k,v in pairs(t) do
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
