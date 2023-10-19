local global = _G
local api = global.api
local table = global.table
local require = require
local RandomAnimalsLuaDatabase = module(...)

RandomAnimalsLuaDatabase.AddContentToCall = function(_tContentToCall)
    if global.api.acse and global.api.acse.versionNumber > 0.640 then
        table.insert(_tContentToCall, require("Database.RandomAnimalsDatabaseManager"))
    end
end