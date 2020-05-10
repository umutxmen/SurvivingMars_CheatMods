-- See LICENSE for terms

local IsValid = IsValid
local SelectionArrowAdd = SelectionArrowAdd
local SuspendPassEdits = SuspendPassEdits
local ResumePassEdits = ResumePassEdits
local drones = {}
local c = 0

local function AddArrows(obj, func, ...)
	table.iclear(drones)
	c = 0
	local cc = obj.command_centers or ""
	for i = 1, #cc do
		local hub_drones = cc[i].drones or ""
		for j = 1, #hub_drones do
			local drone = hub_drones[j]
			if IsValid(drone.target)
				and drone.target.handle == obj.handle
			then
				c = c + 1
				drones[c] = drone
			end
		end
	end
	SuspendPassEdits("ChoGGi.ShowDronesConstructionSite.OnSelected")
	SelectionArrowAdd(drones)
	ResumePassEdits("ChoGGi.ShowDronesConstructionSite.OnSelected")

	if func then
		return func(obj, ...)
	end
end

local orig_Building_OnSelected = Building.OnSelected
function Building:OnSelected(...)
	return AddArrows(self, orig_Building_OnSelected, ...)
end
