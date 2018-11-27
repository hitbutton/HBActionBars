HBActionBars = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0", "AceDB-2.0", "AceDebug-2.0", "AceEvent-2.0", "AceModuleCore-2.0", "AceHook-2.1")
HBActionBars:SetModuleMixins("AceDebug-2.0")

--SHIT THAT DOESNT WORK
--Rogue stealth is untested

local BUTTON_SPACING = 4
HBActionBars.HBActionButtons = {}

local ID_DISABLE = 0
HBActionBars.BARDEFS = {
  MainBar = {
    menuOrder = 1,
    id = { normal = 1 },
  },
  MainBar2 = {
    menuOrder = 2,
    id = { normal = 2 },
  },
  RightBar1 = {
    menuOrder = 3,
    id = { normal = 3 },
  },
  RightBar2 = {
    menuOrder = 4,
    id = { normal = 4 },
  },
  BottomRightBar = {
    menuOrder = 5,
    id = { normal = 5 },
  },
  BottomLeftBar = {
    menuOrder = 6,
    id = { normal = 6 },
  },
  ExtraBar1 = {
    menuOrder = 7,
    id = { normal = 7, DRUID = 8, ROGUE = 8 },
    classMainBarReplacement = { WARRIOR = true },
  },
  ExtraBar2 = {
    menuOrder = 8,
    id = { normal = 8, WARRIOR = 10, DRUID = 10, ROGUE = 9 },
  },
  ExtraBar3 = {
    menuOrder = 9,
    id = { normal = 9, WARRIOR = ID_DISABLE, DRUID = ID_DISABLE, ROGUE = 10 },
  },
  ExtraBar4 = {
    menuOrder = 10,
    id = { normal = 10, WARRIOR = ID_DISABLE, DRUID = ID_DISABLE, ROGUE = ID_DISABLE },
  },
}

local HBToBlizzBinding = {
  BottomLeftBar = "MULTIACTIONBAR1BUTTON",
  BottomRightBar = "MULTIACTIONBAR2BUTTON",
  RightBar1 = "MULTIACTIONBAR3BUTTON",
  RightBar2 = "MULTIACTIONBAR4BUTTON",
}
local BlizzToHBFrame = {
  MultiBarBottomLeft = "BottomLeftBar",
  MultiBarBottomRight = "BottomRightBar",
  MultiBarRight = "RightBar1",
  MultiBarLeft = "RightBar2",
}

local HOOK_FUNCTIONS = {
  "ActionButton_GetPagedID",
  "GetBindingKey",
  "ActionButton_Update",
  "ActionButtonUp",
  "ActionButtonDown",
  "MultiActionButtonUp",
  "MultiActionButtonDown",
  "ActionButton_ShowGrid",
  "MultiActionBar_HideAllGrids",
  "MultiActionBar_ShowAllGrids",
  "ShapeshiftBar_UpdatePosition",
}

function HBActionBars:OnInitialize()
  self:InitBarDefs()
  self.BAR_ANCHOR_PREFIX = "HB"
  self:RegisterDB("HBActionBarsDB")
  self:RegisterDefaults("profile", self:GetDefaultDB() )
  self:RegisterChatCommand( { "/hbactionbars" } , self:BuildOptions() )
  self.OnMenuRequest = self.BuildOptions
  self.frame = CreateFrame("FRAME","HBActionBarsParentFrame",UIParent)
  self.frame:SetScale(self.db.profile.globalScale)
  self:InitBars()
  self:InitButtons()
  HBAddOnMenu:RegisterAddOn(self)  
end

function HBActionBars:OnEnable()
  self:DoHooks()
  self:RefreshOptions()
end

function HBActionBars:OnProfileEnable()
  self:RefreshOptions()
end

function HBActionBars:DoHooks()
  for k,func in pairs(HOOK_FUNCTIONS) do
    if not self:IsHooked(func) then
      self:Hook(func)
    end
  end
end

function HBActionBars:InitBarDefs()
  self.HBBARS = {}
  local _,class = UnitClass("player")
  for barName,data in pairs(self.BARDEFS) do
    local id = data.id[class] or data.id.normal
    if id ~= ID_DISABLE then
      local bar = CreateFrame("FRAME",barName,nil,"HBActionBarTemplate")
      if data.classMainBarReplacement and data.classMainBarReplacement[class]  then
        bar.isMainBarReplacement = true
      end
      bar:SetID(id)
      self.HBBARS[id] = barName
    end
  end
  self.BARS = {"Shapeshift","PetAction"}
  self.EXTRAFRAMES = {"MicroBar","BagBar"}
  self:DoHooks()
  self.ALLBARS = {}
  for k,v in pairs(self.HBBARS) do
    table.insert(self.ALLBARS,v)
  end
  for k,v in pairs(self.BARS) do
    table.insert(self.ALLBARS,v)
  end
  self.ALLFRAMES = {}
  for k,v in pairs(self.ALLBARS) do
    table.insert(self.ALLFRAMES,v)
  end
  for k,v in pairs(self.EXTRAFRAMES) do
    table.insert(self.ALLFRAMES,v)
  end
end

function HBActionBars:InitBars()
  for _,barName in self.ALLFRAMES do
    CreateFrame("FRAME",self.BAR_ANCHOR_PREFIX..barName,self.frame,"HBActionBarAnchor")
    local frame = getglobal(barName)
    if frame then
      frame:SetParent(getglobal(self.BAR_ANCHOR_PREFIX..barName))
    end
  end
  self:InitMicroBar()
  self:InitBagBar()
  ShapeshiftBarFrame:SetParent(HBShapeshift)
  ShapeshiftBarFrame:SetHeight(0)
  PetActionBarFrame:SetParent(HBPetAction)
  PetActionBarFrame:SetHeight(0)
  
  local function PermaHide(frame)
    frame:Hide()
    frame.Show = function()end
  end
  
  PermaHide(MainMenuBar)
  PermaHide(MainMenuBarArtFrame)
  PermaHide(MultiBarBottomLeft)
  PermaHide(MultiBarBottomRight)
  PermaHide(MultiBarLeft)
  PermaHide(MultiBarRight)  
  PermaHide(ShapeshiftBarLeft)
  PermaHide(ShapeshiftBarMiddle)
  PermaHide(ShapeshiftBarRight)
  PermaHide(SlidingActionBarTexture0)
  PermaHide(SlidingActionBarTexture1)
  
  for i=1, GetNumShapeshiftForms() do
    getglobal("ShapeshiftButton"..i.."NormalTexture"):SetAlpha(0)
  end
end

function HBActionBars:InitButtons()
  for k,button in ipairs(self.HBActionButtons) do
    if button:GetParent():GetID() == 1 then
      button.isBonus = true
      button.OnEvent = function()
        ActionButton_OnEvent(event);
        BonusActionButton_OnEvent(event);
      end
    elseif button:GetParent().isMainBarReplacement then
      button.isMainBarReplacement = true
    end
  end
end

function HBActionBars:InitMicroBar()
  local barName = "MicroBar"
  CreateFrame("FRAME",self.BAR_ANCHOR_PREFIX..barName,self.frame,"HBActionBarAnchor")
  local anchor = getglobal(self.BAR_ANCHOR_PREFIX..barName)
  self:UpdateBarPosition(barName)
  CharacterMicroButton:SetParent(anchor)
  CharacterMicroButton:ClearAllPoints()
  CharacterMicroButton:SetPoint("TOPLEFT",anchor,"TOPLEFT")
  SpellbookMicroButton:SetParent(anchor)
  TalentMicroButton:SetParent(anchor)
  QuestLogMicroButton:SetParent(anchor)
  SocialsMicroButton:SetParent(anchor)
  WorldMapMicroButton:SetParent(anchor)
  MainMenuMicroButton:SetParent(anchor)
  HelpMicroButton:SetParent(anchor)
  anchor:SetWidth(CharacterMicroButton:GetWidth() + HelpMicroButton:GetRight() - SpellbookMicroButton:GetLeft())
  anchor:SetHeight(CharacterMicroButton:GetHeight())
end

function HBActionBars:InitBagBar()
  local barName = "BagBar"
  CreateFrame("FRAME",self.BAR_ANCHOR_PREFIX..barName,self.frame,"HBActionBarAnchor")
  local anchor = getglobal(self.BAR_ANCHOR_PREFIX..barName)
  MainMenuBarBackpackButton:SetParent(anchor)
  MainMenuBarBackpackButton:ClearAllPoints()
  MainMenuBarBackpackButton:SetPoint("TOPLEFT", anchor, "TOPLEFT")
  local lastButton
  for i=0,3 do
    local button = getglobal("CharacterBag"..i.."Slot")
    button:SetParent(anchor)
    button:ClearAllPoints()
    if not lastButton then
      button:SetPoint("BOTTOMLEFT", MainMenuBarBackpackButton, "BOTTOMRIGHT")
    else
      button:SetPoint("BOTTOMLEFT", lastButton, "BOTTOMRIGHT")
    end
    lastButton = button
  end
  KeyRingButton:SetParent(anchor)
  KeyRingButton:ClearAllPoints()
  KeyRingButton:SetPoint("LEFT",CharacterBag3Slot,"RIGHT")
  function MainMenuBar_UpdateKeyRing()
    if ( SHOW_KEYRING == 1 ) then
      KeyRingButton:Show();
    end
  end
  --[[
  MainMenuBarPerformanceBarFrame:SetParent(anchor)
  MainMenuBarPerformanceBarFrame:ClearAllPoints()
  MainMenuBarPerformanceBarFrame:SetPoint("LEFT",KeyRingButton,"RIGHT")
  ]]
  anchor:SetHeight(MainMenuBarBackpackButton:GetHeight())
  anchor:SetWidth( KeyRingButton:GetWidth() + MainMenuBarBackpackButton:GetWidth() * 5 )
end

function HBActionBars:RefreshOptions()
  self.frame:SetScale(self.db.profile.globalScale)
  for k,barName in self.ALLFRAMES do
    getglobal(self.BAR_ANCHOR_PREFIX..barName.."Label"):SetText(self.BAR_ANCHOR_PREFIX..barName)
    self:UpdateBarPosition(barName)
  end
  for k,barName in self.ALLBARS do
    self:UpdateButtonPositions(barName)
  end
  self:UpdateAnchors()
  self:UpdateButtons()
end

function HBActionBars:UpdateBarPosition(barName)
  local anchor = getglobal(self.BAR_ANCHOR_PREFIX..barName)
  local data = self.db.profile.bars[barName]
  if data.scale then
    anchor:SetScale(data.scale)
  end
  if data.hide then
    anchor:Hide()
  else
    anchor:Show()
  end
  anchor:ClearAllPoints()
  anchor:SetPoint(data.point,getglobal(data.relativeTo),data.relativePoint,data.xof,data.yof)
end

function HBActionBars:UpdateButtonPositions(barName)
  local bar = getglobal(barName)
  local anchor = getglobal(self.BAR_ANCHOR_PREFIX..barName)
  local data = self.db.profile.bars[barName]
  local cols = data.buttonsPerRow
  local rows = math.ceil(12/data.buttonsPerRow)
  local w = 0
  local h = 0
  for row = 1,rows do
    for col = 1,cols do
      local button = self:GetButtonFromPos(barName,row,col)
      if button then
        if row == 1 then
          w = w + button:GetWidth()
        end
        h = math.max(h,button:GetHeight())
        button:ClearAllPoints()
        if col == 1 then
          if row == 1 then
            button:SetPoint("TOPLEFT",anchor,"TOPLEFT",BUTTON_SPACING/2,-BUTTON_SPACING/2)
          else
            button:SetPoint("TOP",self:GetButtonFromPos(barName,row-1,col),"BOTTOM",0,-BUTTON_SPACING)
          end
        else
          button:SetPoint("LEFT",self:GetButtonFromPos(barName,row,col-1),"RIGHT",BUTTON_SPACING,0)
        end
      end
    end
  end
  anchor:SetWidth(w + BUTTON_SPACING * cols)
  anchor:SetHeight((h + BUTTON_SPACING) * rows)
end

function HBActionBars:GetButton(barName,id)
  if not (barName and id) then
    return
  end
  return getglobal(barName.."Button"..id)
end

function HBActionBars:GetButtonFromPos(barName,row,col)
  local id = self.db.profile.bars[barName].buttonsPerRow * ( row - 1 ) + col
  return self:GetButton(barName,id)
end

function HBActionBars:UpdateAnchors()
  for k,barName in self.ALLFRAMES do
    if self.db.profile.showAnchors then
      getglobal(self.BAR_ANCHOR_PREFIX..barName.."Label"):Show()
      getglobal(self.BAR_ANCHOR_PREFIX..barName.."Texture"):Show()
    else      
      getglobal(self.BAR_ANCHOR_PREFIX..barName.."Label"):Hide()
      getglobal(self.BAR_ANCHOR_PREFIX..barName.."Texture"):Hide()
    end
  end
end

function HBActionBars:UpdateButtons()
  for k,button in ipairs(self.HBActionButtons) do
    self:UpdateButton(button)
  end
end

function HBActionBars:UpdateButton(button)
  local text = getglobal( button:GetName() .. "ButtonID")
  if text and self.db.profile.showID then
    text:SetText( ActionButton_GetPagedID(button) )
    text:Show()
  else
    text:Hide()
  end
end

function HBActionBars:ActionButton_OnLoad()
  table.insert(self.HBActionButtons,this)
  ActionButton_OnLoad()
  this.isHBActionButton = true
  this.SetGrid = function(show)
    local grid = getglobal(this:GetName().."Grid")
    if not grid then return end
    if show then
      grid:Show()
    else
      grid:Hide()
    end
  end
  this:GetPushedTexture():SetVertexColor(0,1,0,1)
  this:GetCheckedTexture():SetVertexColor(1,1,0,1)
  this:GetPushedTexture():SetDrawLayer("OVERLAY")
  this:GetCheckedTexture():SetDrawLayer("OVERLAY")
end

function HBActionBars:Cooldown_OnLoad(frame)
  frame:ClearAllPoints()
  frame:SetModelScale(0.8)
  frame:SetPoint("TOPLEFT",frame:GetParent(),"TOPLEFT")
  frame:SetPoint("BOTTOMRIGHT",frame:GetParent(),"BOTTOMRIGHT",1,-1)
end

function HBActionBars:ActionButton_OnClick()
  if ( MacroFrame_SaveMacro ) then
    MacroFrame_SaveMacro()
  end
  UseAction(ActionButton_GetPagedID(this), 1)
  ActionButton_UpdateState()
end

function HBActionBars:ActionButton_Drag(start)
  if ( LOCK_ACTIONBAR ~= "1" ) then
    if start then
      PickupAction(ActionButton_GetPagedID(this))
    else
      PlaceAction(ActionButton_GetPagedID(this))    
    end
    ActionButton_UpdateHotkeys(this.buttonType)
    ActionButton_UpdateState()
    ActionButton_UpdateFlash()
  end
end

function HBActionBars:OnHotkey(bar,id)
  if bar then
    if ( keystate == "down" ) then
      MultiActionButtonDown(bar:GetName(), id)
    else
      MultiActionButtonUp(bar:GetName(), id, onSelf)
    end
  end
end

function HBActionBars:ActionButton_GetPagedID(button)
  if ( button.isHBActionButton or button.isBonus) then
    return self:ButtonID(button)
  end
  return self.hooks["ActionButton_GetPagedID"](button)
end

function HBActionBars:ButtonID(button)
  if button.isBonus then
    if self:ShowingBonusBar() and CURRENT_ACTIONBAR_PAGE == 1 then
      return (button:GetID() + ((NUM_ACTIONBAR_PAGES + GetBonusBarOffset() - 1) * NUM_ACTIONBAR_BUTTONS))
    else
      return button:GetID() + ( CURRENT_ACTIONBAR_PAGE - 1 ) * NUM_ACTIONBAR_BUTTONS
    end
  elseif button.isMainBarReplacement then
    return button:GetID()
  end
  return button:GetID() + ( button:GetParent():GetID() - 1 ) * NUM_ACTIONBAR_BUTTONS
end

function HBActionBars:ShowingBonusBar()
  return GetBonusBarOffset() > 0
end

function HBActionBars:GetBindingKey(action)
  if this.isHBActionButton then
    if this.isBonus then
      action = "ACTIONBUTTON"..this:GetID()
    else
      local barName = this:GetParent():GetName()
      local blizzBinding = HBToBlizzBinding[barName]
      if blizzBinding then 
        action = blizzBinding..this:GetID()
      else
        action = string.upper(barName).."BUTTON"..this:GetID()
      end
    end
  end
  return self.hooks["GetBindingKey"](action)
end

function HBActionBars:MultiActionBar_ShowAllGrids()
  self:SetGrids(true)
  return self.hooks["MultiActionBar_ShowAllGrids"](action)
end

function HBActionBars:MultiActionBar_HideAllGrids()
  self:SetGrids()
  return self.hooks["MultiActionBar_HideAllGrids"](action)
end

function HBActionBars:ActionButton_Update()
  self.hooks["ActionButton_Update"]()
  if this.isHBActionButton then
    this:GetNormalTexture():SetAlpha(0)
    if this.isBonus then
      self:UpdateButton(this)
    end
    local equippedText = getglobal(this:GetName().."Equipped")
    if ( IsEquippedAction(ActionButton_GetPagedID(this)) ) then
      equippedText:SetText("E")
      equippedText:Show()
    else
      equippedText:Hide()
    end
  end
end

function HBActionBars:SetGrids(show)
  for k,button in pairs(self.HBActionButtons) do
    if show then
      self:ShowGrid(button)
    else
      self:HideGrid(button)
    end
  end
end

function HBActionBars:ShowGrid(button)
  button.showgrid = 1
  button:SetGrid(true)
  button:Show()
end

function HBActionBars:HideGrid(button)
  if (ALWAYS_SHOW_MULTIBARS == "1" or ALWAYS_SHOW_MULTIBARS == 1) then
    return
  end
  button.showgrid = 0
  if ( not HasAction(ActionButton_GetPagedID(button)) ) then
    button:Hide()
  else
    button:Show()
  end
end

function HBActionBars:ActionButton_ShowGrid(button)
	if not button then
		button = this
	end
	button.showgrid = button.showgrid+1
	if button.isHBActionButton then
    button:SetGrid(true)
  else
    getglobal(button:GetName().."NormalTexture"):SetVertexColor(1.0, 1.0, 1.0, 0.5)
  end
	button:Show();
end

function HBActionBars:ActionButtonDown(id)
  self.hooks["ActionButtonDown"](id)
  local button = self:GetButton("MainBar",id)
  if ( button:GetButtonState() == "NORMAL" ) then
    button:SetButtonState("PUSHED")
  end
end

function HBActionBars:ActionButtonUp(id, onSelf)
  self.hooks["ActionButtonUp"](id,onSelf)
  local button = self:GetButton("MainBar",id)
  if ( button:GetButtonState() == "PUSHED" ) then
    button:SetButtonState("NORMAL")
  end
end

function HBActionBars:MultiActionButtonDown(bar, id)
  self.hooks["MultiActionButtonDown"](bar,id)
  local button = self:GetButton(BlizzToHBFrame[bar],id) or button
  if ( button and button:GetButtonState() == "NORMAL" ) then
    button:SetButtonState("PUSHED")
  end
end

function HBActionBars:MultiActionButtonUp(bar, id, onSelf)
  self.hooks["MultiActionButtonUp"](bar,id,onSelf)
  local button = self:GetButton(BlizzToHBFrame[bar],id) or button
  if ( button and button:GetButtonState() == "PUSHED" ) then
    button:SetButtonState("NORMAL")
  end
end

function HBActionBars:ShapeshiftBar_UpdatePosition()
--[[
	if ( MultiBarBottomLeft.isShowing ) then
		ShapeshiftBarFrame:SetPoint("BOTTOMLEFT", "MainMenuBar", "TOPLEFT", 30, 45);
		ShapeshiftBarLeft:Hide();
		ShapeshiftBarRight:Hide();
		ShapeshiftBarMiddle:Hide();
		for i=1, GetNumShapeshiftForms() do
			getglobal("ShapeshiftButton"..i.."NormalTexture"):SetWidth(50);
			getglobal("ShapeshiftButton"..i.."NormalTexture"):SetHeight(50);
		end
	else
		ShapeshiftBarFrame:SetPoint("BOTTOMLEFT", "MainMenuBar", "TOPLEFT", 30, 0);
		if ( GetNumShapeshiftForms() > 2 ) then
			ShapeshiftBarMiddle:Show();
		end
		ShapeshiftBarLeft:Show();
		ShapeshiftBarRight:Show();
		for i=1, GetNumShapeshiftForms() do
			getglobal("ShapeshiftButton"..i.."NormalTexture"):SetWidth(64);
			getglobal("ShapeshiftButton"..i.."NormalTexture"):SetHeight(64);
		end
	end
]]
  Print("ShapeshiftBar_UpdatePosition")
  self.hooks["ShapeshiftBar_UpdatePosition"]()
  for i=1, GetNumShapeshiftForms() do
    getglobal("ShapeshiftButton"..i.."NormalTexture"):SetAlpha(0)
  end
end