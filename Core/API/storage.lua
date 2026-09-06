---@class GW2
local GW = select(2, ...)


local function EnsureCharScope()
    local chars = GW.global.chars
    if not chars or not GW.myrealm or not GW.myname then return end

    chars[GW.myrealm] = chars[GW.myrealm] or {}
    chars[GW.myrealm][GW.myname] = chars[GW.myrealm][GW.myname] or {}
    return chars[GW.myrealm][GW.myname]
end

local function LoadStorage()
    local chars = GW.global.chars

    -- migrate the old standalone saved variable (temp function)
    if type(GW2UI_STORAGE2) == "table" then
        for realm, realmChars in pairs(GW2UI_STORAGE2) do
            if type(realmChars) == "table" then
                chars[realm] = chars[realm] or {}
                for name, values in pairs(realmChars) do
                    if type(values) == "table" and chars[realm][name] == nil then
                        chars[realm][name] = values
                    end
                end
            end
        end
        GW2UI_STORAGE2 = nil
    end
end
GW.LoadStorage = LoadStorage

-- Set a storage value by REALM CHARNAME key = values
local function SetStorage(key, value)
    local s = EnsureCharScope()
    if not s then return end
    s[key] = value
end
GW.SetStorage = SetStorage

-- Get a storage value by passing the key or a tableScope to get the complete table or without an parameter to get char table
-- tableScope: "REALM" | "CHAR" | nil  (nil behaves like "CHAR")
local function GetStorage(key, tableScope)
    local chars = GW.global.chars
    tableScope = tableScope or "CHAR"

    if tableScope == "REALM" then
        return chars[GW.myrealm]
    elseif tableScope == "CHAR" then
        if not GW.myname then return end
        local s = chars[GW.myrealm] and chars[GW.myrealm][GW.myname]
        if not s then return end
        if key ~= nil then
            return s[key]
        else
            return s
        end
    end

    return nil
end
GW.GetStorage = GetStorage

-- Clear the whole storage or just a part of it
local function ClearStorage(key, overrideCharacter)
    local chars = GW.global.chars
    local name = overrideCharacter or GW.myname
    local realmTbl = chars[GW.myrealm]
    local charTbl = realmTbl and realmTbl[name]
    if not charTbl then return end

    if key ~= nil then
        charTbl[key] = nil
    else
        realmTbl[name] = nil
    end
end
GW.ClearStorage = ClearStorage

---------- MONEY ----------
local UpdateMoney = function ()
    if not IsLoggedIn() then return end
    local money = GetMoney() or 0

    -- first store old money
    local prev = GetStorage("money") or money
    local delta = money - prev

    if delta < 0 then
        GW.spentMoney = GW.spentMoney + (-delta)
    elseif delta > 0 then
        GW.earnedMoney = GW.earnedMoney + delta
    end

    SetStorage("money", money)
end
GW.UpdateMoney = UpdateMoney

---------- CHAR DATA ----------
local UpdateCharData = function ()
    SetStorage("name", GW.myname)
    SetStorage("faction", GW.myfaction)
    SetStorage("class", GW.myclass)
    UpdateMoney()
end
GW.UpdateCharData = UpdateCharData
