return PlaceObj("ModDef", {
  "title", "Lock Residence v0.2",
  "version", 2,
  "saved", 1548504000,
	"image", "Preview.png",
  "id", "ChoGGi_LockResidence",
  "author", "ChoGGi",
	"steam_id", "1635694550",
  "code", {
		"Code/Script.lua",
		"Code/ModConfig.lua",
	},
	"lua_revision", LuaRevision,
  "description", [[Adds a "Lock Residence" button to the selection panel for colonists, and residences ("Lock Residents").
They can still be kicked out (if you shutdown the building), they just won't change to a new residence if they're locked.

Includes Mod Config Reborn option to force workers to never change residence (may cause issues).]],
})