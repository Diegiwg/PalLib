local PalLib = {}

PalLib.Name = "PalLib"
PalLib.Version = "0.0.1"
PalLib.Dir = string.gsub(io.popen("cd"):read '*all', "\n", "")

--- Informe that this mod is used by another mod
--- @param ModID string
--- @param ModVersion string
function PalLib.Use(ModID, ModVersion)
    print(string.format("%s [v%s] is used by %s [v%s]", PalLib.Name, PalLib.Version, ModID, ModVersion))
end

--- Logs a simple message
--- @param msg string
function PalLib.Log(msg)
    print("-----------------------------------------")
    print(string.format("[%s] LOG: %s", PalLib.Name, msg))
    print("-----------------------------------------")
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

    return types[type]()
end

--- Internal function to check if a line is a comment
local function ParseComments(line)
    return line == "" or string.sub(line, 1, 1) == ";"
end

--- Internal function to check if a line is a TYPE
local function ParseTypeAnnotation(line)
    if string.sub(line, 1, 1) == "[" and string.sub(line, string.len(line), string.len(line)) == "]" then
        local type = string.lower(string.sub(line, 2, string.len(line) - 1))
        if ValidTypes[type] then return type end
    end

    return nil
end

--- Internal function to check if a line is a VALUE
local function ParseValue(line, configs)
    if string.find(line, "=") ~= nil then
        local key = string.sub(line, 1, string.find(line, "=") - 1)
        local value = string.sub(line, string.find(line, "=") + 1)

        local typed = ConvertValueToTyped(configs.currentType, value)
        if typed then
            configs[key] = typed
            return true
        end
    end

    return false
end

--- Loads and Parses a config file for a Mod
--- @param ModID string
--- @return table | nil (key[str], value[typed])
function Config.Load(ModID)
    if not ModID or ModID == "" then return end
    
    local path = PalLib.Dir .. "\\Mods\\" .. ModID .. "\\config.txt"
    local content = PalLib.File.Read(path)
    if not content then return end

    PalLib.Log("Loading config from " .. path)

    local configs = {}
    configs.currentType = nil

    local lines = PalLib.String.Split(content, "\n")
    PalLib.Array.ForEach(lines, function(index, line)
        -- If the line is empty or a comment (;) then skip
        if ParseComments(line) then return end

        -- If the line starts with "[" and ends with "]" then it's a TYPE
        local type = ParseTypeAnnotation(line)
        if type then
            configs.currentType = type
            return
        end

        -- If the line is not a TYPE and contains "=" and currentType is not nil then it's a value
        if configs.currentType and ParseValue(line, configs) then 
            configs.currentType = nil
            return
        end

        -- If the line doesn't start with "[" and ends with "]" and doesn't contain "=" then it's an error
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
--- @return table
function String.Split(str, sep)
    if sep == nil then
        sep = "%s"
    end

    local words = {}
    for splited in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(words, splited)
    end

    return words
end

PalLib.String = String

-- Array Module --

local Array = {}

--- Applies a function to each element of an array
--- @param arr table
--- @param func function Args (index, elem)
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
