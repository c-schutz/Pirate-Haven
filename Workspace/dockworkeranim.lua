local humanoid = script.Parent.Humanoid
local character = script.Parent
local animation = script.Parent.InsertedAnimations.Idle1 --default
local animation2 = script.Parent.InsertedAnimations.Idle2 --feet kick

local function getAnimationFromServer(character, animation)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	assert(humanoid, "No Humanoid found!")
	local animator = humanoid:FindFirstChildOfClass("Animator")
	assert(animator, "No Animator found!")
	local weight = math.random(1, 10)
	local animationTrack
	if weight < 3 then
		animationTrack = animator:LoadAnimation(animation2)
		repeat task.wait() until animationTrack.Length > 0 --make sure its fully loaded
	else
		animationTrack = animator:LoadAnimation(animation)
		repeat task.wait() until animationTrack.Length > 0 --make sure its fully loaded
	end

	return animationTrack
end

while task.wait(.1) do
	local aTrack = getAnimationFromServer(character, animation) --load new animation based off weights
	aTrack:Play() --play the randomized animation
	task.wait(aTrack.Length) --wait duration of animation
	aTrack:Stop() --stop previous animation
end