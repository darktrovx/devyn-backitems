local QBCore = exports['qb-core']:GetCoreObject()

local CurrentBackItems = {}
local TempBackItems = {}
local checking = true
local currentWeapon = nil
local slots = 40
local s = {}


AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
    BackLoop()
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
    removeAllBackItems()
    CurrentBackItems = {}
    TempBackItems = {}
    currentWeapon = nil
    slots = 40
    s = {}
    checking = false
end)

RegisterNetEvent("backitems:start", function()
    Wait(4000)
    BackLoop()
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
    removeAllBackItems()
    CurrentBackItems = {}
    TempBackItems = {}
    currentWeapon = nil
    slots = 40
    s = {}
    checking = false
end)

-- RegisterCommand("displayBackItems", function(source, args, rawCommand)
--     TriggerEvent("backitems:displayItems", true)
-- end)


-- RegisterCommand("hideBackItems", function(source, args, rawCommand)
--     TriggerEvent("backitems:displayItems", false)
-- end)


RegisterNetEvent("backitems:displayItems", function(toggle)
    if toggle then 
        for k,v in pairs(TempBackItems) do 
            createBackItem(k)
        end
        checking = true
        BackLoop()
    else 
        TempBackItems = CurrentBackItems
        checking = false
        for k,v in pairs(CurrentBackItems) do
            removeBackItem(k)
        end
        CurrentBackItems = {}
    end
end)

function BackLoop()
    print("[Backitems]: Starting Loop")
    CreateThread(function()
        while checking do
            local player = QBCore.Functions.GetPlayerData()
            while player == nil do 
                player = QBCore.Functions.GetPlayerData()
            end
            for i = 1, slots do
                s[i] = player.items[i]
            end
            check()
            Wait(500)
        end
    end)
end

function check()
    for i = 1, slots do
        if s[i] ~= nil then
            local name = s[i].name
            if BackItems[name] then
                if name ~= currentWeapon then
                    createBackItem(name)
                end
            end
        end
    end

    for k,v in pairs(CurrentBackItems) do 
        local hasItem = false
        for j = 1, slots do
            if s[j] ~= nil then
                local name = s[j].name
                if name == k then 
                    hasItem = true
                end
            end
        end
        if not hasItem then 
            removeBackItem(k)
        end
    end
end


function createBackItem(item)
    if not CurrentBackItems[item] then
        if BackItems[item] then 
            local i = BackItems[item]
            local model = i["model"]
            local ped = PlayerPedId()
            local bone = GetPedBoneIndex(ped, i["back_bone"])
            RequestModel(model)
            while not HasModelLoaded(model) do
                Wait(10)
            end
            SetModelAsNoLongerNeeded(model)
            CurrentBackItems[item] = CreateObject(GetHashKey(model), 1.0, 1.0, 1.0, true, true, false)   
            AttachEntityToEntity(CurrentBackItems[item], ped, bone, i["x"], i["y"], i["z"], i["x_rotation"], i["y_rotation"], i["z_rotation"], false, false, false, false, 2, true)
        end
    end
end

function removeBackItem(item)
    if CurrentBackItems[item] then
        DeleteEntity(CurrentBackItems[item])
        CurrentBackItems[item] = nil
    end
end

function removeAllBackItems()
    for k,v in pairs(CurrentBackItems) do 
        removeBackItem(k)
    end
end

RegisterNetEvent('weapons:client:SetCurrentWeapon', function(weap, shootbool)
    if weap == nil then
        createBackItem(currentWeapon)
        currentWeapon = nil
    else
        if currentWeapon ~= nil then  
            createBackItem(currentWeapon)
            currentWeapon = nil
        end
        currentWeapon = tostring(weap.name)
        removeBackItem(currentWeapon)
    end
end)




