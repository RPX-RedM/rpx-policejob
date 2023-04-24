RegisterServerEvent('rpx-policejob:server:handcuff', function(target)
    local src = tonumber(source)
    local char = RPX.GetPlayer(src)
    if not char then return end
    if exports['rpx-core']:HasJobPermission(char.job.name, char.job.rank, "sheriff:general") then
        TriggerClientEvent('rpx-policejob:client:handcuff', target)
    end
end)

RegisterServerEvent('rpx-policejob:server:hardcuff', function(target)
    local src = tonumber(source)
    local char = RPX.GetPlayer(src)
    if not char then return end
    if exports['rpx-core']:HasJobPermission(char.job.name, char.job.rank, "sheriff:general") then
        TriggerClientEvent('rpx-policejob:client:hardcuff', target)
    end
end)

RegisterServerEvent('rpx-policejob:server:hogtie', function(target)
    local src = tonumber(source)
    local char = RPX.GetPlayer(src)
    if not char then return end
    if exports['rpx-core']:HasJobPermission(char.job.name, char.job.rank, "sheriff:general") then
        TriggerClientEvent('rpx-policejob:client:hogtie', target)
    end
end)

RegisterServerEvent('rpx-policejob:server:drag', function(target)
    local src = tonumber(source)
    local char = RPX.GetPlayer(src)
    if not char then return end
    if exports['rpx-core']:HasJobPermission(char.job.name, char.job.rank, "sheriff:general") then
        TriggerClientEvent('rpx-policejob:client:drag', target, src)
    end
end)
