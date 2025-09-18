local button = game.Players.LocalPlayer.PlayerGui:WaitForChild("LeaveWheel").TextButton
local prompt = script.Parent:WaitForChild("promptPart").ProximityPrompt
local pToShip = script.Parent.promptPart.playerToShip
local localPlayer = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local playerOffWheel = game.ReplicatedStorage.playerOffWheel

--load animation
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://18237442922"

button.Activated:Connect(function(inp)
	local humanoid = localPlayer.Character.Humanoid
	local aTrackList = localPlayer.Character.Humanoid.Animator:GetPlayingAnimationTracks()
	for index, value in pairs(aTrackList) do
		value:Stop()
	end
	
	humanoid.WalkSpeed = 16 --default 16
	humanoid.JumpPower = 50 --default 50
	
	button.Parent.Enabled = false
	
	playerOffWheel:FireServer(prompt)
end)

--end of script to remove player from wheel

--initialize
local prompt = script.Parent:WaitForChild("ProximityPrompt")
local standingLocation = script.Parent.standingLocation
local pToShip = script.Parent.playerToShip
local aTrack = nil
local playerOnWheel = nil
local currentDirection = ""
local playerOffWheel = game.ReplicatedStorage.playerOffWheel
local getInputs = game.ReplicatedStorage.getInputs
local sloopModel = script.Parent.Parent.sloopModel

--movement
local forward = script.Parent.Parent.floatPart.shipDirection.forward
local rightRotation = script.Parent.Parent.floatPart.shipDirection.avRight
local leftRotation = script.Parent.Parent.floatPart.shipDirection.avLeft
local backward = script.Parent.Parent.floatPart.shipDirection.backward
local alignOrientationParallel = script.Parent.Parent.floatPart.shipDirection.AlignOrientationParallel
local alignOrientationPerpendicular = script.Parent.Parent.floatPart.shipDirection.AlignOrientationPerpendicular


--raycast
Params = RaycastParams.new()
Params.FilterDescendantsInstances = {workspace.Terrain}
UIS = game:GetService("UserInputService")
Params.FilterType = Enum.RaycastFilterType.Include

--load animation
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://18237442922"

prompt.Triggered:Connect(function(player)
	
	playerOnWheel = player
	prompt.Enabled = false
	local char = player.Character
	local humanoid = char:FindFirstChild("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local animator = humanoid.Animator
	aTrack = animator:LoadAnimation(animation)
	
	--load the animation
	repeat task.wait() until aTrack.Length > 0

	aTrack:Play()
	aTrack:AdjustSpeed(0)
	
	--set humanoid location and lock them in the correct orientation
	humanoid.WalkSpeed += 0.01 --these are from a bug where if you change the walk and jump on the client it doesn't update to the server so you need to reupdate it
	humanoid.JumpPower += 0.01
	task.wait(.1)
	humanoid.WalkSpeed = 0 --default 16
	humanoid.JumpPower = 0 --default 50
	char.HumanoidRootPart.Position = Vector3.new(standingLocation.Position.X,char.HumanoidRootPart.Position.Y + .1,standingLocation.Position.Z)
	char.HumanoidRootPart.Orientation = standingLocation.Orientation
	pToShip.Part0 = hrp
	
	--enable leave wheel button
	player.PlayerGui:WaitForChild("LeaveWheel").Enabled = false --same issue as before
	player.PlayerGui:WaitForChild("LeaveWheel").Enabled = true
	
	--disable align orientation it messes with driving (fix later possibly) (anchor instead? for now at least)
	--alignOrientationParallel.Enabled = false
	--alignOrientationPerpendicular.Enabled = false
	sloopModel.Anchored = false
	
	local prevOutput = {}
	local output = {}
	while playerOnWheel ~= nil do 
		--raycast
		local sPos = script.Parent.Parent.floatPart.Position
		local ePos = sPos + Vector3.new(0,-5,0) --change based on boat height?
		local ray = workspace:Raycast(sPos,ePos - sPos, Params)
		if ray and ray.Material ~= Enum.Material.Water  then
			forward.Enabled = false
			rightRotation.Enabled = false
			leftRotation.Enabled = false
			backward.Enabled = false
			break
		end
		
		--get player input
		local timeoutcount = 0 --safe invoke mousePosition (from commitblue)
		local timeout = 3
		local cr = task.spawn(function()
			output = getInputs:InvokeClient(playerOnWheel)
		end)
		repeat task.wait(.05) timeoutcount += 1 until timeoutcount >= timeout or output ~= nil
		
		--only change inputs if the output has changed
		for key, value in pairs(output) do
			if (prevOutput[key] ~= value) then
				if output[1] then
					forward.Enabled = true

					--check rotations if going backwards
					if output[4] then
						rightRotation.Enabled = true
					else
						rightRotation.Enabled = false
					end
					if output[3] then
						leftRotation.Enabled = true
					else
						leftRotation.Enabled = false
					end
					continue
				else
					forward.Enabled = false
				end

				--backwards
				if output[2] then
					backward.Enabled = true

					--check rotations if going backwards
					if output[4] then
						rightRotation.Enabled = true
					else
						rightRotation.Enabled = false
					end
					if output[3] then
						leftRotation.Enabled = true
					else
						leftRotation.Enabled = false
					end
					continue
				else
					backward.Enabled = false
				end

				--make sure rotation is disabled if they aren't pressed
				if not output[1] and not output[2] then
					rightRotation.Enabled = false
					leftRotation.Enabled = false
				end
			end
		end
		prevOutput = output
	end
	
	forward.Enabled = false
	rightRotation.Enabled = false
	leftRotation.Enabled = false
	backward.Enabled = false
	sloopModel.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- bugs out and applies velocity to player sometimes if these aren't added
	sloopModel.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end)

playerOffWheel.OnServerEvent:Connect(function(player, prompt)	
	playerOnWheel = nil
	pToShip.Part0 = nil
	sloopModel.Anchored = true
	prompt.Enabled = true
end)

--script to handle most of the steering (very messy one of the first scripts I wrote)