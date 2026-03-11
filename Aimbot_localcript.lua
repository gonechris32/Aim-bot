-- ONLY WORKS IN YOUR GAME
if game.PlaceId ~= 17625359962 then return end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local AimAssist = false
local target = nil
local FOV = 150 -- pixel radius, used internally (no circle shown)

---------------------------
-- UI SETUP
---------------------------
local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))

local toggleButton = Instance.new("TextButton")
toggleButton.Parent = gui
toggleButton.Size = UDim2.new(0,130,0,45)
toggleButton.Position = UDim2.new(0,20,0,30)
toggleButton.Text = "Aim Assist"
toggleButton.BackgroundColor3 = Color3.fromRGB(50,200,50)
toggleButton.TextScaled = true

local message = Instance.new("TextLabel")
message.Parent = gui
message.Size = UDim2.new(0,280,0,40)
message.Position = UDim2.new(0.5,-140,0.15,0)
message.BackgroundTransparency = 0.25
message.BackgroundColor3 = Color3.fromRGB(0,0,0)
message.Visible = false
message.TextColor3 = Color3.fromRGB(255,255,255)
message.TextScaled = true

local function showMessage(txt)
	message.Text = txt
	message.Visible = true
	task.delay(5,function()
		message.Visible = false
	end)
end

---------------------------
-- GET CLOSEST HEAD TARGET
---------------------------
local function getClosest()
	local closest = nil
	local shortest = math.huge

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer 
		and plr.Character 
		and plr.Character:FindFirstChild("Head") then

			local head = plr.Character.Head
			local pos, vis = Camera:WorldToViewportPoint(head.Position)
			
			if vis then
				local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
				local dist = (center - Vector2.new(pos.X,pos.Y)).Magnitude

				if dist < shortest and dist < FOV then
					shortest = dist
					closest = head
				end
			end
		end
	end

	return closest
end

---------------------------
-- AUTO-FACE WHEN PUNCHING
---------------------------
UIS.InputBegan:Connect(function(input)
	if AimAssist and target then
		-- Mouse click (PC punch)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
		end
	end
end)

---------------------------
-- MOBILE TAP SUPPORT
---------------------------
UIS.TouchTap:Connect(function()
	if AimAssist and target then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
	end
end)

---------------------------
-- TOGGLE BUTTON
---------------------------
toggleButton.MouseButton1Click:Connect(function()
	AimAssist = not AimAssist

	if not AimAssist then
		target = nil
		showMessage("Aim Assist Disabled")
		toggleButton.BackgroundColor3 = Color3.fromRGB(200,50,50)
	else
		showMessage("Aim Assist Enabled")
		toggleButton.BackgroundColor3 = Color3.fromRGB(50,200,50)
	end
end)

---------------------------
-- MAIN AIM LOOP (SNAP AIM)
---------------------------
RunService.RenderStepped:Connect(function()
	if not AimAssist then return end

	-- Smart target switching
	local newTarget = getClosest()
	if newTarget then
		target = newTarget
	end

	-- Snap aim to target head
	if target then
		Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
	end
end)
