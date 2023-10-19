-----------------------------------------------------------------------
--/  @file    Managers.RandomAnimalsManager.lua
--/  @author  Inaki
--/  @version 1.0
--/
--/  @brief  Boilerplate template for a park manager script
--/  @see    https://github.com/OpenNaja/ACSE
-----------------------------------------------------------------------
local global = _G
local api = global.api
local tWorldAPIs = ((api.world).GetWorldAPIs)()
local animalsAPI = (tWorldAPIs).animals
local habitatAPI = (tWorldAPIs).habitat
local moneyAPI = (tWorldAPIs).money
local facilitiesAPI = (tWorldAPIs).facilities
local pairs = global.pairs
local ipairs = global.ipairs
local require = global.require
local module = global.module
local tostring = global.tostring
local string = global.string
local tonumber = global.tonumber
local Object = require("Common.object")
local Mutators = require("Environment.ModuleMutators")
local GameDatabase = require("Database.GameDatabase")
local Quaternion = require("Quaternion")
local TransformQ = require("TransformQ")
local Vector3 = require("Vector3")
local math = require("math")
local table = require("Common.tableplus")
local AnimalUtils = require("Helpers.AnimalUtils")

local props = nil
local env = nil
local cooldown = 5

--/ Main class definition
local RandomAnimalsManager = module(..., Mutators.Manager())

-- @Brief Init function for this manager
-- @param _tProperties  a table with initialization data for all the managers.
-- @param _tEnvironment a reference to the current Environment
--
-- The Init function is the first function of the manager being called by the game.
-- This function is used to initialize all the custom data required, however at this
-- stage the rest of the managers might not be available.
--
RandomAnimalsManager.Init = function(self, _tProperties, _tEnvironment)
    api.debug.Trace("RandomAnimalsManager:Init()")
    props = _tProperties
    env = _tEnvironment
end

--
-- @Brief Activate function for this manager
--
-- Activate is called after all the Managers of this environment have been initialised,
-- and it is safe to assume that access to the rest of the game managers is guaranteed to
-- work.
--
RandomAnimalsManager.Activate = function(self)
    api.debug.Trace("RandomAnimalsManager:Activate()")
    self.tAnimalsToSpawn = {}
    local cPSInstance = ((api.database).GetPreparedStatementInstance)("Animals", "GetReadyAnimals")
        if cPSInstance ~= nil then
          ((api.database).BindComplete)(cPSInstance)
          ;
          ((api.database).Step)(cPSInstance)
          local tResult = ((api.database).GetAllResults)(cPSInstance, false)
          for _,tData in pairs(tResult) do
            if ((api.content).IsDLCOwned)(tData[2]) then
--                             api.debug.Trace(tData[1])
               (table.insert)(self.tAnimalsToSpawn, tData[1])
--                            api.debug.Trace("Hello")
            end
        end
    end

    self.iNumberOfAnimals = 0

    for k,v in pairs(self.tAnimalsToSpawn) do
        self.iNumberOfAnimals = self.iNumberOfAnimals + 1
    end

    api.debug.Trace(self.iNumberOfAnimals)
end

--
-- @Brief Update function for this manager
--
-- Advance is called on every frame tick.
--
RandomAnimalsManager.Advance = function(self, _nDeltaTime, _nUnscaledDeltaTime)
    local worldScript = ((api.world).GetScript)(((api.world).GetActive)())
    local scenarioManager = (worldScript.tEnvironment):RequireInterface("Interfaces.IScenarioManager")
    local sGameMode = scenarioManager and scenarioManager:GetGameMode() or nil

    if sGameMode == "Sandbox" and cooldown >= 10 and math.random(1, 7500) == 1 then
        local worldScript = ((api.world).GetScript)("sandbox")
        local mainHUD = worldScript:GetHUD()
        local tSimTimeData = (mainHUD):GetSimulationTimeSettings()
        local bIsPaused = tSimTimeData.bPaused
        if not bIsPaused then
            local tHabitats = habitatAPI:GetHabitats()
            local numberOfHabitats = #tHabitats

            if numberOfHabitats > 0 then
                local nHabitatEntityID = tHabitats[math.random(1,numberOfHabitats)]

                local tAnimals = habitatAPI:GetAnimalsInHabitat(nHabitatEntityID)
                local numberOfAnimalsInHabitat = #tAnimals

                if numberOfAnimalsInHabitat > 0 then
                    local nAnimalID = tAnimals[math.random(1, numberOfAnimalsInHabitat)]

                    local isBoxed = animalsAPI:IsAnimalBoxed(nAnimalID)
                    local isPregnant = animalsAPI:IsPregnant(nAnimalID)

                    if not isBoxed and not isPregnant then
                        local animalGUID = animalsAPI:EntityIDToAnimalGUID(nAnimalID)
                        local ageStatus = animalsAPI:GetAgeStatus(nAnimalID)
                        local age = 1

                        if ageStatus == animalsAPI.Juvenile then
                            age = 0
                        end

                        local sName = animalsAPI:GetName(nAnimalID)
                        local resultsTable = facilitiesAPI:CreateAnimalInHabitat(nHabitatEntityID, animalsAPI:GetGender(nAnimalID), age, self.tAnimalsToSpawn[math.random(1, self.iNumberOfAnimals)])

                        animalsAPI:RehomeAnimal(nAnimalID)
                        cooldown = 0
                    end
                end
            end
        end
    end

    cooldown = cooldown + 1
end

--
-- @Brief Deactivate function for this manager
--
-- Deactivate is called when the world is shutting down or closing. Use this function
-- to perform any deinitialisation that still requires access to the current world data
-- or other Managers.
--
RandomAnimalsManager.Deactivate = function(self)
    api.debug.Trace("RandomAnimalsManager:Deactivate()")
end

--
-- @Brief Shutdown function for this manager
--
-- Shutdown is called when the current world is shutting down.
--
RandomAnimalsManager.Shutdown = function(self)
    api.debug.Trace("RandomAnimalsManager:Shutdown()")
end

--/ Validate class methods and interfaces, the game needs
--/ to validate the Manager conform to the module requirements.
Mutators.VerifyManagerModule(RandomAnimalsManager)