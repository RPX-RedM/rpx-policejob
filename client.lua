

local isHandcuffed, isHardCuffed, isHogtied = false, false, false
local PlayerData, dragStatus, currentTask = {}, {}, {}
dragStatus.isDragged = false
local active = false

RegisterNetEvent("rpx-policejob:client:PoliceAction", function(action)
    local closestPlayer, closestDistance = exports['rpx-core']:GetClosestPlayer()
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        action = action[1]
        if not Citizen.InvokeNative(0x3AA24CCC0D451379, PlayerPedId()) then
            if not LocalPlayer.state.isDead then
                if action == "cuff" then
                    TriggerServerEvent('rpx-policejob:server:hardcuff', GetPlayerServerId(closestPlayer))
                elseif action == "drag" then
                    TriggerServerEvent('rpx-policejob:server:drag', GetPlayerServerId(closestPlayer))
                elseif action == "ankle" then
                    TriggerServerEvent('rpx-policejob:server:handcuff', GetPlayerServerId(closestPlayer))
                elseif action == "frisk" then
                    exports['rpx-inventory']:openInventory('player', GetPlayerServerId(closestPlayer))
                elseif action == "hogtie" then
                    TriggerServerEvent('rpx-policejob:server:hogtie', GetPlayerServerId(closestPlayer))
                end
            else
                lib.notify({title = "You can't do this right now!", type = "error" })
            end
        else
            lib.notify({title = "You can't do this right now!", type = "error" })
        end
    else
        lib.notify({title = "Can't Find", description = "No players nearby!", type = "error" })
    end
end)

Citizen.CreateThread(
    function()
        for _, v in pairs(Config.Stations) do
            blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.x, v.y, v.z)
            SetBlipSprite(blip, 1047294027, 1)
            SetBlipScale(blip, 1.5)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.label)
            Citizen.InvokeNative(0x662D364ABF16DE2F, blip, GetHashKey("BLIP_MODIFIER_MP_COLOR_13"))
        end
    end
)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if dragStatus.isDragged then
            if dragStatus.CopId ~= nil then
                local targetPed = GetPlayerPed(GetPlayerFromServerId(dragStatus.CopId))
                AttachEntityToEntity(PlayerPedId(), targetPed, 11816, 0.54, 0.54, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
                if IsPedDeadOrDying(targetPed, true) then
                    dragStatus.isDragged = false
                    DetachEntity(PlayerPedId(), true, false)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if isHandcuffed or isHardCuffed or isHogtied then
            DisableControlAction(0, 0xB2F377E8, true) -- Attack
            DisableControlAction(0, 0xC1989F95, true) -- Attack 2
            DisableControlAction(0, 0x07CE1E61, true) -- Melee Attack 1
            DisableControlAction(0, 0xF84FA74F, true) -- MOUSE2
            DisableControlAction(0, 0xCEE12B50, true) -- MOUSE3
            DisableControlAction(0, 0x8FFC75D6, true) -- Shift
            DisableControlAction(0, 0xD9D0E1C0, true) -- SPACE
            DisableControlAction(0, 0xCEFD9220, true) -- E
            DisableControlAction(0, 0xF3830D8E, true) -- J
            DisableControlAction(0, 0x80F28E95, true) -- L
            DisableControlAction(0, 0xDB096B85, true) -- CTRL
            DisableControlAction(0, 0xE30CD707, true) -- R
        else
            Citizen.Wait(500)
        end
    end
end)

RegisterNetEvent('rpx-policejob:client:handcuff', function()
    isHandcuffed = not isHandcuffed
    local playerPed = PlayerPedId()

    Citizen.CreateThread(function()
        if isHandcuffed then
            lib.notify({ title = "You are being handcuffed!", type = "error" })
            SetEnableHandcuffs(playerPed, true)
            DisablePlayerFiring(playerPed, true)
            SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
            SetPedCanPlayGestureAnims(playerPed, false)
            FreezeEntityPosition(playerPed, true)
            DisplayRadar(false)
        elseif not isHandcuffed then
            if isHardCuffed then
                FreezeEntityPosition(playerPed, false)
            else
                lib.notify({ title = "You are being uncuffed!", type = "success" })
                ClearPedSecondaryTask(playerPed)
                SetEnableHandcuffs(playerPed, false)
                DisablePlayerFiring(playerPed, false)
                SetPedCanPlayGestureAnims(playerPed, true)
                FreezeEntityPosition(playerPed, false)
                DisplayRadar(true)
            end
        end
    end)
end)

RegisterNetEvent('rpx-policejob:client:hardcuff', function()
    isHardCuffed = not isHardCuffed
    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        if isHardCuffed then
            lib.notify({ title = "You are being handcuffed!", type = "error" })
            SetEnableHandcuffs(playerPed, true)
            DisablePlayerFiring(playerPed, true)
            SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
            SetPedCanPlayGestureAnims(playerPed, false)
            DisplayRadar(false)
        elseif not isHardCuffed then
            lib.notify({ title = "You are being uncuffed!", type = "success" })
            ClearPedSecondaryTask(playerPed)
            SetEnableHandcuffs(playerPed, false)
            DisablePlayerFiring(playerPed, false)
            SetPedCanPlayGestureAnims(playerPed, true)
            FreezeEntityPosition(playerPed, false)
            DisplayRadar(true)
            isHandcuffed = false
        end
    end)
end)

RegisterNetEvent('rpx-policejob:client:hogtie', function()
    isHogtied = not isHogtied

    Citizen.CreateThread(function()
        local playerPed = PlayerPedId()
        if isHogtied then
            TaskKnockedOutAndHogtied(playerPed, 0, 0)
            SetEnableHandcuffs(playerPed, true)
            DisablePlayerFiring(playerPed, true)
            SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true) -- unarm player
            SetPedCanPlayGestureAnims(playerPed, false)
            DisplayRadar(false)
            lib.notify({ title = "You are being hogtied!", type = "error" })
        elseif not isHogtied then
            ClearPedTasksImmediately(playerPed, true, false)
            ClearPedSecondaryTask(playerPed)
            SetEnableHandcuffs(playerPed, false)
            DisablePlayerFiring(playerPed, false)
            SetPedCanPlayGestureAnims(playerPed, true)
            DisplayRadar(true)
            lib.notify({ title = "You are being released!", type = "success" })
        end
    end)
end)

RegisterNetEvent('rpx-policejob:client:drag', function(copId)
    dragStatus.isDragged = not dragStatus.isDragged
    dragStatus.CopId = copId
    if dragStatus.isDragged then
        lib.notify({ title = "You are being escorted!", type = "inform" })
    else
        lib.notify({ title = "You are no longer being escorted!", type = "inform" })
    end
end)