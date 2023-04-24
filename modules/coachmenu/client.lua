local playerCoachId = nil
local PromptTimeout = GetGameTimer() - 1000
local hasPermission = false
local PromptSet = false

RegisterNetEvent("rpx-policejob:client:CoachMenu",function()
    lib.showContext('police_coach_menu')
end)

GetClosestSpawnLocation = function()
    local PlayerPos = GetEntityCoords(PlayerPedId())
    for k,v in pairs(Config.CoachSpawners) do
        if #(PlayerPos - v.MenuPosition) < 10.0 then
            return v.SpawnPosition
        end
    end
end

lib.registerContext({
    id = 'police_coach_menu',
    title = 'Law Enforcement Coaches',
    options = {
        {
            title = 'Spawn Armored Stagecoach',
            description = 'Spawn an armored stagecoach. If you have one out already, it will be despawned.',
            icon = 'horse',
            onSelect = function()
                if playerCoachId then
                    if DoesEntityExist(playerCoachId) then
                        SetEntityAsMissionEntity(playerCoachId, true, true)
                        DeleteEntity(playerCoachId)
                        Wait(200)
                    end
                end
                local Position = GetClosestSpawnLocation()
                local model = GetHashKey("STAGECOACH004X")
                while not HasModelLoaded(model) do
                    RequestModel(model)
                    Wait(20)
                end
                if not IsPositionOccupied(Position.x, Position.y, Position.z, 2.0, false, true, true, false, false, 0, false) then
                    playerCoachId = CreateVehicle(model, Position.x,Position.y,Position.z, Position.w, true, true, false)
                    SetEntityAsMissionEntity(playerCoachId, true, true)
                end
                SetModelAsNoLongerNeeded(model)
            end,
        },
        {
            title = 'Despawn Stagecoach',
            description = 'Despawn your current stagecoach.',
            icon = 'trash-can',
            onSelect = function()
                if playerCoachId then
                    if DoesEntityExist(playerCoachId) then
                        SetEntityAsMissionEntity(playerCoachId, true, true)
                        DeleteEntity(playerCoachId)
                    end
                end
            end,
        },
    }
})

Citizen.CreateThread(function()
    while true do
        Wait(1000)
        local plyState = LocalPlayer.state

        hasPermission = exports['rpx-core']:HasJobPermission(plyState.job?.name, plyState.job?.rank, "sheriff:general")

        if hasPermission then
            if not plyState.job.duty then
                hasPermission = false
            end
        end

        if hasPermission then
            if not PromptSet then
                for id,spawner in pairs(Config.CoachSpawners) do
                    exports['rpx-core']:createPrompt('police_coach_spawner_'..id, spawner.MenuPosition, 0xD9D0E1C0, 'Coach Spawner', {
                        func = function()
                            if GetGameTimer() - PromptTimeout > 1000 then
                                PromptTimeout = GetGameTimer()
                                TriggerServerEvent("rpx-policejob:server:RequestCoachMenu")
                            end
                        end
                    })
                end
                PromptSet = true
            end
        else
            if PromptSet then
                for id,spawner in pairs(Config.CoachSpawners) do
                    exports['rpx-core']:deletePrompt('police_coach_spawner_'..id)
                end
                PromptSet = false
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(5)
        if hasPermission then
            local PlayerPos = GetEntityCoords(PlayerPedId())
            for id,spawner in pairs(Config.CoachSpawners) do
                local distance = #(PlayerPos - vector3(spawner.MenuPosition.x, spawner.MenuPosition.y, spawner.MenuPosition.z))
                if distance < 10.0 then
                    Citizen.InvokeNative(0x2A32FAA57B937173, -1795314153, spawner.MenuPosition.x, spawner.MenuPosition.y, spawner.MenuPosition.z - 1.0, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.1, 128, 64, 0, 64, 0, 0, 2, 0, 0, 0, 0) --DrawMarker
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    if PromptSet then
        for id,spawner in pairs(Config.CoachSpawners) do
            exports['rpx-core']:deletePrompt('police_coach_spawner_'..id)
        end
    end
end)