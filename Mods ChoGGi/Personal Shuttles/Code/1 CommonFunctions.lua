local Concat = PersonalShuttles.ComFuncs.Concat

local type,select,pcall,table,tostring = type,select,pcall,table,tostring

local GetInGameInterface = GetInGameInterface
local _InternalTranslate = _InternalTranslate
local AsyncRand = AsyncRand
local OpenXDialog = OpenXDialog

--~ local g_Classes = g_Classes

-- I want a translate func to always return a string
function PersonalShuttles.ComFuncs.Trans(...)
  local trans
  local vararg = {...}
  -- just in case a
  pcall(function()
    if type(vararg[1]) == "userdata" then
      trans = _InternalTranslate(table.unpack(vararg))
    else
      trans = _InternalTranslate(T(vararg))
    end
  end)
  -- just in case b
  if type(trans) ~= "string" then
    if type(vararg[2]) == "string" then
      return vararg[2]
    end
    -- done fucked up (just in case c)
    return Concat(vararg[1]," < Missing locale string id")
  end
  return trans
end
local T = PersonalShuttles.ComFuncs.Trans

-- backup orginal function for later use (checks if we already have a backup, or else problems)
function PersonalShuttles.ComFuncs.SaveOrigFunc(ClassOrFunc,Func)
  local PersonalShuttles = PersonalShuttles
  if Func then
    local newname = Concat(ClassOrFunc,"_",Func)
    if not PersonalShuttles.OrigFuncs[newname] then
--~       PersonalShuttles.OrigFuncs[newname] = _G[ClassOrFunc][Func]
      PersonalShuttles.OrigFuncs[newname] = g_Classes[ClassOrFunc][Func]
    end
  else
    if not PersonalShuttles.OrigFuncs[ClassOrFunc] then
      PersonalShuttles.OrigFuncs[ClassOrFunc] = _G[ClassOrFunc]
    end
  end
end

function PersonalShuttles.ComFuncs.MsgPopup(Msg,Title,Icon,Size)
  local PersonalShuttles = PersonalShuttles
  Icon = type(tostring(Icon):find(".tga")) == "number" and Icon or Concat(PersonalShuttles.MountPath,"TheIncal.tga")
  --eh, it needs something for the id, so I can fiddle with it later
  local id = AsyncRand()
  --build our popup
  local timeout = 10000
  if Size then
    timeout = 30000
  end
  local params = {
    expiration=timeout, --{expiration=99999999999999999}
    --dismissable=false,
  }
  local cycle_objs = params.cycle_objs
  local dlg = GetXDialog("OnScreenNotificationsDlg")
  if not dlg then
    if not GetInGameInterface() then
      return
    end
    dlg = OpenXDialog("OnScreenNotificationsDlg", GetInGameInterface())
  end
  local data = {
    id = id,
    --name = id,
    title = tostring(Title or ""),
    text = tostring(Msg or T(3718--[[NONE--]])),
    image = Icon
  }
  table.set_defaults(data, params)
  table.set_defaults(data, g_Classes.OnScreenNotificationPreset)

  CreateRealTimeThread(function()
		local popup = g_Classes.OnScreenNotification:new({}, dlg.idNotifications)
		popup:FillData(data, nil, params, cycle_objs)
		popup:Open()
		dlg:ResolveRelativeFocusOrder()
  end)
end