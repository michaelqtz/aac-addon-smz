local api = require("api")

local addon = {
    name = "Ser Meatball Tools",
    author = "Michaelqt",
    version = "1.0",
    desc = "Test Addon Please Ignore"
}

local ZONE_STATES = {
    DANGER_RANK_1 = 1,
    DANGER_RANK_3 = 2,
    DANGER_RANK_4 = 3,
    DANGER_RANK_5 = 4,
    CONFLICT = 5,
    WAR = 6,
    PEACE = 7,
}

local zoneCheckTimer = 0
local zoneCheckTimerRate = 5000


local function encodeToJson(tbl)
    local function escapeStr(s)
        return s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r")
    end

    local function serialize(tbl)
        local result = {}
        for k, v in pairs(tbl) do
            local key = type(k) == "string" and '"' .. escapeStr(k) .. '"' or k
            local value
            if type(v) == "table" then
                value = serialize(v)
            elseif type(v) == "string" then
                value = '"' .. escapeStr(v) .. '"'
            else
                value = tostring(v)
            end
            table.insert(result, key .. ":" .. value)
        end
        return "{" .. table.concat(result, ",") .. "}"
    end

    return serialize(tbl)
end

local function markStringWithDelimiters(str, delimiter)
    delimiter = delimiter or "###" -- Default delimiter if none is provided
    return delimiter .. str .. delimiter
end

local function checkZoneStates()
    local jsonStrings = {}
    for i=1, 200 do
        local zoneInfo = api.Zone:GetZoneStateInfoByZoneId(i)
        if zoneInfo ~= nil then 
            local infoToWrite = {}
            infoToWrite.zoneName = zoneInfo.zoneName
            infoToWrite.zoneId = i
            if zoneInfo.isConflictZone ~= false then 
                local conflictState = tonumber(zoneInfo.conflictState)
                infoToWrite.conflictState = conflictState
                if conflictState >= ZONE_STATES.CONFLICT and conflictState <= ZONE_STATES.WAR then 
                    local remainingTime = zoneInfo.remainTime 
                    infoToWrite.remainingTime = remainingTime
                    -- api.Log:Info("Conflict Zone: " .. zoneInfo.zoneName .. " ID: " .. tostring(i) .. " State: " .. tostring(conflictState) .. " Time Left: " .. tostring(remainingTime))
                end
            end 
            if zoneInfo.isLocalDevelopment ~= false then 
                local localDevelopmentRank = zoneInfo.localDevelopmentStep
                local localDevelopmentRankName = zoneInfo.localDevelopmentName
                infoToWrite.localDevelopmentRank = localDevelopmentRank
                infoToWrite.localDevelopmentRankName = localDevelopmentRankName
                -- api.Log:Info("Local Development Zone: " .. zoneInfo.zoneName .. " ID: " .. tostring(i) .. " Rank: " .. tostring(localDevelopmentRank) .. " Rank Name: " .. tostring(localDevelopmentRankName))
            end 

            
            local jsonString = encodeToJson(infoToWrite)
            jsonString = markStringWithDelimiters(jsonString, "###")
            table.insert(jsonStrings, jsonString)
            -- api.Log:Info("Zone Info JSON: " .. jsonString)
        end 
    end
    api.File:Write("sermeatball_zone_states.txt", table.concat(jsonStrings, "\n"))
end 

local function OnUpdate(dt)
    zoneCheckTimer = zoneCheckTimer + dt
    if zoneCheckTimer >= zoneCheckTimerRate then 
        zoneCheckTimer = 0
        checkZoneStates()
    end
end 

local function OnLoad()
    local settings = api.GetSettings("sermeatball")

    
    

    api.On("UPDATE", OnUpdate)
    api.SaveSettings()
end

local function OnUnload()
    api.On("UPDATE", function() return end)
end

addon.OnLoad = OnLoad
addon.OnUnload = OnUnload

return addon
