local PalLib = {}

PalLib.Name = "PalLib"
PalLib.Version = "0.0.3"
PalLib.Dir = string.gsub(io.popen("cd"):read '*all', "\n", "")

--- Logs a simple message
--- @param msg string
function PalLib.Log(msg)
    print(
        "\n-----------------------------------------\n"
        ..
        string.format("[%s] LOG: %s", PalLib.Name, msg)
        ..
        "\n-----------------------------------------"
    )
end

--- Informe that this mod is used by another mod
--- @param ModID string
--- @param ModVersion string
function PalLib.Use(ModID, ModVersion)
    print(string.format("%s [v%s] is used by %s [v%s]", PalLib.Name, PalLib.Version, ModID, ModVersion))
end

-- Config Module --

local Config = {}

local ValidTypes = {
    ["str"] = true,
    ["bool"] = true,
    ["float"] = true,
    ["int"] = true
    -- TODO: range
}

--- Internal function to convert a value to a typed value
local function ConvertValueToTyped(type, value)
    local types = {
        ["str"] = function() return value end,
        ["bool"] = function() return value == "true" or value == "1" end,
        ["float"] = function() return tonumber(value) end,
        ["int"] = function() return tonumber(value) end
    }

    local callback = types[type]
    if not callback then return "err" end

    return callback()
end

--- Internal function to check if a line is a comment
local function ParseComments(line)
    return line == "" or string.sub(line, 1, 1) == ";"
end

--- Internal function to check if a line is a TYPE
local function ParseTypeAnnotation(line)
    if string.sub(line, 1, 1) == "[" and string.sub(line, string.len(line), string.len(line)) == "]" then
        local type = PalLib.String.Trim(string.lower(string.sub(line, 2, string.len(line) - 1)))
        if ValidTypes[type] then return type end
    end

    return nil
end

--- Internal function to check if a line is a VALUE
local function ParseValue(line, configs)
    if string.find(line, "=") < 1 then return false end
    
    local arr = PalLib.String.Split(line, "=")
    if not arr or PalLib.Array.Length(arr) ~= 2 then return false end
    
    local key, value = PalLib.String.Trim(arr[1]), PalLib.String.Trim(arr[2])

    local typed = ConvertValueToTyped(configs.currentType, value)
    if typed == "err" or typed == nil then return false end
    
    configs[key] = typed
    return true
end

--- Loads and Parses a config file for a Mod
--- @param ModID string
--- @return nil|table [{key = value, ...}]
function Config.Load(ModID)
    if not ModID or ModID == "" then return end
    
    local path = PalLib.Dir .. "\\Mods\\" .. ModID .. "\\config.txt"
    local content = PalLib.File.Read(path)
    if not content then return end

    PalLib.Log("Loading config from " .. path)

    local configs = {}
    configs.currentType = nil

    local lines = PalLib.String.Split(content, "\n")
    PalLib.Array.ForEach(lines, function(_, line)
        line = PalLib.String.Trim(line)

        if ParseComments(line) then return end

        local type = ParseTypeAnnotation(line)
        if type then configs.currentType = type; return end

        if configs.currentType and ParseValue(line, configs) then configs.currentType = nil; return end

        PalLib.Log(string.format("Invalid config line: %s", line)) 
    end)
    
    return configs
end

PalLib.Config = Config

-- String Module --

local String = {}

--- Splits a string by a separator, and returns its into a table of strings
--- @param str string
--- @param sep string
--- @return table [PalLib.Array]
function String.Split(str, sep)
    if sep == nil then
        sep = "%s"
    end

    local result = PalLib.Array.New()
    for splited in string.gmatch(str, "([^" .. sep .. "]+)") do
        PalLib.Array.Add(result, splited)
    end

    return result
end

--- Removes all leading and trailing spaces from a string, and returns a new string
---@param str string
---@return string
function String.Trim(str)
    return str:match("^%s*(.-)%s*$")
end

PalLib.String = String

-- Array Module --

local Array = {}

--- Creates an array
---@param ... any Elements to add to the array
---@return table [PalLib.Array]
function Array.New(...)
    local elms = {...}
    
    local arr = {
        ["length"] = 0
    }
    
    for i, v in ipairs(elms) do
        arr[i] = v
        arr.length = arr.length + 1
    end

    return arr
end

--- Returns the length of an array
---@param arr table [PalLib.Array]
---@return number
function Array.Length(arr)
    return arr.length
end

--- Adds an element to an array
---@param arr table [PalLib.Array]
---@param elm any
function Array.Add(arr, elm)
    if not arr or not elm then return end
    if elm == nil or elm == "length" then return end

    table.insert(arr, elm)
    arr.length = arr.length + 1
end

--- Removes an element from an array
---@param arr table [PalLib.Array]
---@param index number
function Array.Remove(arr, index)
    table.remove(arr, index)
    arr.length = arr.length - 1
end

--- Applies a function to each element of an array
--- @param arr table [PalLib.Array]
--- @param func function
function Array.ForEach(arr, func)
    for i, v in ipairs(arr) do
        func(i, v)
    end
end

PalLib.Array = Array

-- File Module --

local File = {}

--- Read a full file contents to a string
--- @param path string
--- @return string|nil
function File.Read(path)
    local file = io.open(path, "r")
    if not file then
        PalLib.Log("File not found: " .. path)
        return nil
    end

    local content = file:read("*a")
    file:close()

    return content
end

PalLib.File = File

-- Module Exports --

return PalLib
