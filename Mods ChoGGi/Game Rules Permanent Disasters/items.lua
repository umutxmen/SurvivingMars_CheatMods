-- See LICENSE for terms

local table_concat = table.concat
local T = T

local properties = {
	-- Meteors
	PlaceObj("ModItemOptionToggle", {
		"name", "MeteorsOverkill",
		"DisplayName", table_concat(T(4146, "Meteors") .. T(": ") .. T(302535920011606, "Overkill")),
		"Help", T(302535920011607, "Lotta Meteors!\n\n<red>You've been warned...</red>"),
		"DefaultValue", false,
	}),
	PlaceObj("ModItemOptionToggle", {
		"name", "MeteorsNoDeposits",
		"DisplayName", table_concat(T(4146, "Meteors") .. T(": ") .. T(302535920011608, "No Deposits")),
		"Help", T(302535920011609, "Enable this option to not have any goodies dropped off.\nThis will override all Meteors!"),
		"DefaultValue", false,
	}),
	-- Dust Storms
	PlaceObj("ModItemOptionToggle", {
		"name", "DustStormsAllowRockets",
		"DisplayName", table_concat(T(4144, "Dust Storms") .. T(": ") .. T(302535920011612, "Allow Rockets")),
		"Help", T(302535920011613, "Allow rockets to take off and land."),
		"DefaultValue", false,
	}),
	PlaceObj("ModItemOptionNumber", {
		"name", "DustStormsMOXIEPerformance",
		"DisplayName", table_concat(T(4144, "Dust Storms") .. T(": ") .. T(302535920011614, "MOXIE Performance")),
		"Help", T(302535920011615, "Set the negative performance of MOXIEs during dust storms (higher = worse for you)."),
		"DefaultValue", 75,
		"MinValue", 0,
		"MaxValue", 100,
	}),
	PlaceObj("ModItemOptionNumber", {
		"name", "DustStormsElectrostatic",
		"DisplayName", table_concat(T(4144, "Dust Storms") .. T(": ") .. T(302535920011616, "Electrostatic Storm")),
		"Help", T(302535920011617, "Chance of an electrostatic storm (lightning strikes)."),
		"DefaultValue", DataInstances.MapSettings_DustStorm.DustStorm_VeryHigh.electrostatic or 5,
		"MinValue", 0,
		"MaxValue", 100,
	}),
	PlaceObj("ModItemOptionNumber", {
		"name", "DustStormsGreatStorm",
		"DisplayName", table_concat(T(4144, "Dust Storms") .. T(": ") .. T(302535920011618, "Great Storm")),
		"Help", T(302535920011619, "Chance of a great storm (turbines spin faster?)."),
		"DefaultValue", DataInstances.MapSettings_DustStorm.DustStorm_VeryHigh.great or 15,
		"MinValue", 0,
		"MaxValue", 100,
	}),
	-- Dust Devils
	PlaceObj("ModItemOptionNumber", {
		"name", "DustDevilsTwisterAmount",
		"DisplayName", table_concat(T(4142, "Dust Devils") .. T(": ") .. T(302535920011620, "Twister Amount")),
		"Help", T(302535920011621, "Minimum amount of twisters on the map (max is 2 * amount)."),
		"DefaultValue", 4,
		"MinValue", 1,
		"MaxValue", 100,
	}),
	PlaceObj("ModItemOptionNumber", {
		"name", "DustDevilsTwisterMaxAmount",
		"DisplayName", table_concat(T(4142, "Dust Devils") .. T(": ") .. T(302535920011620, "Twister Amount") .. " " .. T(8780, "MAX")),
		"Help", T(302535920011634, "If you want to set the max (0 to ignore)."),
		"DefaultValue", 0,
		"MinValue", 0,
		"MaxValue", 100,
	}),
	PlaceObj("ModItemOptionNumber", {
		"name", "DustDevilsElectrostatic",
		"DisplayName", table_concat(T(4142, "Dust Devils") .. T(": ") .. T(302535920011622, "Electrostatic")),
		"Help", T(302535920011623, "Chance of electrostatic dust devil (drains drone batteries)."),
		"DefaultValue", MapSettings_DustDevils.electro_chance or 5,
		"MinValue", 0,
		"MaxValue", 100,
	}),
}

local CmpLower = CmpLower
local _InternalTranslate = _InternalTranslate
table.sort(properties, function(a, b)
	return CmpLower(_InternalTranslate(a.DisplayName), _InternalTranslate(b.DisplayName))
end)

return properties
