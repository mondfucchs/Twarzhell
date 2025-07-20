local utils = {}

utils.unpack = function(t, i)
    local _i = i or 1

    local n = #t
    if _i > n then
        return nil
    end

    return t[_i], utils.unpack(t, _i + 1)
end
---@return integer
utils.roundTo = function(n, m)
    local div = n / m
    return (div > 0) and math.floor(div) * m or math.ceil(div) * m
end
---@return integer
utils.circular = function(v, _end)
    return ((v - 1) % _end) + 1
end
---@return integer
utils.limit = function(c, min, max)
    if min and c <= min then return min
    elseif max and c >= max then return max
    else return c end
end
---@return integer
utils.getSign = function(c, opt_zero)
    if c < 0 then return -1
    elseif c > 0 then return 1
    else return opt_zero or 1 end
end
utils.boolToValue = function(bool, trueoutput, falseoutput)
    if bool then return trueoutput else return falseoutput end
end
---@return table
utils.copyTable = function(table)
    local copytable = {}
    for key, value in pairs(table) do
        if type(value) == "table" then
            copytable[key] = utils.copyTable(value)
        else
            copytable[key] = value
        end
    end
    return copytable
end
---@return table
utils.range = function(n)
    local range = {}
    for i = 1, n do
        range[i] = i
    end
    return range
end
utils.findBlank = function(table, tablesize)
    for index = 1, tablesize do
        if table[index] == nil then
            return index
        end
    end
    return nil
end
---@return table
-- indexed-tables, no maps
utils.takeoutNils = function(table, tablesize)
    local new_table = {}
    local new_i = 1
    local size = tablesize or #table
    for i = 1, size do
        if table[i] then
            new_table[new_i] = table[i]
            new_i = new_i + 1
        end
    end
    return new_table
end
utils.checkHover = function(nx, ny, nw, nh, mx, my)
    local _mx = mx
    local _my = my
    if _mx >= nx and _mx <= nx + nw and _my >= ny and _my <= ny + nh then
        return true
    else
        return false
    end
end
utils.searchTable = function(table, element)
    for i, value in pairs(table) do
        if value == element then return true, i end
    end
    return false
end

return utils