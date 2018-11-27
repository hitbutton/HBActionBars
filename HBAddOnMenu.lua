local version = 3
if type(HBAddOnMenu_Version)=="number" and HBAddOnMenu_Version >= version then
  return
end
HBAddOnMenu_Version = version
HBAddOnMenu = HBAddOnMenu or AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDB-2.0", "FuBarPlugin-2.0")
if not HBAddOnMenu.db then
  HBAddOnMenu:RegisterDB("HBAddOnMenuDB")
end
Dewdrop = Dewdrop or AceLibrary("Dewdrop-2.0")
HBAddOnMenu.hasIcon = true
HBAddOnMenu.title = "HitButton AddOn Menu"
HBAddOnMenu.cannotDetachTooltip = true
HBAddOnMenu.hasNoColor = true
HBADDONMENU_REGISTRY = HBADDONMENU_REGISTRY or {}

function HBAddOnMenu:RegisterAddOn(addon)
  table.insert(HBADDONMENU_REGISTRY,addon)
  table.sort(HBADDONMENU_REGISTRY, function(a,b) return a.title < b.title end)
end

function HBAddOnMenu:OnMenuRequest()
  local menu = {
    type = "group",
    name = "HitButton AddOn Menu",
    desc = "HitButton AddOn Menu",
    args = {
      divider = {
        type = "header",
        order = 9999,
      }
    }
  }
  for k,addon in ipairs(HBADDONMENU_REGISTRY) do
    local addonMenu = addon:OnMenuRequest()
    addonMenu.name = addonMenu.name or addon.name
    addonMenu.desc = addonMenu.desc or addon.title .. " - " .. addon.notes
    menu.args[string.gsub(addon.title,"%s","")] = Dewdrop:InjectAceOptionsTable(addon,addonMenu)
  end
  Dewdrop:FeedAceOptionsTable(menu)
end