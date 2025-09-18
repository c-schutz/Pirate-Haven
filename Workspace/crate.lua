local crate = script.Parent
local hBox = crate.crateHitBox
local debounce = false

--initialize DamageCount and Durability
crate:SetAttribute("DamageCount", 0)
crate:SetAttribute("Durability", 50)

crate:GetAttributeChangedSignal("DamageCount"):Connect(function()
	local remainingDurability = crate:GetAttribute("Durability") - crate:GetAttribute("DamageCount")
	if remainingDurability <= 0 then
		local explosion = Instance.new("Explosion")
		crate.crateTop:Destroy()
		explosion.ExplosionType = Enum.ExplosionType.NoCraters
		explosion.Position = crate.crateRoot.Position
		explosion.BlastRadius = 3
		explosion.BlastPressure = 50000
		explosion.Parent = crate
		task.wait(7)
		crate:Destroy()
	end
end)


--end of first script

local crate = script.Parent
local hBox = crate.crateHitBox
local debounce = false

hBox.Touched:Connect(function()
	if not debounce then
		debounce = true
		crate:SetAttribute("DamageCount", crate:GetAttribute("DamageCount") + 10)
		task.wait(1)
		debounce = false
	end
end)