--initialized variables
local blunderbuss = script.Parent
local handle = blunderbuss.Handle
local bulletCount = 6
local reloadNeeded = false
local reloading = false

--Remote Events
local hitObject = game.ReplicatedStorage.hitObject
local takeDamage = game.ReplicatedStorage.takeDamage

--services
local playerService = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local UIS = game:GetService('UserInputService')

--Tween data
local tweenProperties = {}
local bulletTweenInfo = TweenInfo.new(
	.1, -- num of seconds tween lasts
	Enum.EasingStyle.Linear, --https://create.roblox.com/docs/reference/engine/enums/EasingStyle
	Enum.EasingDirection.Out, --tween direction
	0, -- number of repetitions
	false, -- should it go back to start after?
	0 -- num of seconds before starting
)

local sphereParams = RaycastParams.new()
sphereParams.IgnoreWater = true
sphereParams.FilterType = Enum.RaycastFilterType.Exclude
sphereParams.FilterDescendantsInstances = {blunderbuss}

blunderbuss.Activated:Connect(function()
	if reloadNeeded then return end
	if reloading then return end
	--initialize vars
	local initialPos = handle.barrelExit.WorldPosition
	local player = playerService:GetPlayerFromCharacter(blunderbuss.Parent)
	sphereParams:AddToFilter(player.Character)

	--safe invoke mousePosition (from commitblue)
	local timeoutcount = 0
	local timeout = 5
	local mousePosition = game.Players.LocalPlayer:GetMouse().Hit.Position

	local tHit = workspace:Spherecast(initialPos, .2, mousePosition - initialPos, sphereParams)
	
	--do stuff if humanoid or any targetable object was shot
	local damageAmount = 10
	if tHit.Instance.Name == "crateHitBox" then
		hitObject:FireServer(tHit.Instance.Parent, damageAmount)
		
	elseif tHit.Instance.Parent:FindFirstChild("Humanoid") then
		local humanoid = tHit.Instance.Parent:FindFirstChild("Humanoid")
		takeDamage:FireServer(humanoid, damageAmount)
		
	elseif tHit.Instance.Parent:IsA("Accessory") then
		local humanoid = tHit.Instance.Parent.Parent:FindFirstChild("Humanoid")
		takeDamage:FireServer(humanoid, damageAmount)
	end

	--safe invoke cameraPosition 
	local timeoutcount = 0
	local timeout = 5
	local cameraLookVector = game.Players.LocalPlayer.Character.Head.CFrame.LookVector

	if typeof(cameraLookVector) ~= "Vector3" then
		print("incorrect data entered")
	end

	--figure out if the position the position of the shot is the same direction the head is facing
	local dirShot = mousePosition - initialPos
	local twoDimensionalTH = Vector2.new(dirShot.X, dirShot.Z)
	twoDimensionalTH = twoDimensionalTH.Unit
	local twoDimensionalCLV = Vector2.new(cameraLookVector.X, cameraLookVector.Z)

	--print("Hit: ", mousePosition - initialPos)
	--print("CLV: ", twoDimensionalCLV)

	local directionality = twoDimensionalTH.X * twoDimensionalCLV.X + twoDimensionalTH.Y * twoDimensionalCLV.Y

	--Do stuff based on whether the shot was valid
	if directionality <= 0 then
		print("You can only shoot in the direction your facing!")
	else
		if bulletCount > 0 and not reloadNeeded then
			--update bullet count and gui
			bulletCount = bulletCount - 1
			player.PlayerGui.GunReload.rFrame.TextLabel.Text = tostring(bulletCount) .. "/6"

			--clone bullet and create tween for bullet animation (can't get bullet orientation to work currently)
			blunderbuss.PrimaryPart = handle
			local shotBullet = game.ReplicatedStorage.model.bullet:Clone()
			shotBullet.Parent = workspace
			shotBullet.CanCollide = false
			local bulletPos = handle.barrelExit.WorldPosition
			local fCFrame = CFrame.new(bulletPos)
			shotBullet:PivotTo(fCFrame)
			tweenProperties.Position = tHit.Position
			local sBTween = tweenService:Create(shotBullet, bulletTweenInfo, tweenProperties)
			sBTween:Play()
			task.wait(1)
			shotBullet:Destroy()

		else
			reloadNeeded = true
		end

	end

end)

--enable/disable gui on equip/unequip
blunderbuss.Equipped:Connect(function()
	local player = playerService:GetPlayerFromCharacter(blunderbuss.Parent)
	player.PlayerGui.GunReload.Enabled = true
end)

blunderbuss.Unequipped:Connect(function()
	--its in the backpack so we need the second parent
	blunderbuss.Parent.Parent.PlayerGui.GunReload.Enabled = false
end)

--handle reloading
UIS.InputEnded:Connect(function(inputObject, processedEvent)
	if processedEvent then return end

	if inputObject.UserInputType == Enum.UserInputType.Keyboard then
		if inputObject.KeyCode.Value == 114 then
			reloadNeeded = false
			reloading = true
			task.wait(2)
			--this is where you would play reloading sound/animation
			reloading = false
			bulletCount = 6
			game.Players.LocalPlayer.PlayerGui.GunReload.rFrame.TextLabel.Text = tostring(bulletCount) .. "/6"
		end
	end
end)