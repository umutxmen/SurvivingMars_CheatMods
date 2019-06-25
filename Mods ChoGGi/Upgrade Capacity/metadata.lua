return PlaceObj("ModDef", {
--~ 	"title", "Upgrade Slots: Visitors/Capacity",
	"title", "Upgrade Capacity",
	"version", 5,
	"version_major", 0,
	"version_minor", 5,
	"saved", 0,
	"image", "Preview.png",
	"id", "ChoGGi_UpgradeSlotsVisitorsCapacity",
	"steam_id", "1767471811",
	"pops_any_uuid", "f73b0344-9d78-4489-91d3-4c42a37d581c",
	"author", "ChoGGi",
	"lua_revision", 245618,
	"code", {
		"Code/Script.lua",
	},
	"TagInterface", true,
	"description", [[Adds upgrades to increase the capacity (also increases electricity consumption) of residences, services, etc.
Existing upgrade for the building == skip these upgrades (it will boost cap of upgrade 2).
]],
})