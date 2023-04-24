RegisterServerEvent("rpx-policejob:server:RequestCoachMenu", function()
	local src = source
    local char = RPX.GetPlayer(src)
    if not char then return end
	if exports['rpx-core']:HasJobPermission(char.job.name, char.job.rank, "sheriff:general") then
		TriggerClientEvent("rpx-policejob:client:CoachMenu", src)
	end
end)