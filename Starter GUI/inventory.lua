local TweenService = game:GetService("TweenService")
local imageButton = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BackpackTriggerEvent = ReplicatedStorage:WaitForChild("bpevent")
local tweenback = ReplicatedStorage:WaitForChild("tweenback")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local iui = localPlayer:WaitForChild("PlayerGui"):WaitForChild("inventoryui")
local db = false

-- Store the original position at the top of the script
local originalPosition = imageButton.Position

local function onButtonClicked()
	if not db then
		db = true
		local tweenInfo = TweenInfo.new(.4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
		local goal = { Position = UDim2.new(-0.2, 0, imageButton.Position.Y.Scale, imageButton.Position.Y.Offset) }
		local tween = TweenService:Create(imageButton, tweenInfo, goal)
		tween:Play()

		local bptabledata = BackpackTriggerEvent:InvokeServer()
		print(bptabledata)

		iui.Enabled = true
		task.wait(1)
		db = false
	end
end

tweenback.Event:Connect(function(data)
	print("closed backpack")
	local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
	local goal = { Position = originalPosition }
	local tween = TweenService:Create(imageButton, tweenInfo, goal)
	tween:Play()
end)

-- Connecting the MouseButton1Click event of the ImageButton to the handler function
imageButton.MouseButton1Click:Connect(onButtonClicked)

--end of first script to handle inventory on screen button