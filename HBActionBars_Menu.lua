local POINTS = {"CENTER","TOP","BOTTOM","LEFT","RIGHT","TOPLEFT","TOPRIGHT","BOTTOMLEFT","BOTTOMRIGHT"}

function HBActionBars:GetDefaultDB()
  local defaultDB = {
    globalScale = 1,
    bars = {
      MainBar = {
        point = "BOTTOM",
        relativeTo = "UIParent",
        relativePoint = "BOTTOM",
      },
      MainBar2 = {
        point = "TOP",
        relativeTo = "UIParent",
        relativePoint = "TOP",
        hide = true,
      },
      BottomLeftBar = {
        point = "BOTTOM",
        relativeTo = self.BAR_ANCHOR_PREFIX.."MainBar",
        relativePoint = "TOP",
      },
      BottomRightBar = {
        point = "BOTTOM",
        relativeTo = self.BAR_ANCHOR_PREFIX.."BottomLeftBar",
        relativePoint = "TOP",
      },
      RightBar1 = {
        buttonsPerRow = 1,
        point = "RIGHT",
        relativeTo = "UIParent",
        relativePoint = "RIGHT",
      },
      RightBar2 = {
        buttonsPerRow = 1,
        point = "RIGHT",
        relativeTo = self.BAR_ANCHOR_PREFIX.."RightBar1",
        relativePoint = "LEFT",
      },
      ExtraBar1 = {
        point = "TOP",
        relativeTo = self.BAR_ANCHOR_PREFIX.."MainBar2",
        relativePoint = "BOTTOM",
        hide = true,
      },
      ExtraBar2 = {
        point = "TOP",
        relativeTo = self.BAR_ANCHOR_PREFIX.."ExtraBar1",
        relativePoint = "BOTTOM",
        hide = true,
      },
      ExtraBar3 = {
        point = "TOP",
        relativeTo = self.BAR_ANCHOR_PREFIX.."ExtraBar2",
        relativePoint = "BOTTOM",
        hide = true,
      },
      ExtraBar4 = {
        point = "TOP",
        relativeTo = self.BAR_ANCHOR_PREFIX.."ExtraBar3",
        relativePoint = "BOTTOM",
        hide = true,
      },
      MicroBar = {
        point = "BOTTOMRIGHT",
        relativeTo = self.BAR_ANCHOR_PREFIX.."BagBar",
        relativePoint = "BOTTOMLEFT"
      },
      BagBar = {
        point = "BOTTOMRIGHT",
        relativeTo = "UIParent",
        relativePoint = "BOTTOMRIGHT"
      },
      Shapeshift = {
        point = "BOTTOMLEFT",
        relativeTo = self.BAR_ANCHOR_PREFIX.."BottomRightBar",
        relativePoint = "TOPLEFT"
      },
      PetAction = {
        point = "BOTTOMLEFT",
        relativeTo = self.BAR_ANCHOR_PREFIX.."BottomRightBar",
        relativePoint = "TOPLEFT"
      },
    }
  }
  for k,barName in ipairs(self.ALLBARS) do
    defaultDB.bars[barName] = defaultDB.bars[barName] or {}
    defaultDB.bars[barName].buttonsPerRow = defaultDB.bars[barName].buttonsPerRow or 12
    defaultDB.bars[barName].point = defaultDB.bars[barName].point or "CENTER"
    defaultDB.bars[barName].relativeTo = defaultDB.bars[barName].relativeTo or "UIParent"
    defaultDB.bars[barName].relativePoint = defaultDB.bars[barName].relativePoint or "CENTER"
    defaultDB.bars[barName].xof = 0
    defaultDB.bars[barName].yof = 0
    defaultDB.bars[barName].scale = 1
  end
  
  for k,barName in ipairs(self.EXTRAFRAMES) do
    defaultDB.bars[barName] = defaultDB.bars[barName] or {}
    defaultDB.bars[barName].point = defaultDB.bars[barName].point or "CENTER"
    defaultDB.bars[barName].relativeTo = defaultDB.bars[barName].relativeTo or "UIParent"
    defaultDB.bars[barName].relativePoint = defaultDB.bars[barName].relativePoint or "CENTER"
    defaultDB.bars[barName].xof = 0
    defaultDB.bars[barName].yof = 0
    defaultDB.bars[barName].scale = 1
  end
  
  return defaultDB
end

function HBActionBars:BuildOptions()
  local menu = {
    type = "group",
    args = {
      scale = {
        type = "range",
        name = "Scale",
        desc = "Scale",
        get = function() return self.db.profile.globalScale or 1 end,
        set = function(v) self.db.profile.globalScale = v self.frame:SetScale(v) end,
        min = 0, max = 1, step = 0.02
      },
      reset = {
        type = "execute",
        name = "Reset to defaults",
        desc = "Reset to defaults",
        func = function()
          self:ResetDB("profile")
          self:OnProfileEnable()
        end,
      },
      alwaysShowBars = {
        type = "toggle",
        name = "Always Show Bars",
        desc = "Always Show Bars",
        get = function() return ( ALWAYS_SHOW_MULTIBARS == 1 or ALWAYS_SHOW_MULTIBARS == "1" ) end,
        set = function(v) if v then ALWAYS_SHOW_MULTIBARS = "1" else ALWAYS_SHOW_MULTIBARS = "0" end self:SetGrids(v) end
      },
      showID = {
        type = "toggle",
        name = "Show Action IDs",
        desc = "Show Action IDs",
        get = function() return self.db.profile.showID end,
        set = function(v) self.db.profile.showID = v self:UpdateButtons() end
      },
      showAnchors = {
        type = "toggle",
        name = "Show Anchors",
        desc = "Show Anchors",
        get = function() return self.db.profile.showAnchors end,
        set = function(v) self.db.profile.showAnchors = v self:UpdateAnchors() end,
      },
      bars = {
        type = "group",
        name = "Bars",
        desc = "Bars",
        args = {},
      },
      extraframes = {
        type = "group",
        name = "Extras",
        desc = "Extras",
        args = {},
      }
    }
  }
  for k,bar in pairs(self.ALLBARS) do
    funcs = self:GetFuncsForBar(bar)
    local menuOrder = 100+k
    if self.BARDEFS[bar] then
      menuOrder = self.BARDEFS[bar].menuOrder or menuOrder
    end
    local barGroup = {
      type = "group",
      name = self.BAR_ANCHOR_PREFIX..bar,
      desc = self.BAR_ANCHOR_PREFIX..bar,
      order = menuOrder,
      args = {
        hide = {
          type = "toggle",
          name = "Hide",
          desc = "Hide",
          get = funcs.hideGet,
          set = funcs.hideSet,
        },
        scale = {
          type = "range",
          name = "Scale",
          desc = "Scale",
          get = funcs.scaleGet,
          set = funcs.scaleSet,
          min = 0, max = 1, step = 0.01
        },
        buttonsPerRow = {
          type = "range",
          name = "buttonsPerRow",
          desc = "buttonsPerRow",
          get = funcs.buttonsPerRowGet,
          set = funcs.buttonsPerRowSet,
          min = 1, max = 12, step = 1
        },
        point = {
          type = "text",
          name = "Point",
          desc = "Point",
          get = funcs.pointGet,
          set = funcs.pointSet,
          validate = POINTS,
        },
        relativeTo = {
          type = "text",
          name = "relativeTo",
          desc = "relativeTo",
          get = funcs.relativeToGet,
          set = funcs.relativeToSet,
          usage = "<parent frame name>",
        },
        relativePoint = {
          type = "text",
          name = "relativePoint",
          desc = "relativePoint",
          get = funcs.relativePointGet,
          set = funcs.relativePointSet,
          validate = POINTS,
        },
        xofs = {
          type = "text",
          name = "x offset",
          desc = "x offset",
          get = funcs.xofGet,
          set = funcs.xofSet,
          usage = "<number>",
          validate = function(arg)
            return type(tonumber(arg)) == "number"
          end,
          order = 504,
        },
        yofs = {
          type = "text",
          name = "y offset",
          desc = "y offset",
          get = funcs.yofGet,
          set = funcs.yofSet,
          usage = "<number>",
          validate = function(arg)
            return type(tonumber(arg)) == "number"
          end,
          order = 505,
        },
      }
    }
    menu.args.bars.args[bar] = barGroup
  end
  
  for k,bar in ipairs(self.EXTRAFRAMES) do
    funcs = self:GetFuncsForBar(bar)
    local barGroup = {
      type = "group",
      name = bar,
      desc = bar,
      args = {
        hide = {
          type = "toggle",
          name = "Hide",
          desc = "Hide",
          get = funcs.hideGet,
          set = funcs.hideSet,
        },
        scale = {
          type = "range",
          name = "Scale",
          desc = "Scale",
          get = funcs.scaleGet,
          set = funcs.scaleSet,
          min = 0, max = 1, step = 0.01
        },
        point = {
          type = "text",
          name = "Point",
          desc = "Point",
          get = funcs.pointGet,
          set = funcs.pointSet,
          validate = POINTS,
        },
        relativeTo = {
          type = "text",
          name = "relativeTo",
          desc = "relativeTo",
          get = funcs.relativeToGet,
          set = funcs.relativeToSet,
          usage = "<parent frame name>",
        },
        relativePoint = {
          type = "text",
          name = "relativePoint",
          desc = "relativePoint",
          get = funcs.relativePointGet,
          set = funcs.relativePointSet,
          validate = POINTS,
        },
        xofs = {
          type = "text",
          name = "x offset",
          desc = "x offset",
          get = funcs.xofGet,
          set = funcs.xofSet,
          usage = "<number>",
          validate = function(arg)
            return type(tonumber(arg)) == "number"
          end,
          order = 504,
        },
        yofs = {
          type = "text",
          name = "y offset",
          desc = "y offset",
          get = funcs.yofGet,
          set = funcs.yofSet,
          usage = "<number>",
          validate = function(arg)
            return type(tonumber(arg)) == "number"
          end,
          order = 505,
        },
      }
    }
    menu.args.extraframes.args[bar] = barGroup
  end
  
  return menu
end

function HBActionBars:GetFuncsForBar(bar)
  local funcs = {}
  funcs.buttonsPerRowGet = function() return self.db.profile.bars[bar].buttonsPerRow end
  funcs.buttonsPerRowSet = function(v)
    self.db.profile.bars[bar].buttonsPerRow = v
    self:UpdateButtonPositions(bar)
  end
  funcs.pointGet = function() return self.db.profile.bars[bar].point end
  funcs.pointSet = function(v)
    self.db.profile.bars[bar].point = v
    self:UpdateBarPosition(bar)
  end
  funcs.relativePointGet = function() return self.db.profile.bars[bar].relativePoint end
  funcs.relativePointSet = function(v)
    self.db.profile.bars[bar].relativePoint = v
    self:UpdateBarPosition(bar)
  end
  funcs.relativeToGet = function() return self.db.profile.bars[bar].relativeTo end
  funcs.relativeToSet = function(v)
    self.db.profile.bars[bar].relativeTo = v
    self:UpdateBarPosition(bar)
  end
  funcs.xofGet = function() return self.db.profile.bars[bar].xof end
  funcs.xofSet = function(v)
    self.db.profile.bars[bar].xof = v
    self:UpdateBarPosition(bar)
  end
  funcs.yofGet = function() return self.db.profile.bars[bar].yof end
  funcs.yofSet = function(v)
    self.db.profile.bars[bar].yof = v
    self:UpdateBarPosition(bar)
  end
  funcs.scaleGet = function() return self.db.profile.bars[bar].scale end
  funcs.scaleSet = function(v)
    self.db.profile.bars[bar].scale = v
    self:UpdateBarPosition(bar)
  end
  funcs.hideGet = function() return self.db.profile.bars[bar].hide end
  funcs.hideSet = function(v)
    self.db.profile.bars[bar].hide = v
    self:UpdateBarPosition(bar)
  end
  return funcs
end

BINDING_HEADER_HBACTIONBARS = "HBActionBars"
BINDING_NAME_EXTRABAR1BUTTON1 = "HBExtraBar1 Button 1"
BINDING_NAME_EXTRABAR1BUTTON2 = "HBExtraBar1 Button 2"
BINDING_NAME_EXTRABAR1BUTTON3 = "HBExtraBar1 Button 3"
BINDING_NAME_EXTRABAR1BUTTON4 = "HBExtraBar1 Button 4"
BINDING_NAME_EXTRABAR1BUTTON5 = "HBExtraBar1 Button 5"
BINDING_NAME_EXTRABAR1BUTTON6 = "HBExtraBar1 Button 6"
BINDING_NAME_EXTRABAR1BUTTON7 = "HBExtraBar1 Button 7"
BINDING_NAME_EXTRABAR1BUTTON8 = "HBExtraBar1 Button 8"
BINDING_NAME_EXTRABAR1BUTTON9 = "HBExtraBar1 Button 9"
BINDING_NAME_EXTRABAR1BUTTON10 = "HBExtraBar1 Button 10"
BINDING_NAME_EXTRABAR1BUTTON11 = "HBExtraBar1 Button 11"
BINDING_NAME_EXTRABAR1BUTTON12 = "HBExtraBar1 Button 12"
BINDING_NAME_EXTRABAR2BUTTON1 = "HBExtraBar2 Button 1"
BINDING_NAME_EXTRABAR2BUTTON2 = "HBExtraBar2 Button 2"
BINDING_NAME_EXTRABAR2BUTTON3 = "HBExtraBar2 Button 3"
BINDING_NAME_EXTRABAR2BUTTON4 = "HBExtraBar2 Button 4"
BINDING_NAME_EXTRABAR2BUTTON5 = "HBExtraBar2 Button 5"
BINDING_NAME_EXTRABAR2BUTTON6 = "HBExtraBar2 Button 6"
BINDING_NAME_EXTRABAR2BUTTON7 = "HBExtraBar2 Button 7"
BINDING_NAME_EXTRABAR2BUTTON8 = "HBExtraBar2 Button 8"
BINDING_NAME_EXTRABAR2BUTTON9 = "HBExtraBar2 Button 9"
BINDING_NAME_EXTRABAR2BUTTON10 = "HBExtraBar2 Button 10"
BINDING_NAME_EXTRABAR2BUTTON11 = "HBExtraBar2 Button 11"
BINDING_NAME_EXTRABAR2BUTTON12 = "HBExtraBar2 Button 12"
BINDING_NAME_EXTRABAR3BUTTON1 = "HBExtraBar3 Button 1"
BINDING_NAME_EXTRABAR3BUTTON2 = "HBExtraBar3 Button 2"
BINDING_NAME_EXTRABAR3BUTTON3 = "HBExtraBar3 Button 3"
BINDING_NAME_EXTRABAR3BUTTON4 = "HBExtraBar3 Button 4"
BINDING_NAME_EXTRABAR3BUTTON5 = "HBExtraBar3 Button 5"
BINDING_NAME_EXTRABAR3BUTTON6 = "HBExtraBar3 Button 6"
BINDING_NAME_EXTRABAR3BUTTON7 = "HBExtraBar3 Button 7"
BINDING_NAME_EXTRABAR3BUTTON8 = "HBExtraBar3 Button 8"
BINDING_NAME_EXTRABAR3BUTTON9 = "HBExtraBar3 Button 9"
BINDING_NAME_EXTRABAR3BUTTON10 = "HBExtraBar3 Button 10"
BINDING_NAME_EXTRABAR3BUTTON11 = "HBExtraBar3 Button 11"
BINDING_NAME_EXTRABAR3BUTTON12 = "HBExtraBar3 Button 12"
BINDING_NAME_EXTRABAR4BUTTON1 = "HBExtraBar4 Button 1"
BINDING_NAME_EXTRABAR4BUTTON2 = "HBExtraBar4 Button 2"
BINDING_NAME_EXTRABAR4BUTTON3 = "HBExtraBar4 Button 3"
BINDING_NAME_EXTRABAR4BUTTON4 = "HBExtraBar4 Button 4"
BINDING_NAME_EXTRABAR4BUTTON5 = "HBExtraBar4 Button 5"
BINDING_NAME_EXTRABAR4BUTTON6 = "HBExtraBar4 Button 6"
BINDING_NAME_EXTRABAR4BUTTON7 = "HBExtraBar4 Button 7"
BINDING_NAME_EXTRABAR4BUTTON8 = "HBExtraBar4 Button 8"
BINDING_NAME_EXTRABAR4BUTTON9 = "HBExtraBar4 Button 9"
BINDING_NAME_EXTRABAR4BUTTON10 = "HBExtraBar4 Button 10"
BINDING_NAME_EXTRABAR4BUTTON11 = "HBExtraBar4 Button 11"
BINDING_NAME_EXTRABAR4BUTTON12 = "HBExtraBar4 Button 12"
BINDING_NAME_MAINBAR2BUTTON1 = "HBMainBar2 Button 1"
BINDING_NAME_MAINBAR2BUTTON2 = "HBMainBar2 Button 2"
BINDING_NAME_MAINBAR2BUTTON3 = "HBMainBar2 Button 3"
BINDING_NAME_MAINBAR2BUTTON4 = "HBMainBar2 Button 4"
BINDING_NAME_MAINBAR2BUTTON5 = "HBMainBar2 Button 5"
BINDING_NAME_MAINBAR2BUTTON6 = "HBMainBar2 Button 6"
BINDING_NAME_MAINBAR2BUTTON7 = "HBMainBar2 Button 7"
BINDING_NAME_MAINBAR2BUTTON8 = "HBMainBar2 Button 8"
BINDING_NAME_MAINBAR2BUTTON9 = "HBMainBar2 Button 9"
BINDING_NAME_MAINBAR2BUTTON10 = "HBMainBar2 Button 10"
BINDING_NAME_MAINBAR2BUTTON11 = "HBMainBar2 Button 11"
BINDING_NAME_MAINBAR2BUTTON12 = "HBMainBar2 Button 12"