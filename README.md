# devyn-backitems
FiveM Lua Script for displaying items on the players back.
NOTE: I do not provide any support for this. Just posted because a lot of people asked for it.

![image](https://user-images.githubusercontent.com/7463741/154128851-a8325962-1ef3-4a08-ad5e-048dcb0e023b.png)

If you want to add/remove/change model/backplacement it can be done in the BackItems.lua.

## Spawn Setup

### qb-spawn Setup

In qb-spawn in client.lua, edit the function PostSpawnPlayer and add ```TriggerEvent("backitems:start")``` to the last line.

```lua
    local function PostSpawnPlayer(ped)
    FreezeEntityPosition(ped, false)
    RenderScriptCams(false, true, 500, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    SetCamActive(cam2, false)
    DestroyCam(cam2, true)
    SetEntityVisible(PlayerPedId(), true)
    Wait(500)
    DoScreenFadeIn(250)
    TriggerEvent("backitems:start")
    end
```

### cd_spawnselect Setup

If you use cd_spawnselect you need to edit the function "HasFullySpanwedIn" in the client_customize_me.lua and add ```TriggerEvent("backitems:start")```

![image](https://user-images.githubusercontent.com/7463741/154318777-3c59ce86-47c6-4f11-b51e-5df52666ed10.png)

## Clothing Setup

### qb-clothing Setup

If you use qb-clothing you need to add the follow event to the openMenu function.

```TriggerEvent("backitems:displayItems", false)``` 

It should now look like this.

```lua
   function openMenu(allowedMenus)
    TriggerEvent("backitems:displayItems", false)
    previousSkinData = json.encode(skinData)
    creatingCharacter = true

    local PlayerData = QBCore.Functions.GetPlayerData()
    local trackerMeta = PlayerData.metadata["tracker"]

    GetMaxValues()
    SendNUIMessage({
        action = "open",
        menus = allowedMenus,
        currentClothing = skinData,
        hasTracker = trackerMeta,
    })
    SetNuiFocus(true, true)
    SetCursorLocation(0.9, 0.25)

    FreezeEntityPosition(PlayerPedId(), true)

    enableCam()
end
```

Also add ```TriggerEvent("backitems:displayItems", true)``` to the close NUI callback
```lua
RegisterNUICallback('close', function()
    SetNuiFocus(false, false)
    creatingCharacter = false
    disableCam()
    TriggerEvent("backitems:displayItems", true)
    FreezeEntityPosition(PlayerPedId(), false)
end)
```

### fivem-appearance Setup

If you use fivem-appearance you need to add the triggers whenever you call the startPlayerCustomization export

```lua	
	TriggerEvent("backitems:displayItems", false)
	exports['fivem-appearance']:startPlayerCustomization(function (appearance)
		if appearance then
			TriggerServerEvent('fivem-appearance:save', appearance)
			print('Player Clothing Saved')
		else
			print('Canceled')
		end
		TriggerEvent("backitems:displayItems", true)
	end, config)
 ```

## Show Again Client Event

### fivem-appearance Setup

If you are using fivem-appearance, you must add the triggers when you call the LoadPlayerUniform() export

```lua
local function LoadPlayerUniform()
    QBCore.Functions.TriggerCallback("fivem-appearance:server:getUniform", function(uniformData)
        if not uniformData then
            return
        end
        if Config.BossManagedOutfits then
            QBCore.Functions.TriggerCallback("fivem-appearance:server:getManagementOutfits", function(result)
                local uniform = nil
                for i = 1, #result, 1 do
                    if result[i].name == uniformData.name then
                        uniform = {
                            type = uniformData.type,
                            name = result[i].name,
                            model = result[i].model,
                            components = result[i].components,
                            props = result[i].props,
                            disableSave = true,
                        }
                        break
                    end
                end

                if not uniform then
                    TriggerServerEvent("fivem-appearance:server:syncUniform", nil) -- Uniform doesn't exist anymore
                    return
                end
    
                TriggerEvent("fivem-appearance:client:changeOutfit", uniform)
            end, uniformData.type, getGender())
        else
            local outfits = Config.Outfits[uniformData.jobName][uniformData.gender]
            local uniform = nil
            for i = 1, #outfits, 1 do
                if outfits[i].name == uniformData.label then
                    uniform = outfits[i]
                    break
                end
            end

            if not uniform then
                TriggerServerEvent("fivem-appearance:server:syncUniform", nil) -- Uniform doesn't exist anymore
                return
            end

            uniform.jobName = uniformData.jobName
            uniform.gender = uniformData.gender

            TriggerEvent("qb-clothing:client:loadOutfit", uniform)
            TriggerEvent("backitems:showagain")
        end
    end)
end
```

You must also add the trigger to the reloadSkin Client Event:

```lua
RegisterNetEvent('fivem-appearance:client:reloadSkin', function()
    if InCooldown() or CheckPlayerMeta() then
        QBCore.Functions.Notify("You cannot use reloadskin right now", "error")
        return
    end

    reloadSkinTimer = GetGameTimer()
    local playerPed = PlayerPedId()
    local health = GetEntityHealth(playerPed)
    local maxhealth = GetEntityMaxHealth(playerPed)
    local armour = GetPedArmour(playerPed)

    QBCore.Functions.TriggerCallback('fivem-appearance:server:getAppearance', function(appearance)
        if not appearance then
            return
        end
        exports[resourceName]:setPlayerAppearance(appearance)
        TriggerEvent("backitems:showagain")
        if Config.PersistUniforms then
            TriggerServerEvent("fivem-appearance:server:syncUniform", nil)
        end
        playerPed = PlayerPedId()
        SetPedMaxHealth(playerPed, maxhealth)
        Wait(1000) -- Safety Delay
        SetEntityHealth(playerPed, health)
        SetPedArmour(playerPed, armour)
        ResetRechargeMultipliers()
    end)
end)
```

### qb-apartment Fix / Setup

Add the event to your EnterApartment and LeaveApartment functions after ```TriggerServerEvent("QBCore:Server:SetMetaData", "currentapartment", nil)```

Something like this:

* EnterApartment (Twice)
```lua
            TriggerServerEvent("QBCore:Server:SetMetaData", "currentapartment", CurrentApartment)
            TriggerEvent("backitems:showagain")
        end
```

* LeaveApartment
```lua
        TriggerServerEvent("QBCore:Server:SetMetaData", "currentapartment", nil)
        TriggerEvent("backitems:showagain")
    end)
```
