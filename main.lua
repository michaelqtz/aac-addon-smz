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

local SKIPPED_END_ZONES = {
    ["Arcadian Sea - Sunspeck Sea"] = true,
    -- Below here is to speed things up
    ["Haranya - Mahadevi"] = true,
    ["Haranya - Arcum Iris"] = true,
    ["Nuia - Marianople"] = true,
    ["Nuia - Lilyut Hills"] = true,
    ["Nuia - Dewstone Plains"] = true,
    ["Nuia - Sanddeep"] = true,
}

-- NOTE: keys are now strings
local PACK_ZONES = {
    ["1"] = {
        name = "Gweonid Forest",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["2"] = {
        name = "Marianople",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["3"] = {
        name = "Dewstone Plains",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["4"] = {
        name = "Solis Headlands",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["5"] = {
        name = "Solzreed Peninsula",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["6"] = {
        name = "Lilyut Hills",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["7"] = {
        name = "Arcum Iris",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["8"] = {
        name = "Two Crowns",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["9"] = {
        name = "Mahadevi",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["10"] = {
        name = "Airain Rock",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["11"] = {
        name = "Falcorth Plains",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["12"] = {
        name = "Villanelle",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["13"] = {
        name = "Sunbite Wilds",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["14"] = {
        name = "Windscour Savannah",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["15"] = {
        name = "Perinoor Ruins",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["16"] = {
        name = "Rookborne Basin",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["17"] = {
        name = "Ynystere",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["18"] = {
        name = "White Arden",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["19"] = {
        name = "Karkasse Ridgelands",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["20"] = {
        name = "Cinderstone Moor",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["21"] = {
        name = "Aubre Cradle",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["22"] = {
        name = "Halcyona",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["23"] = {
        name = "Hasla",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["24"] = {
        name = "Tigerspine Mountains",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["25"] = {
        name = "Silent Forest",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["26"] = {
        name = "Hellswamp",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["27"] = {
        name = "Sanddeep",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["93"] = {
        name = "Ahnimar",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
    ["99"] = {
        name = "Rokhala Mountains",
        prices = {
            ["42069"] = {
                yes = true
            }
        }
    },
}


local zoneCheckTimer = 0
local zoneCheckTimerRate = 5000

local landForSaleTimer = 0
local landForSaleTimerRate = 6000

local towerDefMsgsToWrite = {}
local worldMsgsToWrite = {}
local regradeMsgsToWrite = {}
local packPricesToWrite = {}

local packPriceCheckTimer = 0
local packPriceCheckTimerRate = 5100

local packResetTimer = nil

local overallTimer = 0

local smzWindow = nil

local ENCHANT_RESULT = {
    BREAK = 0,
    DOWNGRADE = 1,
    FAIL = 2,
    SUCCESS = 3,
    GREATE_SUCCESS = 4
}
local ITEM_GRADES = {
    [0] = "Crude",
    [1] = "Basic",
    [2] = "Grand",
    [3] = "Rare",
    [4] = "Arcane",
    [5] = "Heroic",
    [6] = "Unique",
    [7] = "Celestial",
    [8] = "Divine",
    [9] = "Epic",
    [10] = "Legendary",
    [11] = "Mythic"
}

function split(s, sep)
    local fields = {}
    
    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    
    return fields
end

local function encodeToJson(tbl)
    local function escapeStr(s)
        return s:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r")
    end

    local function serialize(tbl)
        local result = {}
        -- api.Log:Info(tbl)
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
            -- print(value)
            table.insert(result, key .. ":" .. value)
        end
        return "{" .. table.concat(result, ",") .. "}"
    end

    return serialize(tbl)
end

local function encodeToJsonValue(v)
    local t = type(v)

    if t == "nil" then
        return "null"
    elseif t == "number" then
        -- JSON does not support NaN/inf; stringify them
        if v ~= v or v == math.huge or v == -math.huge then
            return '"' .. tostring(v) .. '"'
        end
        return tostring(v)
    elseif t == "boolean" then
        return v and "true" or "false"
    elseif t == "string" then
        -- escape string
        local s = v
            :gsub("\\", "\\\\")
            :gsub('"', '\\"')
            :gsub("\b", "\\b")
            :gsub("\f", "\\f")
            :gsub("\n", "\\n")
            :gsub("\r", "\\r")
            :gsub("\t", "\\t")
        return '"' .. s .. '"'
    elseif t == "table" then
        return encodeToJsonIPairs(v) -- forward‑declare use
    else
        -- functions, userdata, threads -> stringify
        return '"' .. tostring(v) .. '"'
    end
end

local function encodeToJsonIPairs(tbl)
    -- first determine if this table should be encoded as an array or an object
    local isArray = true
    local maxIndex = 0
    local count = 0

    for k, _ in pairs(tbl) do
        if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then
            isArray = false
            break
        end
        if k > maxIndex then maxIndex = k end
        count = count + 1
    end

    -- array case: consecutive integer keys 1..n
    if isArray and maxIndex == count then
        local parts = {}
        for i = 1, maxIndex do
            parts[i] = encodeToJsonValue(tbl[i])
        end
        return "[" .. table.concat(parts, ",") .. "]"
    end

    -- object (map) case
    local parts = {}
    for k, v in pairs(tbl) do
        -- prices is a nested table; keep it as a JSON object with its own keys/arrays
        -- no special-casing needed, just encode its value as usual
        local keyStr
        if type(k) == "string" then
            local s = k
                :gsub("\\", "\\\\")
                :gsub('"', '\\"')
                :gsub("\b", "\\b")
                :gsub("\f", "\\f")
                :gsub("\n", "\\n")
                :gsub("\r", "\\r")
                :gsub("\t", "\\t")
            keyStr = '"' .. s .. '"'
        else
            keyStr = '"' .. tostring(k) .. '"'
        end

        table.insert(parts, keyStr .. ":" .. encodeToJsonValue(v))
    end

    return "{" .. table.concat(parts, ",") .. "}"
end

local function markStringWithDelimiters(str, delimiter)
    delimiter = delimiter or "###"
    return delimiter .. str .. delimiter
end

local function itemIdFromItemLinkText(itemLinkText)
    local itemIdStr = string.sub(itemLinkText, 3)
    itemIdStr = split(itemIdStr, ",")
    itemIdStr = itemIdStr[1]
    return itemIdStr
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
                if conflictState >= 5 then 
                    local remainingTime = zoneInfo.remainTime 
                    infoToWrite.remainingTime = remainingTime
                end
            end 
            if zoneInfo.isLocalDevelopment ~= false then 
                local localDevelopmentRank = zoneInfo.localDevelopmentStep
                local localDevelopmentRankName = zoneInfo.localDevelopmentName
                infoToWrite.localDevelopmentRank = localDevelopmentRank
                infoToWrite.localDevelopmentRankName = localDevelopmentRankName
            end 
            
            local jsonString = encodeToJson(infoToWrite)
            jsonString = markStringWithDelimiters(jsonString, "###")
            table.insert(jsonStrings, jsonString)
        end 
    end
    api.File:Write("sermeatball_zone_states.txt", table.concat(jsonStrings, "\n"))
end 

local function writeTowerDefMsgs()
    local jsonStrings = {}
    for _, msgInfo in ipairs(towerDefMsgsToWrite) do
        local jsonString = encodeToJson(msgInfo)
        jsonString = markStringWithDelimiters(jsonString, "###")
        table.insert(jsonStrings, jsonString)
    end
    if #jsonStrings > 0 then 
        api.File:Write("sermeatball_tower_def_msgs.txt", table.concat(jsonStrings, "\n"))
        towerDefMsgsToWrite = {}
    end
end 

local function writeWorldMsgs()
    local jsonStrings = {}
    for _, msgInfo in ipairs(worldMsgsToWrite) do
        local jsonString = encodeToJson(msgInfo)
        jsonString = markStringWithDelimiters(jsonString, "###")
        table.insert(jsonStrings, jsonString)
    end
    if #jsonStrings > 0 then 
        api.File:Write("sermeatball_world_msgs.txt", table.concat(jsonStrings, "\n"))
        worldMsgsToWrite = {}
    end
end

local function writeRegradeMsgs()
    local jsonStrings = {}
    for _, msgInfo in ipairs(regradeMsgsToWrite) do
        local jsonString = encodeToJson(msgInfo)
        jsonString = markStringWithDelimiters(jsonString, "###")
        table.insert(jsonStrings, jsonString)
    end
    if #jsonStrings > 0 then 
        api.File:Write("sermeatball_regrade_msgs.txt", table.concat(jsonStrings, "\n"))
        regradeMsgsToWrite = {}
    end
end 

local function writePackPrices()
    local jsonStrings = {}
    -- -- PACK_ZONES is now a map; iterate pairs
    for _, packZone in pairs(packPricesToWrite) do
        local jsonString = encodeToJson(packZone)
        jsonString = markStringWithDelimiters(jsonString, "###")
        table.insert(jsonStrings, jsonString)
    end
    if #jsonStrings > 0 then 
        api.File:Write("sermeatball_pack_prices.txt", table.concat(jsonStrings, "\n"))
        packPricesToWrite = {}
    end
end

local function checkLandForSale()
end

-- use string keys to track the current pack zone
local currentPackZoneKey = nil
local currentSellableZoneIndex = 1
local sellableZones = nil
local packProcessingStartTime = nil
local packProcessingElapsedTime = 0

-- helper to advance numeric ID but use string keys
local function getNextPackZoneKey(currentKey)
    local id = currentKey and tonumber(currentKey) or 0
    id = id + 1
    if id == 28 then
        id = 93
    elseif id == 94 then
        id = 99
    end
    if id > 99 then
        return nil
    end
    local key = tostring(id)
    if PACK_ZONES[key] then
        return key
    end
    -- skip missing ids
    return getNextPackZoneKey(key)
end

local function getSpecialtyInfo(specialtyRatioTable)
    local currentPackZone = currentPackZoneKey and PACK_ZONES[tostring(currentPackZoneKey)] or nil
    local currentSellableZone = sellableZones and sellableZones[currentSellableZoneIndex - 1] or nil

    if not currentPackZone then
        -- api.Log:Info("getSpecialtyInfo called with invalid currentPackZoneKey: " .. tostring(currentPackZoneKey))
        return
    end
    
    if currentPackZone.prices and packResetTimer == nil then 
        for key, value in pairs(specialtyRatioTable) do
            -- api.Log:Info(currentPackZone.prices)
            -- for key2, value2 in pairs(currentPackZone.prices) do 
            local value2 = currentPackZone.prices[tostring(value.itemInfo.itemType)]
            -- api.Log:Info("Comparing new price ratio " .. tostring(value.ratio) .. "% for item " .. (value.itemInfo.name or "Unknown Item") .. " with current ratio " .. tostring(value2 and value2.ratio or "nil"))
            if value2 and value2.ratio and value and value.ratio then 
                if value.ratio > value2.ratio then 
                    api.Log:Info("Price increase detected for " .. value.itemInfo.name .. " from " .. tostring(value2.ratio) .. "% to " .. tostring(value.ratio) .. "%")
                    local irlTimestamp = api.Time:GetLocalTime()
                    local irlTime = api.Time:TimeToDate(irlTimestamp)
                    local timeToWrite = string.format("%02d:%02d", irlTime.hour, irlTime.minute)

                    packResetTimer = {
                        startTime = irlTimestamp,
                        timeToWrite = timeToWrite
                    }
                    local jsonString = encodeToJson(packResetTimer)
                    jsonString = markStringWithDelimiters(jsonString, "###")
                    api.File:Write("sermeatball_pack_price_reset.txt", jsonString)
                end
            end
        end

        for key, value in pairs(specialtyRatioTable) do 
            local pricesObject = {
                ratio = value.ratio,
                itemName = value.itemInfo and value.itemInfo.name or "Unknown Item",
                itemId = value.itemInfo and value.itemInfo.itemType or "Unknown Item ID",
                startZone = currentPackZone.name,
                endZone = currentSellableZone.name
            } 
            -- for k, v in pairs(value.itemInfo) do 
            --     api.Log:Info("Key: " .. tostring(k) .. ", Value: " .. tostring(v))
            -- end
            -- table.insert(packPricesToWrite, pricesObject)


            currentPackZone.prices[tostring(value.itemInfo.itemType)] = pricesObject

        end 
        
        PACK_ZONES[tostring(currentPackZoneKey)] = currentPackZone
    end 
    
    if currentSellableZone and packResetTimer ~= nil then
        for key, value in pairs(specialtyRatioTable) do 
            local pricesObject = {
                ratio = value.ratio,
                itemName = value.itemInfo and value.itemInfo.name or "Unknown Item",
                itemId = value.itemInfo and value.itemInfo.itemType or "Unknown Item ID",
                startZone = currentPackZone.name,
                endZone = currentSellableZone.name
            } 
            -- for k, v in pairs(value.itemInfo) do 
            --     api.Log:Info("Key: " .. tostring(k) .. ", Value: " .. tostring(v))
            -- end
            table.insert(packPricesToWrite, pricesObject)


            currentPackZone.prices[currentSellableZone] = pricesObject

        end 

        PACK_ZONES[tostring(currentPackZoneKey)] = currentPackZone
    end
end 


local function checkPackPrices(dt)
    local function initializePackZone()
        if packProcessingStartTime then
            api.Log:Info("Pack processing completed. Total time taken: " .. packProcessingElapsedTime .. " seconds.")
        end
        currentPackZoneKey = nil
        currentSellableZoneIndex = 1
        sellableZones = nil
        packProcessingStartTime = nil
        packProcessingElapsedTime = 0
    end

    local function processNextPackZone()
        currentPackZoneKey = getNextPackZoneKey(currentPackZoneKey)

        if not currentPackZoneKey then
            initializePackZone()
            packPriceCheckTimer = packPriceCheckTimer + 5000
            overallTimer = overallTimer - 5000
            return false
        end

        local packZone = PACK_ZONES[currentPackZoneKey]
        if packZone then
            if not packProcessingStartTime then
                packProcessingStartTime = true
            end
            -- convert key to number for API call
            local packZoneId = tonumber(currentPackZoneKey)
            sellableZones = api.Store:GetSellableZoneGroups(packZoneId)
            currentSellableZoneIndex = 1

            packPriceCheckTimer = packPriceCheckTimer + 5000
            overallTimer = overallTimer - 5000
            return true
        end

        return false
    end

    local function processNextSellableZone()
        if not sellableZones or currentSellableZoneIndex > #sellableZones then
            return processNextPackZone()
        end

        local endZoneId = sellableZones[currentSellableZoneIndex]
        if endZoneId then
            if SKIPPED_END_ZONES[endZoneId.name] then
                currentSellableZoneIndex = currentSellableZoneIndex + 1
                
                packPriceCheckTimer = packPriceCheckTimer + 5000
                overallTimer = overallTimer - 5000
                return true
            end

            -- convert currentPackZoneKey to number for API
            local packZoneId = tonumber(currentPackZoneKey)
            local results = api.Store:GetSpecialtyRatioBetween(packZoneId, endZoneId.id)

            -- api.Log:Info("Specialty Ratios for Pack Zone " .. PACK_ZONES[currentPackZoneKey].name .. " to Zone ID " .. tostring(endZoneId.name) .. ". " .. overallTimer / 1000 .. " time")
            -- api.Log:Info(packZoneId .. " to " .. endZoneId.id)
            currentSellableZoneIndex = currentSellableZoneIndex + 1
            return true
        end

        return false
    end

    if packProcessingStartTime then
        packProcessingElapsedTime = packProcessingElapsedTime + dt
    end

    if not processNextSellableZone() then
        initializePackZone()
        writePackPrices()
    end
end

local function lookForPackPriceReset()
    local packZoneId = 93
    local packZone = PACK_ZONES[tostring(packZoneId)]
    currentPackZoneKey = tostring(packZoneId)
    currentSellableZoneIndex = 2
    sellableZones = api.Store:GetSellableZoneGroups(packZoneId)
    if packZone then 
        local results = api.Store:GetSpecialtyRatioBetween(packZoneId, 1)
        
        -- api.Log:Info("Looking for pack price reset. Checking Pack Zone " .. packZone.name .. " against all sellable zones. " .. overallTimer / 1000 .. " seconds elapsed.")
    end 
end 

-- 1782 seconds before

local startPackZoneId = 1
local endPackZoneId = 1

local function OnUpdate(dt)
    zoneCheckTimer = zoneCheckTimer + dt
    if zoneCheckTimer >= zoneCheckTimerRate then 
        zoneCheckTimer = 0
        checkZoneStates()
        writeTowerDefMsgs()
        writeWorldMsgs()
        writeRegradeMsgs()
    end

    packPriceCheckTimer = packPriceCheckTimer + dt
    if packPriceCheckTimer >= packPriceCheckTimerRate then 
        packPriceCheckTimer = 0
        if packResetTimer ~= nil then 
            checkPackPrices(dt)
            overallTimer = overallTimer + packPriceCheckTimerRate
        else 
            lookForPackPriceReset()
        end
    end
end 



local function OnLoad()
    local settings = api.GetSettings("sermeatball")
    smzWindow = api.Interface:CreateEmptyWindow("smzWindow", "UIParent")
    smzWindow:Show(true)

    local smzEvents = {
        TOWER_DEF_MSG = function(towerDefInfo)
            local zoneGroup = tostring(towerDefInfo.zoneGroup)
            local text = string.format("%s%s", towerDefInfo.color, towerDefInfo.msg)
            local title = string.format("%s%s", towerDefInfo.color, towerDefInfo.titleMsg)
            local step = tostring(towerDefInfo.step)
            local iconName = string.format("%s_%s", towerDefInfo.iconKey, towerDefInfo.step)
            table.insert(towerDefMsgsToWrite, towerDefInfo)
        end,
        GRADE_ENCHANT_BROADCAST = function(characterName, resultCode, itemLink, oldGrade, newGrade)
            local itemId = itemIdFromItemLinkText(itemLink)
            local itemInfo = api.Item:GetItemInfoByType(tonumber(itemId))
            local itemName = itemInfo and itemInfo.name or "Unknown Item"
            local oldGradeText = ITEM_GRADES[oldGrade] or "Unknown Grade"
            local newGradeText = ITEM_GRADES[newGrade] or "Unknown Grade"
            local msgInfo = {
                characterName = characterName,
                resultCode = resultCode,
                itemLink = itemLink,
                itemId = itemId,
                itemName = itemName,
                oldGrade = oldGradeText,
                newGrade = newGradeText
            }
            table.insert(regradeMsgsToWrite, msgInfo)
        end,
        WORLD_MESSAGE = function(msg, iconKey, sextants, info) 
            local iconName = iconKey or "None"
            local infoStr = info or "None"
            table.insert(worldMsgsToWrite, {msg = msg, iconKey = iconName, sextants = sextants, info = info})
        end,
        SPECIALTY_RATIO_BETWEEN_INFO = function(specialtyRatioTable)
            getSpecialtyInfo(specialtyRatioTable)
        end
        
    }
    smzWindow:SetHandler("OnEvent", function(this, event, ...)
        smzEvents[event](...)
    end)
    for eventName, _ in pairs(smzEvents) do
        smzWindow:RegisterEvent(eventName)
    end

    api.On("UPDATE", OnUpdate)
    api.SaveSettings()
end

local function OnUnload()
    api.On("UPDATE", function() return end)
    api.Interface:Free(smzWindow)
end

addon.OnLoad = OnLoad
addon.OnUnload = OnUnload

return addon
