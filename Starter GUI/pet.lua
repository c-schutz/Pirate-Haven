--lerp testing

local petActivationButton = script.Parent
local frogModel = nil
local playerHead = game.Players.LocalPlayer.Character:FindFirstChild("Head")
local hrp = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart")
local petActive = false
local tweenService = game:GetService("TweenService")
local tInfo = TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)

petActivationButton.Activated:Connect(function()
	petActive = not petActive
	
	if petActive then --when pet is active
		frogModel = game.ReplicatedStorage.model.mogfrodel:Clone()
		frogModel.Parent = workspace
		frogModel.default.Anchored = true
		frogModel.default:PivotTo(hrp.CFrame - (hrp.CFrame.lookVector.Unit * 2))
		
		while petActive do
			--tween orientation
			local newC = CFrame.new(frogModel.default.Position, playerHead.CFrame.LookVector)
			local orientationTween = tweenService:Create(frogModel.default, tInfo, {CFrame = CFrame.new(frogModel.default.Position, (frogModel.default.Position + playerHead.CFrame.LookVector))})
			
			orientationTween:Play()
			task.wait(.3)
			
			--set up bezier curve
			local p1 = frogModel.default.Position --original point of the model
			local p2 = (hrp.CFrame - (hrp.CFrame.lookVector.Unit * 2) + (hrp.CFrame.RightVector.Unit * 2) + (hrp.CFrame.UpVector * 1)).Position --final point for model to reach
			local p3 = ((p2 - p1)/2 + Vector3.new(0, 1.5, 0)) + p1 --anchor point
			for i = 0, 1, .05 do
				local interpol1 = p1:Lerp(p3, i)
				local interpol2 = p3:Lerp(p2, i)
				local interpol3 = interpol1:Lerp(interpol2, i)
				frogModel.default.Position = interpol3
				task.wait(.001) -- set to tween duration
			end
		end
		
	else --when pet is deactivated
		
		frogModel:Destroy()
	end
end)
