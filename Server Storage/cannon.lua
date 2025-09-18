--cannon variables
local cannon = script.Parent
local barrelPos = cannon.barrelExit.Position
local endPos = cannon.endPos.Position
local anchorPosition = cannon.anchor.Position


local tweenCannonball = function(cBall)
	
	--set up bezier curve
	local p1 = barrelPos
	local p2 = endPos
	local p3 = anchorPosition
	for i = 0, 100, .02 do
		local interpol1 = p1:Lerp(p3, i)
		local interpol2 = p3:Lerp(p2, i)
		local interpol3 = interpol1:Lerp(interpol2, i)
		cBall.Position = interpol3
		task.wait()
	end
	
end

while task.wait(math.random(1, 4)) do
	--create cannonball object
	local cannonBall = game.ReplicatedStorage.model.cannonball:Clone()
	cannonBall.Parent = workspace
	cannonBall.Position = barrelPos
	
	local cr = coroutine.wrap(tweenCannonball)
	cr(cannonBall)
	
	cannonBall.Touched:Connect(function(hit)
		if hit.Name ~= "cannonMesh" then
			task.wait(.1)
			cannonBall:Destroy()
		end
	end)
end