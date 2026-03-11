if game.PlaceId ~= 17625359962 then
    warn("AimAssistServer disabled outside your game.")
    return
end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")

-- RemoteEvent that client uses to tell server who it's aiming at
-- (YOU must create this in ReplicatedStorage → AimAssistRemote)
local AimRemote = RS:WaitForChild("AimAssistRemote")

-- This table stores who each player is currently targeting
local CurrentTargets = {}  -- [player] = targetPlayer

-- Validate that a player is aiming at a REAL valid target
local function validateTarget(player, target)
	if typeof(target) ~= "Instance" then return false end
	if not target:IsA("Player") then return false end
	if target == player then return false end
	if not target.Character then return false end
	if not target.Character:FindFirstChild("Head") then return false end
	
	-- optional: if you add teams, block teammates
	-- if player.Team == target.Team then return false end
	
	return true
end

-- When client tells server who they’re locking on to
AimRemote.OnServerEvent:Connect(function(player, target)
	
	-- SECURITY: validate target
	if target ~= nil and validateTarget(player, target) then
		CurrentTargets[player] = target
	else
		CurrentTargets[player] = nil
	end
end)

-- OPTIONAL: Server can boost punches when player is aimed correctly
-- Use this only in your combat system
function ApplyAimAssistBonus(player, damage)
	local t = CurrentTargets[player]
	if not t or not t.Character then return damage end
	
	local head = t.Character:FindFirstChild("Head")
	if not head then return damage end

	-- Example: give 10% bonus accuracy / damage when aimed correctly
	return damage * 1.1
end

-- OPTIONAL: clear when player leaves
Players.PlayerRemoving:Connect(function(plr)
	CurrentTargets[plr] = nil
end)
