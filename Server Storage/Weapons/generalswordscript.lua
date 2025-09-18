local cavalrySabre = script.Parent
local running = false
local hitDebounce = false
local isSwinging = false
local damageAmount = 15
local hitObject = game.ReplicatedStorage.hitObject
local takeDamage = game.ReplicatedStorage.takeDamage
local justTookDamage = {}

cavalrySabre.Activated:Connect(function(player)
	--debounce
	if not running then
		running = true
		justTookDamage = {}
		
		--initialize stuff
		local player = game.Players.LocalPlayer
		local character = player.Character
		local humanoid = character:WaitForChild("Humanoid")
		local animator = Instance.new("Animator")
		animator.Parent = humanoid
		local cSlice1 = cavalrySabre["cavalrySabreSwing1"]
		local cSlice2 = cavalrySabre["cavalrySabreSwing2"]

		--load animations	
		local animationT1 = nil
		--pick one of the two animations randomly
		local pick = math.random(1, 2)
		if pick == 1 then
			animationT1 = animator:LoadAnimation(cSlice1)
		else
			animationT1 = animator:LoadAnimation(cSlice2)
		end
		animationT1:AdjustSpeed(.5)--makes it play twice as long (formula is atrack.Length/speed)
		repeat task.wait() until animationT1.Length > 0 --do this for all the animations to make sure they are fully loaded before running scripts

		--play animations
		isSwinging = true
		animationT1:Play()
		--[[ working on fluid motion (fix later)
		if lp.Character.Humanoid:GetState() == Enum.HumanoidStateType.Running then
			local rAn = lp.Character.Animate.run.RunAnim
			local rTrack = animator:LoadAnimation(rAn)
			repeat task.wait() until rTrack.Length > 0
			rTrack:Play()
			task.wait(rTrack.Length)
			rTrack:Stop()
		end
		]]
		task.wait(animationT1.Length)
		animationT1:Stop()
		isSwinging = false
		
		running = false
	end
end)

cavalrySabre.default.Touched:Connect(function(hit)
	if isSwinging then
		--debounce only activates on non terrain
		if not hitDebounce and not hit:IsA("Terrain") and (table.find(justTookDamage, hit.Parent.Name) == nil) then
			table.insert(justTookDamage, hit.Parent.Name)
			hitDebounce = true
			if hit.Parent:FindFirstChild("Humanoid") then
				local humanoid = hit.Parent:FindFirstChild("Humanoid")
				takeDamage:FireServer(humanoid, damageAmount)
			elseif hit:IsA("Accessory") then
				local humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
				takeDamage:FireServer(humanoid, damageAmount)
			elseif hit.Name == "crateHitBox" then
				hitObject:FireServer(hit.Parent, damageAmount)
			end
			task.wait(1)
			hitDebounce = false
		end
	end
end)
