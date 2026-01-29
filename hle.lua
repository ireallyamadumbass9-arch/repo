-- services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local player = Players.LocalPlayer
local character
local humanoid

local function setupCharacter(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
end

setupCharacter(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(setupCharacter)

-- settings
local TSUNAMI_CLEAR_INTERVAL = 0.5
local PROMPT_FORCE_INTERVAL = 0.5

-- state
local forceZeroPrompts = false

----------------------------------------------------------------
-- tsunami deleter loop (no mercy)
----------------------------------------------------------------
task.spawn(function()
	while true do
		local folder = workspace:FindFirstChild("ActiveTsunamis")
		if folder then
			for _, v in ipairs(folder:GetChildren()) do
				pcall(function()
					v:Destroy()
				end)
			end
		end
		task.wait(TSUNAMI_CLEAR_INTERVAL)
	end
end)

----------------------------------------------------------------
-- prompt zeroing loop (because waiting is cringe)
----------------------------------------------------------------
task.spawn(function()
	while true do
		if forceZeroPrompts then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("ProximityPrompt") then
					pcall(function()
						obj.HoldDuration = 0
						obj.RequiresLineOfSight = false
					end)
				end
			end
		end
		task.wait(PROMPT_FORCE_INTERVAL)
	end
end)

----------------------------------------------------------------
-- ui
----------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "CleanHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(260, 180)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 30)
title.Position = UDim2.fromOffset(10, 10)
title.BackgroundTransparency = 1
title.Text = "clean hub"
title.TextColor3 = Color3.fromRGB(230, 230, 230)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

----------------------------------------------------------------
-- walkspeed slider
----------------------------------------------------------------
local sliderBack = Instance.new("Frame")
sliderBack.Size = UDim2.new(1, -40, 0, 6)
sliderBack.Position = UDim2.fromOffset(20, 60)
sliderBack.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
sliderBack.BorderSizePixel = 0
sliderBack.Parent = main

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = sliderBack

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0.25, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(120, 180, 255)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBack

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = sliderFill

local dragging = false
local MIN_SPEED = 8
local MAX_SPEED = 120

sliderBack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
	end
end)

sliderBack.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

RunService.RenderStepped:Connect(function()
	if dragging and humanoid then
		local mouse = player:GetMouse()
		local x = math.clamp(
			(mouse.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X,
			0,
			1
		)
		sliderFill.Size = UDim2.new(x, 0, 1, 0)
		humanoid.WalkSpeed = math.floor(MIN_SPEED + (MAX_SPEED - MIN_SPEED) * x)
	end
end)

----------------------------------------------------------------
-- circular prompt button
----------------------------------------------------------------
local promptButton = Instance.new("TextButton")
promptButton.Size = UDim2.fromOffset(60, 60)
promptButton.Position = UDim2.fromOffset(100, 100)
promptButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
promptButton.Text = "0s"
promptButton.TextColor3 = Color3.fromRGB(255, 255, 255)
promptButton.Font = Enum.Font.GothamBold
promptButton.TextSize = 18
promptButton.Parent = main

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(1, 0)
buttonCorner.Parent = promptButton

promptButton.MouseButton1Click:Connect(function()
	forceZeroPrompts = not forceZeroPrompts
	promptButton.BackgroundColor3 = forceZeroPrompts
		and Color3.fromRGB(120, 180, 255)
		or Color3.fromRGB(60, 60, 60)
end)
