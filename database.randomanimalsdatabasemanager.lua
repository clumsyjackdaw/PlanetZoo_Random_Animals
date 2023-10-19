-- ExampleContentPack database script
-- This script will hook into the gamedatabase content merging process

-- This little block is required for non-compiled Lua scripts. It re-defines some globals for use within the script
local global = _G
local api = global.api
local debug = api.debug
local table = global.table
local require = require
local string = string
local pairs = global.pairs
local GameDatabase = require("Database.GameDatabase")
local ACSE = require("Database.ACSE")
local RandomAnimalsDatabaseManager = module(...)

-- List of custom managers to force injection on a park
RandomAnimalsDatabaseManager.tParkManagers = {
    ["Managers.RandomAnimalsManager"] = { },  -- Add your custom settings inside the table.
}

RandomAnimalsDatabaseManager.AddParkManagers = function(_fnAdd)
    local tData = RandomAnimalsDatabaseManager.tParkManagers
    for sManagerName, tParams in pairs(tData) do
        _fnAdd(sManagerName, tParams)
    end
end
