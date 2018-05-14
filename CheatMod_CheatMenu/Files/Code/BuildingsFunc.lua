local CCodeFuncs = ChoGGi.CodeFuncs
local CComFuncs = ChoGGi.ComFuncs
local CConsts = ChoGGi.Consts
local CInfoFuncs = ChoGGi.InfoFuncs
local CSettingFuncs = ChoGGi.SettingFuncs
local CTables = ChoGGi.Tables
local CMenuFuncs = ChoGGi.MenuFuncs

local UsualIcon = "UI/Icons/Upgrades/home_collective_04.tga"
local UsualIcon2 = "UI/Icons/Sections/storage.tga"
local UsualIcon3 = "UI/Icons/IPButtons/assign_residence.tga"

function CMenuFuncs.AnnoyingSounds_Toggle()
  --make a list
  local ItemList = {
    {text = "Reset",value = "Reset"},
    {text = "SensorTower",value = "SensorTower"},
    {text = "MirrorSphere",value = "MirrorSphere"},
  }

  --callback
  local CallBackFunc = function(choice)
    local function MirrorSphere_Toggle()
      local tab = UICity.labels.MirrorSpheres or empty_table
      for i = 1, #tab do
        PlayFX("Freeze", "end", tab[i])
        PlayFX("Freeze", "start", tab[i])
      end
    end
    local function SensorTower_Toggle()
      local tab = UICity.labels.SensorTower or empty_table
      for i = 1, #tab do
        CCodeFuncs.ToggleWorking(tab[i])
      end
    end

    local value = choice[1].value
    if value == "SensorTower" then
      FXRules.Working.start.SensorTower.any[3] = nil
      RemoveFromRules("Object SensorTower Loop")
      SensorTower_Toggle()
    elseif value == "MirrorSphere" then
      FXRules.Freeze.start.MirrorSphere.any[2] = nil
      FXRules.Freeze.start.any = nil
      RemoveFromRules("Freeze")
      MirrorSphere_Toggle()
    elseif value == "Reset" then
      RebuildFXRules()
      MirrorSphere_Toggle()
      SensorTower_Toggle()
    end

    CComFuncs.MsgPopup(choice[1].text .. ": Stop that bloody bouzouki!",
      "Sounds"
    )
  end

  local hint = "You can only reset all sounds back."
  CCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Annoying Sounds",hint)
end

function CMenuFuncs.SetProtectionRadius()
  local sel = CCodeFuncs.SelObject()
  if not sel or not sel.protect_range then
    CComFuncs.MsgPopup("Select something with a protect_range (MDSLaser/DefenceTower).",
      "Protect",UsualIcon
    )
    return
  end
  local id = sel.encyclopedia_id
  local DefaultSetting = _G[id]:GetDefaultPropertyValue("protect_range")
  local ItemList = {
    {text = " Default: " .. DefaultSetting,value = DefaultSetting},
    {text = 40,value = 40},
    {text = 80,value = 80},
    {text = 160,value = 160},
    {text = 320,value = 320,hint = "Cover the entire map from the centre."},
    {text = 640,value = 640,hint = "Cover the entire map from a corner."},
  }

  if not ChoGGi.UserSettings.BuildingSettings[id] then
    ChoGGi.UserSettings.BuildingSettings[id] = {}
  end

  local hint = DefaultSetting
  local setting = ChoGGi.UserSettings.BuildingSettings[id]
  if setting and setting.protect_range then
    hint = tostring(setting.protect_range)
  end

  local CallBackFunc = function(choice)
    local value = choice[1].value
    if type(value) == "number" then

      local tab = UICity.labels[id] or empty_table
      for i = 1, #tab do
        tab[i].protect_range = value
        tab[i].shoot_range = value * CConsts.guim
      end

      if value == DefaultSetting then
        ChoGGi.UserSettings.BuildingSettings[id].protect_range = nil
      else
        ChoGGi.UserSettings.BuildingSettings[id].protect_range = value
      end

      CSettingFuncs.WriteSettings()
      CComFuncs.MsgPopup(id .. " range is now " .. choice[1].text,
        "Protect",UsualIcon
      )
    end
  end

  hint = "Current: " .. hint .. "\n\nToggle selection to update visible hex grid."
  CCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set Rover Work Radius",hint)
end

function CMenuFuncs.UnlockLockedBuildings()
  local ItemList = {}
  for Key,_ in pairs(DataInstances.BuildingTemplate) do
    if type(Key) == "string" and not GetBuildingTechsStatus(Key) then
      ItemList[#ItemList+1] = {
        text = _InternalTranslate(DataInstances.BuildingTemplate[Key].display_name),
        value = Key
      }
    end
  end

  local CallBackFunc = function(choice)
    for i = 1, #choice do
      pcall(function()
        UnlockBuilding(choice[i].value)
      end)
    end
    CCodeFuncs.BuildMenu_Toggle()
    CComFuncs.MsgPopup("Buildings unlocked: " .. #choice,
      "Unlocked",UsualIcon
    )
  end

  local hint = "Pick the buildings you want to unlock (use Ctrl/Shift for multiple)."
  CCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Unlock Buildings",hint,true)
end

function CMenuFuncs.PipesPillarsSpacing_Toggle()
  CComFuncs.SetConstsG("PipesPillarSpacing",CComFuncs.ValueRetOpp(Consts.PipesPillarSpacing,1000,CConsts.PipesPillarSpacing))
  CComFuncs.SetSavedSetting("PipesPillarSpacing",Consts.PipesPillarSpacing)

  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.PipesPillarSpacing) .. ": Is that a rocket in your pocket?",
    "Buildings"
  )
end

function CMenuFuncs.UnlimitedConnectionLength_Toggle()
  ChoGGi.UserSettings.UnlimitedConnectionLength = not ChoGGi.UserSettings.UnlimitedConnectionLength
  if ChoGGi.UserSettings.UnlimitedConnectionLength then
    GridConstructionController.max_hex_distance_to_allow_build = 1000
  else
    GridConstructionController.max_hex_distance_to_allow_build = 20
  end

  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.UnlimitedConnectionLength) .. ": Is that a rocket in your pocket?",
    "Buildings"
  )
end

function CMenuFuncs.BuildingPower_Toggle()
  local sel = SelectedObj
  if not sel or not sel.electricity_consumption then
    CComFuncs.MsgPopup("You need to select something that uses electricity.",
      "Buildings",UsualIcon
    )
    return
  end
  local id = sel.encyclopedia_id

  if not ChoGGi.UserSettings.BuildingSettings[id] then
    ChoGGi.UserSettings.BuildingSettings[id] = {}
  end

  local setting = ChoGGi.UserSettings.BuildingSettings[id]
  local amount
  if setting.nopower then
    setting.nopower = nil
    amount = DataInstances.BuildingTemplate[id].electricity_consumption
  else
    setting.nopower = true
    amount = 0
  end

  local tab = UICity.labels[id] or empty_table
  for i = 1, #tab do
    if tab[i].modifications.electricity_consumption then
      if amount == 0 then
      if tab[i].modifications.electricity_consumption then
        local mod = tab[i].modifications.electricity_consumption[1]
        tab[i].ChoGGi_mod_electricity_consumption = {
          amount = mod.amount,
          percent = mod.percent
        }
      mod:Change(0,0)
    end
      else
        if tab[i].ChoGGi_mod_electricity_consumption then
          local mod = tab[i].modifications.electricity_consumption[1]
          local orig = tab[i].ChoGGi_mod_electricity_consumption
          mod:Change(orig.amount,orig.percent)
          tab[i].ChoGGi_mod_electricity_consumption = nil
        end
      end
    end
    tab[i]:SetBase("electricity_consumption", amount)
  end

  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(id .. " power consumption: " .. amount,"Buildings")
end

function CMenuFuncs.SetMaxChangeOrDischarge()
  local sel = SelectedObj
  if not sel or (not sel.base_air_capacity and not sel.base_water_capacity and not sel.base_capacity) then
    CComFuncs.MsgPopup("You need to select something that has capacity (air/water/elec).",
      "Buildings",UsualIcon
    )
    return
  end
  local id = sel.encyclopedia_id
  local r = CConsts.ResourceScale

  --get type of capacity
  local CapType
  if sel.base_air_capacity then
    CapType = "air"
  elseif sel.base_water_capacity then
    CapType = "water"
  elseif sel.electricity and sel.electricity.storage_capacity then
    CapType = "electricity"
  end
  --probably selected something with colonists
  if not CapType then
    return
  end

  --get default amount
  local template = DataInstances.BuildingTemplate[id]
  local DefaultSettingC = template["max_" .. CapType .. "_charge"] / r
  local DefaultSettingD = template["max_" .. CapType .. "_discharge"] / r

  local ItemList = {
    {text = " Defaults",value = 3.1415926535,hint = "Charge: " .. DefaultSettingC .. " / Discharge: " .. DefaultSettingD},
    {text = 25,value = 25},
    {text = 50,value = 50},
    {text = 75,value = 75},
    {text = 100,value = 100},
    {text = 250,value = 250},
    {text = 500,value = 500},
    {text = 1000,value = 1000},
    {text = 2500,value = 2500},
    {text = 5000,value = 5000},
    {text = 10000,value = 10000},
  }

  --check if there's an entry for building
  if not ChoGGi.UserSettings.BuildingSettings[id] then
    ChoGGi.UserSettings.BuildingSettings[id] = {}
  end

  local hint = "charge: " .. DefaultSettingC .. " / discharge: " .. DefaultSettingD
  local setting = ChoGGi.UserSettings.BuildingSettings[id]
  if setting then
    if setting.charge and setting.discharge then
      hint = "charge: " .. tostring(setting.charge / r) .. " / discharge: " .. tostring(setting.discharge / r)
    elseif setting.charge then
      hint = tostring(setting.charge / r)
    elseif setting.discharge then
      hint = tostring(setting.discharge / r)
    end
  end

  local CallBackFunc = function(choice)
    local value = choice[1].value
    local check1 = choice[1].check1
    local check2 = choice[1].check2

    if not check1 and not check2 then
      CComFuncs.MsgPopup("Pick a checkbox or two next time...","Rate",UsualIcon2)
      return
    end

    if type(value) == "number" then
      local numberC = value * r
      local numberD = value * r

      if value == 3.1415926535 then
        if check1 then
          setting.charge = nil
          numberC = DefaultSettingC * r
        end
        if check2 then
          setting.discharge = nil
          numberD = DefaultSettingD * r
        end
      else
        if check1 then
          setting.charge = numberC
        end
        if check2 then
          setting.discharge = numberD
        end
      end

      --updating time
      if CapType == "electricity" then
        local tab = UICity.labels.Power or empty_table
        for i = 1, #tab do
          if tab[i].encyclopedia_id == id then
            if check1 then
              tab[i][CapType].max_charge = numberC
              tab[i]["max_" .. CapType .. "_charge"] = numberC
            end
            if check2 then
              tab[i][CapType].max_discharge = numberD
              tab[i]["max_" .. CapType .. "_discharge"] = numberD
            end
            CCodeFuncs.ToggleWorking(tab[i])
          end
        end
      else --water and air
        local tab = UICity.labels["Life-Support"] or empty_table
        for i = 1, #tab do
          if tab[i].encyclopedia_id == id then
            if check1 then
              tab[i][CapType].max_charge = numberC
              tab[i]["max_" .. CapType .. "_charge"] = numberC
            end
            if check2 then
              tab[i][CapType].max_discharge = numberD
              tab[i]["max_" .. CapType .. "_discharge"] = numberD
            end
            CCodeFuncs.ToggleWorking(tab[i])
          end
        end
      end

      CSettingFuncs.WriteSettings()
      CComFuncs.MsgPopup(id .. " rate is now " .. choice[1].text,
        "Rate",UsualIcon2
      )
    end
  end

  hint = "Current rate: " .. hint
  CCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set " .. id .. " Dis/Charge Rates",hint,nil,"Charge","Change charge rate","Discharge","Change discharge rate")
end

function CMenuFuncs.UseLastOrientation_Toggle()
  ChoGGi.UserSettings.UseLastOrientation = not ChoGGi.UserSettings.UseLastOrientation

  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.UseLastOrientation) .. " Building Orientation",
    "Buildings"
  )
end

function CMenuFuncs.FarmShiftsAllOn()
  local tab = UICity.labels.BaseFarm or empty_table
  for i = 1, #tab do
    tab[i].closed_shifts[1] = false
    tab[i].closed_shifts[2] = false
    tab[i].closed_shifts[3] = false
  end
  --BaseFarm doesn't include FungalFarm...
  tab = UICity.labels.FungalFarm or empty_table
  for i = 1, #tab do
    tab[i].closed_shifts[1] = false
    tab[i].closed_shifts[2] = false
    tab[i].closed_shifts[3] = false
  end

  CComFuncs.MsgPopup("Well, I been working in a coal mine\nGoing down, down\nWorking in a coal mine\nWhew, about to slip down",
    "Farms","UI/Icons/Sections/Food_2.tga",true
  )
end

function CMenuFuncs.SetProductionAmount()
  local sel = SelectedObj
  if not sel or (not sel.base_air_production and not sel.base_water_production and not sel.base_electricity_production and not sel.producers) then
    CComFuncs.MsgPopup("Select something that produces (air,water,electricity,other).",
      "Buildings",UsualIcon2
    )
    return
  end
  local id = sel.encyclopedia_id

  --get type of producer
  local ProdType
  if sel.base_air_production then
    ProdType = "air"
  elseif sel.base_water_production then
    ProdType = "water"
  elseif sel.base_electricity_production then
    ProdType = "electricity"
  elseif sel.producers then
    ProdType = "other"
  end

  --get base amount
  local r = CConsts.ResourceScale
  local DefaultSetting
  if ProdType == "other" then
    DefaultSetting = sel.base_production_per_day1 / r
  else
    DefaultSetting = sel["base_" .. ProdType .. "_production"] / r
  end

  local ItemList = {
    {text = " Default: " .. DefaultSetting,value = DefaultSetting},
    {text = 25,value = 25},
    {text = 50,value = 50},
    {text = 75,value = 75},
    {text = 100,value = 100},
    {text = 250,value = 250},
    {text = 500,value = 500},
    {text = 1000,value = 1000},
    {text = 2500,value = 2500},
    {text = 5000,value = 5000},
    {text = 10000,value = 10000},
    {text = 25000,value = 25000},
    {text = 50000,value = 50000},
    {text = 100000,value = 100000},
  }

  --check if there's an entry for building
  if not ChoGGi.UserSettings.BuildingSettings[id] then
    ChoGGi.UserSettings.BuildingSettings[id] = {}
  end

  local hint = DefaultSetting
  local setting = ChoGGi.UserSettings.BuildingSettings[id]
  if setting and setting.production then
    hint = tostring(setting.production / r)
  end

  local CallBackFunc = function(choice)
    local value = choice[1].value
    if type(value) == "number" then
      local amount = value * r

      --setting we use to actually update prod
      if value == DefaultSetting then
        --remove setting as we reset building type to default (we don't want to call it when we place a new building if nothing is going to be changed)
        ChoGGi.UserSettings.BuildingSettings[id].production = nil
      else
        --update/create saved setting
        ChoGGi.UserSettings.BuildingSettings[id].production = amount
      end

      --all this just to update the displayed amount :)
      local function SetProd(Label)
        local tab = UICity.labels[Label] or empty_table
        for i = 1, #tab do
          if tab[i].encyclopedia_id == id then
            tab[i][ProdType]:SetProduction()
          end
        end
      end
      if ProdType == "electricity" then
        --electricity
        SetProd("Power")
      elseif ProdType == "water" or ProdType == "air" then
        --water/air
        SetProd("Life-Support")
      else --other prod

        local function SetProdOther(Label)
          local tab = UICity.labels[Label] or empty_table
          for i = 1, #tab do
            if tab[i].encyclopedia_id == id then
              tab[i]:GetProducerObj().production_per_day = amount
              tab[i]:GetProducerObj():Produce(amount)
            end
          end
        end
        --extractors/factories
        SetProdOther("Production")
        --moholemine/theexvacator
        SetProdOther("Wonders")
        --farms
        if id:find("Farm") then
          SetProdOther("BaseFarm")
          SetProdOther("FungalFarm")
        end
      end

    end

    CSettingFuncs.WriteSettings()
    CComFuncs.MsgPopup(id .. " Production is now " .. choice[1].text,
      "Buildings",UsualIcon2
    )
  end

  CCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Set " .. id .. " Production Amount","Current production: " .. hint)
end

function CMenuFuncs.FullyAutomatedBuildings()
  local ItemList = {
    {text = " Disable",value = "disable"},
    {text = 100,value = 100},
    {text = 150,value = 150},
    {text = 250,value = 250},
    {text = 500,value = 500},
    {text = 1000,value = 1000},
    {text = 2500,value = 2500},
    {text = 5000,value = 5000},
    {text = 10000,value = 10000},
    {text = 25000,value = 25000},
    {text = 50000,value = 50000},
    {text = 100000,value = 100000},
  }

  local CallBackFunc = function(choice)
    local value = choice[1].value
    if type(value) == "number" then

      local tab = UICity.labels.BuildingNoDomes or empty_table
      for i = 1, #tab do
        if tab[i].base_max_workers then
          tab[i].max_workers = 0
          tab[i].automation = 1
          tab[i].auto_performance = value
        end
      end

      ChoGGi.UserSettings.FullyAutomatedBuildings = value
    else

      local tab = UICity.labels.BuildingNoDomes or empty_table
      for i = 1, #tab do
        if tab[i].base_max_workers then
          tab[i].max_workers = nil
          tab[i].automation = nil
          tab[i].auto_performance = nil
        end
      end

      ChoGGi.UserSettings.FullyAutomatedBuildings = false
    end

    CSettingFuncs.WriteSettings()
    CComFuncs.MsgPopup(choice[1].text .. "\nI presume the PM's in favour of the scheme because it'll reduce unemployment.",
      "Buildings",UsualIcon,true
    )
  end

  CCodeFuncs.FireFuncAfterChoice(CallBackFunc,ItemList,"Fully Automated Buildings: performance","Sets performance of all automated buildings")
end

--used to add or remove traits from schools/sanitariums
function CMenuFuncs.BuildingsSetAll_Traits(Building,Traits,Bool)
  local Buildings = UICity.labels[Building] or 0
  for i = 1,#Buildings do
    local Obj = Buildings[i]
    for j = 1,#Traits do
      if Bool == true then
        Obj:SetTrait(j,nil)
      else
        Obj:SetTrait(j,Traits[j])
      end
    end
  end
end

function CMenuFuncs.SchoolTrainAll_Toggle()
  ChoGGi.UserSettings.SchoolTrainAll = not ChoGGi.UserSettings.SchoolTrainAll
  if ChoGGi.UserSettings.SchoolTrainAll then
    CMenuFuncs.BuildingsSetAll_Traits("School",CTables.PositiveTraits)
  else
    CMenuFuncs.BuildingsSetAll_Traits("School",CTables.PositiveTraits,true)
  end
  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.SchoolTrainAll) .. "\nYou keep your work station so clean, Jerome.\nIt's next to godliness. Isn't that what they say?",
    "School",UsualIcon,true
  )
end

function CMenuFuncs.SanatoriumCureAll_Toggle()
  ChoGGi.UserSettings.SanatoriumCureAll = not ChoGGi.UserSettings.SanatoriumCureAll
  if ChoGGi.UserSettings.SanatoriumCureAll then
    CMenuFuncs.BuildingsSetAll_Traits("Sanatorium",CTables.NegativeTraits)
  else
    CMenuFuncs.BuildingsSetAll_Traits("Sanatorium",CTables.NegativeTraits,true)
  end
  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.SanatoriumCureAll) .. "\nThere's more vodka in this piss than there is piss.",
    "Sanatorium",UsualIcon,true
  )
end

function CMenuFuncs.ShowAllTraits_Toggle()
  if #g_SchoolTraits == 18 then
    g_SchoolTraits = CTables.SchoolTraits
    g_SanatoriumTraits = CTables.SanatoriumTraits
  else
    g_SchoolTraits = CTables.PositiveTraits
    g_SanatoriumTraits = CTables.NegativeTraits
  end

  CComFuncs.MsgPopup(#g_SchoolTraits .. ": Good for what ails you",
    "Traits","UI/Icons/Upgrades/factory_ai_04.tga"
  )
end

function CMenuFuncs.SanatoriumSchoolShowAll()
  ChoGGi.UserSettings.SanatoriumSchoolShowAll = not ChoGGi.UserSettings.SanatoriumSchoolShowAll

	Sanatorium.max_traits = CComFuncs.ValueRetOpp(Sanatorium.max_traits,3,#CTables.NegativeTraits)
	School.max_traits = CComFuncs.ValueRetOpp(School.max_traits,3,#CTables.PositiveTraits)

  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.SanatoriumSchoolShowAll) .. " Good for what ails you",
    "Buildings","UI/Icons/Upgrades/superfungus_03.tga"
  )
end

function CMenuFuncs.MaintenanceBuildingsFree_Toggle()
  ChoGGi.UserSettings.RemoveMaintenanceBuildUp = not ChoGGi.UserSettings.RemoveMaintenanceBuildUp
  local tab = UICity.labels.Building or empty_table
  for i = 1, #tab do

    if tab[i].base_maintenance_build_up_per_hr then
      if ChoGGi.UserSettings.RemoveMaintenanceBuildUp then
        tab[i].maintenance_build_up_per_hr = -10000
      else
        tab[i].maintenance_build_up_per_hr = nil
      end
    end
  end

  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.RemoveMaintenanceBuildUp) .. " The spice must flow!",
    "Buildings",
    "UI/Icons/Sections/dust.tga"
  )
end

function CMenuFuncs.MoistureVaporatorPenalty_Toggle()
  const.MoistureVaporatorRange = CComFuncs.NumRetBool(const.MoistureVaporatorRange,0,CConsts.MoistureVaporatorRange)
  const.MoistureVaporatorPenaltyPercent = CComFuncs.NumRetBool(const.MoistureVaporatorPenaltyPercent,0,CConsts.MoistureVaporatorPenaltyPercent)
  CComFuncs.SetSavedSetting("MoistureVaporatorRange",const.MoistureVaporatorRange)
  CComFuncs.SetSavedSetting("MoistureVaporatorRange",const.MoistureVaporatorPenaltyPercent)
  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.MoistureVaporatorRange) .. ": All right, pussy, pussy, pussy! Come on in pussy lovers! Here at the Titty Twister we're slashing pussy in half! Give us an offer on our vast selection of pussy, this is a pussy blow out! All right, we got white pussy, black pussy, Spanish pussy, yellow pussy, we got hot pussy, cold pussy, we got wet pussy, we got... smelly pussy, we got hairy pussy, bloody pussy, we got snappin' pussy, we got silk pussy, velvet pussy, Naugahyde pussy, we even got horse pussy, dog pussy, chicken pussy! Come on, you want pussy, come on in, pussy lovers! If we don't got it, you don't want it! Come on in, pussy lovers!",
    "Buildings","UI/Icons/Upgrades/zero_space_04.tga",true
  )
end

function CMenuFuncs.CropFailThreshold_Toggle()
  Consts.CropFailThreshold = CComFuncs.NumRetBool(Consts.CropFailThreshold,0,CConsts.CropFailThreshold)
  CComFuncs.SetSavedSetting("CropFailThreshold",Consts.CropFailThreshold)
  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.CropFailThreshold) .. "\nSo, er, we the crew of the Eagle 5, if we do encounter, make first contact with alien beings, it is a friendship greeting from the children of our small but great planet of Potatoho.",
    "Buildings","UI/Icons/Sections/Food_1.tga",true
  )
end

function CMenuFuncs.CheapConstruction_Toggle()

  CComFuncs.SetConstsG("Metals_cost_modifier",CComFuncs.ValueRetOpp(Consts.Metals_cost_modifier,-100,CConsts.Metals_cost_modifier))
  CComFuncs.SetConstsG("Metals_dome_cost_modifier",CComFuncs.ValueRetOpp(Consts.Metals_dome_cost_modifier,-100,CConsts.Metals_dome_cost_modifier))
  CComFuncs.SetConstsG("PreciousMetals_cost_modifier",CComFuncs.ValueRetOpp(Consts.PreciousMetals_cost_modifier,-100,CConsts.PreciousMetals_cost_modifier))
  CComFuncs.SetConstsG("PreciousMetals_dome_cost_modifier",CComFuncs.ValueRetOpp(Consts.PreciousMetals_dome_cost_modifier,-100,CConsts.PreciousMetals_dome_cost_modifier))
  CComFuncs.SetConstsG("Concrete_cost_modifier",CComFuncs.ValueRetOpp(Consts.Concrete_cost_modifier,-100,CConsts.Concrete_cost_modifier))
  CComFuncs.SetConstsG("Concrete_dome_cost_modifier",CComFuncs.ValueRetOpp(Consts.Concrete_dome_cost_modifier,-100,CConsts.Concrete_dome_cost_modifier))
  CComFuncs.SetConstsG("Polymers_dome_cost_modifier",CComFuncs.ValueRetOpp(Consts.Polymers_dome_cost_modifier,-100,CConsts.Polymers_dome_cost_modifier))
  CComFuncs.SetConstsG("Polymers_cost_modifier",CComFuncs.ValueRetOpp(Consts.Polymers_cost_modifier,-100,CConsts.Polymers_cost_modifier))
  CComFuncs.SetConstsG("Electronics_cost_modifier",CComFuncs.ValueRetOpp(Consts.Electronics_cost_modifier,-100,CConsts.Electronics_cost_modifier))
  CComFuncs.SetConstsG("Electronics_dome_cost_modifier",CComFuncs.ValueRetOpp(Consts.Electronics_dome_cost_modifier,-100,CConsts.Electronics_dome_cost_modifier))
  CComFuncs.SetConstsG("MachineParts_cost_modifier",CComFuncs.ValueRetOpp(Consts.MachineParts_cost_modifier,-100,CConsts.MachineParts_cost_modifier))
  CComFuncs.SetConstsG("MachineParts_dome_cost_modifier",CComFuncs.ValueRetOpp(Consts.MachineParts_dome_cost_modifier,-100,CConsts.MachineParts_dome_cost_modifier))
  CComFuncs.SetConstsG("rebuild_cost_modifier",CComFuncs.ValueRetOpp(Consts.rebuild_cost_modifier,-100,CConsts.rebuild_cost_modifier))

  CComFuncs.SetSavedSetting("Metals_cost_modifier",Consts.Metals_cost_modifier)
  CComFuncs.SetSavedSetting("Metals_dome_cost_modifier",Consts.Metals_dome_cost_modifier)
  CComFuncs.SetSavedSetting("PreciousMetals_cost_modifier",Consts.PreciousMetals_cost_modifier)
  CComFuncs.SetSavedSetting("PreciousMetals_dome_cost_modifier",Consts.PreciousMetals_dome_cost_modifier)
  CComFuncs.SetSavedSetting("Concrete_cost_modifier",Consts.Concrete_cost_modifier)
  CComFuncs.SetSavedSetting("Concrete_dome_cost_modifier",Consts.Concrete_dome_cost_modifier)
  CComFuncs.SetSavedSetting("Polymers_cost_modifier",Consts.Polymers_cost_modifier)
  CComFuncs.SetSavedSetting("Polymers_dome_cost_modifier",Consts.Polymers_dome_cost_modifier)
  CComFuncs.SetSavedSetting("Electronics_cost_modifier",Consts.Electronics_cost_modifier)
  CComFuncs.SetSavedSetting("Electronics_dome_cost_modifier",Consts.Electronics_dome_cost_modifier)
  CComFuncs.SetSavedSetting("MachineParts_cost_modifier",Consts.MachineParts_cost_modifier)
  CComFuncs.SetSavedSetting("MachineParts_dome_cost_modifier",Consts.MachineParts_dome_cost_modifier)
  CComFuncs.SetSavedSetting("rebuild_cost_modifier",Consts.rebuild_cost_modifier)
  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.Metals_cost_modifier) .. ": Get yourself a beautiful showhome (even if it falls apart after you move in)",
    "Buildings","UI/Icons/Upgrades/build_2.tga"
  )
end

function CMenuFuncs.BuildingDamageCrime_Toggle()
  CComFuncs.SetConstsG("CrimeEventSabotageBuildingsCount",CComFuncs.ToggleBoolNum(Consts.CrimeEventSabotageBuildingsCount))
  CComFuncs.SetConstsG("CrimeEventDestroyedBuildingsCount",CComFuncs.ToggleBoolNum(Consts.CrimeEventDestroyedBuildingsCount))

  CComFuncs.SetSavedSetting("CrimeEventSabotageBuildingsCount",Consts.CrimeEventSabotageBuildingsCount)
  CComFuncs.SetSavedSetting("CrimeEventDestroyedBuildingsCount",Consts.CrimeEventDestroyedBuildingsCount)
  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.CrimeEventSabotageBuildingsCount) .. "\nWe were all feeling a bit shagged and fagged and fashed, it having been an evening of some small energy expenditure, O my brothers. So we got rid of the auto and stopped off at the Korova for a nightcap.",
    "Buildings","UI/Icons/Notifications/fractured_dome.tga",true
  )
end

function CMenuFuncs.CablesAndPipesNoBreak_Toggle()
  ChoGGi.UserSettings.BreakChanceCablePipe = not ChoGGi.UserSettings.BreakChanceCablePipe

  const.BreakChanceCable = CComFuncs.ValueRetOpp(const.BreakChanceCable,600,10000000)
  const.BreakChancePipe = CComFuncs.ValueRetOpp(const.BreakChancePipe,600,10000000)

  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.BreakChanceCablePipe) .. " Aliens? We gotta deal with aliens too?",
    "Cables & Pipes","UI/Icons/Notifications/timer.tga"
  )
end

function CMenuFuncs.RemoveBuildingLimits_Toggle()
  ChoGGi.UserSettings.RemoveBuildingLimits = not ChoGGi.UserSettings.RemoveBuildingLimits

  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.RemoveBuildingLimits) .. " No no I said over there.",
    "Buildings","UI/Icons/Upgrades/zero_space_04.tga"
  )
end

function CMenuFuncs.Building_wonder_Toggle()
  ChoGGi.UserSettings.Building_wonder = not ChoGGi.UserSettings.Building_wonder
  if ChoGGi.UserSettings.Building_wonder then
    local tab = DataInstances.BuildingTemplate or empty_table
    for i = 1, #tab do
      tab[i].wonder = false
    end
  end

  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.Building_wonder) .. " Unlimited Wonders\n(restart to set disabled)",
    "Buildings",UsualIcon3
  )
end

function CMenuFuncs.Building_dome_spot_Toggle()
  ChoGGi.UserSettings.Building_dome_spot = not ChoGGi.UserSettings.Building_dome_spot
  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.Building_dome_spot) .. " Freedom for spires!\n(restart to set disabled)",
    "Buildings",UsualIcon3
  )
end

function CMenuFuncs.Building_instant_build_Toggle()
  ChoGGi.UserSettings.Building_instant_build = not ChoGGi.UserSettings.Building_instant_build
  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.Building_instant_build) .. " Building Instant Build\n(restart to set disabled).",
    "Buildings",UsualIcon3
  )
end

function CMenuFuncs.Building_hide_from_build_menu_Toggle()
  ChoGGi.UserSettings.Building_hide_from_build_menu = not ChoGGi.UserSettings.Building_hide_from_build_menu
  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.Building_hide_from_build_menu) .. " Buildings hidden\n(restart to toggle).",
    "Buildings",UsualIcon3
  )
end
function CMenuFuncs.CablesAndPipesInstant_Toggle()
  CComFuncs.SetConstsG("InstantCables",CComFuncs.ToggleBoolNum(Consts.InstantCables))
  CComFuncs.SetConstsG("InstantPipes",CComFuncs.ToggleBoolNum(Consts.InstantPipes))

  CComFuncs.SetSavedSetting("InstantCables",Consts.InstantCables)
  CComFuncs.SetSavedSetting("InstantPipes",Consts.InstantPipes)
  CSettingFuncs.WriteSettings()
  CComFuncs.MsgPopup(tostring(ChoGGi.UserSettings.InstantCables) .. " Aliens? We gotta deal with aliens too?",
    "Cables & Pipes","UI/Icons/Notifications/timer.tga"
  )
end
